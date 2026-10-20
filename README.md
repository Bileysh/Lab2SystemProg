# Профілювання та оптимізація C-програми: FlameGraph, perf, енергоспоживання

Досліджувана програма — [`src/bench.c`](src/bench.c): конвеєр «генерація даних → множення матриць
→ згортка 3×3 → контрольна сума». Вона збирається двічі з одного вихідного коду:

| Збірка | Прапорці | Призначення |
|---|---|---|
| `build/bench_O0` | `-O0` | базова лінія, без оптимізацій |
| `build/bench_O3` | `-O3 -march=native` | оптимізована: векторизація AVX2 + FMA |

Обидві збірки мають `-g -fno-omit-frame-pointer`, щоб perf міг розгортати стек.

**Стенд:** Intel Core i5‑12500H (Alder Lake: 4P + 8E ядер, AVX2/FMA, без AVX‑512), Windows 11,
WSL2 Ubuntu 24.04, ядро 6.6.87.2‑microsoft‑standard‑WSL2, gcc 13.3, perf 6.8.
Навантаження за замовчуванням: `N=1024`, `REPEATS=2` (2 × 2.1 GFLOP).

## Швидкий старт

```bash
sudo bash scripts/setup_wsl.sh

make all asm vecreport           
bash scripts/1_flamegraph.sh O0  
bash scripts/1_flamegraph.sh O3
bash scripts/1_flamegraph.sh O3 system   
bash scripts/4_diff_flamegraph.sh        
bash scripts/2_stats.sh O0      
bash scripts/2_stats.sh O3
```

```powershell
powershell -ExecutionPolicy Bypass -File scripts\3_energy.ps1 -Variant O0
powershell -ExecutionPolicy Bypass -File scripts\3_energy.ps1 -Variant O3 -Runs 20
```

---

## 1. FlameGraph

### 1.1 Процес побудови
За [інструкцією Брендана Грегга](https://www.brendangregg.com/FlameGraphs/cpuflamegraphs.html#Instructions),
див. [`scripts/1_flamegraph.sh`](scripts/1_flamegraph.sh):

```bash
perf record -F 999 -g -- ./build/bench_O0 1024 2   
perf script > out.perf                             
stackcollapse-perf.pl out.perf > out.folded         
flamegraph.pl out.folded > flame_O0.svg           
```

`-F 999`, а не 1000, щоб частота семплювання не збігалась із періодичними таймерами ядра (lockstep).
SVG інтерактивний: його можна відкрити в браузері, клікнути на кадр для збільшення, а через Ctrl+F шукати функції.

### 1.2 Інтерпретація
* **Вісь X** показує частку семплів, тобто частку процесорного часу. Це не час: кадри впорядковано за абеткою.
* **Вісь Y** — це глибина стека: `_start → __libc_start_main → main → matmul`.
* Широкий кадр без «даху» означає функцію, яка сама витрачає час (self time).

Результати `bench_O0` (власний час, верх стека):

| функція | частка |
|---|---|
| `matmul` | **98.6 %** |
| `blur3x3` | 0.7 % |
| `fill_random` | 0.2 % |
| ядро (page faults: `clear_page_erms`, `do_user_addr_fault`) | ~0.2 % |

Висновок: майже весь час займає множення матриць (O(N³)). Згортка й контрольна сума мають складність O(N²),
тому вони на 3 порядки «дешевші». Оптимізувати варто лише `matmul`.
На O0 видно також кадри `at` і `xorshift32` — це маленькі `static inline` функції, які без
оптимізацій лишаються справжніми викликами.

**FlameGraph системи** (`1_flamegraph.sh O3 system`, `perf record -a`): 90.9 % семплів припадає на
`pv_native_safe_halt`. Це цикл простою (idle) решти 15 віртуальних CPU, бо програма однопотокова
і завантажує лише 1 з 16 логічних ядер. `matmul` займає 5.3 % від усієї системи. Також видно
переривання (`handle_softirqs`) і перемикання контексту.

## 2. Статистика виконання

### 2.1 `/usr/bin/time --verbose`
| показник | O0 | O3 | що означає |
|---|---|---|---|
| User time | 5.69 с | 0.19 с | час CPU у режимі користувача: це обчислення |
| System time | 0.01 с | 0.01 с | час у ядрі: виділення памʼяті, page faults |
| Elapsed (wall) | 5.63 с | 0.22 с | реальний час |
| % CPU | 101 % | 96 % | один потік повністю завантажує одне ядро |
| Max RSS | 17.8 МБ | 17.8 МБ | 4 матриці × 1024² × 4 Б = 16 МБ + код/libc |
| Minor page faults | 4175 | 4173 | ≈ 16 МБ / 4 КБ: перший дотик до кожної сторінки |
| Major page faults | 1 | 1 | читання з диска майже відсутнє |
| Context switches (vol/invol) | 14 / 13 | 15 / 0 | програму рідко витісняють |

Обсяг памʼяті й кількість page faults однакові, бо алгоритм не змінився. Змінився лише час CPU.

### 2.2 `perf stat -d`
[`results/O0_perfstat.txt`](results/O0_perfstat.txt), [`results/O3_perfstat.txt`](results/O3_perfstat.txt),
5 повторів (`-r 5`) із середнім і розкидом:

| подія | O0 | O3 |
|---|---|---|
| task-clock | 5714 мс (0.997 CPU) | 225 мс (0.978 CPU) |
| context-switches | 14 | 4 |
| cpu-migrations | 0 | 0 |
| page-faults | 4161 | 4161 |
| elapsed | 5.73 с ± 0.6 % | 0.230 с ± 2.1 % |
| cycles, instructions, branches, L1/LLC | `<not supported>` | `<not supported>` |

**Чому `<not supported>`?** WSL2 — це віртуальна машина Hyper‑V, а гіпервізор не передає гостю
апаратний PMU (Performance Monitoring Unit). Тому доступні лише програмні події ядра. З тієї ж
причини perf 6.8 повідомляє про помилку `cpu_core/TOPDOWN.SLOTS`: це метрика гібридних ядер Alder Lake, яку
він намагається додати автоматично. На нативному Linux ті самі команди покажуть IPC, промахи кешу тощо.

**Заміна апаратних лічильників** — `valgrind --tool=cachegrind`. Він симулює процесор і кеші та
рахує інструкції точно. Задача менша (N=256, 1 прохід), бо симуляція повільна:

| показник | O0 | O3 | різниця |
|---|---|---|---|
| Instructions (I refs) | 731.7 млн | 11.5 млн | **÷ 64** |
| Data refs | 334.1 млн | 20.4 млн | ÷ 16 |
| D1 misses | 1.09 млн | 1.09 млн | однаково |
| D1 miss rate | 0.3 % | 5.3 % | ↑, бо звернень стало значно менше |

Промахів кешу стільки ж, бо програма читає ті самі дані. Але O3 робить у 64 рази менше інструкцій:
одна векторна інструкція обробляє 8 float, а змінні тримаються в регістрах, а не на стеку.

### 2.3 `perf record` + `perf report`
[`results/O0_report.txt`](results/O0_report.txt), [`results/O3_report.txt`](results/O3_report.txt):

* `--no-children` (self): `matmul` 98.7 % (O0) і 93.4 % (O3).
* `--children` (з урахуванням нащадків): `_start` = 100 %, `main` ≈ 97–100 %. Це корінь, через який проходить увесь час.
* `[.]` позначає код користувача, `[k]` — ядро. На O3 частка ядра зросла до ~3.5 % (`asm_exc_page_fault`
  → `do_anonymous_page`): page faults зайняли стільки ж часу, що й раніше, але сама програма стала у 25 разів коротшою.
* `perf annotate -s matmul` ([`results/O0_annotate_matmul.txt`](results/O0_annotate_matmul.txt)) показує
  відсотки по окремих інструкціях: на O0 «гарячі» ті інструкції, що завантажують і зберігають `[rbp-…]`.

## 3. Енергоспоживання

У WSL2 немає RAPL (`/sys/class/powercap` порожній, а у perf немає `power/energy-pkg/`). Проте **Windows сама
читає RAPL‑регістри** процесора і публікує їх як лічильник продуктивності **`Energy Meter`**:
`RAPL_Package0_PKG` (увесь пакет CPU), `RAPL_Package0_PP0` (лише ядра), `RAPL_Package0_PP1` (iGPU).
Накопичувальне значення `Energy` вимірюється в пВт·год (1 пВт·год = 3.6·10⁻⁹ Дж).
Скрипт [`scripts/3_energy.ps1`](scripts/3_energy.ps1) працює так:

1. 10 с міряє споживання у простої (`P_idle`).
2. Запускає програму у WSL і кожні 100 мс записує потужність у `results/energy_*_trace.csv`.
3. Рахує енергію як різницю показань лічильника до і після запуску.

### 3.1 Система
`E_system = ΔE_pkg`, тобто вся енергія процесорного пакета за час роботи (сюди входить фон ОС).
Якщо ноутбук працює від батареї, скрипт додатково читає `BatteryStatus.DischargeRate` (WMI), щоб
отримати енергію **всього ноутбука**, включно з екраном і SSD.

### 3.2 Лише програма
`E_program = ΔE_pkg − P_idle · t` — енергія понад фон, яку спричинила саме програма.
`program_cores_J` рахується так само, але лише для домену ядер (PP0). Він майже збігається з PKG: майже
вся додаткова енергія йде на ядра.

| | O0 (1 запуск) | O3 (20 запусків) |
|---|---|---|
| час | 5.92 с | 4.53 с (0.23 с/запуск) |
| P_idle (PKG) | 6.1 Вт | 5.8 Вт |
| середня P (PKG) | 13.3 Вт | 15.2 Вт |
| E_system | 78.9 Дж | 68.9 Дж |
| E_program | 42.7 Дж | 42.9 Дж |
| **E_program на 1 запуск** | **42.7 Дж** | **2.14 Дж** |

Обмеження методики: у фон потрапляють сторонні процеси Windows, а саме значення шумить на ±1–2 Вт. Тому
заміри повторюють кілька разів і дивляться на порядок величин.

## 4. До і після оптимізації

### 4.1 Асемблер ([`asm/`](asm/), або на https://godbolt.org з тими ж прапорцями)
Внутрішній цикл `c[i][j] += aik * b[k][j]`.

**O0** ([`asm/matmul_O0.dis`](asm/matmul_O0.dis)) обробляє ~38 інструкцій на **один** float:
```asm
mov    eax,DWORD PTR [rbp-0xc]     ; k читається зі стека в кожній ітерації
imul   rdx,rax                     ; k*n — адреса перераховується щоразу
...
movss  xmm0,DWORD PTR [rax]        ; скалярне завантаження b[k][j]
mulss  xmm0,DWORD PTR [rbp-0x4]    ; * aik (теж зі стека)
addss  xmm0,xmm1                   ; + c[i][j]
movss  DWORD PTR [rax],xmm0        ; запис c[i][j]
add    DWORD PTR [rbp-0x8],0x1     ; j++ у памʼяті
```
Усі змінні живуть у памʼяті (`[rbp-…]`), адреси перераховуються множенням, а за одну операцію обробляється 1 float.

**O3** ([`asm/matmul_O3.dis`](asm/matmul_O3.dis)) — 7 інструкцій на **16** множень-додавань:
```asm
vbroadcastss ymm1,DWORD PTR [r13]      ; a[i][k+1] -> всі 8 лінійок ymm1
vbroadcastss ymm2,xmm3                 ; a[i][k]   -> всі 8 лінійок ymm2
.loop:
vmovups     ymm0,YMMWORD PTR [r9+rsi]  ; 8 float з рядка b[k]
vfmadd213ps ymm0,ymm2,[rax+rsi]        ; ymm0 = a[i][k]*b[k][j..j+7] + c[i][j..j+7]
vfmadd231ps ymm0,ymm1,[rdi+rsi]        ; ymm0 += a[i][k+1]*b[k+1][j..j+7]
vmovups     YMMWORD PTR [rax+rsi],ymm0 ; 8 float назад у c
add rsi,0x20 / cmp / jne               ; крок 32 байти
```
Що зробив компілятор:
* **Розмістив змінні в регістрах** (`rsi`, `r9`, …) замість стека.
* **Прибрав множення з циклу** (strength reduction): адреса збільшується на 32 байти через `add`.
* **Розгорнув цикл по k на 2 і злив тіла** (unroll‑and‑jam): ряд `c` завантажується і записується один раз на два рядки `b`.
* **Векторизував цикл** (див. [`asm/vec_optimized.txt`](asm/vec_optimized.txt): `loop vectorized using 32 byte vectors`)
  і додав скалярний «хвіст» та 16‑байтну (xmm) версію для залишку.

### 4.1.1 AVX / SIMD
* `ymm0..15` — 256‑бітні регістри AVX: в один такий регістр вміщується 8 float.
  `-march=native` вмикає AVX2 і FMA на i5‑12500H. AVX‑512 цей процесор не підтримує.
* `vbroadcastss` копіює один скаляр у всі 8 лінійок, тому один `aik` множиться на 8 елементів рядка одночасно.
* `vfmadd231ps` (FMA3) обчислює `a*b + c` над 8 парами за **одну** інструкцію з **одним** округленням.
  Тому контрольна сума відрізняється в 6‑му знаку (364.583443 на O0 проти 364.582054 на O3).
  Це очікувана різниця в округленні, а не помилка.
* Суфікс `ps` = packed single (вектор float), `ss` = scalar single (на O0 використовуються лише `movss/mulss/addss`).
* **Контрприклад** — `checksum`: [`asm/vec_missed.txt`](asm/vec_missed.txt) показує `couldn't vectorize loop`.
  Сума у double з float вимагає перестановки порядку додавань, а для чисел з плаваючою комою це змінює
  результат. Без `-ffast-math` (`-fassociative-math`) компілятор не має на це права.

### 4.2 Час та інші показники
| показник | O0 | O3 | співвідношення |
|---|---|---|---|
| час (perf stat, середнє з 5) | 5.73 с | 0.230 с | **× 25** швидше |
| продуктивність | 0.76 GFLOP/s | 17.3–20.0 GFLOP/s | × 23–26 |
| інструкції (cachegrind, N=256) | 731.7 млн | 11.5 млн | ÷ 64 |
| звернення до памʼяті (cachegrind) | 334 млн | 20.4 млн | ÷ 16 |
| Max RSS / page faults | 17.8 МБ / 4175 | 17.8 МБ / 4173 | без змін |

### 4.3 FlameGraph після оптимізації
Порівнюються [`results/flame_O0.svg`](results/flame_O0.svg), [`results/flame_O3.svg`](results/flame_O3.svg) і
диференційний [`results/flame_diff_O0_O3.svg`](results/flame_diff_O0_O3.svg) (`difffolded.pl -n`).
* Загальна ширина графіка відповідає кількості семплів. На O3 їх приблизно у 23 рази менше (249 проти 5666).
* `matmul` усе ще домінує (91 %), але його частка зменшилась. Відносно зросли `fill_random` (0.2 → 1.6 %)
  і кадри ядра (page faults: 0.2 → ~5 %), бо ця «фіксована» робота не прискорилась.
* Зникли кадри `at` і `xorshift32`: на O3 компілятор вбудував їх (inlining) у місця виклику.
* На диференційному графіку синій колір означає частку, що зменшилась (`matmul`), а червоний — частку, що зросла (`fill_random`, ядро).

### 4.4 Енергія після оптимізації
| | O0 | O3 | |
|---|---|---|---|
| енергія програми на 1 запуск | 42.7 Дж | 2.14 Дж | **÷ 20** |
| середня потужність пакета | 13.3 Вт | 15.2 Вт | O3 «гарячіший» на 14 % |

Причина: **E = P · t**. AVX/FMA‑блоки споживають більше, тому потужність навіть трохи зросла. Але час
скоротився у ~25 разів, тому енергія впала у ~20 разів: трохи менше, ніж час, саме через вищу потужність. Процесор швидше повертається в режим простою (принцип «race to
idle»). Кожна інструкція коштує енергії, а O3 виконує їх у ~64 рази менше.

## Структура
```
src/bench.c                 досліджувана програма
Makefile                    збірки O0/O3, asm, vecreport
scripts/setup_wsl.sh        встановлення gcc, perf, valgrind, FlameGraph
scripts/1_flamegraph.sh     п.1 / 4.3
scripts/2_stats.sh          п.2.1–2.3
scripts/3_energy.ps1        п.3 / 4.4 (Windows, RAPL через Energy Meter)
scripts/4_diff_flamegraph.sh п.4.3, диференційний FlameGraph
asm/                        асемблер, дизасемблювання matmul, звіти векторизації
results/                    SVG, звіти perf/time, енергія (json + csv-траси)
```

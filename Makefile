CC      ?= gcc
COMMON  := -std=gnu11 -Wall -Wextra -g -fno-omit-frame-pointer
O0FLAGS := -O0
O3FLAGS := -O3 -march=native

BIN := build/bench_O0 build/bench_O3
ASM := asm/bench_O0.s asm/bench_O3.s

.PHONY: all asm vecreport clean

all: $(BIN)

build/bench_O0: src/bench.c | build
	$(CC) $(COMMON) $(O0FLAGS) -o $@ $<

build/bench_O3: src/bench.c | build
	$(CC) $(COMMON) $(O3FLAGS) -o $@ $<

asm: $(ASM) asm/matmul_O0.dis asm/matmul_O3.dis

asm/bench_O0.s: src/bench.c
	@mkdir -p asm
	$(CC) -std=gnu11 $(O0FLAGS) -S -masm=intel -fno-asynchronous-unwind-tables -o $@ $<

asm/bench_O3.s: src/bench.c
	@mkdir -p asm
	$(CC) -std=gnu11 $(O3FLAGS) -S -masm=intel -fno-asynchronous-unwind-tables -o $@ $<

asm/matmul_%.dis: build/bench_%
	@mkdir -p asm
	objdump -d -M intel --no-show-raw-insn --disassemble=matmul $< > $@

vecreport:
	@mkdir -p asm
	$(CC) -std=gnu11 $(O3FLAGS) -c -o /dev/null src/bench.c \
	    -fopt-info-vec-optimized 2> asm/vec_optimized.txt
	$(CC) -std=gnu11 $(O3FLAGS) -c -o /dev/null src/bench.c \
	    -fopt-info-vec-missed 2> asm/vec_missed.txt
	@cat asm/vec_optimized.txt

build:
	mkdir -p $@

clean:
	rm -rf build asm/*.s asm/*.dis asm/*.txt

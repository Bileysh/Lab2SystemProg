#include <stdint.h>
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <time.h>

#define NOINLINE __attribute__((noinline))

static uint32_t rng_state = 2463534242u;

static inline uint32_t xorshift32(void)
{
    uint32_t x = rng_state;
    x ^= x << 13;
    x ^= x >> 17;
    x ^= x << 5;
    return rng_state = x;
}

static inline float *at(float *m, int n, int row, int col)
{
    return &m[(size_t)row * n + col];
}

NOINLINE void fill_random(float *m, int n)
{
    for (int i = 0; i < n; i++)
        for (int j = 0; j < n; j++)
            *at(m, n, i, j) = (float)(xorshift32() & 0xFFFF) / 65536.0f - 0.5f;
}

NOINLINE void matmul(const float *restrict a, const float *restrict b,
                     float *restrict c, int n)
{
    memset(c, 0, (size_t)n * n * sizeof(float));
    for (int i = 0; i < n; i++)
        for (int k = 0; k < n; k++) {
            float aik = a[(size_t)i * n + k];
            for (int j = 0; j < n; j++)
                c[(size_t)i * n + j] += aik * b[(size_t)k * n + j];
        }
}

NOINLINE void blur3x3(const float *restrict src, float *restrict dst, int n)
{
    memcpy(dst, src, (size_t)n * n * sizeof(float));
    const float k = 1.0f / 9.0f;
    for (int i = 1; i < n - 1; i++)
        for (int j = 1; j < n - 1; j++) {
            float s = 0.0f;
            for (int di = -1; di <= 1; di++)
                for (int dj = -1; dj <= 1; dj++)
                    s += src[(size_t)(i + di) * n + (j + dj)];
            dst[(size_t)i * n + j] = s * k;
        }
}

NOINLINE double checksum(const float *m, int n)
{
    double s = 0.0;
    for (size_t i = 0; i < (size_t)n * n; i++)
        s += m[i];
    return s;
}

static double now_sec(void)
{
    struct timespec ts;
    clock_gettime(CLOCK_MONOTONIC, &ts);
    return ts.tv_sec + ts.tv_nsec * 1e-9;
}

int main(int argc, char **argv)
{
    int n = argc > 1 ? atoi(argv[1]) : 768;
    int repeats = argc > 2 ? atoi(argv[2]) : 3;
    if (n < 3 || repeats < 1) {
        fprintf(stderr, "usage: %s [N>=3] [REPEATS>=1]\n", argv[0]);
        return 1;
    }

    size_t bytes = (size_t)n * n * sizeof(float);
    float *a = aligned_alloc(64, bytes);
    float *b = aligned_alloc(64, bytes);
    float *c = aligned_alloc(64, bytes);
    float *d = aligned_alloc(64, bytes);
    if (!a || !b || !c || !d) {
        fprintf(stderr, "out of memory\n");
        return 1;
    }

    double t0 = now_sec();
    fill_random(a, n);
    fill_random(b, n);

    double sum = 0.0;
    for (int r = 0; r < repeats; r++) {
        matmul(a, b, c, n);
        blur3x3(c, d, n);
        sum += checksum(d, n);
    }
    double t1 = now_sec();

    double gflop = 2.0 * n * (double)n * n * repeats / 1e9;
    printf("N=%d repeats=%d checksum=%.6f time=%.3f s  (%.2f GFLOP/s)\n",
           n, repeats, sum, t1 - t0, gflop / (t1 - t0));

    free(a);
    free(b);
    free(c);
    free(d);
    return 0;
}

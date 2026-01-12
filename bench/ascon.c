#include "bench.h"

uint8_t *out, *in;

extern int crypto_hash(uint8_t *out, const uint8_t *in, size_t len);

static void
ascon_hash(void *restrict dest, void const *restrict src, size_t n) {
	crypto_hash(dest, src, n);
}

typedef void *Func(void *restrict dest, void const *restrict src, size_t n);

Impl impls[] = {
	{ "scalar", &ascon_hash, 0 },
};

void init(void) {
	bench_memrand(mem, MAX_MEM);
}

ux checksum(size_t n) {
	ux sum = 0;
	for (size_t i = 0; i < 32; ++i)
		sum = uhash(sum) + mem[i];
	return sum;
}

BENCH_BEG(aligned) {
	TIME f(mem, mem + MAX_MEM/2 + 16, n);
} BENCH_END

Bench benches[] = {
	BENCH( impls, MAX_MEM/2 - 16, "ascon hash aligned", bench_aligned )
}; BENCH_MAIN(benches)

#include "../thirdparty/ascon/hash.c"

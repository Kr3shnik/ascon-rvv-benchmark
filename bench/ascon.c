#include "bench.h"
// #if __riscv_xlen != 32
#include "../thirdparty/ascon/crypto_hash.h"

uint8_t *dest, *src;


extern int crypto_hash(uint8_t *out, const uint8_t *in, size_t in_len);  // C implementation

static void
crypto_hash_scalar(void *restrict dest, void const *restrict src, size_t n) {
	crypto_hash(dest, src, n);
}

static void
crypto_hash_rvv(void *restrict dest, void const *restrict src, size_t n) {
	crypto_hash(dest, src, n);
}

typedef void Func(void *restrict dest, void const *restrict src, size_t n);

Impl impls[] = {
	{ "scalar", &crypto_hash_scalar, 0 },
	{ "rvv", &crypto_hash_rvv, 0 },
};

void init(void) {}

ux checksum(size_t n) {
	ux sum = 0;
	for (size_t i = 0; i < 32; ++i)
		sum = uhash(sum) + dest[i];
	return sum;
}

BENCH_BEG(aligned) {
	dest = mem;
	src = mem + MAX_MEM/2;
	bench_memrand(src, n);
	memset(dest, 0, 32);
	TIME f(dest, src, n);
} BENCH_END

Bench benches[] = {
	BENCH( impls, MAX_MEM/2 - 512, "ascon hash aligned", bench_aligned )
}; BENCH_MAIN(benches)

// Undefine print macro from nolibc.h to avoid conflict with ascon's print
#undef print

#include "../thirdparty/ascon/hash.c"
#include "../thirdparty/ascon/printstate.c"

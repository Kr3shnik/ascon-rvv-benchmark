.POSIX:

include ../../../config.mk

TESTS=kat_test

all: ${TESTS}

kat_test: kat_test.c ../hash.c ../api.h ../ascon.h ../constants.h ../crypto_hash.h ../permutations.h ../printstate.h ../round.h ../word.h
	${CC} ${CFLAGS} -o kat_test kat_test.c

clean:
	rm -f ${TESTS}

run: all
	../../../run.sh ./kat_test || { printf "\n\n\033[0;31mFAILED\033[0m\n\n"; exit 1; }

.PHONY: all clean run

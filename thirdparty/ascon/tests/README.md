# ASCON Hash KAT Tests

This directory contains Known Answer Tests (KAT) for verifying the ASCON hash implementation.

## Building

```sh
make
```

## Running

```sh
make run
```

Or directly (if you have QEMU configured):

```sh
../../run.sh ./kat_test
```

## What it tests

The `kat_test` program verifies the ASCON hash implementation against the official
KAT vectors from `../LWC_HASH_KAT_128_256.txt`. It tests:

- Empty message hashing
- Short messages (1-8 bytes, within single block)
- Messages spanning multiple blocks
- Various message lengths to ensure correct padding

If all tests pass, you'll see:
```
ALL TESTS PASSED!
```

If any test fails, it will show the expected vs actual hash values.

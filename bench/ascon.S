# ASCON ROUND function - RISC-V RVV 1.0 Vector implementation
# void ROUND_rvv_vector(ascon_state_t* s, uint8_t C)
#
# This version uses vector registers to hold the state
# and performs operations in a more vectorized manner. 
#
# Note: Since ASCON state is only 5 elements, we use LMUL=1
# with element width 64 bits. 

.global ROUND_rvv_vector
. type ROUND_rvv_vector, @function

ROUND_rvv_vector:
    # Set vector length for 5 x 64-bit elements
    # vsetvli returns actual VL in a2
    li      t0, 5
    vsetvli zero, t0, e64, m1, ta, ma   # SEW=64, LMUL=1

    # Load all 5 state elements into v0
    vle64.v v0, (a0)        # v0 = {x[0], x[1], x[2], x[3], x[4]}

    # We need to work with individual elements for the complex
    # substitution layer, so extract to scalar registers
    # (Vector shuffles for this pattern are complex)
    
    vslidedown.vi v1, v0, 0     # v1[0] = x[0]
    vmv.x.s t0, v1              # t0 = x[0]
    
    vslidedown.vi v1, v0, 1     # v1[0] = x[1]
    vmv.x.s t1, v1              # t1 = x[1]
    
    vslidedown.vi v1, v0, 2     # v1[0] = x[2]
    vmv.x.s t2, v1              # t2 = x[2]
    
    vslidedown.vi v1, v0, 3     # v1[0] = x[3]
    vmv.x.s t3, v1              # t3 = x[3]
    
    vslidedown.vi v1, v0, 4     # v1[0] = x[4]
    vmv. x.s t4, v1              # t4 = x[4]

    # ===== Addition of round constant =====
    xor     t2, t2, a1          # x[2] ^= C

    # ===== Substitution layer (first part) =====
    xor     t0, t0, t4          # x[0] ^= x[4]
    xor     t4, t4, t3          # x[4] ^= x[3]
    xor     t2, t2, t1          # x[2] ^= x[1]

    # ===== Keccak S-box =====
    # Use a5-a7 and s0-s1 as temporaries for intermediate t[] values
    addi    sp, sp, -16
    sd      s0, 0(sp)
    sd      s1, 8(sp)

    # t'[0] = x[0] ^ (~x[1] & x[2])
    not     a5, t1
    and     a5, a5, t2
    xor     a5, t0, a5          # a5 = t'[0]

    # t'[1] = x[1] ^ (~x[2] & x[3])
    not     a6, t2
    and     a6, a6, t3
    xor     a6, t1, a6          # a6 = t'[1]

    # t'[2] = x[2] ^ (~x[3] & x[4])
    not     a7, t3
    and     a7, a7, t4
    xor     a7, t2, a7          # a7 = t'[2]

    # t'[3] = x[3] ^ (~x[4] & x[0])
    not     s0, t4
    and     s0, s0, t0
    xor     s0, t3, s0          # s0 = t'[3]

    # t'[4] = x[4] ^ (~x[0] & x[1])
    not     s1, t0
    and     s1, s1, t1
    xor     s1, t4, s1          # s1 = t'[4]

    # ===== Substitution layer (second part) =====
    xor     a6, a6, a5          # t[1] ^= t[0]
    xor     a5, a5, s1          # t[0] ^= t[4]
    xor     s0, s0, a7          # t[3] ^= t[2]
    not     a7, a7              # t[2] = ~t[2]

    # Now:  a5=t[0], a6=t[1], a7=t[2], s0=t[3], s1=t[4]

    # ===== Linear diffusion layer =====
    # x[0] = t[0] ^ ROR(t[0], 19) ^ ROR(t[0], 28)
    rori    t0, a5, 19
    rori    t1, a5, 28
    xor     t0, a5, t0
    xor     t0, t0, t1          # t0 = final x[0]

    # x[1] = t[1] ^ ROR(t[1], 61) ^ ROR(t[1], 39)
    rori    t1, a6, 61
    rori    t2, a6, 39
    xor     t1, a6, t1
    xor     t1, t1, t2          # t1 = final x[1]

    # x[2] = t[2] ^ ROR(t[2], 1) ^ ROR(t[2], 6)
    rori    t2, a7, 1
    rori    t3, a7, 6
    xor     t2, a7, t2
    xor     t2, t2, t3          # t2 = final x[2]

    # x[3] = t[3] ^ ROR(t[3], 10) ^ ROR(t[3], 17)
    rori    t3, s0, 10
    rori    t4, s0, 17
    xor     t3, s0, t3
    xor     t3, t3, t4          # t3 = final x[3]

    # x[4] = t[4] ^ ROR(t[4], 7) ^ ROR(t[4], 41)
    rori    t4, s1, 7
    rori    t5, s1, 41
    xor     t4, s1, t4
    xor     t4, t4, t5          # t4 = final x[4]

    # Restore saved registers
    ld      s0, 0(sp)
    ld      s1, 8(sp)
    addi    sp, sp, 16

    # Store results back to memory
    sd      t0, 0(a0)           # x[0]
    sd      t1, 8(a0)           # x[1]
    sd      t2, 16(a0)          # x[2]
    sd      t3, 24(a0)          # x[3]
    sd      t4, 32(a0)          # x[4]

    ret

.size ROUND_rvv_vector, .-ROUND_rvv_vector
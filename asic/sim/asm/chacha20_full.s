# =============================================================================
# RISC-V RV32I + Zbb ChaCha20 Block - Adapted for CPU Testbench
# =============================================================================
# Memory Layout:
#   0x000 - 0x03F: Input data (16 words = 64 bytes)
#   0x040 - 0x07F: Output data (16 words = 64 bytes)  
#   0x080 - 0x0FF: Working state (16 words = 64 bytes)
#   0x100 - 0x1FF: Stack (256 bytes)
#   0x200:         Cycle count result
#   0x204:         Final marker
# =============================================================================

# _start: Entry point
# Set up stack pointer (use address 0x1FC = 508, top of stack area)
lui     sp, 0           # sp = 0
addi    sp, sp, 0x1FC   # sp = 0x1FC (508)

# Performance monitoring - use a simple counter (rdcycle not supported)
# Instead, we'll count loop iterations
addi    t5, x0, 0       # t5 = 0 (start marker)

# Set up pointers: a0 = output (0x40), a1 = input (0x00)
addi    a0, x0, 0x40    # a0 = 64 (output buffer)
addi    a1, x0, 0x00    # a1 = 0 (input buffer)

# Call chacha20_block (inline, no actual call needed for small test)
# Jump to chacha20_block code
j       12              # Jump forward 12 bytes (3 instructions) to block start

# End marker location (we'll jump back here)
# end_program:
addi    t6, x0, 1       # t6 = 1 (completion marker)
sw      t6, 0x204(x0)   # Store completion marker
nop                     # Halt point

# =============================================================================
# chacha20_block: ChaCha20 block function
# Input: a0 = output buffer, a1 = input buffer
# =============================================================================
# chacha20_block:

# --- Copy input to working state (at 0x80) ---
# Simple loop: copy 16 words from input to state
addi    t0, x0, 0       # t0 = loop counter
addi    t1, x0, 16      # t1 = loop limit
addi    t2, x0, 0x80    # t2 = state base address

# copy_loop:
lw      t3, 0(a1)       # Load from input
sw      t3, 0(t2)       # Store to state
addi    a1, a1, 4       # input++
addi    t2, t2, 4       # state++
addi    t0, t0, 1       # counter++
blt     t0, t1, -20     # if counter < 16, loop back

# Reset pointers
addi    a1, x0, 0x00    # a1 = input base (reset)
addi    t2, x0, 0x80    # t2 = state base (reset)

# --- Load state into registers ---
# s0-s3 = state[0-3], s4-s7 = state[4-7]
# a2-a5 = state[8-11], a6-a7,t3,t4 = state[12-15]
lw      s0, 0(t2)       # state[0]
lw      s1, 4(t2)       # state[1]
lw      s2, 8(t2)       # state[2]
lw      s3, 12(t2)      # state[3]
lw      s4, 16(t2)      # state[4]
lw      s5, 20(t2)      # state[5]
lw      s6, 24(t2)      # state[6]
lw      s7, 28(t2)      # state[7]
lw      a2, 32(t2)      # state[8]
lw      a3, 36(t2)      # state[9]
lw      a4, 40(t2)      # state[10]
lw      a5, 44(t2)      # state[11]
lw      a6, 48(t2)      # state[12]
lw      a7, 52(t2)      # state[13]
lw      t3, 56(t2)      # state[14]
lw      t4, 60(t2)      # state[15]

# --- Main loop: 10 double-rounds (20 rounds total) ---
addi    t0, x0, 0       # t0 = round counter
addi    t1, x0, 10      # t1 = round limit (10 double-rounds)

# round_loop:
# === Column round ===
# QR(0, 4, 8, 12): s0, s4, a2, a6
add     s0, s0, s4      # a += b
xor     a6, a6, s0      # d ^= a
addi    t6, x0, 16
rol     a6, a6, t6      # d = ROL(d, 16)
add     a2, a2, a6      # c += d
xor     s4, s4, a2      # b ^= c
addi    t6, x0, 12
rol     s4, s4, t6      # b = ROL(b, 12)
add     s0, s0, s4      # a += b
xor     a6, a6, s0      # d ^= a
addi    t6, x0, 8
rol     a6, a6, t6      # d = ROL(d, 8)
add     a2, a2, a6      # c += d
xor     s4, s4, a2      # b ^= c
addi    t6, x0, 7
rol     s4, s4, t6      # b = ROL(b, 7)

# QR(1, 5, 9, 13): s1, s5, a3, a7
add     s1, s1, s5
xor     a7, a7, s1
addi    t6, x0, 16
rol     a7, a7, t6
add     a3, a3, a7
xor     s5, s5, a3
addi    t6, x0, 12
rol     s5, s5, t6
add     s1, s1, s5
xor     a7, a7, s1
addi    t6, x0, 8
rol     a7, a7, t6
add     a3, a3, a7
xor     s5, s5, a3
addi    t6, x0, 7
rol     s5, s5, t6

# QR(2, 6, 10, 14): s2, s6, a4, t3
add     s2, s2, s6
xor     t3, t3, s2
addi    t6, x0, 16
rol     t3, t3, t6
add     a4, a4, t3
xor     s6, s6, a4
addi    t6, x0, 12
rol     s6, s6, t6
add     s2, s2, s6
xor     t3, t3, s2
addi    t6, x0, 8
rol     t3, t3, t6
add     a4, a4, t3
xor     s6, s6, a4
addi    t6, x0, 7
rol     s6, s6, t6

# QR(3, 7, 11, 15): s3, s7, a5, t4
add     s3, s3, s7
xor     t4, t4, s3
addi    t6, x0, 16
rol     t4, t4, t6
add     a5, a5, t4
xor     s7, s7, a5
addi    t6, x0, 12
rol     s7, s7, t6
add     s3, s3, s7
xor     t4, t4, s3
addi    t6, x0, 8
rol     t4, t4, t6
add     a5, a5, t4
xor     s7, s7, a5
addi    t6, x0, 7
rol     s7, s7, t6

# === Diagonal round ===
# QR(0, 5, 10, 15): s0, s5, a4, t4
add     s0, s0, s5
xor     t4, t4, s0
addi    t6, x0, 16
rol     t4, t4, t6
add     a4, a4, t4
xor     s5, s5, a4
addi    t6, x0, 12
rol     s5, s5, t6
add     s0, s0, s5
xor     t4, t4, s0
addi    t6, x0, 8
rol     t4, t4, t6
add     a4, a4, t4
xor     s5, s5, a4
addi    t6, x0, 7
rol     s5, s5, t6

# QR(1, 6, 11, 12): s1, s6, a5, a6
add     s1, s1, s6
xor     a6, a6, s1
addi    t6, x0, 16
rol     a6, a6, t6
add     a5, a5, a6
xor     s6, s6, a5
addi    t6, x0, 12
rol     s6, s6, t6
add     s1, s1, s6
xor     a6, a6, s1
addi    t6, x0, 8
rol     a6, a6, t6
add     a5, a5, a6
xor     s6, s6, a5
addi    t6, x0, 7
rol     s6, s6, t6

# QR(2, 7, 8, 13): s2, s7, a2, a7
add     s2, s2, s7
xor     a7, a7, s2
addi    t6, x0, 16
rol     a7, a7, t6
add     a2, a2, a7
xor     s7, s7, a2
addi    t6, x0, 12
rol     s7, s7, t6
add     s2, s2, s7
xor     a7, a7, s2
addi    t6, x0, 8
rol     a7, a7, t6
add     a2, a2, a7
xor     s7, s7, a2
addi    t6, x0, 7
rol     s7, s7, t6

# QR(3, 4, 9, 14): s3, s4, a3, t3
add     s3, s3, s4
xor     t3, t3, s3
addi    t6, x0, 16
rol     t3, t3, t6
add     a3, a3, t3
xor     s4, s4, a3
addi    t6, x0, 12
rol     s4, s4, t6
add     s3, s3, s4
xor     t3, t3, s3
addi    t6, x0, 8
rol     t3, t3, t6
add     a3, a3, t3
xor     s4, s4, a3
addi    t6, x0, 7
rol     s4, s4, t6

# Loop control
addi    t0, t0, 1       # counter++
blt     t0, t1, -516    # Branch back to round_loop (inst 167 -> inst 38 = -129 * 4 = -516)

# --- Add original state back ---
# Reload original input and add to state
addi    t2, x0, 0x00    # t2 = input base
lw      t5, 0(t2)
add     s0, s0, t5      # state[0] += input[0]
lw      t5, 4(t2)
add     s1, s1, t5
lw      t5, 8(t2)
add     s2, s2, t5
lw      t5, 12(t2)
add     s3, s3, t5
lw      t5, 16(t2)
add     s4, s4, t5
lw      t5, 20(t2)
add     s5, s5, t5
lw      t5, 24(t2)
add     s6, s6, t5
lw      t5, 28(t2)
add     s7, s7, t5
lw      t5, 32(t2)
add     a2, a2, t5
lw      t5, 36(t2)
add     a3, a3, t5
lw      t5, 40(t2)
add     a4, a4, t5
lw      t5, 44(t2)
add     a5, a5, t5
lw      t5, 48(t2)
add     a6, a6, t5
lw      t5, 52(t2)
add     a7, a7, t5
lw      t5, 56(t2)
add     t3, t3, t5
lw      t5, 60(t2)
add     t4, t4, t5

# --- Store output ---
sw      s0, 0x40(x0)    # output[0]
sw      s1, 0x44(x0)    # output[1]
sw      s2, 0x48(x0)    # output[2]
sw      s3, 0x4C(x0)    # output[3]
sw      s4, 0x50(x0)    # output[4]
sw      s5, 0x54(x0)    # output[5]
sw      s6, 0x58(x0)    # output[6]
sw      s7, 0x5C(x0)    # output[7]
sw      a2, 0x60(x0)    # output[8]
sw      a3, 0x64(x0)    # output[9]
sw      a4, 0x68(x0)    # output[10]
sw      a5, 0x6C(x0)    # output[11]
sw      a6, 0x70(x0)    # output[12]
sw      a7, 0x74(x0)    # output[13]
sw      t3, 0x78(x0)    # output[14]
sw      t4, 0x7C(x0)    # output[15]

# Store round counter for verification
sw      t0, 0x200(x0)   # Store round count (should be 10)

# --- Zbb Integrity Check: CPOP ---
cpop    t5, s0          # Count bits in final state[0]
sw      t5, 0x204(x0)   # Store popcount

# Halt (infinite loop on NOP)
halt_loop:
nop
j       -4              # Loop here forever (halt)


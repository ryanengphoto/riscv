# Simple loop test to verify branch behavior
# Should run exactly 10 iterations and store results

# Initialize
addi    t0, x0, 0       # t0 = counter = 0
addi    t1, x0, 10      # t1 = limit = 10
addi    t2, x0, 0       # t2 = accumulator = 0

# Loop: add counter to accumulator, 10 times
loop:
addi    t2, t2, 1       # accumulator++
addi    t0, t0, 1       # counter++
blt     t0, t1, -8      # if counter < 10, branch back to "addi t2, t2, 1"

# Store results
sw      t0, 0(x0)       # Store final counter (should be 10)
sw      t1, 4(x0)       # Store limit (should be 10)
sw      t2, 8(x0)       # Store accumulator (should be 10)

# Done
nop


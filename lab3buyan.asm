.text
main:
    # Setup
    la $s0, M               # Base address of matrix M
    la $s1, buffer          # Address of input buffer
    li $s2, 1               # Row counter (1 to 4)

read_matrix:
    # Print row prompt
    li $v0, 4
    la $a0, row_label
    syscall
    li $v0, 1
    move $a0, $s2
    syscall
    li $v0, 4
    la $a0, colon_space
    syscall

    # Read row input
    li $v0, 8
    move $a0, $s1
    li $a1, 20
    syscall

    # Prepare arguments for read_vector
    move $a0, $s1           # Buffer address
    addi $t0, $s2, -1       # Current row index (0-based)
    sll $t0, $t0, 4         # Multiply by 16 (bytes per row)
    add $a1, $s0, $t0       # Destination address in M
    jal read_vector          # Call to read and convert row

    # Next row
    addi $s2, $s2, 1
    ble $s2, 4, read_matrix

    # Sum all elements of M
    la $t0, M               # Pointer to matrix
    li $t1, 16              # Total elements (loop counter)
    li $t2, 0               # Sum accumulator

sum_loop:
    lw $t3, 0($t0)          # Load current element
    add $t2, $t2, $t3       # Add to sum
    addi $t0, $t0, 4        # Move to next element
    addi $t1, $t1, -1       # Decrement counter
    bnez $t1, sum_loop      # Loop until all elements summed

    # Print sum
    li $v0, 4
    la $a0, sum_label
    syscall
    li $v0, 1
    move $a0, $t2
    syscall

    # Determine and print parity
    andi $t0, $t2, 1        # Check least significant bit
    li $v0, 4
    la $a0, parity_label
    syscall
    li $v0, 1
    move $a0, $t0
    syscall

    # Exit
    li $v0, 10
    syscall

# Procedures
read_vector:
    # Arguments: $a0 = buffer, $a1 = destination
    addi $sp, $sp, -4
    sw $ra, 0($sp)          # Save return address

    li $t2, 0               # Element counter

process_element:
    # Load two characters
    lb $t0, 0($a0)
    lb $t1, 1($a0)

    # Call leaf procedure for conversion
    move $a2, $t0
    move $a3, $t1
    jal atoi

    # Store converted integer
    sw $v0, 0($a1)

    # Advance pointers
    addi $a0, $a0, 3        # Next element in buffer
    addi $a1, $a1, 4        # Next position in matrix

    # Loop control
    addi $t2, $t2, 1
    blt $t2, 4, process_element

    lw $ra, 0($sp)
    addi $sp, $sp, 4
    jr $ra

atoi:
    # Convert two ASCII chars to integer (leaf procedure)
    andi $t0, $a2, 0x0F     # First digit
    li $t1, 10
    mult $t0, $t1           # Multiply by 10
    mflo $t0
    andi $t1, $a3, 0x0F     # Second digit
    add $v0, $t0, $t1
    jr $ra

.data
M:          .space 64       # 4x4 matrix (16 integers)
buffer:     .space 20       # Input buffer for each row
row_label:  .asciiz "Row "
colon_space: .asciiz ": "
sum_label:  .asciiz "\nSum: "
parity_label: .asciiz "\nParity: "
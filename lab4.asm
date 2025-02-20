.text
    # Read two 4x4 matrices
    jal read_matrix
    la $s0, M1  # First matrix
    jal read_matrix
    la $s0, M2  # Second matrix

    # Perform matrix multiplication
    jal matrix_multiply

    # Print the result matrix
    jal print_matrix

    li $v0, 10  # Exit program
    syscall

# Procedure to read a 4x4 matrix
read_matrix:
    li $s2, 1  # Row counter
read_matrix_row:
    li $t2, 0  # Column counter
    move $a1, $s0  # Store matrix base address
process_element:
    # Read user input
    li $v0, 8
    move $a0, $s1
    li $a1, 20
    syscall

    # Convert ASCII to integer (Assumes single-digit input)
    lb $t0, buffer  # Load first character
    andi $t0, $t0, 0x0F  # Convert ASCII to integer

    # Store integer into matrix
    sw $t0, 0($a1)

    # Update pointers
    addi $a1, $a1, 4  # Move to next column
    addi $t2, $t2, 1  # Column counter++
    blt $t2, 4, process_element

    addi $s2, $s2, 1  # Row counter++
    ble $s2, 4, read_matrix_row
    jr $ra  # Return

# Matrix multiplication subroutine
matrix_multiply:
    la $s0, M1
    la $s1, M2
    la $s2, Result
    li $t0, 0  # Row index i
mat_mult_row:
    li $t1, 0  # Column index j
mat_mult_col:
        li $t2, 0  # Accumulator for sum
        li $t3, 0  # k index
mat_mult_inner:
        lw $t4, 0($s0)  # M1[i][k]
        lw $t5, 0($s1)  # M2[k][j]
        mul $t6, $t4, $t5  # M1[i][k] * M2[k][j]
        add $t2, $t2, $t6  # Accumulate sum

        addi $s0, $s0, 4  # Move to next column in M1
        addi $s1, $s1, 16  # Move to next row in M2
        addi $t3, $t3, 1  # k++
        blt $t3, 4, mat_mult_inner

        sw $t2, 0($s2)  # Store result in Result[i][j]
        addi $s2, $s2, 4  # Move to next column in Result
        addi $s1, $s1, -64  # Reset M2 pointer
        addi $t1, $t1, 1  # j++
        blt $t1, 4, mat_mult_col

    addi $s0, $s0, -16  # Reset M1 row pointer
    addi $t0, $t0, 1  # i++
    blt $t0, 4, mat_mult_row
    jr $ra  # Return

# Print matrix
print_matrix:
    li $s2, 1  # Row counter
print_matrix_row:
    li $t2, 0  # Column counter
    move $a1, $s2  # Row number
    li $v0, 1
    syscall

    li $v0, 4
    la $a0, colon_space
    syscall

print_matrix_col:
    lw $a0, 0($s0)
    li $v0, 1
    syscall

    li $v0, 4
    la $a0, space
    syscall

    addi $s0, $s0, 4
    addi $t2, $t2, 1
    blt $t2, 4, print_matrix_col

    li $v0, 4
    la $a0, newline
    syscall

    addi $s2, $s2, 1
    ble $s2, 4, print_matrix_row
    jr $ra

.data
M1: .space 64
M2: .space 64
Result: .space 64
buffer: .space 20
colon_space: .asciiz ": "
space: .asciiz " "
newline: .asciiz "\n"

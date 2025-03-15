.text
main:
    # Multiply matrixes
    la $a0, Matrix1         
    la $a1, Matrix2         
    la $a2, Result          # Result matrix address
    jal multiply_matrix
    
    # print result
    li $v0, 4
    la $a0, result_msg
    syscall
    la $a0, Result
    jal print_matrix
    
    li $v0, 10
    syscall

multiply_matrix:
    addi $sp, $sp, -4
    sw $ra, ($sp)
    li $t0, 0              # row counter
outer_loop:
    li $t1, 0              # col counter
middle_loop:
    # calculate base address for c[i][j]
    mul $t4, $t0, 32       # row offset (8 ints * 4 bytes)
    mul $t5, $t1, 4        # column offset
    add $t4, $t4, $t5     
    add $t4, $t4, $a2      
    
    #  sum for c[i][j]
    li $t2, 0              # sum = 0
    
    li $t3, 0              # k = 0 (position counter)
inner_loop:
    # calculate address for a[i][k]
    mul $t5, $t0, 32       # t5 = i * 32
    mul $t6, $t3, 4        # t6 = k * 4
    add $t5, $t5, $t6      
    add $t5, $t5, $a0      
    
    # calculate address for b[k][j]
    mul $t6, $t3, 32       # row offset
    mul $t7, $t1, 4        # column offset
    add $t6, $t6, $t7     
    add $t6, $t6, $a1     
    
    #  values and multiply
    lw $t7, ($t5)          
    lw $t8, ($t6)          
    mul $t9, $t7, $t8      
    add $t2, $t2, $t9      
    
    addi $t3, $t3, 1       # k++
    blt $t3, 8, inner_loop # if k < 8 continue inner loop
    
    # final sum in c[i][j]
    sw $t2, ($t4)          # c[i][j] = sum
    
    addi $t1, $t1, 1       # j++
    blt $t1, 8, middle_loop # if j < 8 continue middle loop
    
    addi $t0, $t0, 1       # i++
    blt $t0, 8, outer_loop # if i < 8 continue outer loop

    lw $ra, ($sp)
    addi $sp, $sp, 4
    jr $ra

# Print matrix procedure
print_matrix:
    li $t0, 0              # row count
    move $t1, $a0          # matrixes addr
print_row_loop:
        # Print row header
        li $v0, 4
        la $a0, row_prompt
        syscall
        li $v0, 1
        addi $a0, $t0, 1
        syscall
        li $v0, 4
        la $a0, colon
        syscall
        li $t2, 0          # count column
        print_number_loop:
            # number print and space print
            li $v0, 1
            lw $a0, ($t1)
            syscall
            li $v0, 4
            la $a0, space
            syscall
            addi $t1, $t1, 4   # next num
            addi $t2, $t2, 1   
            blt $t2, 8, print_number_loop
        # newline print
        li $v0, 4
        la $a0, newline
        syscall
        addi $t0, $t0, 1      
        blt $t0, 8, print_row_loop
        jr $ra

.data
result_msg:       .asciiz "\nResult matrix:\n"
row_prompt:       .asciiz "Row "
colon:           .asciiz ": "
space:           .asciiz " " #for results
newline:         .asciiz "\n"

.align 2
# First matrix - initialize with values 1-8 for each row
Matrix1:         
    .word 1, 2, 3, 4, 5, 6, 7, 8
    .word 1, 2, 3, 4, 5, 6, 7, 8
    .word 1, 2, 3, 4, 5, 6, 7, 8
    .word 1, 2, 3, 4, 5, 6, 7, 8
    .word 1, 2, 3, 4, 5, 6, 7, 8
    .word 1, 2, 3, 4, 5, 6, 7, 8
    .word 1, 2, 3, 4, 5, 6, 7, 8
    .word 1, 2, 3, 4, 5, 6, 7, 8

# Second matrix - identity matrix
Matrix2:         
    .word 1, 0, 0, 0, 0, 0, 0, 0
    .word 0, 1, 0, 0, 0, 0, 0, 0
    .word 0, 0, 1, 0, 0, 0, 0, 0
    .word 0, 0, 0, 1, 0, 0, 0, 0
    .word 0, 0, 0, 0, 1, 0, 0, 0
    .word 0, 0, 0, 0, 0, 1, 0, 0
    .word 0, 0, 0, 0, 0, 0, 1, 0
    .word 0, 0, 0, 0, 0, 0, 0, 1

# Result matrix - will be populated by the program
Result:          .space 256    # 8*8*4 = 256 bytes
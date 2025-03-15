.text
main:
    # first matrix
    la $a0, Matrix1         # address first matrix
    jal read_matrix         
    # second matrix msg
    li $v0, 4
    la $a0, second_matrix_msg
    syscall
    # second matrix
    la $a0, Matrix2         # address second matrix
    jal read_matrix         
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
read_matrix:
    addi $sp, $sp, -8      
    sw $ra, 4($sp)
    sw $s0, 0($sp)
    move $s0, $a0          #  matrix base addr
    li $s1, 8              # rows (changed from 4 to 8)
    li $s2, 0              # rows count
    read_row_loop:
        # row print
        li $v0, 4
        la $a0, row_prompt
        syscall
        li $v0, 1
        addi $a0, $s2, 1
        syscall
        li $v0, 4
        la $a0, colon
        syscall
        move $a0, $s0          # current position
        jal read_vector
        addi $s0, $s0, 32      # Move to next row (8 integers * 4 bytes) (changed from 16 to 32)
        addi $s2, $s2, 1       # Increment row counter
        blt $s2, $s1, read_row_loop
        lw $s0, 0($sp)
        lw $ra, 4($sp)
        addi $sp, $sp, 8
        jr $ra
# non leaf vector read
read_vector:
    addi $sp, $sp, -4
    sw $ra, ($sp)   
    li $t0, 8              # changed from 4 to 8
    li $t1, 0              # counter
    move $s3, $a0          # save matrix position
    li $v0, 8
    la $a0, input_buffer
    li $a1, 25             # increased buffer size (changed from 13 to 25)
    syscall
    
    la $t3, input_buffer
    
    read_number_loop:
        lb $a0, ($t3)      # First digit
        jal convert_digit   # Convert to integer (leaf procedure)  
        sw $v0, ($s3)      # Store in matrix 
        addi $t3, $t3, 2   # Skip to next number (digit + space)
        addi $s3, $s3, 4   # Next matrix position
        addi $t1, $t1, 1   # Increment counter
        blt $t1, $t0, read_number_loop 
    lw $ra, ($sp)
    addi $sp, $sp, 4
    jr $ra
# leaf digit convers
convert_digit:
    subi $v0, $a0, 48      # ascii to int
    jr $ra
multiply_matrix:
    addi $sp, $sp, -4
    sw $ra, ($sp)
    li $t0, 0              # row counter
outer_loop:
    li $t1, 0              # col counter
middle_loop:
    # calculate base address for c[i][j]
    mul $t4, $t0, 32       # changed from 16 to 32
    mul $t5, $t1, 4        
    add $t4, $t4, $t5     
    add $t4, $t4, $a2      
    
    #  sum for c[i][j]
    li $t2, 0              # sum = 0
    
    li $t3, 0              #k = 0(position counter)
inner_loop:
    # calculate address for a[i][k]
    mul $t5, $t0, 32       # t5 = i * 32 (changed from 16 to 32)
    mul $t6, $t3, 4        # t6 = k * 4
    add $t5, $t5, $t6      
    add $t5, $t5, $a0      
    
    # calculate address for b[k][j]
    mul $t6, $t3, 32       # changed from 16 to 32
    mul $t7, $t1, 4        
    add $t6, $t6, $t7     
    add $t6, $t6, $a1     
    
    #  values and multiply
    lw $t7, ($t5)          
    lw $t8, ($t6)          
    mul $t9, $t7, $t8      
    add $t2, $t2, $t9      
    
    addi $t3, $t3, 1       # k++
    blt $t3, 8, inner_loop # if k < 8 continue inner loop (changed from 4 to 8)
    
    # final sum in c[i][j]
    sw $t2, ($t4)          # c[i][j] = sum
    
    addi $t1, $t1, 1       # j++
    blt $t1, 8, middle_loop # if j < 8 continue middle loop (changed from 4 to 8)
    
    addi $t0, $t0, 1       # i++
    blt $t0, 8, outer_loop # if i < 8 continue outer loop (changed from 4 to 8)

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
            blt $t2, 8, print_number_loop  # changed from 4 to 8
        # newline print
        li $v0, 4
        la $a0, newline
        syscall
        addi $t0, $t0, 1      
        blt $t0, 8, print_row_loop  # changed from 4 to 8
        jr $ra

.data

second_matrix_msg: .asciiz "\nSecond matrix: \n"
result_msg:       .asciiz "\nResult matrix:\n"
row_prompt:       .asciiz "Row "
colon:           .asciiz ": "
space:           .asciiz " " #for results
newline:         .asciiz "\n"

.align 2
input_buffer:    .space 32     # increased buffer size (changed from 24 to 32)
Matrix1:         .space 256    # 8*8*4 = 256 bytes (changed from 64 to 256)
Matrix2:         .space 256    # 8*8*4 = 256 bytes (changed from 64 to 256)
Result:          .space 256    # 8*8*4 = 256 bytes (changed from 64 to 256)
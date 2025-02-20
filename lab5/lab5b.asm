.text
main:
    # first matrix
    la $a0, Matrix1         
    jal read_matrix         
    # second matrix msg
    li $v0, 4
    la $a0, second_matrix_msg
    syscall
    # second matrix
    la $a0, Matrix2         
    jal read_matrix         
    # Multiply matrices
    la $a0, Matrix1         
    la $a1, Matrix2         
    la $a2, Result          
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
    	li $s1, 4              # rows
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
	        addi $s0, $s0, 16      # Move to next row (4 integers * 4 bytes)
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
    	li $t0, 4
    	li $t1, 0              # counter
    	move $s3, $a0          # save matrix position
    	li $v0, 8
    	la $a0, input_buffer
    	li $a1, 13
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
    	li $t0, 0              # i (row counter)
outer_loop:
    	li $t1, 0              # j (col counter)
middle_loop:
    	# c[i][j]
    	mul $s0, $t0, 16       # s0 = i * 16
    	mul $s1, $t1, 4        # s1 = j * 4
    	add $s0, $s0, $s1      # s0 = i * 16 + j * 4
    	add $s0, $s0, $a2      # s0 = address of c[i][j]
    
    	# k = 0
    	# a[i][0] address
    	mul $t2, $t0, 16
    	add $t2, $t2, $a0      
    
    	# b[0][j] address
    	mul $t3, $t1, 4        
    	add $t3, $t3, $a1     
    
    	# multiply first pair
    	lw $s1, ($t2)          #s1 = a[i][0]
    	lw $s2, ($t3)          #s2 = b[0][j]
    	mul $s3, $s1, $s2      #s3 = a[i][0] * b[0][j]
    
    	# k = 1
    	# a[i][1] address
    	mul $t4, $t0, 16       
    	addi $t4, $t4, 4       
    	add $t4, $t4, $a0      
    
    	# b[1][j] address
    	mul $t5, $t1, 4        # t5 = j * 4
    	addi $t5, $t5, 16      
    	add $t5, $t5, $a1      # t5 =  b[1][j] address
    
    	# multiply second pair
    	lw $s4, ($t4)          # s4 = a[i][1]
    	lw $s5, ($t5)          # s5 = b[1][j]
    	mul $s6, $s4, $s5      # s6 = a[i][1] * b[1][j]
    
    	# k = 2
    	# a[i][2] address
    	mul $t6, $t0, 16       
    	addi $t6, $t6, 8       
    	add $t6, $t6, $a0      
    
    	# b[2][j] address
    	mul $t7, $t1, 4        
    	addi $t7, $t7, 32      
    	add $t7, $t7, $a1      # t7 = address of b[2][j]
    
    	# multiply third pair
    	lw $t8, ($t6)          
    	lw $t9, ($t7)         
    	mul $s7, $t8, $t9      
    
    	# k = 3
    	# a[i][3] address
    	mul $t2, $t0, 16       
    	addi $t2, $t2, 12      
    	add $t2, $t2, $a0      
    
    	# b[3][j] address
    	mul $t3, $t1, 4        
    	addi $t3, $t3, 48      
    	add $t3, $t3, $a1      # t3 = address of b[3][j]
    
    	# multiply fourth pair
    	lw $t4, ($t2)          # reuse
    	lw $t5, ($t3)          # 
    	mul $t6, $t4, $t5      #
    
    	# Sum all
    	add $t7, $s3, $s6      # t7 = first + second
    	add $t8, $s7, $t6      # t8 = third + fourth
    	add $t9, $t7, $t8      # t9 = total sum
    
    	# result
    	sw $t9, ($s0)
    
    	addi $t1, $t1, 1       # j++
    	blt $t1, 4, middle_loop # if j < 4 continue middle loop
    
    	addi $t0, $t0, 1       # i++
    	blt $t0, 4, outer_loop # if i < 4 continue outer loop

    	lw $ra, ($sp)
    	addi $sp, $sp, 4
    	jr $ra
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
            		blt $t2, 4, print_number_loop
        	# newline print
        	li $v0, 4
        	la $a0, newline
        	syscall
        	addi $t0, $t0, 1      
        	blt $t0, 4, print_row_loop
        	jr $ra


.data

second_matrix_msg: .asciiz "\Second matrix: \n"
result_msg:       .asciiz "\nResult matrix:\n"
row_prompt:       .asciiz "Row "
colon:           .asciiz ": "
space:           .asciiz " " #for results
newline:         .asciiz "\n"

.align 2
input_buffer:    .space 24
Matrix1:         .space 64    
Matrix2:         .space 64   
Result:          .space 64     

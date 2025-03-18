# Buyan Lab 6 e2
# Memory Access Count - 1507, Cache Hit Count 1031, Cache Miss Count 476
# Cache Hit Rate 68%
# 24% increase

.text
main:
    	# multiply matrices  blocking
    	la $a0, Matrix1         
    	la $a1, Matrix2         
    	la $a2, Result          # result address
    	jal multiply_matrix_blocked
    
    	# print result
    	li $v0, 4
    	la $a0, result_msg
    	syscall
    	la $a0, Result
    	jal print_matrix
    
    	li $v0, 10
    	syscall

	# matrix multi 4x4 blocking
	multiply_matrix_blocked:
    		addi $sp, $sp, -4
    		sw $ra, ($sp)
    
    	# blocks (2x2 grid of 4x4 blocks)
    	li $t0, 0              # block row counter (0-1)
	block_row_loop:
    		li $t1, 0              # block column counter (0-1)
	block_col_loop:
    		li $t2, 0              # block k counter (0-1)
	block_k_loop:
    		# block starting positions
    		mul $t3, $t0, 4        # block_i * 4 = starting row of block
    		mul $t4, $t1, 4        # block_j * 4 = starting column of block
    		mul $t5, $t2, 4        # block_k * 4 = starting k position
    
    		# current 4x4 block
    		move $a3, $t3          # a3 = starting row
    		addi $t6, $t3, 4       # t6 = ending row
	block_i_loop:
    		move $t7, $t4          # t7 = starting column
    		addi $t8, $t4, 4       # t8 = ending column
	block_j_loop:
    		# address for c[i][j] in result matrix
    		mul $s0, $a3, 32       # row offset (8 ints * 4 bytes)
    		mul $s1, $t7, 4        # column offset
    		add $s0, $s0, $s1     
    		add $s0, $s0, $a2      # address of c[i][j]
    
    		# If first block in k sum to 0 else  current value to accumulate
    		
    		beq $t2, 0, init_sum
    		lw $s2, ($s0)          # load current value if not first block
    		j continue_sum
	init_sum:
    		li $s2, 0              # sum = 0 if first block
	continue_sum:
    
    		move $t9, $t5          # t9 = starting k
    	addi $s3, $t5, 4       # s3 = ending k
	block_k_inner_loop:
    		# calculate address for a[i][k]
    		mul $s4, $a3, 32       # s4 = i * 32
    		mul $s5, $t9, 4        # s5 = k * 4
    		add $s4, $s4, $s5      
    		add $s4, $s4, $a0      # address of a[i][k]
    
    		# calculate address for b[k][j]
		mul $s5, $t9, 32       # row offset for k
    		mul $s6, $t7, 4        # column offset for j
    		add $s5, $s5, $s6     
    		add $s5, $s5, $a1      # address of b[k][j]
    	
    		# get values and multiply
    		lw $s6, ($s4)          # a[i][k]
    		lw $s7, ($s5)          # b[k][j]
    		mul $s7, $s6, $s7      # a[i][k] * b[k][j]
    		add $s2, $s2, $s7      # sum += a[i][k] * b[k][j]
    
    		addi $t9, $t9, 1       # k++
    		blt $t9, $s3, block_k_inner_loop # if k < ending k, continue inner loop
    
    		# final sum in c[i][j]
    		sw $s2, ($s0)          # c[i][j] = sum
    
    		addi $t7, $t7, 1       # j++
    		blt $t7, $t8, block_j_loop # if j < ending j, continue j loop
    
		addi $a3, $a3, 1       # i++
    		blt $a3, $t6, block_i_loop # if i < ending i, continue i loop
    
    		addi $t2, $t2, 1       # block_k++
    		blt $t2, 2, block_k_loop # if block_k < 2, continue k loop
    
   	 	addi $t1, $t1, 1       # block_j++
    		blt $t1, 2, block_col_loop # if block_j < 2, continue block_j loop
    
    		addi $t0, $t0, 1       # block_i++
    		blt $t0, 2, block_row_loop # if block_i < 2, continue block_i loop
    
    		lw $ra, ($sp)
    		addi $sp, $sp, 4
    		jr $ra

	# print matrix
	print_matrix:
    		li $t0, 0              # row count
    		move $t1, $a0          # matrix addr
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
	# first matrix
	Matrix1:         
    	.word 1, 2, 3, 4, 5, 6, 7, 8
    	.word 1, 2, 3, 4, 5, 6, 7, 8
    	.word 1, 2, 3, 4, 5, 6, 7, 8
    	.word 1, 2, 3, 4, 5, 6, 7, 8
    	.word 1, 2, 3, 4, 5, 6, 7, 8
    	.word 1, 2, 3, 4, 5, 6, 7, 8
    	.word 1, 2, 3, 4, 5, 6, 7, 8
    	.word 1, 2, 3, 4, 5, 6, 7, 8
	# second matrix - identity matrix
	Matrix2:         
    	.word 1, 2, 3, 4, 5, 6, 7, 8
    	.word 1, 2, 3, 4, 5, 6, 7, 8
    	.word 1, 2, 3, 4, 5, 6, 7, 8
    	.word 1, 2, 3, 4, 5, 6, 7, 8
    	.word 1, 2, 3, 4, 5, 6, 7, 8
    	.word 1, 2, 3, 4, 5, 6, 7, 8
    	.word 1, 2, 3, 4, 5, 6, 7, 8
    	.word 1, 2, 3, 4, 5, 6, 7, 8
	# result matrix 
	Result:          .space 256    # 8*8*4=256

# Buyan Lab 6 e2
# Memory Access Count - 1507, Cache Hit Count 1031, Cache Miss Count 476
# Cache Hit Rate 68%
# 24% increase


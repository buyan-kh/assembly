.text
main:
    # Initialize first matrix read
    la $a0, Matrix1         # Load address of first matrix
    jal read_matrix         
    
    # Print welcome message for second matrix
    li $v0, 4
    la $a0, second_matrix_msg
    syscall
    
    # Read second matrix
    la $a0, Matrix2         # Load address of second matrix
    jal read_matrix         # Call matrix read procedure
    
    # Multiply matrices
    la $a0, Matrix1         # First matrix address
    la $a1, Matrix2         # Second matrix address
    la $a2, Result          # Result matrix address
    jal multiply_matrix     # Call multiplication procedure
    
    # Print result matrix
    li $v0, 4
    la $a0, result_msg
    syscall
    la $a0, Result
    jal print_matrix
    
    li $v0, 10             # Exit program
    syscall

# Matrix read procedure
read_matrix:
    addi $sp, $sp, -8      # Save $ra and $s0
    sw $ra, 4($sp)
    sw $s0, 0($sp)
    
    move $s0, $a0          # Save matrix base address
    li $s1, 4              # Number of rows
    li $s2, 0              # Row counter
    
    read_row_loop:
        # Print row prompt
        li $v0, 4
        la $a0, row_prompt
        syscall
        li $v0, 1
        addi $a0, $s2, 1
        syscall
        li $v0, 4
        la $a0, colon
        syscall
        
        # Read row
        move $a0, $s0          # Current position in matrix
        jal read_vector        # Read one row
        
        addi $s0, $s0, 16      # Move to next row (4 integers * 4 bytes)
        addi $s2, $s2, 1       # Increment row counter
        blt $s2, $s1, read_row_loop
        
        lw $s0, 0($sp)
        lw $ra, 4($sp)
        addi $sp, $sp, 8
        jr $ra

# Vector read procedure (non-leaf)
read_vector:
    addi $sp, $sp, -4
    sw $ra, ($sp)
    
    li $t0, 4              # Numbers per row
    li $t1, 0              # Counter
    move $s3, $a0          # Save matrix position
    
    # Read input string
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

# Digit conversion (leaf procedure)
convert_digit:
    subi $v0, $a0, 48      # Convert ASCII to integer
    jr $ra

# Matrix multiplication procedure
multiply_matrix:
    addi $sp, $sp, -4
    sw $ra, ($sp)
    
    li $t0, 0              # Row counter
    
    mult_outer_loop:
        li $t1, 0          # Column counter
        
        mult_inner_loop:
            li $t2, 0      # Sum for current element
            li $t3, 0      # Position counter
            
            mult_sum_loop:
                # Calculate offsets
                mul $t4, $t0, 16        # Row offset for matrix 1
                mul $t5, $t3, 4         # Position offset for matrix 1
                add $t4, $t4, $t5       # Total offset for matrix 1
                add $t4, $t4, $a0       # Address in matrix 1
                
                mul $t5, $t3, 16        # Row offset for matrix 2
                mul $t6, $t1, 4         # Column offset for matrix 2
                add $t5, $t5, $t6       # Total offset for matrix 2
                add $t5, $t5, $a1       # Address in matrix 2
                
                # Load values and multiply
                lw $t6, ($t4)           # Value from matrix 1
                lw $t7, ($t5)           # Value from matrix 2
                mul $t8, $t6, $t7       # Multiply values
                add $t2, $t2, $t8       # Add to sum
                
                addi $t3, $t3, 1        # Increment position counter
                blt $t3, 4, mult_sum_loop
            
            # Store result
            mul $t4, $t0, 16            # Row offset for result
            mul $t5, $t1, 4             # Column offset for result
            add $t4, $t4, $t5           # Total offset for result
            add $t4, $t4, $a2           # Address in result
            sw $t2, ($t4)               # Store sum
            
            addi $t1, $t1, 1            # Increment column counter
            blt $t1, 4, mult_inner_loop
        
        addi $t0, $t0, 1                # Increment row counter
        blt $t0, 4, mult_outer_loop
    
    lw $ra, ($sp)
    addi $sp, $sp, 4
    jr $ra

# Print matrix procedure
print_matrix:
    li $t0, 0              # Row counter
    move $t1, $a0          # Matrix address
    
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
        
        li $t2, 0          # Column counter
        print_number_loop:
            # Print number and space
            li $v0, 1
            lw $a0, ($t1)
            syscall
            li $v0, 4
            la $a0, space
            syscall
            
            addi $t1, $t1, 4   # Next number
            addi $t2, $t2, 1   # Increment column counter
            blt $t2, 4, print_number_loop
        
        # Print newline
        li $v0, 4
        la $a0, newline
        syscall
        
        addi $t0, $t0, 1       # Increment row counter
        blt $t0, 4, print_row_loop
        
        jr $ra

.data
first_matrix_msg:  .asciiz "Enter the first 4x4 matrix (single digits 0-9):\n"
second_matrix_msg: .asciiz "\nEnter the second 4x4 matrix (single digits 0-9):\n"
result_msg:       .asciiz "\nResult matrix:\n"
row_prompt:       .asciiz "Row "
colon:           .asciiz ": "
space:           .asciiz " "
newline:         .asciiz "\n"

.align 2
input_buffer:    .space 24
Matrix1:         .space 64     # First 4x4 matrix (16 integers)
Matrix2:         .space 64     # Second 4x4 matrix (16 integers)
Result:          .space 64     # Result matrix (16 integers)
# My student ID is 20545406, ends with an even number I used sll
.text
    	li $v0, 8
    	
    	la $a0, inputPrompt      
    	syscall
    	li $v0, 8                
    	la $a0, buffer           
    	li $a1, 24               
    	syscall
    	la $t0, buffer           
    	la $t1, V                
    	li $t2, 8                

convert_loop:
    	lb $t3, 0($t0)           
    	andi $t3, $t3, 0x0F      
    	sll $t4, $t3, 3          
    	sll $t5, $t3, 1          
    	add $t3, $t4, $t5        
    	lb $t4, 1($t0)           
    	andi $t4, $t4, 0x0F      
    	add $t3, $t3, $t4        
    	sw $t3, 0($t1)           
    	addi $t1, $t1, 4         
    	addi $t0, $t0, 3         
    	addi $t2, $t2, -1        
    	bnez $t2, convert_loop   
    	li $v0, 4                
    	la $a0, inputPrompt2     
    	syscall
    	la $t1, VPrime           
    	li $t2, 8                

read_loop:
    	li $v0, 5                
    	syscall
    	sw $v0, 0($t1)           
    	addi $t1, $t1, 4         
    	addi $t2, $t2, -1        
    	bnez $t2, read_loop      
    	la $t0, V                
    	la $t1, VPrime           
    	la $t2, VCheck           
    	li $t3, 8                

subtract_loop:
    	lw $t4, 0($t0)           
    	lw $t5, 0($t1)           
    	sub $t6, $t4, $t5        
    	sw $t6, 0($t2)           
    	addi $t0, $t0, 4         
    	addi $t1, $t1, 4         
    	addi $t2, $t2, 4         
    	addi $t3, $t3, -1        
    	bnez $t3, subtract_loop  
    	la $t0, VCheck           
    	li $t1, 8                
    	li $t2, 0                

sum_loop:
    	lw $t3, 0($t0)           
    	add $t2, $t2, $t3        
    	addi $t0, $t0, 4         
    	addi $t1, $t1, -1        
    	bnez $t1, sum_loop       
    	li $v0, 4                
    	la $a0, outputPrompt     
    	syscall
    	li $v0, 1                
    	move $a0, $t2            
    	syscall
    	li $v0, 10               
    	syscall
    
.data
	V:          .space 32        
	VPrime:     .space 32        
	VCheck:     .space 32        
	inputPrompt: .asciiz "Input V: "
	inputPrompt2: .asciiz " Input VPrime:\n"
	outputPrompt: .asciiz "Check Result: "
	buffer:     .space 24   

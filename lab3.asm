.text
    	la $s0, M
    	la $s1, buffer
    	li $s2, 1
read_matrix:
    	li $v0, 4
    	la $a0, row_label
    	syscall
    	li $v0, 1
    	move $a0, $s2
    	syscall
    	li $v0, 4
    	la $a0, colon_space
    	syscall
    	li $v0, 8
    	move $a0, $s1
    	li $a1, 20
    	syscall
    	move $a0, $s1
    	addi $t0, $s2, -1
    	sll $t0, $t0, 4
    	add $a1, $s0, $t0
    	li $t2, 0
process_element:
    	lb $t0, 0($a0)
    	lb $t1, 1($a0)
    	move $a2, $t0
    	move $a3, $t1
    	li $t3, 0
    	andi $t3, $t0, 0x0F
    	sll $t4, $t3, 3
    	sll $t5, $t3, 1
    	add $t3, $t4, $t5
    	lb $t4, 1($a0)
    	andi $t4, $t4, 0x0F
    	add $v0, $t3, $t4
    	sw $v0, 0($a1)

    	addi $a0, $a0, 3
    	addi $a1, $a1, 4
    	addi $t2, $t2, 1
    	blt $t2, 4, process_element
    	addi $s2, $s2, 1
    	ble $s2, 4, read_matrix
    	la $t0, M
    	li $t1, 16
    	li $t2, 0
sum_loop:
    	lw $t3, 0($t0)
    	add $t2, $t2, $t3
    	addi $t0, $t0, 4
    	addi $t1, $t1, -1
    	bnez $t1, sum_loop
    	li $v0, 4
    	la $a0, sum_label
    	syscall
    	li $v0, 1
    	move $a0, $t2
    	syscall
    	andi $t0, $t2, 1
    	li $v0, 4
    	la $a0, parity_label
    	syscall
    	li $v0, 1
    	move $a0, $t0
    	syscall
    	li $v0, 10
    	syscall

.data
	M: .space 64
	buffer: .space 20
	row_label: .asciiz "Row "
	colon_space: .asciiz ": "
	sum_label: .asciiz "\nSum: "
	parity_label: .asciiz "\nParity: "

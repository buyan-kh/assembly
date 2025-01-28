.data 
	number1: .word 5
	number2: .word 10
.text
	lw $t0, number1($zero)
	lw $t1, number2($zero)
	
	add $t2, $t0, $t1	# t2 = t0 + t1
	
	li $v0, 1	# print integer
	add $a0, $zero, $t2	# print t2, move zero to a0 argument, move value
	syscall
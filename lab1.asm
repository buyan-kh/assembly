li $v0,4
la $a0,prompt1
syscall
li $v0,8
la $a0,answer
li $a1,50
syscall
li $v0,4
la $a0,prompt2
syscall
li $v0,5
syscall
move $t0,$v0
li $v0,4
la $a0,msg1
syscall
li $v0,4
la $a0,answer
syscall
addi $t1,$t0,4
li $v0,4
la $a0,msg2
syscall
li $v0,1
move $a0,$t1
syscall
li $v0,4
la $a0,msg3
syscall
li $v0,10
syscall
.data
prompt1: .asciiz "What is your name?"
prompt2: .asciiz "What is your age?"
msg1: .asciiz "Hello, "
msg2: .asciiz "You will be "
msg3: .asciiz " years old in four years\n"
answer: .space 51
alength: .word 50
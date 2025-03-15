.text
main:
addi $s0, $zero, 0 #A pointer
addi $s1, $zero, 0 #B pointer
addi $s2, $zero, 0 #A/B_4_x_$ offset
addi $s3, $zero, 0 #parse_loop iterator, int j = 0;
addi $s4, $zero, 0 #C pointer

addi $sp, $sp, -20 #make room for 5 ints

parse_loop:

addi $t0, $zero, 0 #load_A iterator, int y = 0;
addi $s2, $zero, 0 #A/B_4_x_4 pointer reset
#------A
load_A:
la $t1, A
add $t1, $t1, $s0

la $t6, A_4_x_4
add $t6, $t6, $s2

lw $t2, 0($t1)
lw $t3, 4($t1)
lw $t4, 8($t1)
lw $t5, 12($t1)

sw $t2, 0($t6)
sw $t3, 4($t6)
sw $t4, 8($t6)
sw $t5, 12($t6)

addi $t0, $t0, 1
addi $s2, $s2, 16
addi $s0, $s0, 32 

blt $t0, 4, load_A
#-----A

addi $t0, $zero, 0 #load_B iterator, int y = 0;
addi $s2, $zero, 0 #A/B_4_x_4 pointer reset

#------B
load_B:
la $t1, B
add $t1, $t1, $s1

la $t6, B_4_x_4
add $t6, $t6, $s2

lw $t2, 0($t1)
lw $t3, 4($t1)
lw $t4, 8($t1)
lw $t5, 12($t1)

sw $t2, 0($t6)
sw $t3, 4($t6)
sw $t4, 8($t6)
sw $t5, 12($t6)

addi $t0, $t0, 1
addi $s2, $s2, 16
addi $s1, $s1, 32 

blt $t0, 4, load_B
#-----B
#-----STACK-----#
sw $s0, 0($sp)
sw $s1, 4($sp)
sw $s2, 8($sp)
sw $s3, 12($sp)
sw $s4, 16($sp)
#-----STACK-----#
#----------MATRIX_MULT
matrix_mult:
addi $s0, $zero, 0 #int i = 0; C offset
addi $s1, $zero, 0 #int j = 0; A offset
addi $s2, $zero, 0 #int k = 0; B offset
addi $s3, $zero, 0 #int t = 0; outside_loop counter
addi $s5, $zero, 0 #B address shift

outside_loop:
la $t0, C_4_x_4
add $t0, $t0, $s0 #add C ofFset

addi $s4, $zero, 0 #int x = 0; inside_loop counter
#-----------------------
inside_loop:
lw $t1, ($t0) #C[i]

la $t2, A_4_x_4
add $t2, $t2, $s1 #add offset
lw $t3, ($t2)

la $t5, B_4_x_4
add $t5, $t5, $s5 #shift to correct column
add $t5, $t5, $s2
lw $t4, ($t5)

mul $t3, $t3, $t4
add $t1, $t1, $t3

sw $t1, ($t0)

addi $s1, $s1, 4 #A offset
addi $s2, $s2, 16 #B offset
addi $s4, $s4, 1 #insdide loop x++

blt $s4, 4, inside_loop
#----------------------
addi $s0, $s0, 4 #next C element
addi $s1, $zero, 0 #reset A offset
addi $s2, $zero, 0 #reset B offset
addi $s3, $s3, 1 #t++
addi $s5, $s5, 4 #next B colum

blt $s3, 4, outside_loop

addi $s1, $zero, 16
addi $s2, $s2, -16
blt $s3, 8, outside_loop

addi $s1, $zero, 32
addi $s2, $s2, -16
blt $s3, 12, outside_loop

addi $s1, $zero, 48
addi $s2, $s2, -16
blt $s3, 16, outside_loop
#----------MATRIX_MULT
#-----STACK-----#
lw $s0, 0($sp)
lw $s1, 4($sp)
lw $s2, 8($sp)
lw $s3, 12($sp)
lw $s4, 16($sp)
#-----STACK-----#
#-----C[]-----#
addi $t0, $zero, 0 #ADD_MATRIX iterator
addi $t1, $zero, 0 #C_4_x_4 pointer
ADD_MATRIX:
la $t2, C
add $t2, $t2, $s4

la $t3, C_4_x_4
add $t3, $t3, $t1

lw $t4, 0($t3)
lw $t5, 4($t3)
lw $t6, 8($t3)
lw $t7, 12($t3)

sw $t4, 0($t2)
sw $t5, 4($t2)
sw $t6, 8($t2)
sw $t7, 12($t2)

addi $t0, $t0, 1 #i++
addi $t1, $t1, 16
addi $s4, $s4, 32

blt $t0, 4, ADD_MATRIX
#-----C[]-----#

addi $s0, $zero, 16
addi $s1, $zero, 128
addi $s3, $s3, 1
addi $s4, $zero, 0
blt $s3, 2, parse_loop

bgt $s3, 2, next1 
jal zero

next1:
addi $s0, $zero, 0
addi $s1, $zero, 16
addi $s4, $zero, 16
blt $s3, 3, parse_loop

addi $s0, $zero, 16
addi $s1, $zero, 144
blt $s3, 4, parse_loop

bgt $s3, 4, next2 
jal zero

next2:
addi $s0, $zero, 128
addi $s1, $zero, 0
addi $s4, $zero, 128
blt $s3, 5, parse_loop

addi $s0, $zero, 144
addi $s1, $zero, 128
blt $s3, 6, parse_loop

bgt $s3, 6, next3 
jal zero

next3:
addi $s0, $zero, 128
addi $s1, $zero, 16
addi $s4, $zero, 144
blt $s3, 7, parse_loop

addi $s0, $zero, 144
addi $s1, $zero, 144
blt $s3, 8, parse_loop
#----------------exit-----------------------#
exit:
li $v0, 10
syscall
#-------------------------------------------#
#-----ZERO-C------#
zero:

addi $t0, $zero, 0 #iterator
addi $t1, $zero, 0 #pointer
zero_loop:
la $t2, C_4_x_4
add $t2, $t2, $t1

sw $zero, ($t2)

addi $t0, $t0, 1 #i++
addi $t1, $t1, 4 #increment pointer
blt $t0, 16, zero_loop
jr $ra
#------ZERO-C-----#

.data
C: .word 0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
C_4_x_4: .space 64
A_4_x_4: .space 64
B_4_x_4: .space 64
A: .word 0,1,2,3,4,5,6,7,8,9,10,11,12,13,14,15,16,17,18,19,20,21,22,23,24,25,26,27,28,29,30,31,32,33,34,35,36,37,38,39,40,41,42,43,44,45,46,47,48,49,50,51,52,53,54,55,56,57,58,59,60,61,62,63
B: .word 0,1,2,3,4,5,6,7,8,9,10,11,12,13,14,15,16,17,18,19,20,21,22,23,24,25,26,27,28,29,30,31,32,33,34,35,36,37,38,39,40,41,42,43,44,45,46,47,48,49,50,51,52,53,54,55,56,57,58,59,60,61,62,63
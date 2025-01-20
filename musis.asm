la $t0, notes
lw $t1, num_notes
li $t2, 4

loop:
    beq $t1, 0, exit
    lw $a0, 0($t0)
    lw $a1, 4($t0)
    lw $a2, 8($t0)
    lw $a3, 12($t0)
    li $v0, 33
    syscall
    addi $t0, $t0, 16
    subi $t1, $t1, 1
    j loop

.data
notes: .word 60, 300, 1, 100
       .word 62, 400, 1, 100
       .word 64, 200, 1, 100
       .word 66, 500, 1, 100
       .word 68, 300, 1, 100
       .word 70, 400, 1, 100
       .word 72, 200, 1, 100
       .word 74, 500, 1, 100
       .word 76, 300, 1, 100
       .word 78, 400, 1, 100
       .word 80, 200, 1, 100
       .word 85, 200, 1, 100
       .word 90, 200, 1, 100
num_notes: .word 14

exit:
    li $v0, 10
    syscall

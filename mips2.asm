.data
notes: .word 60, 500, 1, 100    # Middle C, duration 500ms, instrument 1 (piano), volume 100
       .word 62, 500, 1, 100    # D
       .word 64, 500, 1, 100    # E
       .word 65, 500, 1, 100    # F
       .word 67, 500, 1, 100    # G
       .word 69, 500, 1, 100    # A
       .word 71, 500, 1, 100    # B
       .word 72, 500, 1, 100    # High C
       .word 71, 500, 1, 100    # B
       .word 69, 500, 1, 100    # A
       .word 67, 500, 1, 100    # G
       .word 65, 500, 1, 100    # F
num_notes: .word 12             # Total number of notes

.text
.globl main
main:
    la $t0, notes           # Load base address of notes array into $t0
    lw $t1, num_notes       # Load the number of notes into $t1
    li $t2, 4               # Constant for word size

loop:
    beq $t1, 0, exit        # Exit loop if all notes are played
    lw $a0, 0($t0)          # Load pitch from the array
    lw $a1, 4($t0)          # Load duration from the array
    lw $a2, 8($t0)          # Load instrument from the array
    lw $a3, 12($t0)         # Load volume from the array
    li $v0, 33              # MIDI out synchronous system call
    syscall
    addi $t0, $t0, 16       # Move to the next set of note parameters
    subi $t1, $t1, 1        # Decrement note counter
    j loop                  # Repeat for the next note

exit:
    li $v0, 10              # Exit program
    syscall

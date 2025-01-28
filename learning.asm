.data
prompt_x: .asciiz "Enter value for x: "
prompt_y: .asciiz "Enter value for y: "
prompt_z: .asciiz "Enter value for z: "
prompt_q: .asciiz "Enter value for q: "
result_msg: .asciiz "The result is: "

.text
.globl main

main:
    # Prompt and read input for x
    li $v0, 4              # Syscall to print string
    la $a0, prompt_x       # Load address of prompt for x
    syscall

    li $v0, 5              # Syscall to read integer
    syscall
    move $s1, $v0          # Store input in $s1 (x)

    # Prompt and read input for y
    li $v0, 4
    la $a0, prompt_y
    syscall

    li $v0, 5
    syscall
    move $s2, $v0          # Store input in $s2 (y)

    # Prompt and read input for z
    li $v0, 4
    la $a0, prompt_z
    syscall

    li $v0, 5
    syscall
    move $s3, $v0          # Store input in $s3 (z)

    # Prompt and read input for q
    li $v0, 4
    la $a0, prompt_q
    syscall

    li $v0, 5
    syscall
    move $s4, $v0          # Store input in $s4 (q)

    # Perform x = x + y - z + q
    add $s1, $s1, $s2      # $s1 = x + y
    sub $s1, $s1, $s3      # $s1 = (x + y) - z
    add $s1, $s1, $s4      # $s1 = (x + y - z) + q

    # Print the result
    li $v0, 4              # Syscall to print string
    la $a0, result_msg     # Load address of result message
    syscall

    li $v0, 1              # Syscall to print integer
    move $a0, $s1          # Move result into $a0
    syscall

    # Exit program
    li $v0, 10             # Syscall to exit
    syscall

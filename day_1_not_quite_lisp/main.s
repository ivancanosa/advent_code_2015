# --- Day 1: Not Quite Lisp ---
# Santa was hoping for a white Christmas, but his weather machine's "snow"
# function is powered by stars, and he's fresh out! To save Christmas, he needs
# you to collect fifty stars by December 25th.
#
# Collect stars by helping Santa solve puzzles. Two puzzles will be made
# available on each day in the Advent calendar; the second puzzle is unlocked
# when you complete the first. Each puzzle grants one star. Good luck!
#
# Here's an easy puzzle to warm you up.
#
# Santa is trying to deliver presents in a large apartment building, but he
# can't find the right floor - the directions he got are a little confusing. He
# starts on the ground floor (floor 0) and then follows the instructions one
# character at a time.
#
# An opening parenthesis, (, means he should go up one floor, and a closing
# parenthesis, ), means he should go down one floor.
#
# The apartment building is very tall, and the basement is very deep; he will
# never find the top or bottom floors.
#
# For example:
#
# (()) and ()() both result in floor 0.
# ((( and (()(()( both result in floor 3.
# ))((((( also results in floor 3.
# ()) and ))( both result in floor -1 (the first basement level).
# ))) and )())()) both result in floor -3.
# To what floor do the instructions take Santa?
#
#
# --- Part Two ---
# Now, given the same instructions, find the position of the first character
# that causes him to enter the basement (floor -1). The first character in the
# instructions has position 1, the second character has position 2, and so on.
#
# For example:
#
# ) causes him to enter the basement at character position 1.
# ()()) causes him to enter the basement at character position 5.
# What is the position of the character that causes Santa to first enter the
# basement?


.include "linux.s"

.section .data
filename: .asciz "input"

.section .bss
.equ BUFFER_SIZE, 4096
.lcomm buffer, BUFFER_SIZE




############################## _start ########################################

.section .text
.globl _start

# Local variables
.equ ST_INPUT_FD, -4
.equ ST_CHAR_COUNT, -8
.equ ST_FLOOR, -12
.equ ST_BASEMENT_TRIGGER, -16
.equ ST_CURRENT_CHAR, -20

# VARIABLES:
#       %ecx - Iterator over the buffer
#       %dl  - Stores current character
# Start function
_start:
movl %esp, %ebp
subl $20, %esp # Allocate space for local variables

# Init local variables
movl $0, ST_FLOOR(%ebp)            # We start at floor 0
movl $0, ST_BASEMENT_TRIGGER(%ebp) # 0 to indicate that we haven't found a solution
movl $1, ST_CURRENT_CHAR(%ebp)     # Our position in the input

# Syscall open file
movl $SYS_OPEN, %eax
movl $filename, %ebx
movl $O_RDONLY, %ecx
movl $0666    , %edx
int  $LINUX_SYSCALL
movl %eax, ST_INPUT_FD(%ebp) # Save input file descriptor

read_file:
# Syscall read file
movl $SYS_READ        , %eax
movl ST_INPUT_FD(%ebp), %ebx
movl $buffer          , %ecx
movl $BUFFER_SIZE     , %edx # Buffer size
int  $LINUX_SYSCALL

# Jump to end if EOF
cmpl $0, %eax
je computation_end

# Otherwise, save readed bytes
movl %eax, ST_CHAR_COUNT(%ebp)

# Init character counter to 0
movl $0, %ecx

# loop over all chars of the buffer
loop:
# Jump to end if we read all characters
cmpl ST_CHAR_COUNT(%ebp), %ecx
jge loop_end

# Retrieves current char
movb buffer(,%ecx, 1), %dl

# Init %eax
movl $0, %eax

# Check if should go up stairs
cmpb $'(', %dl
sete %al   # %al is 1 if we have '(', 0 otherwise
addl %eax, ST_FLOOR(%ebp)

# Check if should go down stairs
cmpb $')', %dl
sete %al   # %al is 1 if we have ')', 0 otherwise
subl %eax, ST_FLOOR(%ebp)

# Check if we already found a solution to problem 2
cmpl $0, ST_BASEMENT_TRIGGER(%ebp)
jne loop_next 

# Check if current basement is -1
cmpl $-1, ST_FLOOR(%ebp)
je found_trigger
jmp loop_next

found_trigger:
# We found a solution to problem 2, save current character position
movl ST_CURRENT_CHAR(%ebp), %eax
movl %eax, ST_BASEMENT_TRIGGER(%ebp)

loop_next:
incl %ecx
incl ST_CURRENT_CHAR(%ebp)
jmp loop

loop_end:
jmp read_file

computation_end:

# Print solution
pushl ST_BASEMENT_TRIGGER(%ebp)
pushl ST_FLOOR(%ebp)
call print_solution
addl $8, %esp

# Exit
movl $SYS_EXIT, %eax
movl $0, %ebx
int  $LINUX_SYSCALL



######################### print_solution ######################################
#
# PURPOSE: Prints the solution to stdout
# INPUT:   - Solution to problem 1
#          - Solution to problem 2
# OUTPUT:  Nothing

.section .data
str_problem1: .asciz "problem 1 solution: %i\n"
str_problem2: .asciz "problem 2 solution: %i\n"

.section .text
.equ ST_SOLUTION_1, 8
.equ ST_SOLUTION_2, 12

print_solution:
pushl %ebp
movl %esp, %ebp

# Print solution 1
pushl ST_SOLUTION_1(%ebp)
pushl $str_problem1
call printf
addl $8, %esp

# Print solution 2
pushl ST_SOLUTION_2(%ebp)
pushl $str_problem2
call printf
addl $8, %esp

# Return 
movl %ebp, %esp
popl %ebp
ret

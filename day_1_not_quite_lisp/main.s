.include "linux.s"

.section .data
filename: .asciz "input"
str: .asciz "%i\n"

.section .bss
.equ BUFFER_SIZE, 4096
.lcomm buffer, BUFFER_SIZE


.section .text
.globl _start

# Local variables
.equ ST_INPUT_FD, -4
.equ ST_CHAR_COUNT, -8
.equ ST_FLOOR, -12

# VARIABLES:
#       %ecx - Iterator over the buffer
#       %dl  - Stores current character
# Start function
_start:
movl %esp, %ebp
subl $4, %esp # Allocate space for local variables

# Init local variables
movl $0, ST_FLOOR(%ebp)

# Syscall open file
movl $SYS_OPEN, %eax
movl $filename, %ebx
movl $O_RDONLY, %ecx
movl $0666     , %edx
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

# loop over all chars of the buffer
movl $0, %ecx

loop:
# Jump to end if we readed all characters
cmpl ST_CHAR_COUNT(%ebp), %ecx
jge loop_end

# Retrieves current char
movb buffer(,%ecx, 1), %dl

# Test character
cmpb $'(', %dl
je up
cmpb $')', %dl
je down
jmp loop_next

up:
incl ST_FLOOR(%ebp)
jmp loop_next

down:
decl ST_FLOOR(%ebp)
jmp loop_next

loop_next:
incl %ecx
jmp loop

loop_end:
jmp read_file

computation_end:
# Print result
pushl ST_FLOOR(%ebp)
pushl $str
call printf
addl $8, %esp

# Exit
movl $SYS_EXIT, %eax
movl ST_FLOOR(%ebp), %ebx
int  $LINUX_SYSCALL

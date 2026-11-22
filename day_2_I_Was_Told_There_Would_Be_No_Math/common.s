.include "linux.s"

############################### exit #########################################
#
# PURPOSE:  Exits the program
# INPUT:    - Error code
# OUTPUT:   Nothing

.section .text
.globl exit

exit:
movl $SYS_EXIT, %eax
movl 4(%esp)  , %ebx  # The error code input argument
int  $LINUX_SYSCALL

############################### open_file #####################################
#
# PURPOSE:  Opens a file for reading into a file descriptior
# INPUT:    - A file name
# OUTPUT:   - The file descriptor

.section .text
.globl open_file
.local open_file_success

open_file:
pushl %ebp
movl %esp, %ebp

# Save registers state
pushl %ebx
pushl %ecx
pushl %edx

# Syscall to open a file for reading
movl $SYS_OPEN, %eax
movl 8(%ebp)  , %ebx  # The filename argument
movl $O_RDONLY, %ecx
movl $0666    , %edx
int  $LINUX_SYSCALL

# Check of there has been an error opening the file
cmpl $0, %eax
jge open_file_success

# There has been an error opening the file
pushl %eax
call exit

open_file_success:
# Retrieve registers state
popl %edx
popl %ecx
popl %ebx

# Return, the file descriptor is already in %eax
movl %ebp, %esp
popl %ebp
ret

############################### getline #######################################
#
# PURPOSE:  Reads a line from a file descriptor
# INPUT:    - A file descriptor
#           - A buffer where to write
#           - The size of the buffer
# OUTPUT:   The line written to the buffer. In %eax there is 0 if nothing
#           happened, EOF if there is no more to write, and something else
#           if there has been an error.
# VARIABLES:
#       - %ecx: How many characters have been read
#       - %ebx: Current position in the buffer

.section .text
.globl getline
.local getline_loop, getline_eof, getline_loop_end, getline_return

.equ GETLINE_ST_FD, 8
.equ GETLINE_ST_BUFFER, 12
.equ GETLINE_ST_BSIZE, 16

getline:
pushl %ebp
movl  %esp, %ebp

# Save registers state
pushl %ebx
pushl %ecx
pushl %edx

# Init registers
movl GETLINE_ST_BUFFER(%ebp), %ebx
movl $0, %ecx
decl GETLINE_ST_BSIZE(%ebp)  # We reserve 1 byte for '\0' 
                             # from the buffer

getline_loop:
# Check if we filled the buffer
cmpl GETLINE_ST_BSIZE(%ebp), %ecx
jge getline_loop_end

# Retrieve a character
pushl GETLINE_ST_FD(%ebp)
call getchar
addl $4, %esp

# Check if we reached EOF
cmpl $EOF, %eax
je  getline_eof

# Check if it is a newline character
cmpb $'\n', %al
je getline_loop_end

# Append the character to the buffer
movb %al, (%ebx)

incl %ebx # Go next position in the buffer
incl %ecx # Increase character count
jmp getline_loop

getline_eof:
movl $EOF, %eax
jmp getline_return

getline_loop_end:
movb $0, (%ebx) # Append the end of string
movl $0, %eax   # Return value OK
# continue ahead

getline_return:
# Retrieve registers state
popl %edx
popl %ecx
popl %ebx

movl %ebp, %esp
popl %ebp
ret


############################### getchar ####################################
#
# PURPOSE:  Reads the next character of a file descriptor
# INPUT:    - A file descriptor
# OUTPUT:   A character or EOF

.section .data
getchar_current:       .long 0  # Our current position in the buffer
getchar_buffer_length: .long 0  # The number of characters inside the buffer

.section .bss
.equ GETCHAR_BUFFER_SIZE, 4096
.lcomm getchar_buffer, GETCHAR_BUFFER_SIZE

.section .text
.globl getchar
.local getchar_error, getchar_read_success, getchar_read_from_buffer
.local getchar_eof, getchar_return

.equ GETCHAR_ST_FD, 8 # File descriptor argument

getchar:
pushl %ebp
movl  %esp, %ebp

# Save registers state
pushl %ebx
pushl %ecx
pushl %edx

# Check if we should perform a read syscall
movl getchar_current, %edx
cmpl getchar_buffer_length, %edx
jl getchar_read_from_buffer

# Syscall read
movl $SYS_READ           , %eax
movl GETCHAR_ST_FD(%ebp) , %ebx
movl $getchar_buffer     , %ecx
movl $GETCHAR_BUFFER_SIZE, %edx
int  $LINUX_SYSCALL

# Check for EOF or error from the syscall
cmp $0, %eax
je getchar_eof
jl getchar_error
jmp getchar_read_success

# There has been an error during the read
getchar_error:
pushl %eax
call exit

getchar_read_success:
# Save how many characters we read from the file descriptor
movl %eax, getchar_buffer_length
movl $0, getchar_current
# continue ahead

# Read a single character from the buffer
getchar_read_from_buffer:
xorl %eax, %eax  # Init %eax
movl getchar_current         , %ecx
movb getchar_buffer(,%ecx, 1), %al # Load the character into first byte of %eax
incl getchar_current  # Increase current character position
jmp getchar_return

getchar_eof:
movl $EOF, %eax
# continue ahead

getchar_return:
# Retrieve registers state
popl %edx
popl %ecx
popl %ebx

movl %ebp, %esp
popl %ebp
ret

############################## isdigit ########################################
# PURPOSE:  Checks if a character is a digit or not
# INPUT:    - %eax The character to check in its first byte %al
# OUTPUT:   - 1 or 0 in %eax
.section .text
.globl isdigit
.local isdigit_true

isdigit:
# Creck if %al is a character between '0' and '9'
cmpb $'0', %al
jl isdigit_false
cmpb $'9', %al
jg isdigit_false

# The character is a number, return 1
movl $1, %eax
ret

isdigit_false:
# The character is not a number, return 0
movl $0, %eax
ret


############################## stoi ###########################################
# PURPOSE:  Transforms a string that has a number, into an actual number. The
#           end of the string is any character that is not a number
# INPUT:    - A string
# OUTPUT;   - The parsed number
# VARIABLES:
#       - %al the current digit
#       - %ebx a pointer to current position in the string
#       - %ecx the result number

.section .text
.globl stoi
.local stoi_loop, stoi_end, stoi_return

stoi:
pushl %ebp
movl  %esp, %ebp
pushl %ebx
pushl %ecx
pushl %edx

# Init registers
movl $0     , %eax
movl $0     , %ecx
movl 8(%ebp), %ebx # The input string
movl $0     , %edx

stoi_loop:
movl $0, %eax
movb (%ebx), %al # Get next number

# Check if next character is a number
movb (%ebx), %al # Get next number
call isdigit
cmpb $0, %al
je stoi_end

# The next character is a number, so add it
imul $10, %ecx # Shift digits of current number to the left
xorl %eax, %eax
movb (%ebx), %al
subb $'0', %al
addl %eax, %ecx

# To next loop
incl %ebx
jmp stoi_loop

stoi_end:
movl %ecx, %eax
# continue ahead

stoi_return:
popl %edx
popl %ecx
popl %ebx
movl %ebp, %esp
popl %ebp
ret

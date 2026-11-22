# --- Day 2: I Was Told There Would Be No Math ---
# The elves are running low on wrapping paper, and so they need to submit an
# order for more. They have a list of the dimensions (length l, width w, and
# height h) of each present, and only want to order exactly as much as they
# need.
#
# Fortunately, every present is a box (a perfect right rectangular prism),
# which makes calculating the required wrapping paper for each gift a little
# easier: find the surface area of the box, which is 2*l*w + 2*w*h + 2*h*l. The
# elves also need a little extra paper for each present: the area of the
# smallest side.
#
# For example:
#
# - A present with dimensions 2x3x4 requires 2*6 + 2*12 + 2*8 = 52 square feet
# of wrapping paper plus 6 square feet of slack, for a total of 58 square feet.
# - A present with dimensions 1x1x10 requires 2*1 + 2*10 + 2*10 = 42 square
# feet of wrapping paper plus 1 square foot of slack, for a total of 43 square
# feet.
#
# All numbers in the elves' list are in feet. How many total square feet of
# wrapping paper should they order?
#
# --- Part Two ---
# The elves are also running low on ribbon. Ribbon is all the same width, so
# they only have to worry about the length they need to order, which they would
# again like to be exact.
#
# The ribbon required to wrap a present is the shortest distance around its
# sides, or the smallest perimeter of any one face. Each present also requires
# a bow made out of ribbon as well; the feet of ribbon required for the perfect
# bow is equal to the cubic feet of volume of the present. Don't ask how they
# tie the bow, though; they'll never tell.
#
# For example:
#
# - A present with dimensions 2x3x4 requires 2+2+3+3 = 10 feet of ribbon to
# wrap the present plus 2*3*4 = 24 feet of ribbon for the bow, for a total of
# 34 feet.
# - A present with dimensions 1x1x10 requires 1+1+1+1 = 4 feet of ribbon to
# wrap the present plus 1*1*10 = 10 feet of ribbon for the bow, for a total of
# 14 feet. 
#
# How many total feet of ribbon should they order?



.include "linux.s"

.section .data
str: .asciz "|%i|\n"
str_input: .asciz "input"
str_triplet: .asciz "%i %i %i\n"

triplet: .long 0, 0, 0 # This is were the three parsed number will be stored

.section .bss
.equ BUFFER_SIZE, 4096
.lcomm buffer, BUFFER_SIZE

.section .text
.globl _start

_start:
movl %esp, %ebp

# Open fd
pushl $str_input
call open_file
addl $4, %esp

movl %eax, %ebx # save fd into %ebx

loop:
# Read a line
pushl $BUFFER_SIZE
pushl $buffer
pushl %ebx
call getline
addl $12, %esp

cmpl $EOF, %eax
je loop_end

# Get the number
pushl $buffer
call parse_triplet
addl $4, %esp

# Print the number
pushl 8 + triplet
pushl 4 + triplet
pushl triplet
pushl $str_triplet
call printf
addl $8, %esp

jmp loop

loop_end:

# Exit
pushl $0
call exit


############################ parse_triplet ####################################
# PURPOSE:  Takes a string as input and outputs the three numbers that 
#           it finds as global state.
# INPUT:    - A string
# OUTPUT:   - Writes the three numbers in the global triplet address
# VARIABLES:
#       - global triplet as output parameter
#       - %ebx the pointer to current character
#       - %ecx triplet offset

.section .text

parse_triplet:
pushl %ebp
movl  %esp, %ebp
pushl %ebx
pushl %ecx

# Init registers
movl 8(%ebp), %ebx
movl $0     , %ecx

parse_triplet_loop:
# Parse number
pushl %ebx
call stoi
addl $4, %esp
movl %eax, triplet(, %ecx, 4) # save into the triplet

# Check if we finished the triplet
cmpl $2, %ecx
je parse_triplet_end 

incl %ecx  # Shift offset to next value in the triplet

# Advance pointer until it reaches the character 'x'
parse_triplet_find_x:
incl %ebx
cmpb $'x', (%ebx)
jne parse_triplet_find_x

incl %ebx  # We increase again to be in the first digit of next number
jmp parse_triplet_loop


parse_triplet_end:
movl $0, %eax

popl %ecx
popl %ebx
movl %ebp, %esp
popl %ebp
ret

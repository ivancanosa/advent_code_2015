# ------ Common Linux Definitions ------

# -- System Call Numbers --
.equ SYS_EXIT  , 1
.equ SYS_READ  , 3
.equ SYS_WRITE , 4
.equ SYS_OPEN  , 5
.equ SYS_CLOSE , 6
.equ SYS_LSEEK , 19
.equ SYS_BRK   , 45

# -- System Call Interrupt Number --
.equ LINUX_SYSCALL, 0x80

# -- Standard File Descriptors --
.equ STDIN , 0
.equ STDOUT, 1
.equ STDERR, 2

# -- Symbols File permissions
.equ O_RDONLY , 0
.equ O_WRONLY , 1
.equ O_RDWR   , 2
.equ O_ACCMODE, 3

.equ O_CREAT     ,1 << 6	
.equ O_EXCL	     ,1 << 7	
.equ O_TRUNC     ,1 << 9	
.equ O_APPEND    ,1 << 10
.equ O_NONBLOCK	 ,1 << 11
.equ O_DSYNC     ,1 << 12	
.equ FASYNC	     ,1 << 13	
.equ O_DIRECT    ,1 << 14	
.equ O_LARGEFILE ,1 << 15
.equ O_DIRECTORY ,1 << 16	
.equ O_NOFOLLOW	 ,1 << 17	
.equ O_NOATIME   ,1 << 18
.equ O_CLOEXEC   ,1 << 19	


# -- Common Status Codes --
.equ EOF, -1

# -- Symbols lseek --
.equ SEEK_SET, 0 # Seek from beginning of file
.equ SEEK_CUR, 1 # Seek from current position
.equ SEEK_END, 2 # Seek from end of file


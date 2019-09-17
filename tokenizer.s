
#=========================================================================
# Tokenizer
#=========================================================================
# Split a string into alphabetic, punctuation and space tokens
# 
# Inf2C Computer Systems
# 
# Siavash Katebzadeh
# 8 Oct 2018
# 
#
#=========================================================================
# DATA SEGMENT
#=========================================================================
.data
#-------------------------------------------------------------------------
# Constant strings
#-------------------------------------------------------------------------

input_file_name:        .asciiz  "input.txt"   
newline:                .asciiz  "\n"
        
#-------------------------------------------------------------------------
# Global variables in memory
#-------------------------------------------------------------------------
# 
content:                .space 2049     # Maximun size of input_file + NULL


# You can add your data here!

#=========================================================================
# TEXT SEGMENT  
#=========================================================================
.text

#-------------------------------------------------------------------------
# MAIN code block
#-------------------------------------------------------------------------

.globl main                     # Declare main label to be globally visible.
                                # Needed for correct operation with MARS
main:
        
#-------------------------------------------------------------------------
# Reading file block. DO NOT MODIFY THIS BLOCK
#-------------------------------------------------------------------------

# opening file for reading

        li   $v0, 13                    # system call for open file
        la   $a0, input_file_name       # input file name
        li   $a1, 0                     # flag for reading
        li   $a2, 0                     # mode is ignored
        syscall                         # open a file
        
        move $s0, $v0                   # save the file descriptor 

# reading from file just opened

        move $t0, $0                    # idx = 0

READ_LOOP:                              # do {
        li   $v0, 14                    # system call for reading from file
        move $a0, $s0                   # file descriptor
                                        # content[idx] = c_input
        la   $a1, content($t0)          # address of buffer from which to read
        li   $a2,  1                    # read 1 char
        
                        syscall                         # c_input = fgetc(input_file);
        blez $v0, END_LOOP              # if(feof(input_file)) { break }
        lb   $t1, content($t0)          
        addi $v0, $0, 10                # newline \n
        beq  $t1, $v0, END_LOOP         # if(c_input == '\n')
        addi $t0, $t0, 1                # idx += 1
        j    READ_LOOP
END_LOOP:
        sb   $0,  content($t0)

        li   $v0, 16                    # system call for close file
        move $a0, $s0                   # file descriptor to close
        syscall                         # fclose(input_file)
#------------------------------------------------------------------
# End of reading file block.
#------------------------------------------------------------------

#ASCII for ' ' = 32, ',' = 44,'.' = 46,'?' = 63, '!' = 33, 'A' = 65, newline = 10
#The ASCII values were loaded into a temporary register and this register was used for comparisons whenever ASCII values had to be compared

        move $s0, $0                    #loading index value 0 into $s0
        lb   $s1, content               #loading address of content into $s1
tokenizer:
        li      $t9, 65
        bge     $s1, $t9, character_loop          #element of contents array compared to ASCII character 'A'. Jump to character loop
        li      $t9, 33
        beq     $s1, $t9, punctuation_loop        #element of contents array compared to '!', ',', '?', '.'. Jump to punctuation loop
        li      $t9, 44                  
        beq     $s1, $t9, punctuation_loop
        li      $t9, 46       
        beq     $s1, $t9, punctuation_loop
        li      $t9, 63
        beq     $s1, $t9, punctuation_loop       
        li      $t9, 32
        beq     $s1, $t9, space_loop              #element of contents array compared to '[space]'. Jump to space loop     
        beq     $s1, $0, main_end                 #end program once reaching the end of the contents array


character_loop:  
        li      $v0, 11                 #telling MIPS what system call to do
        move    $a0, $s1                #moving value in $s1 register (character) to $a0 for syscall
        syscall                         #printing value in $a0
        
        addi    $s0, $s0, 1             #adding to index
        lb      $s1, content($s0)       #loading next element of content into $s1
        li      $t9, 65
        bge     $s1, $t9, character_loop         #loop if next character is alphabetic

	addi    $t1, $s0, 1             #increment $s0 for end of input check
        lb      $t2, content($s0)       #load character into $t2
        beq     $t2, $0, tokenizer	#if current character ($s1, not $t2) is last one in input and go back to tokenizer so no extra newline printed
        
        li      $v0, 11                 #telling MIPS what system call to do
        li      $a0, 10                 #loading newline into $a0
        syscall                         #printing newline
		
        j tokenizer                     #jump back to tokenizer to print next token
	
punctuation_loop:
        li      $v0, 11                 #punctuation loop is the same as cloop but checks for the punctuation instead of alphatbetic characters
        move    $a0, $s1                
        syscall                         
        addi    $s0, $s0, 1
        lb      $s1, content($s0)
        li      $t9, 33
        beq     $s1, $t9, punctuation_loop        #element of contents array compared to '!', ',', '?', '.'. Jump to punctuation loop
        li      $t9, 44                  
        beq     $s1, $t9, punctuation_loop
        li      $t9, 46       
        beq     $s1, $t9, punctuation_loop
        li      $t9, 63
        beq     $s1, $t9, punctuation_loop
        
        addi    $t1, $s0, 1
        lb      $t2, content($s0)
        beq     $t2, $0, tokenizer
        li      $v0, 11                 
        li      $a0, 10               
        syscall                         
		
        j tokenizer
	
space_loop:
        li      $v0, 11                 #space loop is the same as cloop but checks for spaces to loop the printing rather than for alphabetic characters
        move    $a0, $s1                
        syscall                         
        
        addi    $s0, $s0, 1
        lb      $s1, content($s0)
        li      $t9, 32 
        beq     $s1, $t9, space_loop         #loop back to start of space loop
        
        addi    $t1, $s0, 1
        lb      $t2, content($s0)
        beq     $t2, $0, tokenizer
        li      $v0, 11                 
        li      $a0, 10               
        syscall                         
	
        j tokenizer

#------------------------------------------------------------------
# Exit, DO NOT MODIFY THIS BLOCK
#------------------------------------------------------------------
main_end:      
        li   $v0, 10          # exit()
        syscall

#----------------------------------------------------------------
# END OF CODE
#----------------------------------------------------------------

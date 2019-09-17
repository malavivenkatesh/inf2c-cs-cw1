
#=========================================================================
# Spell checker 
#=========================================================================
# Marks misspelled words in a sentence according to a dictionary
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
dictionary_file_name:   .asciiz  "dictionary.txt"
newline:                .asciiz  "\n"
        
#-------------------------------------------------------------------------
# Global variables in memory
#-------------------------------------------------------------------------
# 
content:                .space 2049     # Maximun size of input_file + NULL
.align 4                                # The next field will be aligned
dictionary:             .space 200001   # Maximum number of words in dictionary *
                                        # maximum size of each word + NULL

# You can add your data here!
#.align 2
#tokens                  .space 204
        
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
        sb   $0,  content($t0)          # content[idx] = '\0'

        # Close the file 

        li   $v0, 16                    # system call for close file
        move $a0, $s0                   # file descriptor to close
        syscall                         # fclose(input_file)


        # opening file for reading

        li   $v0, 13                    # system call for open file
        la   $a0, dictionary_file_name  # input file name
        li   $a1, 0                     # flag for reading
        li   $a2, 0                     # mode is ignored
        syscall                         # fopen(dictionary_file, "r")
        
        move $s0, $v0                   # save the file descriptor 

        # reading from file just opened

        move $t0, $0                    # idx = 0

READ_LOOP2:                             # do {
        li   $v0, 14                    # system call for reading from file
        move $a0, $s0                   # file descriptor
                                        # dictionary[idx] = c_input
        la   $a1, dictionary($t0)       # address of buffer from which to read
        li   $a2,  1                    # read 1 char
        syscall                         # c_input = fgetc(dictionary_file);
        blez $v0, END_LOOP2             # if(feof(dictionary_file)) { break }
        lb   $t1, dictionary($t0)                             
        beq  $t1, $0,  END_LOOP2        # if(c_input == '\0')
        addi $t0, $t0, 1                # idx += 1
        j    READ_LOOP2
END_LOOP2:
        sb   $0,  dictionary($t0)       # dictionary[idx] = '\0'

        # Close the file 

        li   $v0, 16                    # system call for close file
        move $a0, $s0                   # file descriptor to close
        syscall                         # fclose(dictionary_file)
#------------------------------------------------------------------
# End of reading file block.
#------------------------------------------------------------------

#ASCII for ' ' = 32, ',' = 44,'.' = 46,'?' = 63, '!' = 33, 'A' = 65, newline = 10
#The ASCII values were loaded into a temporary register and this register was used for comparisons whenever ASCII values had to be compared


        move $s0, $0                             #loading index value 0 into $s0
        lb   $s1, content                        #loading address of content into $s1

#tokenizer prints the tokens while going through the content array so there is no storage of tokens
tokenizer:
        li      $t9, 65
        bge     $s1, $t9, character          #element of contents array compared to ASCII character 'A'. Jump to character loop
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



character:  
        jal  spellchecker                        #jump to spellchecker function to check if alphatbetic token is in dictionary
        beqz $v0, not_word_print                 #$v0 returned by spellchecker and if it is 0, jump to section that prints underscores
                                                 #otherwise, continue and print without underscores
character_loop:
        lb      $s1, content($s0)
        li      $v0, 11                          #telling MIPS what system call to do
        move    $a0, $s1                         #moving value in $s1 register (character) to $a0 for syscall
        syscall                                  #printing value in $a0
        
        addi    $s0, $s0, 1                      #adding to index
        lb      $s1, content($s0)                #loading next element of content into $s1
        li      $t9, 65
        bge     $s1, $t9, character_loop         #loop with new character
		
        j tokenizer
	
punctuation_loop:                            
        li      $v0, 11                 
        move    $a0, $s1                
        syscall                         
        addi    $s0, $s0, 1
        lb      $s1, content($s0)
        li      $t9, 33
        beq     $s1, $t9, punctuation_loop       #loop punctuation loop
        li      $t9, 63        
        beq     $s1, $t9, punctuation_loop      
        li      $t9, 46
        beq     $s1, $t9, punctuation_loop
        li      $t9, 44
        beq     $s1, $t9, punctuation_loop
		
        j tokenizer
	
space_loop:
        li      $v0, 11                 
        move    $a0, $s1                
        syscall                         
        addi    $s0, $s0, 1
        lb      $s1, content($s0)
        li      $t9, 32
        beq     $s1, $t9, space_loop             #loop space loop

        j tokenizer
  
       
                 
spellchecker:
        move    $t1, $s0                         #$t1 is the token's character index
        move    $t2, $0                          #$t2 is the dictionary's character index
        li      $v0, 0                           #$v0 is the function's return value
        
spellloop:
        lb      $t3, dictionary($t2)             #load first char in dictionary to $t3
        beq     $t3, $0, end_spell_check       #end function if dictionary is empty
        lb      $t6, content($t1)                #load first alphabetical character from content array

        addi    $t1, $t1, 1                      #increment indexes
        addi    $t2, $t2, 1
        
        li      $t9, 10
        beq     $t3, $t9, newword               #if $t3 is a newline, the current dicionary word has ended
        bne     $t6, $t3, casechecker            #if the content and dictionary characters are not equal, check if they are not the same case
        lb      $t4, dictionary($t2)             #load the next dictionary character ($t2 was already incremented)
        li      $t9, 10
        beq     $t4, $t9, endchecker            #if the next character is empty, go to endchecker section
        j spellloop                              
        
endchecker:        
        li      $t9, 65                           
        lb      $t5, content($t1)                #load the next value of content into $t5
        
        slt     $v0, $t5, $t9                    #if $t5 < $t4 then the next character in content is not alphabetic and we have a match for a 
                                                 #word in the dictionary since the current dictionary word has ended (new line char needed to 
                                                 #jump to this function. Set result value to 1
                                                   
        bge     $t5, $t9 newline1                 #if the next character is alphabetic, jump to the next dictionary word since the current dictionary word is empty
        j end_spell_check                        #next char is not alphabetic so we have the end of the token and a match

newline1:                                        #get a new dictinary word
        move    $t1, $s0                         #set token index back to start of token 
        addi    $t2, $t2, 1                      #increment dictionary index by 1 since current character is a newline character
        j spellloop                              #jump to start of spellchecker loop
        
newword:
        addi     $t2, $t2, 1                     #increment dictionary index
        lb       $t3, dictionary($t2)
        li       $t9, 10
        beq      $t3, $t9, newline1             #if current dictionary character is newline jump to newline1
        beq      $t3, $0, end_spell_check        #if dictionary is empty, end
        j newword                                #dictionary character is not empty or newline, so keep incrementing
                
casechecker:                                     #checks for a character match with the dictionary if the token character is uppercase
        addi    $t6, $t6, 32                     #add 32 to token character to get lowercase version of it
        bne     $t6, $t3, newword                #if there is still no character match, jump to newword1 to get a new dictionary word
        lb      $t3, dictionary($t2)             #load next character of dictionary
        li      $t9, 10
        beq     $t3, $t9, endchecker            #if this is the newline char, check if the token has ended
        
        j spellloop                              #if next dictionary character is not a newline character, dictionary word has not ended so check
                                                 #the next characters in dictionary and token

end_spell_check:
        jr $ra                             
        
        
not_word_print:                                  #prints underscores before and after token if token is not a valid word
        li $a0, 95                              #print underscore
        li $v0, 11
        syscall
        
nwprintloop:                                     #new word print loop prints the current token character by character
        lb      $s1, content($s0)
        li      $v0, 11                 
        move    $a0, $s1                 
        syscall                         
        
        beqz    $s1, nw_print_end                #if input string is empty, jump to the section that prints the underscore
        addi    $s0, $s0, 1                      #index incremented before we jump back to tokenizer for next character
        lb      $s1, content($s0)      
        li      $t9, 65 
        bge     $s1, $t9, nwprintloop   
nw_print_end:
        li $a0, 95                              #print underscore after token
        li $v0, 11
        syscall
        
        j tokenizer                              #jump back to tokenizer to check next token
         
#------------------------------------------------------------------
# Exit, DO NOT MODIFY THIS BLOCK
#------------------------------------------------------------------
main_end:      
        li   $v0, 10          # exit()
        syscall

#----------------------------------------------------------------
# END OF CODE
#----------------------------------------------------------------


#=========================================================================
# Punctuation checker 
#=========================================================================
# Marks misspelled words and punctuation errors in a sentence according to a dictionary
# and punctuation rules
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
        lb   $t1, dictionary($t0)               
        beq  $t1, $0,  END_LOOP2        # if(c_input == '\n')
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

#code added from spell_checker is uncommented since it is unchanged
#ASCII for ' ' = 32, ',' = 44,'.' = 46,'?' = 63, '!' = 33, 'A' = 65, newline = 10
#The ASCII values were loaded into a temporary register and this register was used for comparisons whenever ASCII values had to be compared

        move $s0, $0                          #loading index value 0 into $s0
        lb   $s1, content                     #loading address of content into $s1
				
tokenizer:
        li      $t9, 65
        bge     $s1, $t9, character           #element of contents array compared to ASCII character 'A'. Jump to character 
        li      $t9, 33
        beq     $s1, $t9, punctuation         #element of contents array compared to '!', ',', '?', '.'. Jump to punctuation 
        li      $t9, 44                  
        beq     $s1, $t9, punctuation 
        li      $t9, 46       
        beq     $s1, $t9, punctuation 
        li      $t9, 63
        beq     $s1, $t9, punctuation     
        li      $t9, 32
        beq     $s1, $t9, space_loop          #element of contents array compared to '[space]'. Jump to space loop     
        beq     $s1, $0, main_end             #end program once reaching the end of the contents array


character:  
        jal  spellchecker
        beqz    $v0, not_word_print
        
character_loop:
        lb      $s1, content($s0)
        li      $v0, 11               
        move    $a0, $s1              
        syscall                       
        
        addi    $s0, $s0, 1                    
        lb      $s1, content($s0)       
        li      $t9, 65    
        bge     $s1, $t9, character_loop      #loop character print loop
		
        j tokenizer

punctuation:
        jal punctuation_checker               #jump to punctuation checker function
        beqz    $v0, not_punct_print          #if return value from punctuation checker is 0, punctuation is invalid
                                              #and jump to part of tokenizer that prints underscores before and after inva;id punctuation
        
punctuation_loop:                             #prints punctuation token
        lb      $s1, content($s0)
        li      $v0, 11               
        move    $a0, $s1              
        syscall                     
        addi    $s0, $s0, 1
        lb      $s1, content($s0)
        
        beq     $s1, $t9, punctuation_loop        #element of contents array compared to '!', ',', '?', '.'. Jump to punctuation loop
        li      $t9, 44                  
        beq     $s1, $t9, punctuation_loop
        li      $t9, 46       
        beq     $s1, $t9, punctuation_loop
        li      $t9, 63
        beq     $s1, $t9, punctuation_loop 
		
        j tokenizer
	
space_loop:                                  #prints space token
        li      $v0, 11        
        move    $a0, $s1               
        syscall                         
        addi    $s0, $s0, 1
        lb      $s1, content($s0)
        li      $t9, 32
        beq     $s1, $t9, space_loop         #loop space loop

        j tokenizer
  
#spellchecker is unchanged from spellchecker.s        
                 
spellchecker:
        move    $t1, $s0                         #$t1 is the token's character index
        move    $t2, $0                          #$t2 is the dictionary's character index
        li      $v0, 0                           #$v0 is the function's return value
        
spellloop:
        lb      $t3, dictionary($t2)             #load first char in dictionary to $t3
        beqz    $t3, end_spell_check             #end function if dictionary is empty
        lb      $t6, content($t1)                #load first alphabetical character from content array

        addi    $t1, $t1, 1                      #increment indexes
        addi    $t2, $t2, 1
        
        li      $t9, 10
        beq     $t3, $t9, newword               #if $t3 is a newline, the current dicionary word has ended
        bne     $t6, $t3, casechecker           #if the content and dictionary characters are not equal, check if they are not the same case
        lb      $t4, dictionary($t2)            #load the next dictionary character ($t2 was already incremented)
        li      $t9, 10
        beq     $t4, $t9, endchecker            #if the next character is empty, go to endchecker section
        j spellloop                              
        
endchecker:       
        li      $t9, 65                           
        lb      $t5, content($t1)                #load the next value of content into $t5
        
        slt     $v0, $t5, $t9                    #if $t5 < $t4 then the next character in content is not alphabetic and we have a match for a 
                                                 #word in the dictionary since the current dictionary word has ended (new line char needed to 
                                                 #jump to this function. Set result value to 1
                                                   
        bge    $t5, $t9 newline1                 #if the next character is alphabetic, jump to the next dictionary word since the current dictionary word is empty
        j end_spell_check                        #next char is not alphabetic so we have the end of the token and a match

newline1:                                        #get a new dictinary word
        move     $t1, $s0                        #set token index back to start of token 
        addi     $t2, $t2, 1                     #increment dictionary index by 1 since current character is a newline character
        j spellloop                              #jump to start of spellchecker loop
        
newword:
        addi     $t2, $t2, 1                     #increment dictionary index
        lb       $t3, dictionary($t2)
        li       $t9, 10
        beq      $t3, $t9, newline1              #if current dictionary character is newline jump to newline1
        beqz     $t3, end_spell_check            #if dictionary is empty, end
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
        
        
        
punctuation_checker:
        la      $t1, content($s0)                  #load address of current value of content into $s3
        lb      $t3, 0($t1)                        #t3 is the current character
        addi    $t1, $t1, -1                       
        lb      $t2, 0($t1)                        #t2 is the previous character
        addi    $t1, $t1, 2
        lb      $t4, 0($t1)                        #t4 is the next character
        move    $v0, $0                            #set return value to 0 initially

rule2:  li      $t9, 32
        beq     $t2, $t9  end_pcheck               #if the previous character is a space, invalid punctuation        
        beqz    $t4, is_token                      #if the current character is the last one, the punctuation is valid if rule 1 is followed
        li      $t9, 65
rule1:  bge     $t4, $t9, end_pcheck               #if the character directly after the current one is alphabetical, invalid punctuation
        beqz    $s0, rule3                         #if the character is the first one, $s0 = 0 and there is no previous token and rule 2 doesn't apply

        li      $t9, 46
rule3:  beq     $t3, $t9, space_check              #check for a space after the punctuation if neither of the above rules are not broken
        li      $t9, 63
        beq     $t3, $t9, space_check
        li      $t9, 33
        beq     $t3, $t9, space_check
        li      $t9, 44
        beq     $t3, $t9, space_check
        j end_pcheck
       
space_check:
        li      $t9, 32
        beq     $t4, $t9, is_token                 #if there is a space directly after the character, it is valid
        li      $t9, 46
        beq     $t4, $t9, ellipses_check           #if the next character is not a '.' character, it is not ellipses so this is invalid punctuation
        j end_pcheck                               #otherwise end the punctuation check with a fail ($v0 = 0)= returned)
ellipses_check:
        addi    $t1, $t1, 1                        #increment the address by 1 and do another check for a '.' as before
        lb      $t4, 0($t1)
        li      $t9, 46
        beq     $t4, $t9, ellipses_check1
        j end_pcheck
ellipses_check1:
        
        addi    $t1, $t1, 1
        lb      $t4, 0($t1)
        li      $t9, 32
        beq     $t4, $t9, is_token                 #if this character is a space, then it is a token
        beqz    $t4, is_token                      #if the string ends after the ellipses, this is a valid punctuation token
        j end_pcheck                               #else end the punctuation check in with a fail
                      
is_token:
        addi    $v0, $v0, 1                        #if the punctuation is vali, set $v0 to 1
        jr $ra                                     #return to print punctuation token
        
end_pcheck:
        jr $ra                                     #return to print punctuation check
        
        
        
not_word_print:                                    #prints a word with underscores before and after if it is not in the dictionary
        li $a0, 95
        li $v0, 11
        syscall
        
nwprintloop:
        lb      $s1, content($s0)
        li      $v0, 11                 
        move    $a0, $s1                
        syscall                         
       
        beqz    $s1, nw_print_end 
        addi    $s0, $s0, 1             
        lb      $s1, content($s0)   
        li      $t9, 65    
        bge     $s1, $t9, nwprintloop   
nw_print_end:
        li $a0, 95
        li $v0, 11
        syscall
        
        j tokenizer



not_punct_print:                                   #prints a punctuation token with underscores before and after if is not valid
        li $a0, 95
        li $v0, 11
        syscall
        
npprintloop:
        lb      $s1, content($s0)
        li      $v0, 11                            
        move    $a0, $s1                           
        syscall                                    
        
        beqz    $s1, punct_print_end               #if the charatcer is the last one, print the underscore and jump back to tokenizer
        addi    $s0, $s0, 1                        
        lb      $s1, content($s0)                  
        li      $t9, 65
        blt     $s1, $t9, space_print_check        #if the character is less than 'A', check if it is a space
        j punct_print_end                          #if it is greater than 'A', it is no longer a punctuation token and the final underscore should be printed
space_print_check:       
        li      $t9, 32                         
        bne     $s1, $t9, npprintloop              #if the next character is a space, print the final underscore and move onto the next token
        
punct_print_end:                                   #print final underscore and go back to tokeniser with next character in content
        li $a0, 95
        li $v0, 11
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

/***********************************************************************
* File       : <spell_checker.c>
*
* Author     : <Siavash Katebzadeh>
*
* Description:
*
* Date       : 08/10/18
*
***********************************************************************/
// ==========================================================================
// Spell checker
// ==========================================================================
// Marks misspelled words in a sentence according to a dictionary

// Inf2C-CS Coursework 1. Task B/C
// PROVIDED file, to be used as a skeleton.

// Instructor: Boris Grot
// TA: Siavash Katebzadeh
// 08 Oct 2018

#include <stdio.h>

// maximum size of input file
#define MAX_INPUT_SIZE 2048
// maximum number of words in dictionary file
#define MAX_DICTIONARY_WORDS 10000
// maximum size of each word in the dictionary
#define MAX_WORD_SIZE 20

int read_char() { return getchar(); }
int read_int()
{
    int i;
    scanf("%i", &i);
    return i;
}
void read_string(char* s, int size) { fgets(s, size, stdin); }

void print_char(int c)     { putchar(c); }
void print_int(int i)      { printf("%i", i); }
void print_string(char* s) { printf("%s", s); }
void output(char *string)  { print_string(string); }

// dictionary file name
char dictionary_file_name[] = "dictionary.txt";
// input file name
char input_file_name[] = "input.txt";
// content of input file
char content[MAX_INPUT_SIZE + 1];
// valid punctuation marks
char punctuations[] = ",.!?";
// tokens of input file
char tokens[MAX_INPUT_SIZE + 1][MAX_INPUT_SIZE + 1];
// number of tokens in input file
int tokens_number = 0;
// content of dictionary file
char dictionary[MAX_DICTIONARY_WORDS * MAX_WORD_SIZE + 1];

///////////////////////////////////////////////////////////////////////////////
/////////////// Do not modify anything above
///////////////////////////////////////////////////////////////////////////////

// You can define your global variables here!

// Task B

// compare_words compares two char arrays(strings) and checks whether they are the same, regardeless of case
//it returns 1 if they are equal and 0 if they are not
int compare_words(char word1[], char word2[]){
  int char_idx = 0;

  //loop for every character in word1 and word2 until a return value is given
  do {
    //true if both strings are empty since no characters were unequal
    if (word2[char_idx] == '\0' && word1[char_idx] == '\0') {
      return 1;
    }
    //returns false if characters are unequal and checks for case
    if (word1[char_idx] < word2[char_idx]){
      if (word1[char_idx] + 32 != word2[char_idx]){
        return 0;
      }
    }
    //returns false if characters are unequal and checks for case
    if (word1[char_idx] > word2[char_idx]){
      if (word2[char_idx] + 32 != word1[char_idx]){
        return 0;
      }
    }

    char_idx++;

  } while (1);
}

//spell_checker runs through the words in the dictionary and checks every word against the given word
int spell_checker(char token[]) {
  //set indexes to 0
  int char_idx = 0;
  int dictionary_idx = 0;
  int valid_word = 0;

  do {
    //loads characters in dictionary to new string so they can be compared using compare_words
    char dict_word[21] = "";
    //reset char index since this is a new word being loaded into the dict_word array
    char_idx = 0;

    //loading word into array with do loop
    do {
      dict_word[char_idx] = dictionary [dictionary_idx];
      char_idx++;
      dictionary_idx++;
    //break when a newline character is reached
    } while(dictionary[dictionary_idx] != '\n');

    //checks the token against this dictionary word and returns 1 if they are equal
    if (compare_words(dict_word, token) == 1){
      return 1;
    }
    //move onto start of next word
    dictionary_idx++;

  //end check for this word when dictionary is empty, if no match is reached
  } while (dictionary[dictionary_idx] != '\0');

  return valid_word;
}

//output_tokens prints the tokens and checks any alphabetical tokens against the dictionary by calling spell_checker on them
void output_tokens() {
  int tokens_num = 0;

  //loop through the words in the tokens array
  do {
    //checks if the start of the token is alphabetical
    if (tokens[tokens_num][0] >= 'A' && tokens[tokens_num][0] <= 'Z' || tokens[tokens_num][0] >= 'a' && tokens[tokens_num][0] <= 'z'){
      //runs spell_checker if the token is alphabetical
      if (spell_checker(tokens[tokens_num]) == 0) {
        //print underscores if word is not valid
        printf("_%s_", tokens[tokens_num] );
      }
      else {
        //print token alone if it is valid
        printf("%s", tokens[tokens_num]);
      }
    }
    //just print the token if the word is non-alphabetic
    else{
      printf("%s", tokens[tokens_num]);
    }
    //move onto the next token
    tokens_num++;
  //loop ends when the tokens array is empty by checking the value of the first column in the tokens_num row
  } while (tokens[tokens_num][0] != '\0');

  return;
}

//---------------------------------------------------------------------------
// Tokenizer function
// Split content into tokens
//---------------------------------------------------------------------------
void tokenizer(){
  char c;

  // index of content
  int c_idx = 0;
  c = content[c_idx];
  do {

    // end of contentreturn
    if(c == '\0'){
      break;
    }

    // if the token starts with an alphabetic character
    if(c >= 'A' && c <= 'Z' || c >= 'a' && c <= 'z') {

      int token_c_idx = 0;
      // copy till see any non-alphabetic character
      do {
        tokens[tokens_number][token_c_idx] = c;

        token_c_idx += 1;
        c_idx += 1;

        c = content[c_idx];
      } while(c >= 'A' && c <= 'Z' || c >= 'a' && c <= 'z');
      tokens[tokens_number][token_c_idx] = '\0';
      tokens_number += 1;

      // if the token starts with one of punctuation marks
    } else if(c == ',' || c == '.' || c == '!' || c == '?') {

      int token_c_idx = 0;
      // copy till see any non-punctuation mark character
      do {
        tokens[tokens_number][token_c_idx] = c;

        token_c_idx += 1;
        c_idx += 1;

        c = content[c_idx];
      } while(c == ',' || c == '.' || c == '!' || c == '?');
      tokens[tokens_number][token_c_idx] = '\0';
      tokens_number += 1;

      // if the token starts with space
    } else if(c == ' ') {

      int token_c_idx = 0;
      // copy till see any non-space character
      do {
        tokens[tokens_number][token_c_idx] = c;

        token_c_idx += 1;
        c_idx += 1;

        c = content[c_idx];
      } while(c == ' ');
      tokens[tokens_number][token_c_idx] = '\0';
      tokens_number += 1;
    }
  } while(1);
}
//---------------------------------------------------------------------------
// MAIN function
//---------------------------------------------------------------------------

int main (void)
{


  /////////////Reading dictionary and input files//////////////
  ///////////////Please DO NOT touch this part/////////////////
  int c_input;
  int idx = 0;

  // open input file
  FILE *input_file = fopen(input_file_name, "r");
  // open dictionary file
  FILE *dictionary_file = fopen(dictionary_file_name, "r");

  // if opening the input file failed
  if(input_file == NULL){
    print_string("Error in opening input file.\n");
    return -1;
  }

  // if opening the dictionary file failed
  if(dictionary_file == NULL){
    print_string("Error in opening dictionary file.\n");
    return -1;
  }

  // reading the input file
  do {
    c_input = fgetc(input_file);
    // indicates the the of file
    if(feof(input_file)) {
      content[idx] = '\0';
      break;
    }

    content[idx] = c_input;

    if(c_input == '\n'){
      content[idx] = '\0';
    }

    idx += 1;

  } while (1);

  // closing the input file
  fclose(input_file);

  idx = 0;

  // reading the dictionary file
  do {
    c_input = fgetc(dictionary_file);
    // indicates the end of file
    if(feof(dictionary_file)) {
      dictionary[idx] = '\0';
      break;
    }

    dictionary[idx] = c_input;
    idx += 1;
  } while (1);

  // closing the dictionary file
  fclose(dictionary_file);
  //////////////////////////End of reading////////////////////////
  ////////////////////////////////////////////////////////////////

//call tokenizer to tokenize the input array into the tokens array
  tokenizer();
//call output_tokens to print the input string and check each word against the dictionary
  output_tokens();
  return 0;
}

#include <stdio.h>

char tokens[1][1] = {{'c'}};

int compare_words(char word1[], char word2[]){
  int char_idx = 0;
  int valid = 1;


  do {
    if (word2[char_idx] == '\0'){
      return 0;
    }
    if (word1[char_idx] < word2[char_idx]){
      if (word1[char_idx] + 32 != word2[char_idx]){
        return 0;
      }
    }
    if (word1[char_idx] > word2[char_idx]){
      if (word2[char_idx] + 32 != word1[char_idx]){
        return 0;
      }
    }

    char_idx++;

  } while (word1[char_idx] != '\0');

  return valid;
}


int spell_checker(char token[]) {

  int char_idx = 0;
  int dictionary_idx = 0;
  int valid_word = 0;

  do {

    char dict_word[21] = "";

    do {
      dict_word[char_idx] = dictionary [dictionary_idx];
      char_idx++;
      dictionary_idx++;

    } while(dictionary[dictionary_idx] != '\n');

    if (compare_words(dict_word, token) == 1){
      valid_word = 1;
      break;
    }

    dictionary_idx++;

  } while (dictionary[dictionary_idx] != '\0');

  return valid_word;
}


void output_tokens() {
  int tokens_num = 0;


  do {
    if (tokens[tokens_num][0] >= 'A' && tokens[tokens_num][0] <= 'Z' || tokens[tokens_num][0] >= 'a' && tokens[tokens_num][0] <= 'z'){
      if(spell_checker(tokens[tokens_num]) == 0){
        printf("_%s_", tokens[tokens_num] );
      }
    }
    else{
      printf("%s", tokens[tokens_num]);
    }

    tokens_num++;

  } while (tokens[tokens_num][0] != '\0');

  return;
}

int main(){

  output_tokens();

}

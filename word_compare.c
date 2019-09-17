#include <stdio.h>

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

int main()
{

printf("%d\n", compare_words("hello", "hEllO"));

}

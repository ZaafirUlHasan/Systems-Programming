#include <stdio.h>
#include <string.h>
#include <stdlib.h>


#define BUFFER_SZ 50

//prototypes
void usage(char *);
void print_buff(char *, int);
int  setup_buff(char *, char *, int);


//prototypes for functions to handle required functionality
int  count_words(char *, int, int);
char* reverse_buffer(char *, int);
int print_words(char *buff, int buff_len, int str_len);
//add additional prototypes here


int setup_buff(char *buff, char *user_str, int len){
    //TODO: #4:  Implement the setup buff as per the directions
    int inputLen = 0;
    int spaceRemoved = 0;
    char *lastNonSpace = NULL; // Pointer to the last non-space character

    while (*user_str != '\0')
    {
        if(inputLen >= len){
            return -1; //input length in greater than the buffer size and so -1 returned according to directions
        }
        while (*user_str == ' ' || *user_str == '\t')
        {
            user_str++;
            spaceRemoved = 1;
        }
        if (spaceRemoved && (inputLen > 0))
        {
            *buff = ' ';
            lastNonSpace = buff;
            buff++;
            inputLen++;
        }
        if(*user_str!= '\0'){
            *buff = *user_str;
            lastNonSpace = buff;
            buff++;
            user_str++;
            inputLen++;
        }
        spaceRemoved = 0;
    }

    // If the last character written is a space, overwrite it with '.'
    if (lastNonSpace != NULL && *lastNonSpace == ' ') {
        *lastNonSpace = '.';
    }
    if(inputLen < len){
        memset(buff, '.', len - inputLen);
    }
    
    
    return inputLen;
}

void print_buff(char *buff, int len){
    printf("Buffer:  [");
    for (int i=0; i<len; i++){
        putchar(*(buff+i));
    }
    printf("]");
    putchar('\n');
}

void usage(char *exename){
    printf("usage: %s [-h|c|r|w|x] \"string\" [other args]\n", exename);

}

int count_words(char *buff, int len, int str_len){
    //YOU MUST IMPLEMENT
    int numWords = 0;
    while (*buff != '\0')
    {
        while (*buff != ' ' && *buff != '\0')
        {
            *buff++;
        }
        numWords++;
        *buff++;
    }
    
    return numWords;
}

char *reverse_buffer(char *buff, int str_len)
{
    char *startPtr = buff;
    char *endPtr = buff + str_len - 1;

    char temp = '\0';

    while (startPtr < endPtr)
    {
        temp = *startPtr;
        *startPtr = *endPtr;
        *endPtr = temp;
        startPtr++;
        endPtr--;
    }
    
    return buff;
}

int print_words(char *buff, int buff_len, int str_len){
    printf("Word Print\n");
    printf("----------\n");
    if (str_len > buff_len){
        return -1;
    }
    else if (str_len == 0)
    {
        printf("No words!");
        return 0;
    }

// APPROACH
     int word_count = 0;
     int char_counter = 0;     //length of current word
     int at_start = 1;   //this will capture if we are at the start of a word
     char c = *buff;

    //  loop over each character
     for (int i = 0; i < str_len; i++)
     {
         if (at_start)
         {
             word_count++;
             printf("%d. ", word_count);
             at_start = 0; // we are processing a new word
         }

         if (c == ' ') // we hit the end of the word
         {
             printf("(%d)\n", char_counter); //(length of current word)
             char_counter = 0;           //(start count for next word)
             at_start = 1;               //(we are starting next word)
         }
         else
         {                    // we are just encountering a regular character
             printf("%c", c); //(current character)
             char_counter++;  //(add to length of current string)
         }
         c = *(++buff);
     }

     //   all characters processed
     printf("(%d)\n", char_counter); //(this is for the last word)
     printf("\nNumber of words returned: %d\n", word_count);
     return word_count;          //(holds total number of words)
}

//ADD OTHER HELPER FUNCTIONS HERE FOR OTHER REQUIRED PROGRAM OPTIONS

int main(int argc, char *argv[]){

    char *buff; //placehoder for the internal buffer


    char *input_string;     //holds the string provided by the user on cmd line
    char opt;               //used to capture user option from cmd line
    int  rc;                //used for return codes
    int  user_str_len;      //length of user supplied string

    //TODO:  #1. WHY IS THIS SAFE, aka what if arv[1] does not exist?
    //      PLACE A COMMENT BLOCK HERE EXPLAINING
    // if argv[1] does not exist then that means that no option was provided.
    // Since we first check that argc < 2 i.e we check that if only 1 input parameter was passed,
    // we show the usage information. If two or more input parameters were passed, only then will
    // the second condition be checked due to the nature of OR. This prevents access to argv[1]
    // when it doesn’t exist, ensuring no out-of-bounds array access occurs. All of the options require
    // at least 2 arguments i.e the program name and the option itself
    if ((argc < 2) || (*argv[1] != '-')){
        usage(argv[0]);
        exit(1);
    }

    opt = (char)*(argv[1]+1);   //get the option flag

    //handle the help flag and then exit normally
    if (opt == 'h'){
        usage(argv[0]);
        exit(0);
    }

    //WE NOW WILL HANDLE THE REQUIRED OPERATIONS

    //TODO:  #2 Document the purpose of the if statement below
    //      If the user did not use the -h command then there need to be a sample/input
    // string provided for the program to work on. That is what this if statement is checking
    // If the at least 3 arguments have not been provided, then we print the usage information
    // and exit the program
    if (argc < 3){
        usage(argv[0]);
        exit(1);
    }

    input_string = argv[2]; //capture the user input string

    //TODO:  #3 Allocate space for the buffer using malloc and
    //          handle error if malloc fails by exiting with a 
    //          return code of 99
    // CODE GOES HERE FOR #3

    buff = (char*)malloc(BUFFER_SZ); 
    if (buff == NULL) {
        printf("Memory allocation failure\n");
        exit(2);
    }


    user_str_len = setup_buff(buff, input_string, BUFFER_SZ);     //see todos
    if (user_str_len < 0){
        printf("Error setting up buffer, error = %d", user_str_len);
        exit(2);
    }

    switch (opt){
        case 'c':
            rc = count_words(buff, BUFFER_SZ, user_str_len);  //you need to implement
            if (rc < 0){
                printf("Error counting words, rc = %d", rc);
                exit(2);
            }
            printf("Word Count: %d\n", rc);
            break;
        //TODO:  #5 Implement the other cases for 'r' and 'w' by extending
        //       the case statement options
        case 'r':
            char* reversedString = reverse_buffer(buff, user_str_len);  //you need to implement
            if (reversedString == NULL){
                printf("Error reversing string, reversed string was NULL");
                exit(2);
            }
            break;
        case 'w':
            int numWords = print_words(buff, BUFFER_SZ, user_str_len);  //you need to implement
            if (numWords == -1){
                printf("Error printing words, provided input string is too long");
                exit(3);
            }
            break;

        
        default:
            usage(argv[0]);
            exit(1);
    }

    //TODO:  #6 Dont forget to free your buffer before exiting
    print_buff(buff,BUFFER_SZ);
    free(buff);
    exit(0);
}

//TODO:  #7  Notice all of the helper functions provided in the 
//          starter take both the buffer as well as the length.  Why 
//          do you think providing both the pointer and the length
//          is a good practice, after all we know from main() that 
//          the buff variable will have exactly 50 bytes?
//  
//          This avoids hard-coding any constants. While the buffer size may be
//          currently defined to be of 50 bytes, this requirement may change in the 
//          future as requirements often do in software. In that case we would have
//          manually find and replace each instance where we used the buff_size. This
//          way, even if we decide to change the buff_size, we only have to replace it
//          once. It also allows functions to verify they do not read or write beyond
//          the allocated memory. This helps prevent dangerous bugs such as buffer 
//          overflows, which can lead to crashes or security vulnerabilities.
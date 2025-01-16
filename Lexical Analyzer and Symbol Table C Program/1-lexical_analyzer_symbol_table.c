#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <ctype.h>

//Step 1: Define the keywords and function calls

char *keywords[]={"int", "return" , "if", "else", "while", "for"};
char *functionCalls[]={"printf", "scanf", "getch", "clrscr"};

//Step 2: Define a struct that will be the symbol table
struct SymbolTableStruct{
    char name[50];
    char type[10];
    int bytes;
    int address;
    
};

//Step 3: Initialize the struct array
struct SymbolTableStruct symbolTable[100];
int symbolTableIndex=0; // is the array index


//Step 4: Write a function to check if a word is a keyword
int isKeyword(char *word){

    //iterate through each term in the keyword array
    for (int i=0;i<sizeof(keywords)/sizeof(keywords[0]);i++){
        if (strcmp(word,keywords[i])==0){
            return 1;
        }
    }
    return 0;
}


//Step 5: Write a function to check if a word is a function call
int isFunctionCall(char*word){
    for (int i=0;i<sizeof(functionCalls)/sizeof(functionCalls[0]);i++){
        if (strcmp(word,functionCalls[i])==0){
            return 1;
        }
    }

    return 0;
}

//Step 6.1: Check if the identifier is already there in the table
int findIdentifier(char*name){
    for (int i=0;i<symbolTableIndex;i++){
        if (strcmp(name,symbolTable[i].name)==0){
            return 1;
        }
    }

    return -1;
}


//Step 6: Write a function to add variables into the symbol table
void addToSymbolTable(char*name, char*type, int bytes, int address){
    
        strcpy(symbolTable[symbolTableIndex].name, name);
        strcpy(symbolTable[symbolTableIndex].type, type);
        symbolTable[symbolTableIndex].bytes=bytes;
        symbolTable[symbolTableIndex].address=address;
        symbolTableIndex++;

    

}



//Step 7: Write a scanner function that will identify different kinds of tokens
void scan(char *sourceCode){
    char token[100];
    int i=0;
    int address=1000;

    //set up a while loop to traverse the code
    while (sourceCode[i]!= '\0'){

        //skip white spaces
        if (isspace(sourceCode[i])){
            i++;
            continue;
        }


        //identify string constants which are not identifiers or functions
        if (sourceCode[i]=='"'){
            i++;

            //set up a loop that reads until it encounters the end of a word or the end of the program
            int j=0;
            while(sourceCode[i]!='"' && sourceCode[i]!='\0'){
                token[j++]=sourceCode[i++];
            }

            //terminate the string
            token[j]='\0';
            printf("%s - String \n", token);
            
            i++;
            continue;
        }


        //identify keywords, identifiers and function calls
        if (isalpha(sourceCode[i])){
            int j =0;
            while(isalnum(sourceCode[i])|| sourceCode[i]=='_'){
                token[j++]=sourceCode[i++];
            }

            token[j]='\0';

            if (isKeyword(token)){
                printf("%s - Keyword \n", token);
            }

            else if (isFunctionCall(token)){
                printf("%s - Function \n", token);
            }

            else if (strcmp(token, "main") == 0 && sourceCode[i] =='('){
                printf("%s - Main Function \n", token);
            }

            else{
                printf("%s - Identifier \n", token);
                if (findIdentifier(token) == -1) { // only add if not found
                    addToSymbolTable(token, "int", 4, address);
                    address += 4;
                }
            }


        }

        //identify integger constants
        if (isdigit(sourceCode[i])){
            int j=0;
            while(isdigit(sourceCode[i])){
                token[j++]=sourceCode[i++];

            }
            token[j]='\0';
            int value= atoi(token);
            printf("%s - integer constant\n", token);
        }

        // Identify operators and special characters
        if (strchr("+-*/%", sourceCode[i])) { // Arithmetic operators
            if (sourceCode[i + 1] == '=') { // Arithmetic assignment operators
                printf("%c= - arithmetic assignment operator\n", sourceCode[i]);
                i += 2;
            } else {
                printf("%c - arithmetic operator\n", sourceCode[i]);
                i++;
            }
            continue;
        }
        
        if (sourceCode[i] == '&' && sourceCode[i + 1] == '&') { // Logical operator &&
            printf("&& - logical operator\n");
            i += 2;
            
        }
        if (sourceCode[i] == '|' && sourceCode[i + 1] == '|') { // Logical operator ||
            printf("|| - logical operator\n");
            i += 2;
            
        }
        if (sourceCode[i] == '!') { // Logical operator ! or relational operator !=
            if (sourceCode[i + 1] == '=') {
                printf("!= - relational operator\n");
                i += 2;
            } else {
                printf("! - logical operator\n");
                i++;
            }
            
        }

        if (sourceCode[i] == '=' && sourceCode[i + 1] == '=') { // Relational operator ==
            printf("== - relational operator\n");
            i += 2;
            
        }
        if (sourceCode[i] == '<' || sourceCode[i] == '>') { // Relational operators <, <=, >, >=
            if (sourceCode[i + 1] == '=') {
                printf("%c= - relational operator\n", sourceCode[i]);
                i += 2;
            } else {
                printf("%c - relational operator\n", sourceCode[i]);
                i++;
            }
            continue;
        }

        if (sourceCode[i] == '=') { // Assignment operator
            printf("= - assignment operator\n");
            i++;
            continue;
        }

        if (strchr(";,.[](){}[]", sourceCode[i])) { // Special characters
            printf("%c - special character\n", sourceCode[i]);
            i++;
            continue;
        }

        //anything else=skip, just increment i
        i++;

    }
}



void main(){
    char sourceCode[] = "int main() { int a = 10 ; if (a >= 5) printf(\"hello\"); for ( i = 0; i < 10; i++ ) { printf( \"Hi\")};}";

    // Scan the source code
    scan(sourceCode);

    for (int i = 0; i < symbolTableIndex; i++) {
        printf("Name: %s, Type: %s, Bytes: %d, Address: %d \n\n",
               symbolTable[i].name,
               symbolTable[i].type,
               symbolTable[i].bytes,
               symbolTable[i].address);
    }
}


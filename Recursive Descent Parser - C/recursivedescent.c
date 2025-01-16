//Exercise 3- Recursive Descent Parser
//Name: Pooja Premnath
//Register Number: 3122 21 5001 066

#include <stdio.h>
#include <stdlib.h>
#include <ctype.h>
#include <string.h>

char input[100];
int pos=0;
char lookahead;

void E();
void E_prime();
void T();
void F();
void T_prime();
void F();
void match (char token);


//write the body of each function 


//function to match the terminal and then advance forward
void match(char token){
    

    if(lookahead==token){
        lookahead=input[++pos];
    }

    else{
        printf("Error in parsing- unexpected token %c \n", lookahead);
        exit(1);
    }
}

void E(){
    printf("E -> TE' \n");
    T();
    E_prime();

}

void E_prime(){
    if (lookahead =='+'){
        printf("E' -> +TE' \n");
        match('+');
        T();
        E_prime();
    }

    else{
        printf("E' -> epsilon \n");
    }
}
    
void T(){
    printf("T -> FT' \n");
    F();
    T_prime();
}

void T_prime(){
    if (lookahead=='*'){
        printf("T' -> *FT' \n");
        match('*');
        F();
        T_prime();
    }

    else{
        printf("T' -> epsilon \n");
    }
}

void F(){
    if(lookahead=='('){
        printf("F -> (E) \n");
        match('(');
        E();
        match(')');
    }

    else if(isalpha(lookahead)){
        printf("F -> id \n");

        //match the whole string 'id'
        while(isalnum(lookahead)){
            lookahead=input[++pos];
        }
    }

    else{
        printf("Error in parsing- unexpected token %c \n", lookahead);
        exit(1);
    }
}


//function to start the parsing
void parse(char *inputString){
    strcpy(input, inputString);
    pos=0;
    lookahead=input[pos];

    E();

    if (lookahead == '\0') {
        printf("Parsing Successful!\n");
    } else {
        printf("Parsing Failed. Remaining input: %s\n", input + pos);
    }
}


void main(){
    char inputString[100];
    printf("Enter an expression: ");
    fgets(inputString, sizeof(inputString), stdin);
    size_t len = strlen(inputString);
    if (len > 0 && inputString[len - 1] == '\n') {
        inputString[len - 1] = '\0';
    }

    parse(inputString);
}
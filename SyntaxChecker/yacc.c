

%{
#include <stdio.h>
#include <stdlib.h>
extern int yylineno;   // Declare line number variable
extern char *yytext;
int yylex();
void yyerror(const char *s);

extern FILE *yyin;  // Declare yyin for file input
%}

/* Token Definitions from Lex */
%token INT IF ELSE WHILE ID NUMBER RELOP

/* Define Precedence and Associativity for Operators */
%left '+' '-'
%left '*' '/'

%%

program:
    statement_list
    ;

statement_list:
    statement
    | statement_list statement
    ;

statement:
    declaration_statement
    | assignment_statement
    | conditional_statement
    | loop_statement
    | block
    ;

declaration_statement:
    INT id_list ';'
    ;

id_list:
    ID
    | id_list ',' ID
    ;

assignment_statement:
    ID '=' expression ';'
    ;

expression:
    ID
    | NUMBER
    | expression '+' expression
    | expression '-' expression
    | expression '*' expression
    | expression '/' expression
    ;

conditional_statement:
    IF '(' condition ')' block ELSE block
    | IF '(' condition ')' block
    ;

condition:
    ID RELOP ID
    | ID RELOP NUMBER
    ;

loop_statement:
    WHILE '(' condition ')' block
    ;

block:
    '{' statement_list '}'
    ;

%%

void yyerror(const char *s) {
    fprintf(stderr, "Syntax error: %s at line %d near '%s'\n", s, yylineno, yytext);
}

int main(int argc, char *argv[]) {
    FILE *file = fopen(argv[1], "r");
    if (!file) {
        perror("Could not open file");
        return 1;
    }

    // Use yyin to read from the file
    yyin = file;

    printf("Checking syntax for code in %s:\n", argv[1]);
    if (yyparse() == 0) {
        printf("Syntactically correct\n");
    } else {
        printf("Syntactically incorrect\n");
    }

    fclose(file);  // Close the file after parsing
    return 0;
}

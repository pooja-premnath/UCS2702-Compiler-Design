%{
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <math.h>

int yyerror(char *s);
extern int yylex();
extern FILE *yyin;
FILE *out;

int tempcount = 0;
int regcount = 0;
char* createTemp()
{
   char* temp = malloc(10);
   sprintf(temp, "t%d", tempcount++);
   return temp;
}
char* createRegister()
{
   char* temp = malloc(10);
   sprintf(temp, "R%d", regcount++);
   return temp;
}

%}
%union {
    char *addr;
    char *name;
    double value;   // Change to double to support decimal numbers
}

%left '+' '-'
%left '*' '/'
%right _UMINUS

%token <name> ID
%token <value> NUM
%type <addr> E
%type <value> NUM_E

%%

SS :
   | SS P
   ;

P : S
  ;

S : ID '=' E ';' {
        printf("%s := %s\n", $1, $3);
        char* temp = createRegister();
        fprintf(out, "MOV %s,%s\n", temp, $3);
        fprintf(out, "MOV %s,%s\n", $1, temp);
    }
  | ID '=' NUM_E ';' {
        printf("%s := %g\n", $1, $3);
        char* temp = createRegister();
        fprintf(out, "MOV %s,#%g\n", temp, $3);
        fprintf(out, "MOV %s,%s\n", $1, temp);
    }
  ;

E : E '+' E {
        $$ = createTemp();
        
        if (!strcmp($1, "0")) {
            // Optimization: 0 + x = x
            printf("%s := %s\n", $$, $3);
            char* temp = createRegister();
            fprintf(out, "MOV %s,%s\n", temp, $3);
            fprintf(out, "MOV %s,%s\n", $$, temp);
        } else if (!strcmp($3, "0")) {
            // Optimization: x + 0 = x
            printf("%s := %s\n", $$, $1);
            char* temp = createRegister();
            fprintf(out, "MOV %s,%s\n", temp, $1);
            fprintf(out, "MOV %s,%s\n", $$, temp);
        } else {
            // Regular addition
            printf("%s := %s + %s\n", $$, $1, $3);
            char* temp1 = createRegister();
            char* temp2 = createRegister();
            fprintf(out, "MOV %s,%s\n", temp1, $1);
            fprintf(out, "MOV %s,%s\n", temp2, $3);
            fprintf(out, "ADD %s,%s\n", temp1, temp2);
            fprintf(out, "MOV %s,%s\n", $$, temp1);
        }
    }
  | E '-' E {
        $$ = createTemp();
        if (!strcmp($3, "0")) {
            // Optimization: x - 0 = x
            printf("%s := %s\n", $$, $1);
            char* temp = createRegister();
            fprintf(out, "MOV %s,%s\n", temp, $1);
            fprintf(out, "MOV %s,%s\n", $$, temp);
        } else {
            // Regular subtraction
            printf("%s := %s - %s\n", $$, $1, $3);
            char* temp1 = createRegister();
            char* temp2 = createRegister();
            fprintf(out, "MOV %s,%s\n", temp1, $1);
            fprintf(out, "MOV %s,%s\n", temp2, $3);
            fprintf(out, "SUB %s,%s\n", temp1, temp2);
            fprintf(out, "MOV %s,%s\n", $$, temp1);
        }
    }
  | E '*' E {
        $$ = createTemp();
        if (!strcmp($1, "1")) {
            // Optimization: 1 * x = x
            printf("%s := %s\n", $$, $3);
            char* temp = createRegister();
            fprintf(out, "MOV %s,%s\n", temp, $3);
            fprintf(out, "MOV %s,%s\n", $$, temp);
        } else if (!strcmp($3, "1")) {
            // Optimization: x * 1 = x
            printf("%s := %s\n", $$, $1);
            char* temp = createRegister();
            fprintf(out, "MOV %s,%s\n", temp, $1);
            fprintf(out, "MOV %s,%s\n", $$, temp);
        } else if (!strcmp($3, "0") || !strcmp($1, "0")) {
            // Optimization: x * 0 = 0
            printf("%s := 0\n", $$);
            char* temp = createRegister();
            fprintf(out, "MOV %s,#0\n", temp);
            fprintf(out, "MOV %s,%s\n", $$, temp);
        } else {
            // Regular multiplication
            printf("%s := %s * %s\n", $$, $1, $3);
            char* temp1 = createRegister();
            char* temp2 = createRegister();
            fprintf(out, "MOV %s,%s\n", temp1, $1);
            fprintf(out, "MOV %s,%s\n", temp2, $3);
            fprintf(out, "MUL %s,%s\n", temp1, temp2);
            fprintf(out, "MOV %s,%s\n", $$, temp1);
        }
    }
  | E '/' E {
        $$ = createTemp();
        if (!strcmp($3, "1")) {
            // Optimization: x / 1 = x
            printf("%s := %s\n", $$, $1);
            char* temp = createRegister();
            fprintf(out, "MOV %s,%s\n", temp, $1);
            fprintf(out, "MOV %s,%s\n", $$, temp);
        } else if (!strcmp($1, "0")) {
            // Optimization: 0 / x = 0 (assuming x != 0)
            printf("%s := 0\n", $$);
            char* temp = createRegister();
            fprintf(out, "MOV %s,#0\n", temp);
            fprintf(out, "MOV %s,%s\n", $$, temp);
        } else {
            // Regular division
            printf("%s := %s / %s\n", $$, $1, $3);
            char* temp1 = createRegister();
            char* temp2 = createRegister();
            fprintf(out, "MOV %s,%s\n", temp1, $1);
            fprintf(out, "MOV %s,%s\n", temp2, $3);
            fprintf(out, "DIV %s,%s\n", temp1, temp2);
            fprintf(out, "MOV %s,%s\n", $$, temp1);
        }
    }
  | '-' E %prec _UMINUS {
        $$ = createTemp();
        printf("%s := - %s\n", $$, $2);
        char* temp = createRegister();
        fprintf(out, "MOV %s,%s\n", temp, $2);
        fprintf(out, "NEG %s\n", temp);
        fprintf(out, "MOV %s,%s\n", $$, temp);
    }
  | '(' E ')' {
        $$ = $2; // Brackets return the enclosed expression's value
    }
  | ID {
        $$ = strdup($1);
    }
  | NUM_E {
        $$ = malloc(10);
        sprintf($$, "%g", $1);  // %g for printing decimal numbers as needed
    }
  ;

NUM_E : NUM_E '+' NUM_E { $$ = $1 + $3; }
  | NUM_E '-' NUM_E { $$ = $1 - $3; }
  | '-' NUM_E %prec _UMINUS { $$ = -$2; }
  | NUM_E '*' NUM_E { $$ = $1 * $3; }
  | NUM_E '/' NUM_E { $$ = $1 / $3; }
  | NUM { $$ = $1; }
  ;

%%

int yyerror(char *s)
{
    fprintf(stderr, "ERROR: %s\n", s);
    exit(1);
}

int main(int argc, char **argv)
{
    yyin = fopen(argv[1], "r");
    out = fopen("out.asm", "a+");
    if (!out) { printf("Cannot open output file\n"); exit(1); }
    
    if (!yyin) {
        printf("Cannot open input file\n");
        exit(1);
    }
    
    if (yyparse() == 0) {
        printf("******SYNTACTICALLY CORRECT******\n");
    } else {
        printf("******SYNTACTICALLY INCORRECT******\n");
    }
    
    fclose(out);
}

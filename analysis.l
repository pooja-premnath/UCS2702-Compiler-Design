%{
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
%}

word [A-Za-z]+
integers [0-9]+
decimal ({integers}"."{integers}?)|({integers}?"."{integers})
id ({word})({word}|{integers})*

%%

"+"       { printf("Token: PLUS, Value: %s\n", yytext); return '+'; }
"-"       { printf("Token: MINUS, Value: %s\n", yytext); return '-'; }
"/"       { printf("Token: DIVIDE, Value: %s\n", yytext); return '/'; }
"*"       { printf("Token: MULTIPLY, Value: %s\n", yytext); return '*'; }
"="       { printf("Token: ASSIGN, Value: %s\n", yytext); return '='; }
";"       { printf("Token: SEMICOLON, Value: %s\n", yytext); return ';'; }
"("       { printf("Token: LPAREN, Value: %s\n", yytext); return '('; }
")"       { printf("Token: RPAREN, Value: %s\n", yytext); return ')'; }
{word}    { printf("Token: ID, Value: %s\n", yytext); return 1; }
(-?){integers} { printf("Token: NUM (Integer), Value: %s\n", yytext); return 2; }
{decimal} { printf("Token: NUM (Decimal), Value: %s\n", yytext); return 3; }
. { printf("INVALID: %s\n", yytext); exit(1); }

%%

int yywrap() { return 1; }

// Main function for standalone lexical analysis
int main(int argc, char **argv) {
    if (argc > 1) {
        yyin = fopen(argv[1], "r");
        if (!yyin) {
            fprintf(stderr, "Cannot open %s\n", argv[1]);
            return 1;
        }
    }

    int token;
    while ((token = yylex())) {
        // Each token is printed by the individual rules above
    }

    if (yyin) fclose(yyin);
    return 0;
}

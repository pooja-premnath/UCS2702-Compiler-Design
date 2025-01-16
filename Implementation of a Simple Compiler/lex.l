%{
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include "yacc.tab.h"
%}

word [A-Za-z]+
integers [0-9]+
decimal ({integers}"."{integers}?)|({integers}?"."{integers})
id ({word})({word}|{integers})*

%%

"+"       { return yytext[0]; }
"-"       {  return yytext[0]; }
"/"       { return yytext[0]; }
"*"       {  return yytext[0]; }
"="       { return yytext[0]; }
";"       { return yytext[0]; }
"("       { return yytext[0]; }
")"       {  return yytext[0]; }
{word}    { yylval.name = strdup(yytext); return ID; }
(-?){integers} { yylval.value = atoi(yytext); return NUM; }
{decimal} { yylval.value = atof(yytext); return NUM; }
. { exit(1); }

%%

int yywrap() { return 1; }

// Standalone main function for lexical analysis
int lex_main(int argc, char **argv) {
    if (argc > 1) {
        yyin = fopen(argv[1], "r");
        if (!yyin) {
            fprintf(stderr, "Cannot open %s\n", argv[1]);
            return 1;
        }
    }

    if (yyin) fclose(yyin);
    return 0;
}

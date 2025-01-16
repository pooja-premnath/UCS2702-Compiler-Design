%option yylineno

%{
#include "yacc.tab.h"
#include <stdlib.h>
%}

/* Token Definitions */
%%
"int"                   { return INT; }
"if"                    { return IF; }
"else"                  { return ELSE; }
"while"                 { return WHILE; }

[0-9]+                  { yylval = atoi(yytext); return NUMBER; }
[a-zA-Z_][a-zA-Z_0-9]*  { return ID; }
"<="|">="|"=="|"!="     { return RELOP; }
"<"|">"                 { return RELOP; }
"="                     { return '='; }
"+"                     { return '+'; }
"-"                     { return '-'; }
"*"                     { return '*'; }
"/"                     { return '/'; }
"("                     { return '('; }
")"                     { return ')'; }
"{"                     { return '{'; }
"}"                     { return '}'; }
";"                     { return ';'; }
","                     { return ','; }

[ \t\n]+                { /* Ignore whitespace */ }
.                       { /* Ignore unknown characters */ }

%%

int yywrap() {
    return 1;
}

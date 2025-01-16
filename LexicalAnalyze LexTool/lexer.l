%{
#include <stdio.h>
#include <stdlib.h>
%}

%%
"int"|"return"|"if"|"else"|"while"|"for"                { printf("%s - Keyword\n", yytext); }
"printf"|"scanf"|"getch"|"clrscr"                       { printf("%s - Function\n", yytext); }
"main"                                                  { printf("%s - Main Function\n", yytext); }
[0-9]+                                                  { printf("%s - Integer constant\n", yytext); }
\"[^"]*\"                                               { printf("%s - String\n", yytext); }
"&&"                                                    { printf("%s - Logical operator\n", yytext); }
"||"                                                    { printf("%s - Logical operator\n", yytext); }
"!="                                                    { printf("%s - Relational operator\n", yytext); }
"=="                                                    { printf("%s - Relational operator\n", yytext); }
"<="|">="                                               { printf("%s - Relational operator\n", yytext); }
"<"|">"                                                 { printf("%s - Relational operator\n", yytext); }
"="                                                     { printf("%s - Assignment operator\n", yytext); }
"+"|"-"|"*"|"/"|"%"|"+="|"-="|"*="|"/="|"%="            { printf("%s - Arithmetic operator\n", yytext); }
";"|","|"."|"["|"]"|"("|")"|"{"|"}"                     { printf("%s - Special character\n", yytext); }
[a-zA-Z_][a-zA-Z0-9_]*                                  { printf("%s - Identifier\n", yytext); }
[ \t\n]                                                 { /* Ignore whitespace */ }
.                                                       { printf("%s - Unknown character\n", yytext); }
%%

int main(int argc, char **argv) {
    

    FILE *file = fopen(argv[1], "r");
    if (!file) {
        perror("Could not open file");
        return 1;
    }

    // Use yyin to read from the file
    yyin = file;

    // Run the lexer
    yylex();

    // Close the file
    fclose(file);
    return 0;
}

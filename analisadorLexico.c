%option noyywrap yylineno
/*-------------------------- Definitions--------------------------*/
%{
#include <stdio.h>
int line_number = 1;
int column_number = 1;

%}

letter          [A-Za-z]
digit           [0-9]   
number          {digit}+(\.{digit}+)?(E[+-]?{digit}+)?
id              {letter} ({letter} | {digit})*
delim           [ \t\n]
ws              {delim}+
Scomment        \/\/[^\n]*
Mcomment        \/\*([^*]|\*+[^*/])*\*+\/
other           .

%%

int             { fprintf(yyout, "%d(%d):%s(INT)\n", yylineno,column_number,yytext); column_number+=yyleng; }
float           { fprintf(yyout, "%d(%d):%s(FLOAT)\n", yylineno,column_number,yytext); column_number+=yyleng; }
bool            { fprintf(yyout, "%d(%d):%s(BOOL)\n", yylineno,column_number,yytext); column_number+=yyleng; }
if              { fprintf(yyout, "%d(%d):%s(IF)\n", yylineno,column_number,yytext); column_number+=yyleng; }
else            { fprintf(yyout, "%d(%d):%s(ELSE)\n", yylineno,column_number,yytext); column_number+=yyleng; }
while           { fprintf(yyout, "%d(%d):%s(WHILE)\n", yylineno,column_number,yytext); column_number+=yyleng; }
print           { fprintf(yyout, "%d(%d):%s(PRINT)\n", yylineno,column_number,yytext); column_number+=yyleng; }
read            { fprintf(yyout, "%d(%d):%s(READ)\n", yylineno,column_number,yytext); column_number+=yyleng; }
true            { fprintf(yyout, "%d(%d):%s(TRUE)\n", yylineno,column_number,yytext); column_number+=yyleng; }
false           { fprintf(yyout, "%d(%d):%s(FALSE)\n", yylineno,column_number,yytext); column_number+=yyleng; }
{number}        { fprintf(yyout, "%d(%d):%s(NUMBER)\n", yylineno,column_number,yytext); column_number+=yyleng; }
{Scomment}      {}
{Mcomment}      {}
\n              { column_number=1; }
{ws}            {}
"+"             { fprintf(yyout, "%d(%d):+(PLUS)\n", yylineno,column_number); column_number+=yyleng; }
"-"             { fprintf(yyout, "%d(%d):-(MINUS)\n", yylineno,column_number); column_number+=yyleng; }
"*"             { fprintf(yyout, "%d(%d):-(TIMES)\n", yylineno,column_number); column_number+=yyleng; }
"/"             { fprintf(yyout, "%d(%d):-(DIVISOR)\n", yylineno,column_number); column_number+=yyleng; }
":="            { fprintf(yyout, "%d(%d):-(EQ)\n", yylineno,column_number); column_number+=yyleng; }
"<"             { fprintf(yyout, "%d(%d):-(LT)\n", yylineno,column_number); column_number+=yyleng; }
"<="            { fprintf(yyout, "%d(%d):-(LE)\n", yylineno,column_number); column_number+=yyleng; }
"<>"            { fprintf(yyout, "%d(%d):-(NE)\n", yylineno,column_number); column_number+=yyleng; }
">"             { fprintf(yyout, "%d(%d):-(GT)\n", yylineno,column_number); column_number+=yyleng; }
">="            { fprintf(yyout, "%d(%d):-(GE)\n", yylineno,column_number); column_number+=yyleng; }
"&&"            { fprintf(yyout, "%d(%d):-(AND)\n", yylineno,column_number); column_number+=yyleng; }
"||"            { fprintf(yyout, "%d(%d):-(OR)\n", yylineno,column_number); column_number+=yyleng; }
";"             { fprintf(yyout, "%d(%d):-(SCOL)\n", yylineno,column_number); column_number+=yyleng; }
","             { fprintf(yyout, "%d(%d):-(COMMA)\n", yylineno,column_number); column_number+=yyleng; }



{other}         { fprintf(yyout,"Lexicalerror on line %d andcolumn%d. Input->\"%s\"\n", yylineno,column_number,yytext); column_number+=yyleng; }

%%
     
    int main(int argc, char *argv[]) {
 = fopen(argv[1], "r");
        yyout=stdout;
    yylex();
    fclose(yyin);
    return 0;
}
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
string          \"([^"]|\\.)*\"
id              {letter}({letter}|{digit})*
delim           [ \t]
ws              {delim}+
Scomment        \/\/[^\n]*
Mcomment        \/\*([^*]|\*+[^*/])*\*+\/

other           .

%%
int             { fprintf(yyout, "<INT> "); column_number+=yyleng; }
float           { fprintf(yyout, "<FLOAT> "); column_number+=yyleng; }
bool            { fprintf(yyout, "<BOOL> "); column_number+=yyleng; }
if              { fprintf(yyout, "<IF> "); column_number+=yyleng; }
else            { fprintf(yyout, "<ELSE> "); column_number+=yyleng; }
while           { fprintf(yyout, "<WHILE> "); column_number+=yyleng; }
print           { fprintf(yyout, "<PRINT> "); column_number+=yyleng; }
read            { fprintf(yyout, "<READ> "); column_number+=yyleng; }
true            { fprintf(yyout, "<TRUE> "); column_number+=yyleng; }
false           { fprintf(yyout, "<FALSE> "); column_number+=yyleng; }
{number}        { fprintf(yyout, "<NUMBER, %s> ", yytext); column_number+=yyleng; }
{id}            { fprintf(yyout, "<ID, %s> ", yytext); column_number+=yyleng; }
{string}        { fprintf(yyout, "<STRING, %s> ", yytext); column_number+=yyleng; }
{Scomment}      {}
{Mcomment}      {}
\n              { fprintf(yyout, "\n"); column_number=1; }
{ws}            { column_number += yyleng; }
"+"             { fprintf(yyout, "<PLUS> "); column_number+=yyleng; }
"-"             { fprintf(yyout, "<MINUS> "); column_number+=yyleng; }
"*"             { fprintf(yyout, "<TIMES> "); column_number+=yyleng; }
"/"             { fprintf(yyout, "<DIVISOR> "); column_number+=yyleng; }
":="            { fprintf(yyout, "<EQ> "); column_number+=yyleng; }
"<"             { fprintf(yyout, "<LT> "); column_number+=yyleng; }
"<="            { fprintf(yyout, "<LE> "); column_number+=yyleng; }
"<>"            { fprintf(yyout, "<NE> "); column_number+=yyleng; }
">"             { fprintf(yyout, "<GT> "); column_number+=yyleng; }
">="            { fprintf(yyout, "<GE> "); column_number+=yyleng; }
"&&"            { fprintf(yyout, "<AND> "); column_number+=yyleng; }
"||"            { fprintf(yyout, "<OR> "); column_number+=yyleng; }
";"             { fprintf(yyout, "<SEMICOL> "); column_number+=yyleng; }
","             { fprintf(yyout, "<COMMA> "); column_number+=yyleng; }
"("             { fprintf(yyout, "<LPARENTESE> "); column_number+=yyleng; }
")"             { fprintf(yyout, "<RPARENTESE> "); column_number+=yyleng; }
"{"             { fprintf(yyout, "<LCHAVES> "); column_number+=yyleng; }
"}"             { fprintf(yyout, "<RCHAVES> "); column_number+=yyleng; }


{other}         { fprintf(yyout,"Lexicalerror on line %d and column %d. Input->\"%s\"\n", yylineno,column_number,yytext); column_number+=yyleng; }

%%

int main(int argc, char *argv[]){
    yyin = fopen(argv[1], "r");
    yyout=stdout;
    yylex();
    fclose(yyin);
    return 0;
}

// SALVANDO OUTRO TREM AQUI

// int             { fprintf(yyout, "line: %d (%d) => (INT) \n", yylineno,column_number,yytext); column_number+=yyleng; }
// float           { fprintf(yyout, "line: %d (%d) => (FLOAT) \n", yylineno,column_number,yytext); column_number+=yyleng; }
// bool            { fprintf(yyout, "line: %d (%d) => (BOOL) \n", yylineno,column_number,yytext); column_number+=yyleng; }
// if              { fprintf(yyout, "line: %d (%d) => (IF) \n", yylineno,column_number,yytext); column_number+=yyleng; }
// else            { fprintf(yyout, "line: %d (%d) => (ELSE) \n", yylineno,column_number,yytext); column_number+=yyleng; }
// while           { fprintf(yyout, "line: %d (%d) => (WHILE) \n", yylineno,column_number,yytext); column_number+=yyleng; }
// print           { fprintf(yyout, "line: %d (%d) => (PRINT) \n", yylineno,column_number,yytext); column_number+=yyleng; }
// read            { fprintf(yyout, "line: %d (%d) => (READ) \n", yylineno,column_number,yytext); column_number+=yyleng; }
// true            { fprintf(yyout, "line: %d (%d) => (TRUE) \n", yylineno,column_number,yytext); column_number+=yyleng; }
// false           { fprintf(yyout, "line: %d (%d) => (FALSE) \n", yylineno,column_number,yytext); column_number+=yyleng; }
// {number}        { fprintf(yyout, "line: %d (%d) => (NUMBER, %s) \n", yylineno,column_number,yytext); column_number+=yyleng; }
// {id}            { fprintf(yyout, "line: %d (%d) => (ID, %s) \n", yylineno,column_number,yytext); column_number+=yyleng; }
// {Scomment}      {}
// {Mcomment}      {}
// \n              { fprintf(yyout, "\n"); column_number=1; }
// {ws}            { column_number += yyleng; }
// "+"             { fprintf(yyout, "line: %d (%d) => (PLUS) \n", yylineno,column_number); column_number+=yyleng; }
// "-"             { fprintf(yyout, "line: %d (%d) => (MINUS) \n", yylineno,column_number); column_number+=yyleng; }
// "*"             { fprintf(yyout, "line: %d (%d) => (TIMES) \n", yylineno,column_number); column_number+=yyleng; }
// "/"             { fprintf(yyout, "line: %d (%d) => (DIVISOR) \n", yylineno,column_number); column_number+=yyleng; }
// ":="            { fprintf(yyout, "line: %d (%d) => (EQ) \n", yylineno,column_number); column_number+=yyleng; }
// "<"             { fprintf(yyout, "line: %d (%d) => (LT) \n", yylineno,column_number); column_number+=yyleng; }
// "<="            { fprintf(yyout, "line: %d (%d) => (LE) \n", yylineno,column_number); column_number+=yyleng; }
// "<>"            { fprintf(yyout, "line: %d (%d) => (NE) \n", yylineno,column_number); column_number+=yyleng; }
// ">"             { fprintf(yyout, "line: %d (%d) => (GT) \n", yylineno,column_number); column_number+=yyleng; }
// ">="            { fprintf(yyout, "line: %d (%d) => (GE) \n", yylineno,column_number); column_number+=yyleng; }
// "&&"            { fprintf(yyout, "line: %d (%d) => (AND) \n", yylineno,column_number); column_number+=yyleng; }
// "||"            { fprintf(yyout, "line: %d (%d) => (OR) \n", yylineno,column_number); column_number+=yyleng; }
// ";"             { fprintf(yyout, "line: %d (%d) => (SEMICOL) \n", yylineno,column_number); column_number+=yyleng; }
// ","             { fprintf(yyout, "line: %d (%d) => (COMMA) \n", yylineno,column_number); column_number+=yyleng; }
// "("             { fprintf(yyout, "<LPARENTESE> "); column_number+=yyleng; }
// ")"             { fprintf(yyout, "<RPARENTESE> "); column_number+=yyleng; }



// CODIGO QUE TAVA ANTES 


// %option noyywrap yylineno
// %{
// #include <stdio.h>
// int line_number = 1;
// int column_number = 1;

// %}

// letter          [A-Za-z]
// digit           [0-9]   
// number          {digit}+(\.{digit}+)?(E[+-]?{digit}+)?
// id              {letter} ({letter} | {digit})*
// delim           [ \t\n]
// ws              {delim}+
// Scomment        \/\/[^\n]*
// Mcomment        \/\*([^*]|\*+[^*/])*\*+\/
// other           .

// %%

// int             { fprintf(yyout, "%d(%d):%s(INT)\n", yylineno,column_number,yytext); column_number+=yyleng; }
// float           { fprintf(yyout, "%d(%d):%s(FLOAT)\n", yylineno,column_number,yytext); column_number+=yyleng; }
// bool            { fprintf(yyout, "%d(%d):%s(BOOL)\n", yylineno,column_number,yytext); column_number+=yyleng; }
// if              { fprintf(yyout, "%d(%d):%s(IF)\n", yylineno,column_number,yytext); column_number+=yyleng; }
// else            { fprintf(yyout, "%d(%d):%s(ELSE)\n", yylineno,column_number,yytext); column_number+=yyleng; }
// while           { fprintf(yyout, "%d(%d):%s(WHILE)\n", yylineno,column_number,yytext); column_number+=yyleng; }
// print           { fprintf(yyout, "%d(%d):%s(PRINT)\n", yylineno,column_number,yytext); column_number+=yyleng; }
// read            { fprintf(yyout, "%d(%d):%s(READ)\n", yylineno,column_number,yytext); column_number+=yyleng; }
// true            { fprintf(yyout, "%d(%d):%s(TRUE)\n", yylineno,column_number,yytext); column_number+=yyleng; }
// false           { fprintf(yyout, "%d(%d):%s(FALSE)\n", yylineno,column_number,yytext); column_number+=yyleng; }
// {number}        { fprintf(yyout, "%d(%d):%s(NUMBER)\n", yylineno,column_number,yytext); column_number+=yyleng; }
// {Scomment}      {}
// {Mcomment}      {}
// \n              { column_number=1; }
// {ws}            {}
// "+"             { fprintf(yyout, "%d(%d):+(PLUS)\n", yylineno,column_number); column_number+=yyleng; }
// "-"             { fprintf(yyout, "%d(%d):-(MINUS)\n", yylineno,column_number); column_number+=yyleng; }
// "*"             { fprintf(yyout, "%d(%d):-(TIMES)\n", yylineno,column_number); column_number+=yyleng; }
// "/"             { fprintf(yyout, "%d(%d):-(DIVISOR)\n", yylineno,column_number); column_number+=yyleng; }
// ":="            { fprintf(yyout, "%d(%d):-(EQ)\n", yylineno,column_number); column_number+=yyleng; }
// "<"             { fprintf(yyout, "%d(%d):-(LT)\n", yylineno,column_number); column_number+=yyleng; }
// "<="            { fprintf(yyout, "%d(%d):-(LE)\n", yylineno,column_number); column_number+=yyleng; }
// "<>"            { fprintf(yyout, "%d(%d):-(NE)\n", yylineno,column_number); column_number+=yyleng; }
// ">"             { fprintf(yyout, "%d(%d):-(GT)\n", yylineno,column_number); column_number+=yyleng; }
// ">="            { fprintf(yyout, "%d(%d):-(GE)\n", yylineno,column_number); column_number+=yyleng; }
// "&&"            { fprintf(yyout, "%d(%d):-(AND)\n", yylineno,column_number); column_number+=yyleng; }
// "||"            { fprintf(yyout, "%d(%d):-(OR)\n", yylineno,column_number); column_number+=yyleng; }
// ";"             { fprintf(yyout, "%d(%d):-(SCOL)\n", yylineno,column_number); column_number+=yyleng; }
// ","             { fprintf(yyout, "%d(%d):-(COMMA)\n", yylineno,column_number); column_number+=yyleng; }



// {other}         { fprintf(yyout,"Lexicalerror on line %d andcolumn%d. Input->\"%s\"\n", yylineno,column_number,yytext); column_number+=yyleng; }

// %%
     
//     int main(int argc, char *argv[]) {
//  = fopen(argv[1], "r");
//         yyout=stdout;
//     yylex();
//     fclose(yyin);
//     return 0;
// }

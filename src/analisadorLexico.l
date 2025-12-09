%option noyywrap yylineno

/*-------------------------- Seção de Definições em C --------------------------*/
%{
#include <stdio.h>
#include <string.h>
#include "analisadorSemantico.h"
#include "analisadorSintatico.tab.h"

// Variável global para contar as colunas manualmente
int column_number = 1;
int token_start_column = 1;
%}

/*-------------------------- Definições de Expressões Regulares --------------------------*/
letter          [A-Za-z]
digit           [0-9]
digitNZ         [1-9]   
number          [-]?{digitNZ}{digit}*|{digit}+
id              {letter}({letter}|{digit})*
delim           [ \t\r]
ws              {delim}+
Scomment        \/\/[^\n]*
Mcomment        \/\*([^*]|\*+[^*/])*\*+\/
string_literal  \"[^"\n]*\"
other           .

/*-------------------------- Regras Léxicas --------------------------*/
%%

"int"     { token_start_column = column_number; column_number+=yyleng; return T_INT; }
"bool"    { token_start_column = column_number; column_number+=yyleng; return T_BOOL; }
"if"      { token_start_column = column_number; column_number+=yyleng; return T_IF; }
"else"    { token_start_column = column_number; column_number+=yyleng; return T_ELSE; }
"while"   { token_start_column = column_number; column_number+=yyleng; return T_WHILE; }
"print"   { token_start_column = column_number; column_number+=yyleng; return T_PRINT; }
"read"    { token_start_column = column_number; column_number+=yyleng; return T_READ; }
"true"    { token_start_column = column_number; column_number+=yyleng; return T_TRUE; }
"false"   { token_start_column = column_number; column_number+=yyleng; return T_FALSE; }

{number}  { 
            token_start_column = column_number; 
            column_number+=yyleng;
            yylval.lexeme = strdup(yytext); 
            return T_NUMBER; 
          }

{id}      {
            token_start_column = column_number;
            column_number += yyleng;
            yylval.lexeme = strdup(yytext);
            return T_ID;
          }

{string_literal} { 
            token_start_column = column_number; 
            column_number += yyleng; 
            yylval.lexeme = strdup(yytext);
            return T_STRING; 
}

{Scomment} {}
{Mcomment} {}
{ws}       { column_number += yyleng; }
\n         { column_number = 1; }

"+"       { token_start_column = column_number; column_number+=yyleng; return T_PLUS; }
"-"       { token_start_column = column_number; column_number+=yyleng; return T_MINUS; }
"*"       { token_start_column = column_number; column_number+=yyleng; return T_TIMES; }
"/"       { token_start_column = column_number; column_number+=yyleng; return T_DIV; }
"="       { token_start_column = column_number; column_number+=yyleng; return T_ASSIGN; }
"=="      { token_start_column = column_number; column_number+=yyleng; return T_EQ; }
"!="      { token_start_column = column_number; column_number+=yyleng; return T_NE; }
"<"       { token_start_column = column_number; column_number+=yyleng; return T_LT; }
"<="      { token_start_column = column_number; column_number+=yyleng; return T_LE; }
">"       { token_start_column = column_number; column_number+=yyleng; return T_GT; }
">="      { token_start_column = column_number; column_number+=yyleng; return T_GE; }
"&&"      { token_start_column = column_number; column_number+=yyleng; return T_AND; }
"||"      { token_start_column = column_number; column_number+=yyleng; return T_OR; }
"!"       { token_start_column = column_number; column_number+=yyleng; return T_NOT; }

";"       { token_start_column = column_number; column_number+=yyleng; return T_SEMICOLON; }
"("       { token_start_column = column_number; column_number+=yyleng; return T_LPARENTESE; }
")"       { token_start_column = column_number; column_number+=yyleng; return T_RPARENTESE; }
"{"       { token_start_column = column_number; column_number+=yyleng; return T_LCHAVES; }
"}"       { token_start_column = column_number; column_number+=yyleng; return T_RCHAVES; }

{other}   { 
            fprintf(stderr,"Erro lexico na linha %d, coluna %d: \"%s\"\n", yylineno, column_number, yytext);
            column_number += yyleng; 
          }

%%

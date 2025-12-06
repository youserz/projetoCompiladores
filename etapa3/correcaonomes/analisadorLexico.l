%option noyywrap yylineno

%{
#include <stdio.h>
#include <string.h>
#include "semantica.h"              // Inclui nossas estruturas traduzidas
#include "analisadorSintatico.tab.h" // Tokens gerados pelo Bison

int column_number = 1;
int token_start_column = 1;
%}

/* --- Definições de Expressões Regulares --- */
letra           [A-Za-z]
digito          [0-9]
digitoNZ        [1-9]   
numero          [-]?{digitoNZ}{digito}*|{digito}+
identificador   {letra}({letra}|{digito})*
delimitador     [ \t\r]
espaco          {delimitador}+
comentario_linha \/\/[^\n]*
comentario_bloco \/\*([^*]|\*+[^*/])*\*+\/
string_literal  \"[^"\n]*\"
outro           .

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

{numero}  { 
            token_start_column = column_number; 
            column_number+=yyleng;
            yylval.lexema = strdup(yytext); // Passa o valor string para o Bison
            return T_NUMBER; 
          }

{identificador} {
            token_start_column = column_number;
            column_number += yyleng;
            yylval.lexema = strdup(yytext); // Passa o nome da variável
            return T_ID;
          }

{string_literal} { 
            token_start_column = column_number; 
            column_number += yyleng; 
            yylval.lexema = strdup(yytext); 
            return T_STRING; 
          }

{comentario_linha} {}
{comentario_bloco} {}
{espaco}           { column_number += yyleng; }
\n                 { column_number = 1; }

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

{outro}   { 
            fprintf(stderr,"Erro lexico na linha %d, coluna %d: \"%s\"\n", yylineno, column_number, yytext);
            column_number += yyleng; 
          }

%%
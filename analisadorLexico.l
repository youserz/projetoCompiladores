%option noyywrap yylineno

/*-------------------------- Seção de Definições em C --------------------------*/
%{
#include <stdio.h>
#include <string.h>
#include "parser.h"

// Variável global para contar as colunas manualmente
int column_number = 1;
int token_start_column = 1;

typedef struct {
    int id;
    char *lexeme;
    int line;
    int column;
} SymbolEntry;

#define MAX_SYMBOLS 100
SymbolEntry symbolTable[MAX_SYMBOLS];
int symbolCount = 0;

void insert_symbol(char *lexeme, int line, int column) {
    for (int i = 0; i < symbolCount; i++) {
        if (strcmp(symbolTable[i].lexeme, lexeme) == 0) {
            return;
        }
    }
    if (symbolCount < MAX_SYMBOLS) {
        symbolTable[symbolCount].id = symbolCount + 1;
        symbolTable[symbolCount].lexeme = strdup(lexeme);
        symbolTable[symbolCount].line = line;
        symbolTable[symbolCount].column = column;
        symbolCount++;
    }
}

void display_symbol_table() {
    printf("\n\n--- Tabela de Símbolos ---\n");
    printf("ID\tLexema\t\tPosição (Linha, Coluna)\n");
    printf("----------------------------------------\n");
    for (int i = 0; i < symbolCount; i++) {
        printf("%-3d\t%-15s\t(%d, %d)\n", symbolTable[i].id, symbolTable[i].lexeme, symbolTable[i].line, symbolTable[i].column);
    }
    printf("----------------------------------------\n");
}
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

/*-------------------------- Regras Léxicas (MODIFICADAS) --------------------------*/
%%

"int"             { token_start_column = column_number; column_number+=yyleng; return T_INT; }
"bool"            { token_start_column = column_number; column_number+=yyleng; return T_BOOL; }
"if"              { token_start_column = column_number; column_number+=yyleng; return T_IF; }
"else"            { token_start_column = column_number; column_number+=yyleng; return T_ELSE; }
"while"           { token_start_column = column_number; column_number+=yyleng; return T_WHILE; }
"print"           { token_start_column = column_number; column_number+=yyleng; return T_PRINT; }
"read"            { token_start_column = column_number; column_number+=yyleng; return T_READ; }
"true"            { token_start_column = column_number; column_number+=yyleng; return T_TRUE; }
"false"           { token_start_column = column_number; column_number+=yyleng; return T_FALSE; }

{number}          { token_start_column = column_number; column_number+=yyleng; return T_NUMBER; }
{id}              {
                    token_start_column = column_number;
                    insert_symbol(yytext, yylineno, column_number);
                    column_number += yyleng;
                    return T_ID;
                  }

{string_literal}  { token_start_column = column_number; column_number += yyleng; return T_STRING; }

{Scomment}      { token_start_column = column_number; column_number += yyleng; }
{Mcomment}      { token_start_column = column_number; column_number += yyleng; }
{ws}            { column_number += yyleng; }
\n              { column_number = 1; }

"+"               { token_start_column = column_number; column_number+=yyleng; return T_PLUS; }
"-"               { token_start_column = column_number; column_number+=yyleng; return T_MINUS; }
"*"               { token_start_column = column_number; column_number+=yyleng; return T_TIMES; }
"/"               { token_start_column = column_number; column_number+=yyleng; return T_DIV; }
"="               { token_start_column = column_number; column_number+=yyleng; return T_ASSIGN; }
"=="              { token_start_column = column_number; column_number+=yyleng; return T_EQ; }
"!="              { token_start_column = column_number; column_number+=yyleng; return T_NE; }
"<"               { token_start_column = column_number; column_number+=yyleng; return T_LT; }
"<="              { token_start_column = column_number; column_number+=yyleng; return T_LE; }
">"               { token_start_column = column_number; column_number+=yyleng; return T_GT; }
">="              { token_start_column = column_number; column_number+=yyleng; return T_GE; }
"&&"              { token_start_column = column_number; column_number+=yyleng; return T_AND; }
"||"              { token_start_column = column_number; column_number+=yyleng; return T_OR; }
"!"               { token_start_column = column_number; column_number+=yyleng; return T_NOT; }

";"               { token_start_column = column_number; column_number+=yyleng; return T_SEMICOLON; }
"("               { token_start_column = column_number; column_number+=yyleng; return T_LPARENTESE; }
")"               { token_start_column = column_number; column_number+=yyleng; return T_RPARENTESE; }
"{"               { token_start_column = column_number; column_number+=yyleng; return T_LCHAVES; }
"}"               { token_start_column = column_number; column_number+=yyleng; return T_RCHAVES; }

{other}           { 
                    token_start_column = column_number;
                    fprintf(stderr,"Erro lexico na linha %d, coluna %d. Caractere desconhecido: \"%s\"\n", yylineno, column_number, yytext);
                    column_number += yyleng; 
                  }

%%

/*-------------------------- Seção de Definições em C --------------------------*/
%{
#include <stdio.h>
#include <string.h>

int yylex(void);
void yyerror(const char *s);
extern void display_symbol_table(void);
extern int yylineno;
extern int token_start_column;
extern int column_number;
extern FILE *yyin;
%}

/*-------------------------- Definições do Bison --------------------------*/
%token T_INT T_BOOL
%token T_IF T_ELSE T_WHILE T_PRINT T_READ
%token T_TRUE T_FALSE
%token T_ID T_NUMBER
%token T_STRING

%token T_ASSIGN T_EQ T_NE T_LT T_LE T_GT T_GE
%token T_AND T_OR T_NOT
%token T_PLUS T_MINUS T_TIMES T_DIV

%token T_SEMICOLON T_LPARENTESE T_RPARENTESE T_LCHAVES T_RCHAVES

%define parse.error verbose

%right T_ASSIGN
%left T_OR
%left T_AND
%left T_EQ T_NE
%left T_LT T_LE T_GT T_GE
%left T_PLUS T_MINUS
%left T_TIMES T_DIV
%right T_NOT
%precedence T_UMINUS

%nonassoc T_IFX
%nonassoc T_ELSE

%start program_start

%%
/*-------------------------- Regras da Gramática (CORRIGIDAS) --------------------------*/

program_start:
    declaration_list
    ;

declaration_list: // vazio OU declaration_list declaration 
    | declaration_list declaration
    ;

declaration:
    variable_declaration
    | function_declaration
    ;

variable_declaration:
    type T_ID T_SEMICOLON
    | type T_ID T_ASSIGN expression T_SEMICOLON 
    ;

function_declaration:
    type T_ID T_LPARENTESE T_RPARENTESE block_statement
    ;

block_statement_list: // vazio OU block_statement_list statement 
    | block_statement_list statement
    ;

statement:
    variable_declaration { }
    | assignment_statement { }
    | if_statement { }
    | while_statement { }
    | io_statement { }
    | block_statement { }
    ;

type:
    T_INT
    | T_BOOL
    ;

assignment_statement:
    T_ID T_ASSIGN expression T_SEMICOLON
    ;

if_statement:
    T_IF T_LPARENTESE expression T_RPARENTESE statement %prec T_IFX // %prec T_IFX Resolve dangling else garantindo que o else sempre se liga ao if mais próximo.
    | T_IF T_LPARENTESE expression T_RPARENTESE statement T_ELSE statement
    ;

while_statement:
    T_WHILE T_LPARENTESE expression T_RPARENTESE statement
    ;

block_statement:
    T_LCHAVES block_statement_list T_RCHAVES
    ;

io_statement:
    T_PRINT T_LPARENTESE expression T_RPARENTESE T_SEMICOLON
    | T_READ T_LPARENTESE T_ID T_RPARENTESE T_SEMICOLON
    ;

expression:
    T_ID
    | T_NUMBER
    | T_TRUE
    | T_FALSE
    | T_STRING
    | expression T_PLUS expression
    | expression T_MINUS expression
    | expression T_TIMES expression
    | expression T_DIV expression
    | expression T_EQ expression
    | expression T_NE expression
    | expression T_LT expression
    | expression T_LE expression
    | expression T_GT expression
    | expression T_GE expression
    | expression T_AND expression
    | expression T_OR expression
    | T_NOT expression
    | T_MINUS expression %prec T_UMINUS
    | T_LPARENTESE expression T_RPARENTESE
    ;

%%
/*-------------------------- Seção de Código do Usuário (sem mudanças) --------------------------*/

int main(int argc, char *argv[]){
    if (argc < 2) {
        fprintf(stderr, "Uso: %s <arquivo_de_entrada>\n", argv[0]);
        return 1;
    }

    yyin = fopen(argv[1], "r");
    if (!yyin) {
        perror(argv[1]);
        return 1;
    }
    
    if (yyparse() == 0) {
        printf("aceita\n");
    }

    display_symbol_table();
    
    fclose(yyin);
    return 0;
}

void yyerror(const char *s) {
    fprintf(stderr, "Erro Sintatico na linha %d, coluna %d: %s\n", 
            yylineno, token_start_column, s);
}

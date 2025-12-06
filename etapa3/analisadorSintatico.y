%{
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include "analisadorSemantico.h"

int yylex(void);
void yyerror(const char *s);
extern int yylineno;
extern int token_start_column;
extern FILE *yyin;

/* Removemos a variável global current_decl_type e usamos a pilha ($0) */
%}

%code requires {
    #include "analisadorSemantico.h"
}

%union {
    char *lexeme;       
    DataType dtype;     
    ExprAttr expr;      
}

%token <lexeme> T_ID T_NUMBER T_STRING
%token T_TRUE T_FALSE
%token T_INT T_BOOL 
%token T_IF T_ELSE T_WHILE T_PRINT T_READ
%token T_ASSIGN T_EQ T_NE T_LT T_LE T_GT T_GE T_AND T_OR T_NOT
%token T_PLUS T_MINUS T_TIMES T_DIV
%token T_SEMICOLON T_LPARENTESE T_RPARENTESE T_LCHAVES T_RCHAVES

%type <dtype> type
%type <expr> expression

/* Marcadores para controlar Labels e Fluxo */
%type <lexeme> M_if_false M_else_jump M_while_start M_while_cond

/* Precedência */
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

program_start:
    { init_symbol_table(); } declaration_list
    ;

declaration_list:
    | declaration_list declaration
    ;

declaration:
    variable_declaration
    | function_declaration
    ;

/* --- RESOLUÇÃO DO CONFLITO DE VARIÁVEL VS FUNÇÃO --- */
variable_declaration:
    type single_var_decl T_SEMICOLON
    ;

single_var_decl:
      T_ID {
        /* $<dtype>0 refere-se ao 'type' na regra variable_declaration acima */
        DataType t = $<dtype>0; 
        if (!insert_symbol($1, t)) {
            fprintf(stderr, "Erro Semantico [%d]: Variavel '%s' redeclarada.\n", yylineno, $1);
        }
      }
    | T_ID T_ASSIGN expression {
        DataType t = $<dtype>0; /* Pega o tipo da pilha anterior */
        if (!insert_symbol($1, t)) {
            fprintf(stderr, "Erro Semantico [%d]: Variavel '%s' redeclarada.\n", yylineno, $1);
        } else {
            if (t != $3.type && $3.type != TYPE_ERROR) {
                fprintf(stderr, "Erro Semantico [%d]: Tipo incompativel.\n", yylineno);
            }
            emit("%s = %s", $1, $3.addr);
        }
      }
    ;

function_declaration:
    type T_ID T_LPARENTESE T_RPARENTESE block_statement
    ;

block_statement:
    T_LCHAVES { enter_scope(); } block_statement_list T_RCHAVES { exit_scope(); }
    ;

block_statement_list:
    | block_statement_list statement
    ;

statement:
      variable_declaration
    | assignment_statement
    | if_statement
    | while_statement
    | io_statement
    | block_statement
    ;

type:
      T_INT  { $$ = TYPE_INT; }
    | T_BOOL { $$ = TYPE_BOOL; }
    ;

assignment_statement:
    T_ID T_ASSIGN expression T_SEMICOLON {
        SymbolEntry *entry = lookup_symbol($1);
        if (entry == NULL) {
            fprintf(stderr, "Erro Semantico [%d]: Variavel '%s' nao declarada.\n", yylineno, $1);
        } else {
            if (entry->type != $3.type && $3.type != TYPE_ERROR) {
                fprintf(stderr, "Erro Semantico [%d]: Atribuicao incompativel.\n", yylineno);
            }
            emit("%s = %s", $1, $3.addr);
        }
    }
    ;

/* --- IF STATEMENT COM MARCADORES --- */

if_statement:
    T_IF T_LPARENTESE expression T_RPARENTESE M_if_false statement M_else_jump else_part
    {
        /* Final do IF: Imprime o label de saída (L_end) gerado pelo M_else_jump */
        emit_label($7); 
    }
    ;

/* Marcador 1: Gera label FALSE e testa a condição */
M_if_false: 
    {
        /* CORREÇÃO: Usar -1 para pular o RPARENTESE e pegar a expression */
        if ($<expr>-1.type != TYPE_BOOL) fprintf(stderr, "Erro Semantico [%d]: IF requer bool.\n", yylineno);
        char *L_false = new_label();
        emit("ifFalse %s goto %s", $<expr>-1.addr, L_false);
        $$ = L_false; 
    }
    ;

/* Marcador 2: Prepara o pulo do ELSE e coloca o label FALSE */
M_else_jump:
    {
        char *L_end = new_label();
        emit("goto %s", L_end);       // Pula o else se veio do if
        /* Acessa M_if_false em $-1 (pois statement é $0) */
        emit_label($<lexeme>-1);      // Cola o label L_false aqui
        $$ = L_end;                   // Retorna L_end para ser usado no final
    }
    ;

else_part:
    %prec T_IFX /* Sem else */
    | T_ELSE statement
    ;

/* --- WHILE STATEMENT COM MARCADORES --- */

while_statement:
    T_WHILE T_LPARENTESE M_while_start expression T_RPARENTESE M_while_cond statement
    {
        emit("goto %s", $3); // Pula para M_while_start
        emit_label($6);      // Cola M_while_cond (saída)
    }
    ;

M_while_start:
    {
        char *L_start = new_label();
        emit_label(L_start);
        $$ = L_start;
    }
    ;

M_while_cond:
    {
        /* CORREÇÃO: Usar -1 para pular o RPARENTESE e pegar a expression */
        if ($<expr>-1.type != TYPE_BOOL) fprintf(stderr, "Erro Semantico [%d]: WHILE requer bool.\n", yylineno); 
        char *L_end = new_label();
        emit("ifFalse %s goto %s", $<expr>-1.addr, L_end);
        $$ = L_end;
    }
    ;

io_statement:
      T_PRINT T_LPARENTESE expression T_RPARENTESE T_SEMICOLON { emit("print %s", $3.addr); }
    | T_READ T_LPARENTESE T_ID T_RPARENTESE T_SEMICOLON { emit("read %s", $3); }
    ;

expression:
      T_ID { 
          SymbolEntry *e = lookup_symbol($1);
          if (!e) {
              fprintf(stderr, "Erro Semantico [%d]: '%s' nao declarado.\n", yylineno, $1);
              $$.type = TYPE_ERROR;
          } else {
              $$.type = e->type;
              strcpy($$.addr, $1);
          }
      }
    | T_NUMBER { $$.type = TYPE_INT; strcpy($$.addr, $1); }
    | T_TRUE   { $$.type = TYPE_BOOL; strcpy($$.addr, "true"); }
    | T_FALSE  { $$.type = TYPE_BOOL; strcpy($$.addr, "false"); }
    | T_STRING { $$.type = TYPE_VOID; strcpy($$.addr, $1); }
    
    | expression T_PLUS expression {
        $$.type = check_arithmetic($1.type, $3.type);
        char *t = new_temp(); emit("%s = %s + %s", t, $1.addr, $3.addr); strcpy($$.addr, t);
    }
    | expression T_MINUS expression {
        $$.type = check_arithmetic($1.type, $3.type);
        char *t = new_temp(); emit("%s = %s - %s", t, $1.addr, $3.addr); strcpy($$.addr, t);
    }
    | expression T_TIMES expression {
        $$.type = check_arithmetic($1.type, $3.type);
        char *t = new_temp(); emit("%s = %s * %s", t, $1.addr, $3.addr); strcpy($$.addr, t);
    }
    | expression T_DIV expression {
        $$.type = check_arithmetic($1.type, $3.type);
        char *t = new_temp(); emit("%s = %s / %s", t, $1.addr, $3.addr); strcpy($$.addr, t);
    }
    | expression T_LT expression {
        $$.type = check_relational($1.type, $3.type);
        char *t = new_temp(); emit("%s = %s < %s", t, $1.addr, $3.addr); strcpy($$.addr, t);
    }
    | expression T_GT expression {
        $$.type = check_relational($1.type, $3.type);
        char *t = new_temp(); emit("%s = %s > %s", t, $1.addr, $3.addr); strcpy($$.addr, t);
    }
    | expression T_LE expression {
        $$.type = check_relational($1.type, $3.type);
        char *t = new_temp(); emit("%s = %s <= %s", t, $1.addr, $3.addr); strcpy($$.addr, t);
    }
    | expression T_GE expression {
        $$.type = check_relational($1.type, $3.type);
        char *t = new_temp(); emit("%s = %s >= %s", t, $1.addr, $3.addr); strcpy($$.addr, t);
    }
    | expression T_EQ expression {
         char *t = new_temp(); emit("%s = %s == %s", t, $1.addr, $3.addr); strcpy($$.addr, t);
         if ($1.type == $3.type) $$.type = TYPE_BOOL; else $$.type = TYPE_ERROR;
    }
    | expression T_NE expression {
         char *t = new_temp(); emit("%s = %s != %s", t, $1.addr, $3.addr); strcpy($$.addr, t);
         if ($1.type == $3.type) $$.type = TYPE_BOOL; else $$.type = TYPE_ERROR;
    }
    | expression T_AND expression {
        $$.type = check_logical($1.type, $3.type);
        char *t = new_temp(); emit("%s = %s && %s", t, $1.addr, $3.addr); strcpy($$.addr, t);
    }
    | expression T_OR expression {
        $$.type = check_logical($1.type, $3.type);
        char *t = new_temp(); emit("%s = %s || %s", t, $1.addr, $3.addr); strcpy($$.addr, t);
    }
    | T_NOT expression {
        $$.type = check_logical($2.type, TYPE_BOOL);
        char *t = new_temp(); emit("%s = !%s", t, $2.addr); strcpy($$.addr, t);
    }
    | T_LPARENTESE expression T_RPARENTESE { $$ = $2; }
    ;

%%

int main(int argc, char *argv[]){
    if (argc < 2) {
        fprintf(stderr, "Uso: %s <arquivo_entrada>\n", argv[0]);
        return 1;
    }
    yyin = fopen(argv[1], "r");
    if (!yyin) { perror(argv[1]); return 1; }
    
    printf("--- Compilacao Iniciada ---\n");
    yyparse();
    printf("--- Compilacao Finalizada ---\n");
    
    fclose(yyin);
    return 0;
}

void yyerror(const char *s) {
    fprintf(stderr, "Erro Sintatico na linha %d: %s\n", yylineno, s);
}
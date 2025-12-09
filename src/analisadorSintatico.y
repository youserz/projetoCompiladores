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

/* * Union define os tipos que os tokens e não-terminais podem carregar.
 * lexeme: para identificadores e literais (string pura).
 * dtype: para passagem de tipos (int/bool) nas declarações.
 * expr: struct completa com tipo e endereço (t1, L2) para gerar código.
 */

%union {
    char *lexeme;       
    DataType dtype;     
    ExprAttr expr;      
}

/* Tokens e Tipos */
%token <lexeme> T_ID T_NUMBER T_STRING
%token T_TRUE T_FALSE
%token T_INT T_BOOL 
%token T_IF T_ELSE T_WHILE T_PRINT T_READ
%token T_ASSIGN T_EQ T_NE T_LT T_LE T_GT T_GE T_AND T_OR T_NOT
%token T_PLUS T_MINUS T_TIMES T_DIV
%token T_SEMICOLON T_LPARENTESE T_RPARENTESE T_LCHAVES T_RCHAVES

%type <dtype> type
%type <expr> expression

/* * Marcadores para Controle de Fluxo:
 * Usamos estes não-terminais vazios para gerar labels e gotos
 * no meio das regras de IF e WHILE sem quebrar a gramática LR.
 */
%type <lexeme> M_if_false M_else_jump M_while_start M_while_cond

/* * Precedência de Operadores:
 * Definida da menor para a maior prioridade para resolver conflitos
 * e garantir a ordem correta das operações matemáticas e lógicas.
 */
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
    declaration_list
    ;

declaration_list:
    | declaration_list declaration
    ;

declaration:
    variable_declaration
    | function_declaration
    ;

/* --- Declaração de Variáveis --- */
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
            /* Verifica compatibilidade de tipos na inicialização */
            if (t != $3.type && $3.type != TYPE_ERROR) {
                fprintf(stderr, "Erro Semantico [%d]: Tipo incompativel.\n", yylineno);
            }
            /* Gera código: x = valor */
            printf("%s = %s\n", $1, $3.addr);
        }
      }
    ;

function_declaration:
    type T_ID T_LPARENTESE T_RPARENTESE block_statement
    ;
/* --- Blocos e Escopos --- */
/* enter_scope() é chamado antes do bloco para preparar a tabela */
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
            printf("%s = %s\n", $1, $3.addr);
        }
    }
    ;

/* * --- ESTRUTURA IF/ELSE ---
 * Utiliza marcadores para gerar labels em ordem linear.
 * Estrutura: if (expr) [M_false] stmt [M_jump] else stmt [Label_Fim]
 */
if_statement:
    T_IF T_LPARENTESE expression T_RPARENTESE M_if_false statement M_else_jump else_part
    {
        /* Final do IF: Imprime o label de saída (L_end) gerado pelo M_else_jump */
        printf("%s\n",$7); 
    }
    ;

/* Marcador 1: Gera label FALSE e testa a condição */
M_if_false: 
    {
        /* Checagem de Tipo: IF exige booleano */
        /* Usa $<expr>-1 pois expression está antes do RPARENTESE */
        if ($<expr>-1.type != TYPE_BOOL) fprintf(stderr, "Erro Semantico [%d]: IF requer bool.\n", yylineno);
        char *L_false = new_label();
        /* Gera salto condicional: se falso, pule para o label do else/fim */
        printf("ifFalse %s goto %s\n", $<expr>-1.addr, L_false);
        $$ = L_false; 
    }
    ;

/* Marcador 2: Prepara o pulo do ELSE e coloca o label FALSE */
M_else_jump:
    {
        char *L_end = new_label();
        printf("goto %s\n", L_end);       // Pula o else se veio do if
        /* Acessa M_if_false em $-1 (pois statement é $0) */
        printf("%s\n", $<lexeme>-1);      // Cola o label L_false aqui
        $$ = L_end;                   // Retorna L_end para ser usado no final
    }
    ;

else_part:
    %prec T_IFX /* Regra sem ELSE: precedência menor (shift no else) */
    | T_ELSE statement
    ;

/* * --- ESTRUTURA WHILE ---
 * Estrutura: while ( [M_start] expr ) [M_cond] stmt [Goto_Start]
 */
while_statement:
    T_WHILE T_LPARENTESE M_while_start expression T_RPARENTESE M_while_cond statement
    {
        printf("goto %s\n", $3); // Volta para o início do loop
        printf("%s\n",$6);       // Cola label de saída
    }
    ;

M_while_start:
    {
        char *L_start = new_label();
        printf("%s\n", L_start); // Marca o início do loop
        $$ = L_start;
    }
    ;

M_while_cond:
    {
        /* Usa $<expr>-1 pois expression está antes do RPARENTESE */
        if ($<expr>-1.type != TYPE_BOOL) fprintf(stderr, "Erro Semantico [%d]: WHILE requer bool.\n", yylineno); 
        char *L_end = new_label();
        printf("ifFalse %s goto %s\n", $<expr>-1.addr, L_end); // Se condição falsa, sai do loop
        $$ = L_end;
    }
    ;

io_statement:
      T_PRINT T_LPARENTESE expression T_RPARENTESE T_SEMICOLON { printf("print %s\n", $3.addr); }
    | T_READ T_LPARENTESE T_ID T_RPARENTESE T_SEMICOLON { printf("read %s\n", $3); }
    ;

/* --- EXPRESSÕES --- */
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
    | T_STRING { $$.type = TYPE_STRING; strcpy($$.addr, $1); }
    
    /* Operações Aritméticas: Geram código de 3 endereços (t = a op b) */
    | expression T_PLUS expression {
        $$.type = check_arithmetic($1.type, $3.type);
        char *t = new_temp(); printf("%s = %s + %s\n", t, $1.addr, $3.addr); strcpy($$.addr, t);
    }
    | expression T_MINUS expression {
        $$.type = check_arithmetic($1.type, $3.type);
        char *t = new_temp(); printf("%s = %s - %s\n", t, $1.addr, $3.addr); strcpy($$.addr, t);
    }
    | expression T_TIMES expression {
        $$.type = check_arithmetic($1.type, $3.type);
        char *t = new_temp(); printf("%s = %s * %s\n", t, $1.addr, $3.addr); strcpy($$.addr, t);
    }
    | expression T_DIV expression {
        $$.type = check_arithmetic($1.type, $3.type);
        char *t = new_temp(); printf("%s = %s / %s\n", t, $1.addr, $3.addr); strcpy($$.addr, t);
    }
    /* Operador Unário */
    | T_MINUS expression %prec T_UMINUS {
        // Verificação de Tipo: Unário só aceita INT
        if ($2.type != TYPE_INT) {
            fprintf(stderr, "Erro Semantico [%d]: Operacao unaria (-) requer int.\n", yylineno);
            $$.type = TYPE_ERROR; 
        } else {
            $$.type = TYPE_INT;
        }

        // Geração de Código
        char *t = new_temp();
        // Gera instrução: t1 = -t0
        printf("%s = -%s\n", t, $2.addr); 
        
        // Propagação
        strcpy($$.addr, t);
    }
    /* Operações Relacionais */
    | expression T_LT expression {
        $$.type = check_relational($1.type, $3.type);
        char *t = new_temp(); printf("%s = %s < %s\n", t, $1.addr, $3.addr); strcpy($$.addr, t);
    }
    | expression T_GT expression {
        $$.type = check_relational($1.type, $3.type);
        char *t = new_temp(); printf("%s = %s > %s\n", t, $1.addr, $3.addr); strcpy($$.addr, t);
    }
    | expression T_LE expression {
        $$.type = check_relational($1.type, $3.type);
        char *t = new_temp(); printf("%s = %s <= %s\n", t, $1.addr, $3.addr); strcpy($$.addr, t);
    }
    | expression T_GE expression {
        $$.type = check_relational($1.type, $3.type);
        char *t = new_temp(); printf("%s = %s >= %s\n", t, $1.addr, $3.addr); strcpy($$.addr, t);
    }
    | expression T_EQ expression {
         char *t = new_temp(); printf("%s = %s == %s\n", t, $1.addr, $3.addr); strcpy($$.addr, t);
         if ($1.type == $3.type) $$.type = TYPE_BOOL; else $$.type = TYPE_ERROR;
    }
    | expression T_NE expression {
         char *t = new_temp(); printf("%s = %s != %s\n", t, $1.addr, $3.addr); strcpy($$.addr, t);
         if ($1.type == $3.type) $$.type = TYPE_BOOL; else $$.type = TYPE_ERROR;
    }
    /* Operações Lógicas */
    | expression T_AND expression {
        $$.type = check_logical($1.type, $3.type);
        char *t = new_temp(); printf("%s = %s && %s\n", t, $1.addr, $3.addr); strcpy($$.addr, t);
    }
    | expression T_OR expression {
        $$.type = check_logical($1.type, $3.type);
        char *t = new_temp(); printf("%s = %s || %s\n", t, $1.addr, $3.addr); strcpy($$.addr, t);
    }
    | T_NOT expression {
        $$.type = check_logical($2.type, TYPE_BOOL);
        char *t = new_temp(); printf("%s = !%s\n", t, $2.addr); strcpy($$.addr, t);
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

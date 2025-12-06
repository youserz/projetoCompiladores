%{
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include "semantica.h" // Inclui o novo header traduzido

int yylex(void);
void yyerror(const char *s);
extern int yylineno;
extern FILE *yyin;
%}

/* Garante que o header seja incluído no arquivo .tab.h gerado */
%code requires {
    #include "semantica.h"
}

/* União: define os tipos que podem ser transportados pelos tokens */
%union {
    char *lexema;          // Para T_ID, T_NUMBER (string)
    TipoDado tipo_dado;    // Para T_INT, T_BOOL (enum)
    AtributosExpressao expr; // Para expressões (tipo + endereço)
}

/* Declaração dos Tokens com seus tipos */
%token <lexema> T_ID T_NUMBER T_STRING
%token T_TRUE T_FALSE
%token T_INT T_BOOL 
%token T_IF T_ELSE T_WHILE T_PRINT T_READ
%token T_ASSIGN T_EQ T_NE T_LT T_LE T_GT T_GE T_AND T_OR T_NOT
%token T_PLUS T_MINUS T_TIMES T_DIV
%token T_SEMICOLON T_LPARENTESE T_RPARENTESE T_LCHAVES T_RCHAVES

/* Declaração dos Não-Terminais */
%type <tipo_dado> type
%type <expr> expression

/* Marcadores para geração de rótulos (Labels) */
%type <lexema> Marcador_If_Falso Marcador_Else_Pulo Marcador_While_Inicio Marcador_While_Condicao

/* Precedência de Operadores */
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

/* --- Gramática Principal --- */

program_start:
    { tabela_iniciar(); } declaration_list
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
    type var_decl_core T_SEMICOLON
    ;

var_decl_core:
    single_var_decl
    ;

single_var_decl:
      T_ID {
        /* Pega o tipo declarado anteriormente na pilha ($<tipo_dado>0) */
        TipoDado t = $<tipo_dado>0; 
        if (!tabela_inserir($1, t)) {
            fprintf(stderr, "Erro Semantico [%d]: Variavel '%s' redeclarada.\n", yylineno, $1);
        }
      }
    | T_ID T_ASSIGN expression {
        TipoDado t = $<tipo_dado>0;
        if (!tabela_inserir($1, t)) {
            fprintf(stderr, "Erro Semantico [%d]: Variavel '%s' redeclarada.\n", yylineno, $1);
        } else {
            if (t != $3.tipo && $3.tipo != TIPO_ERRO) {
                fprintf(stderr, "Erro Semantico [%d]: Tipo incompativel na atribuicao.\n", yylineno);
            }
            gerar_codigo("%s = %s", $1, $3.endereco);
        }
      }
    ;

/* --- Declaração de Funções --- */
function_declaration:
    type T_ID T_LPARENTESE T_RPARENTESE block_statement
    ;

block_statement:
    T_LCHAVES { escopo_entrar(); } block_statement_list T_RCHAVES { escopo_sair(); }
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
      T_INT  { $$ = TIPO_INT; }
    | T_BOOL { $$ = TIPO_BOOL; }
    ;

/* --- Atribuição --- */
assignment_statement:
    T_ID T_ASSIGN expression T_SEMICOLON {
        EntradaTabela *entrada = tabela_buscar($1);
        if (entrada == NULL) {
            fprintf(stderr, "Erro Semantico [%d]: Variavel '%s' nao declarada.\n", yylineno, $1);
        } else {
            if (entrada->tipo != $3.tipo && $3.tipo != TIPO_ERRO) {
                fprintf(stderr, "Erro Semantico [%d]: Atribuicao incompativel.\n", yylineno);
            }
            gerar_codigo("%s = %s", $1, $3.endereco);
        }
    }
    ;

/* --- Estrutura IF/ELSE (Sem Conflitos) --- */
if_statement:
    T_IF T_LPARENTESE expression T_RPARENTESE Marcador_If_Falso statement Marcador_Else_Pulo else_part
    {
        /* Imprime o rótulo de saída final (L_fim) */
        gerar_codigo_rotulo($7); 
    }
    ;

Marcador_If_Falso: 
    {
        /* Pega a expressão antes do ')' e gera o teste */
        if ($<expr>-1.tipo != TIPO_BOOL) fprintf(stderr, "Erro Semantico [%d]: IF requer bool.\n", yylineno);
        char *L_falso = gerar_rotulo();
        gerar_codigo("ifFalse %s goto %s", $<expr>-1.endereco, L_falso);
        $$ = L_falso; 
    }
    ;

Marcador_Else_Pulo:
    {
        char *L_fim = gerar_rotulo();
        gerar_codigo("goto %s", L_fim);     // Pula o else se o if foi verdadeiro
        gerar_codigo_rotulo($<lexema>-1);   // Coloca o label de Falso aqui
        $$ = L_fim;
    }
    ;

else_part:
    %prec T_IFX /* Caso sem else */
    | T_ELSE statement
    ;

/* --- Estrutura WHILE --- */
while_statement:
    T_WHILE T_LPARENTESE Marcador_While_Inicio expression T_RPARENTESE Marcador_While_Condicao statement
    {
        gerar_codigo("goto %s", $3); // Volta para o início
        gerar_codigo_rotulo($6);     // Rótulo de saída
    }
    ;

Marcador_While_Inicio:
    {
        char *L_inicio = gerar_rotulo();
        gerar_codigo_rotulo(L_inicio);
        $$ = L_inicio;
    }
    ;

Marcador_While_Condicao:
    {
        if ($<expr>-1.tipo != TIPO_BOOL) fprintf(stderr, "Erro Semantico [%d]: WHILE requer bool.\n", yylineno); 
        char *L_saida = gerar_rotulo();
        gerar_codigo("ifFalse %s goto %s", $<expr>-1.endereco, L_saida);
        $$ = L_saida;
    }
    ;

/* --- Entrada e Saída --- */
io_statement:
      T_PRINT T_LPARENTESE expression T_RPARENTESE T_SEMICOLON { gerar_codigo("print %s", $3.endereco); }
    | T_READ T_LPARENTESE T_ID T_RPARENTESE T_SEMICOLON { gerar_codigo("read %s", $3); }
    ;

/* --- Expressões --- */
expression:
      T_ID { 
          EntradaTabela *e = tabela_buscar($1);
          if (!e) {
              fprintf(stderr, "Erro Semantico [%d]: '%s' nao declarado.\n", yylineno, $1);
              $$.tipo = TIPO_ERRO;
          } else {
              $$.tipo = e->tipo;
              strcpy($$.endereco, $1);
          }
      }
    | T_NUMBER { $$.tipo = TIPO_INT; strcpy($$.endereco, $1); }
    | T_TRUE   { $$.tipo = TIPO_BOOL; strcpy($$.endereco, "true"); }
    | T_FALSE  { $$.tipo = TIPO_BOOL; strcpy($$.endereco, "false"); }
    | T_STRING { $$.tipo = TIPO_VOID; strcpy($$.endereco, $1); }
    
    /* Aritmética */
    | expression T_PLUS expression {
        $$.tipo = verificar_aritmetico($1.tipo, $3.tipo);
        char *t = gerar_temp(); 
        gerar_codigo("%s = %s + %s", t, $1.endereco, $3.endereco); 
        strcpy($$.endereco, t);
    }
    | expression T_MINUS expression {
        $$.tipo = verificar_aritmetico($1.tipo, $3.tipo);
        char *t = gerar_temp(); 
        gerar_codigo("%s = %s - %s", t, $1.endereco, $3.endereco); 
        strcpy($$.endereco, t);
    }
    | expression T_TIMES expression {
        $$.tipo = verificar_aritmetico($1.tipo, $3.tipo);
        char *t = gerar_temp(); gerar_codigo("%s = %s * %s", t, $1.endereco, $3.endereco); strcpy($$.endereco, t);
    }
    | expression T_DIV expression {
        $$.tipo = verificar_aritmetico($1.tipo, $3.tipo);
        char *t = gerar_temp(); gerar_codigo("%s = %s / %s", t, $1.endereco, $3.endereco); strcpy($$.endereco, t);
    }
    
    /* Relacional */
    | expression T_LT expression {
        $$.tipo = verificar_relacional($1.tipo, $3.tipo);
        char *t = gerar_temp(); gerar_codigo("%s = %s < %s", t, $1.endereco, $3.endereco); strcpy($$.endereco, t);
    }
    | expression T_GT expression {
        $$.tipo = verificar_relacional($1.tipo, $3.tipo);
        char *t = gerar_temp(); gerar_codigo("%s = %s > %s", t, $1.endereco, $3.endereco); strcpy($$.endereco, t);
    }
    | expression T_LE expression {
        $$.tipo = verificar_relacional($1.tipo, $3.tipo);
        char *t = gerar_temp(); gerar_codigo("%s = %s <= %s", t, $1.endereco, $3.endereco); strcpy($$.endereco, t);
    }
    | expression T_GE expression {
        $$.tipo = verificar_relacional($1.tipo, $3.tipo);
        char *t = gerar_temp(); gerar_codigo("%s = %s >= %s", t, $1.endereco, $3.endereco); strcpy($$.endereco, t);
    }
    | expression T_EQ expression {
         char *t = gerar_temp(); gerar_codigo("%s = %s == %s", t, $1.endereco, $3.endereco); strcpy($$.endereco, t);
         if ($1.tipo == $3.tipo) $$.tipo = TIPO_BOOL; else $$.tipo = TIPO_ERRO;
    }
    | expression T_NE expression {
         char *t = gerar_temp(); gerar_codigo("%s = %s != %s", t, $1.endereco, $3.endereco); strcpy($$.endereco, t);
         if ($1.tipo == $3.tipo) $$.tipo = TIPO_BOOL; else $$.tipo = TIPO_ERRO;
    }
    
    /* Lógica */
    | expression T_AND expression {
        $$.tipo = verificar_logico($1.tipo, $3.tipo);
        char *t = gerar_temp(); gerar_codigo("%s = %s && %s", t, $1.endereco, $3.endereco); strcpy($$.endereco, t);
    }
    | expression T_OR expression {
        $$.tipo = verificar_logico($1.tipo, $3.tipo);
        char *t = gerar_temp(); gerar_codigo("%s = %s || %s", t, $1.endereco, $3.endereco); strcpy($$.endereco, t);
    }
    | T_NOT expression {
        $$.tipo = verificar_logico($2.tipo, TIPO_BOOL);
        char *t = gerar_temp(); gerar_codigo("%s = !%s", t, $2.endereco); strcpy($$.endereco, t);
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
#ifndef ANALISADOR_SEMANTICO_H
#define ANALISADOR_SEMANTICO_H

#include <stdio.h>
#include <stdlib.h>
#include <string.h>

// --- Definição dos Tipos de Dados da Linguagem Mini-C ---
typedef enum { 
    TIPO_INT, 
    TIPO_BOOL, 
    TIPO_VOID, 
    TIPO_ERRO 
} TipoDado;

// --- Estrutura para Atributos de Expressões (usada no Bison) ---
// Carrega o tipo (para verificação) e o endereço (para geração de código)
typedef struct {
    TipoDado tipo;
    char endereco[64]; // Ex: "t1", "x", "10"
} AtributosExpressao;

// --- Estrutura da Tabela de Símbolos ---
typedef struct EntradaTabela {
    char *lexema;              // Nome da variável
    TipoDado tipo;             // Tipo da variável
    int nivel_escopo;          // Profundidade do escopo (0 = global)
    struct EntradaTabela *prox;// Ponteiro para o próximo (Lista Encadeada)
} EntradaTabela;

// --- Funções da Tabela de Símbolos e Escopo ---
void tabela_iniciar();
void escopo_entrar();
void escopo_sair();
int tabela_inserir(char *lexema, TipoDado tipo);
EntradaTabela* tabela_buscar(char *lexema);

// --- Funções de Geração de Código Intermediário ---
char* gerar_temp();                // Gera t1, t2...
char* gerar_rotulo();              // Gera L1, L2...
void gerar_codigo(const char *fmt, ...); // Imprime instrução (ex: t1 = a + b)
void gerar_codigo_rotulo(char *rotulo);  // Imprime rótulo (ex: L1:)

// --- Funções de Verificação de Tipos (Semântica) ---
TipoDado verificar_aritmetico(TipoDado t1, TipoDado t2);
TipoDado verificar_relacional(TipoDado t1, TipoDado t2);
TipoDado verificar_logico(TipoDado t1, TipoDado t2);

#endif
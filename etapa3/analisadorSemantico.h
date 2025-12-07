#ifndef ANALISADOR_SEMANTICO_H
#define ANALISADOR_SEMANTICO_H

#include <stdio.h>
#include <stdlib.h>
#include <string.h>

// Definição dos Tipos de Dados da Linguagem
typedef enum { TYPE_INT, TYPE_BOOL, TYPE_STRING, TYPE_ERROR } DataType;

// Estrutura usada dentro do Bison para passar tipo e endereço
typedef struct {
    DataType type;
    char addr[64]; // Ex: "t1", "x", "10"
} ExprAttr;

// --- Tabela de Símbolos ---
typedef struct SymbolEntry {
    char *lexeme;
    DataType type;
    int scope_level;
    struct SymbolEntry *next;
} SymbolEntry;

// Funções de Tabela de Símbolos
void enter_scope();
void exit_scope();
int insert_symbol(char *lexeme, DataType type);
SymbolEntry* lookup_symbol(char *lexeme);

// Funções de Geração de Código
char* new_temp();
char* new_label();

// Verificações de Tipos
DataType check_arithmetic(DataType t1, DataType t2);
DataType check_relational(DataType t1, DataType t2);
DataType check_logical(DataType t1, DataType t2);

#endif

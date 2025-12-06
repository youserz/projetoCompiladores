#include "analisadorSemantico.h"
#include <stdarg.h> // <--- ESSENCIAL PARA O ERRO DO va_start

int current_scope = 0;
int temp_count = 0;
int label_count = 0;

SymbolEntry *symbol_table = NULL;

void init_symbol_table() {
    symbol_table = NULL;
    current_scope = 0;
    temp_count = 0;
    label_count = 0;
}

void enter_scope() {
    current_scope++;
}

void exit_scope() {
    SymbolEntry *current = symbol_table;
    SymbolEntry *prev = NULL;
    
    while (current != NULL) {
        if (current->scope_level == current_scope) {
            SymbolEntry *to_delete = current;
            if (prev == NULL) {
                symbol_table = current->next;
                current = symbol_table;
            } else {
                prev->next = current->next;
                current = current->next;
            }
            free(to_delete->lexeme);
            free(to_delete);
        } else {
            prev = current;
            current = current->next;
        }
    }
    current_scope--;
}

int insert_symbol(char *lexeme, DataType type) {
    SymbolEntry *current = symbol_table;
    while (current != NULL) {
        if (strcmp(current->lexeme, lexeme) == 0 && current->scope_level == current_scope) {
            return 0; // Erro: Redeclaração no mesmo escopo
        }
        current = current->next;
    }

    SymbolEntry *new_entry = (SymbolEntry*)malloc(sizeof(SymbolEntry));
    new_entry->lexeme = strdup(lexeme);
    new_entry->type = type;
    new_entry->scope_level = current_scope;
    new_entry->next = symbol_table;
    symbol_table = new_entry;
    return 1;
}

SymbolEntry* lookup_symbol(char *lexeme) {
    SymbolEntry *current = symbol_table;
    while (current != NULL) {
        if (strcmp(current->lexeme, lexeme) == 0) {
            return current;
        }
        current = current->next;
    }
    return NULL;
}

char* new_temp() {
    char *name = (char*)malloc(10);
    sprintf(name, "t%d", ++temp_count);
    return name;
}

char* new_label() {
    char *name = (char*)malloc(10);
    sprintf(name, "L%d", ++label_count);
    return name;
}

void emit(const char *fmt, ...) {
    va_list args;
    va_start(args, fmt);
    vprintf(fmt, args);
    printf("\n");
    va_end(args);
}

void emit_label(char *label) {
    printf("%s:\n", label);
}

DataType check_arithmetic(DataType t1, DataType t2) {
    if (t1 == TYPE_INT && t2 == TYPE_INT) return TYPE_INT;
    return TYPE_ERROR;
}

DataType check_relational(DataType t1, DataType t2) {
    if (t1 == TYPE_INT && t2 == TYPE_INT) return TYPE_BOOL;
    return TYPE_ERROR;
}

DataType check_logical(DataType t1, DataType t2) {
    if (t1 == TYPE_BOOL && t2 == TYPE_BOOL) return TYPE_BOOL;
    return TYPE_ERROR;
}
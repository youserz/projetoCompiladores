#include "analisadorSemantico.h"

int current_scope = 0;
int temp_count = 0;
int label_count = 0;

SymbolEntry *symbol_table = NULL;

/*
 * Incrementa o nível de escopo ao entrar em um novo bloco.
 */
void enter_scope() {
    current_scope++;
}

/*
 * Remove símbolos do escopo atual da tabela e decrementa o nível.
 */
void exit_scope() {
    SymbolEntry *current = symbol_table;
    
    while (current != NULL && current->scope_level == current_scope){
    	SymbolEntry *to_delete = current;
    	symbol_table = current->next;
    	current = symbol_table;
    	
    	free(to_delete->lexeme);
    	free(to_delete);
    }
    
    current_scope--;
}

/*
 * Insere um símbolo na tabela. Retorna 0 se houver redeclaração no escopo atual.
 */
int insert_symbol(char *lexeme, DataType type) {
    SymbolEntry *current = symbol_table;
    while (current != NULL) {
        if (strcmp(current->lexeme, lexeme) == 0 && current->scope_level == current_scope) {
            return 0; // Erro: Redeclaração no mesmo escopo
        }
        current = current->next;
    }

    // Insere sempre no topo
    SymbolEntry *new_entry = (SymbolEntry*)malloc(sizeof(SymbolEntry));
    new_entry->lexeme = strdup(lexeme);
    new_entry->type = type;
    new_entry->scope_level = current_scope;
    new_entry->next = symbol_table;
    symbol_table = new_entry;
    return 1;
}

/*
 * Busca a primeira ocorrência de um símbolo na tabela e o retorna.
 */
SymbolEntry* lookup_symbol(char *lexeme) {
    SymbolEntry *current = symbol_table;
    while (current != NULL) {
        if (strcmp(current->lexeme, lexeme) == 0) { // strcmp retorna 0 quando as duas strings são identicas
            return current;
        }
        current = current->next;
    }
    return NULL;
}


/*
 * Gera e retorna um nome único para variável (t1, t2, ...)
 */
char* new_temp() {
    char *name = (char*)malloc(10);
    sprintf(name, "t%d", ++temp_count);
    return name;
}


/*
 * Gera e retorna um nome único para rótulo (label) de código (ex: L1, L2).
 */
char* new_label() {
    char *name = (char*)malloc(10);
    sprintf(name, "L%d", ++label_count);
    return name;
}

/*
 * Verifica se ambos os operandos são inteiros (retorna INT ou ERROR).
 */
DataType check_arithmetic(DataType t1, DataType t2) {
    if (t1 == TYPE_INT && t2 == TYPE_INT) return TYPE_INT;
    return TYPE_ERROR;
}

/*
 * Verifica se operandos inteiros resultam em booleano (retorna BOOL ou ERROR).
 */
DataType check_relational(DataType t1, DataType t2) {
    if (t1 == TYPE_INT && t2 == TYPE_INT) return TYPE_BOOL;
    return TYPE_ERROR;
}

/*
 * Verifica se ambos os operandos são booleanos (retorna BOOL ou ERROR).
 */
DataType check_logical(DataType t1, DataType t2) {
    if (t1 == TYPE_BOOL && t2 == TYPE_BOOL) return TYPE_BOOL;
    return TYPE_ERROR;
}

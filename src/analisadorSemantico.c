#include "analisadorSemantico.h"

/* Variáveis globais para controle de geração de código */
int current_scope = 0;
int temp_count = 0;
int label_count = 0;

/* Tabela de símbolos como Lista Encadeada (funciona como pilha) */
SymbolEntry *symbol_table = NULL;

/*
 * Gerenciamento de Escopo:
 * Aumentamos o nível ao entrar em um bloco { }.
 */
void enter_scope() {
    current_scope++;
}

/*
 * Limpeza de Escopo:
 * Ao sair de um bloco, removemos todas as variáveis declaradas
 * naquele nível, liberando memória e impedindo acesso externo.
 * Decrementa um nivel
 */
void exit_scope() {
    SymbolEntry *current = symbol_table;
    
    while (current != NULL && current->scope_level == current_scope){
    	SymbolEntry *to_delete = current;
    	symbol_table = current->next; // Move a cabeça da lista
    	current = symbol_table;
    	
    	free(to_delete->lexeme);
    	free(to_delete);
    }
    
    current_scope--;
}

/*
 * Insere sempre no início da lista (topo da pilha).
 * Retorna 0 se houver redeclaração no escopo atual.
 * Verifica duplicidade APENAS no nível atual de escopo.
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
 * Busca de Símbolos:
 * Procura do topo para baixo. A primeira ocorrência encontrada
 * será a do escopo mais interno.
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

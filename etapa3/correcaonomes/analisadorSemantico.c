#include "analisadorSemantico.h"
#include <stdarg.h> // Necessário para va_list (função gerar_codigo)

// Variáveis Globais de Controle
int escopo_atual = 0;
int cont_temp = 0;   // Contador para temporários (t1, t2...)
int cont_rotulo = 0; // Contador para rótulos (L1, L2...)

EntradaTabela *tabela_simbolos = NULL; // Ponteiro para o topo da tabela

// --- Gerenciamento da Tabela ---

void tabela_iniciar() {
    tabela_simbolos = NULL;
    escopo_atual = 0;
    cont_temp = 0;
    cont_rotulo = 0;
}

void escopo_entrar() {
    escopo_atual++;
}

void escopo_sair() {
    // Remove todas as variáveis declaradas no escopo atual ao sair dele
    EntradaTabela *atual = tabela_simbolos;
    EntradaTabela *anterior = NULL;
    
    while (atual != NULL) {
        if (atual->nivel_escopo == escopo_atual) {
            EntradaTabela *para_deletar = atual;
            if (anterior == NULL) {
                tabela_simbolos = atual->prox;
                atual = tabela_simbolos;
            } else {
                anterior->prox = atual->prox;
                atual = atual->prox;
            }
            free(para_deletar->lexema);
            free(para_deletar);
        } else {
            anterior = atual;
            atual = atual->prox;
        }
    }
    escopo_atual--;
}

int tabela_inserir(char *lexema, TipoDado tipo) {
    // Verifica se já existe variável com mesmo nome NO MESMO ESCOPO
    EntradaTabela *atual = tabela_simbolos;
    while (atual != NULL) {
        if (strcmp(atual->lexema, lexema) == 0 && atual->nivel_escopo == escopo_atual) {
            return 0; // Erro: Redeclaração
        }
        atual = atual->prox;
    }

    // Insere no topo da lista
    EntradaTabela *nova_entrada = (EntradaTabela*)malloc(sizeof(EntradaTabela));
    nova_entrada->lexema = strdup(lexema);
    nova_entrada->tipo = tipo;
    nova_entrada->nivel_escopo = escopo_atual;
    nova_entrada->prox = tabela_simbolos;
    tabela_simbolos = nova_entrada;
    return 1; // Sucesso
}

EntradaTabela* tabela_buscar(char *lexema) {
    // Busca linear do topo para baixo (encontra o escopo mais interno primeiro)
    EntradaTabela *atual = tabela_simbolos;
    while (atual != NULL) {
        if (strcmp(atual->lexema, lexema) == 0) {
            return atual;
        }
        atual = atual->prox;
    }
    return NULL; // Não encontrado
}

// --- Geração de Código ---

char* gerar_temp() {
    char *nome = (char*)malloc(10);
    sprintf(nome, "t%d", ++cont_temp);
    return nome;
}

char* gerar_rotulo() {
    char *nome = (char*)malloc(10);
    sprintf(nome, "L%d", ++cont_rotulo);
    return nome;
}

void gerar_codigo(const char *fmt, ...) {
    va_list args;
    va_start(args, fmt);
    vprintf(fmt, args); // Imprime formatado no terminal
    printf("\n");
    va_end(args);
}

void gerar_codigo_rotulo(char *rotulo) {
    printf("%s:\n", rotulo);
}

// --- Verificações de Tipo ---

TipoDado verificar_aritmetico(TipoDado t1, TipoDado t2) {
    if (t1 == TIPO_INT && t2 == TIPO_INT) return TIPO_INT;
    return TIPO_ERRO;
}

TipoDado verificar_relacional(TipoDado t1, TipoDado t2) {
    // Compara apenas inteiros (ex: 10 < 20)
    if (t1 == TIPO_INT && t2 == TIPO_INT) return TIPO_BOOL;
    return TIPO_ERRO;
}

TipoDado verificar_logico(TipoDado t1, TipoDado t2) {
    // Opera apenas sobre booleanos (ex: true && false)
    if (t1 == TIPO_BOOL && t2 == TIPO_BOOL) return TIPO_BOOL;
    return TIPO_ERRO;
}
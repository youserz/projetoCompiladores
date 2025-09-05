# Compilador Mini C - GCC130 UFLA

Este projeto implementa um **compilador para uma linguagem didática inspirada em C**, como parte do Trabalho Prático da disciplina **Compiladores (GCC130)**, ministrada pelo professor Ricardo Terra (UFLA).

## 🚀 Estrutura do Projeto
O desenvolvimento do compilador é dividido em três etapas:

1. **Etapa 1 - Analisador Léxico (Flex)**
   - Reconhecimento de tokens (identificadores, números, operadores, palavras-chave).
   - Impressão de token, lexema e posição (linha/coluna).
   - Tratamento de erros léxicos.
   - Geração e exibição da tabela de símbolos.

2. **Etapa 2 - Analisador Sintático (Bison)**
   - Implementação de uma gramática em BNF.
   - Reconhecimento de estruturas da linguagem (declarações, atribuições, if/else, while, etc.).
   - Relatório de erros sintáticos com posição.
   - Integração com o analisador léxico.

3. **Etapa 3 - Análise Semântica e Geração de Código Intermediário**
   - Verificação de tipos e escopos.
   - Relato de erros semânticos.
   - Geração de código de três endereços (IR).

## 📂 Organização
- `src/` → Códigos-fonte (arquivos `.l`, `.y`, e auxiliares).
- `tests/` → Programas de teste da linguagem.
- `docs/` → Relatórios e diagramas.

## 🔧 Ferramentas
- [Flex](https://github.com/westes/flex) (Analisador Léxico)
- [Bison](https://www.gnu.org/software/bison/) (Analisador Sintático)
- C/C++ para integração e execução

## 📜 Como compilar
```bash
flex scanner.l
bison -d parser.y
gcc lex.yy.c parser.tab.c -o compilador
```

## 👥 Autores
Bernado Diniz, Luan Shimosaka, Luiz Philip


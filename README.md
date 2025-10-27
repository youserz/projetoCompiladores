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
As instruções de compilação mudam dependendo da etapa do projeto.

### Etapa 1: Analisador Léxico (Standalone)

Estas instruções se aplicam à versão da Etapa 1, onde o arquivo `main.l` (ou `scanner.l`) **deve conter sua própria função `main()`** e **não deve incluir `parser.h`**.

```bash
# 1. Gera o analisador C a partir do arquivo Flex (ex: main.l)
flex main.l

# 2. Compila o arquivo C gerado (lex.yy.c)
# A flag -lfl é (geralmente) necessária para incluir
# a biblioteca do Flex, caso você não defina sua própria yywrap().
# Se você usou %option noyywrap, ela pode não ser necessária.
gcc lex.yy.c -o analisador_lexico -lfl

# 3. Executa o analisador passando um arquivo de teste
./analisador_lexico < tests/seu_teste.txt
```
#### Etapa 2: Analisador Sintático (Flex + Bison)
Estas são as instruções para compilar o projeto completo (Etapa 2), que integra o Flex e o Bison. O arquivo `main.l` depende do `parser.y`.
```bash
# 1. Executa o Bison para gerar o parser C e o header
# -d -> Cria o arquivo de definições 'parser.tab.h'
# 'parser.y' -> Gera 'parser.tab.c' (o parser) e 'parser.tab.h' (os tokens)
bison -d -o -v parser.y

# 2. Executa o Flex para gerar o scanner C
# 'main.l' -> Gera 'lex.yy.c'
# (Nota: main.l deve incluir "parser.tab.h" gerado acima)
flex main.l

# 3. Compila e linca os dois arquivos C gerados
# A função main() está definida dentro de 'parser.y'
# O resultado é um executável chamado 'compilador'
gcc lex.yy.c parser.tab.c -o compilador

# 4. Executa o compilador completo passando um arquivo de teste
./compilador tests/seu_teste.txt
```
## 👥 Autores
Bernado Diniz, Luan Shimosaka, Luiz Philip


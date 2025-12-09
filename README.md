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

## 📜 Como Compilar e Executar

Siga os passos abaixo para gerar o executável final do compilador.

### 1. Gerar o Analisador Sintático
O Bison processa a gramática e gera o parser em C (`analisadorSintatico.tab.c`) e o cabeçalho de tokens (`analisadorSintatico.tab.h`).

```bash
bison -d analisadorSintatico.y
```
### 2. Gerar o Analisador Léxico
O Flex processa as regras léxicas e gera o scanner em C (`lex.yy.c`).
```bash
flex analisadorLexico.l
```

### 3. Compilar e Linkar
O GCC compila o parser, o scanner e o módulo semântico juntos para criar o executável final (`compilador`).
```bash
gcc -o compilador analisadorSintatico.tab.c lex.yy.c analisadorSemantico.c
```
(Nota: Não é necessário a flag ``-lfl`` pois o léxico utiliza ``%option noyywrap``)

### 4. Executar o Teste
Para rodar o compilador, passe um arquivo de código fonte como argumento.

```bash
./compilador teste.bll
```
Se houver erros (léxicos, sintáticos ou semânticos), eles serão reportados na saída de erro (``stderr``) indicando a linha: ``Erro Semantico [15]: Variavel 'y' nao declarada``.
## 👥 Autores

| [<img src="https://github.com/youserz.png" width="100">](https://github.com/youserz) | [<img src="https://github.com/LuizPhillipResende.png" width="100">](https://github.com/LuizPhillipResende) | [<img src="https://github.com/luanShimosaka.png" width="100">](https://github.com/luanShimosaka) |
|---|---|---|
| [Bernardo Diniz](https://github.com/youserz) | [Luiz Phillip Resende](https://github.com/LuizPhillipResende) | [Luan Shimosaka](https://github.com/luanShimosaka) | [Marco Franco](https://github.com/MarcoTFranco) |

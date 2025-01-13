# Analisador Léxico - Subconjunto da Linguagem C

## Tabela de Conteúdos

- [Visão Geral](#visão-geral)
- [Funcionalidades da Linguagem](#funcionalidades-da-linguagem)
- [Estrutura do Projeto](#estrutura-do-projeto)
- [Requisitos](#requisitos)
- [Como Compilar e Executar](#como-compilar-e-executar)
- [Casos de Uso](#casos-de-uso)
- [Tabela de Símbolos](#tabela-de-símbolos)
- [Erros Léxicos](#erros-léxicos)
- [Contribuindo](#contribuindo)

## Visão Geral

Este projeto implementa um analisador léxico para um subconjunto da linguagem C. O analisador foi desenvolvido utilizando o **Flex** e suporta funcionalidades essenciais de linguagens imperativas, como inicialização de variáveis, controle de fluxo, vetores, e funções.

---

## Funcionalidades da Linguagem

A linguagem reconhece os seguintes elementos:

### Palavras Reservadas:
- `int`, `float`, `void` - Tipos de dados.
- `if`, `else` - Controle condicional.
- `while` - Laço de repetição.
- `return` - Retorno de valores em funções.

### Operadores:
- **Operadores aritméticos**: `+`, `-`, `*`, `/`.
- **Operadores de comparação**: `==`, `!=`, `<`, `<=`, `>`, `>=`.
- **Atribuição**: `=`.

### Símbolos e Estruturas:
- Parênteses, colchetes e chaves: `(`, `)`, `[`, `]`, `{`, `}`.
- Separadores: `,`, `;`.

### Números e Identificadores:
- Números inteiros e de ponto flutuante (ex.: `123`, `45.67`).
- Identificadores alfanuméricos que começam com uma letra (ex.: `variavel1`, `soma`).

### Comentários:
- Suporte a comentários de múltiplas linhas no estilo C: `/* comentário */`.

---

## Estrutura do Projeto

O projeto contém os seguintes arquivos principais:

- **analisador.lex**: Código fonte do analisador léxico escrito em Flex.
- **README.md**: Este arquivo, contendo informações sobre o projeto.
- **Exemplos de teste**: Arquivos `.c` com casos para validação do analisador.
- **Entrada**: Input `.c` a ser analisado pelo Analisador Léxico.

---

## Requisitos

Certifique-se de que o **Flex** está instalado no seu sistema. Você pode instalá-lo com o comando:

```bash
sudo apt-get install flex
```

---

## Como Compilar e Executar

### 1. Compilar o Analisador Léxico
Use o comando abaixo para gerar o analisador léxico:

```bash
flex analisador.lex
gcc lex.yy.c -o analisador
```

### 2. Executar o Analisador
Forneça o arquivo de entrada com o código a ser analisado e um arquivo de saída para os tokens gerados:

```bash
./analisador <arquivo_entrada.c> <arquivo_saida.txt>
```

Esses processo pode ser automatizado através de um arquivo de configuração Makefile.
Para construir o arquivo executável basta realizar:

```bash
make build
```

Para executar basta fazer:

```bash
make run
```

Ou ainda é possível fazer o `build` e `run` em um único momento com:

```bash
make all
```

### 3. Exemplo
Suponha que você tenha um arquivo `entrada.c` com o seguinte código:

```c
int main() {
    int a = 5;
    float b = 2.5;
    if (a > b) {
        a = a - 1;
    }
    return 0;
}
```

Execute o analisador:

```bash
./analisador entrada.c saida.txt
```

O arquivo `saida.txt` conterá os tokens gerados, além da tabela de símbolos ao final.

---

## Casos de Uso

O analisador reconhece e gera tokens para:

1. **Declarações de variáveis**:
   - `int x = 5;`
   - Token: `<KEY, int>`, `<1, ID, x>`, `<SYM, =>`, `<NUM, 5>`.

2. **Vetores**:
   - `float arr[10]; arr[0] = 1.5;`
   - Tokens: `<KEY, float>`, `<1, ID, arr>`, `<SYM, [>`, `<NUM, 10>`, `<SYM, ]>`...

3. **Expressões aritméticas**:
   - `b = a + 2 * 3;`
   - Tokens: `<1, ID, b>`, `<SYM, =>`, `<1, ID, a>`, `<OP, +>`, `<NUM, 2>`, `<OP, *>`, `<NUM, 3>`.

4. **Desvios condicionais**:
   - `if (a > b) { return 0 }`
   - Tokens: `<KEY, if>`, `<SYM, (>`, `<1, ID, a>`, `<COM_OP, >>`, `<2, ID, b>`, `<SYM, )>`...

5. **Laços de repetição**:
   - `while (x < 10) { x = x + 1 }`
   - Tokens: `<KEY, while>`, `<SYM, (>`, `<1, ID, x>`, `<COM_OP, <>`, `<NUM, 10>`, `<SYM, )>`...

6. **Funções**:
   - `float soma(float a, float b) { return a + b; }`
   - Tokens: `<KEY, float>`, `<1, ID, soma>`, `...`, `<KEY, return>`, ...

---

## Tabela de Símbolos

Ao final da execução, o analisador gera uma tabela de símbolos com todos os identificadores encontrados, indicando sua posição única. Por exemplo:

```plaintext
Tabela de Símbolos:
<1, main>
<2, a>
<3, b>
<4, arr>
<5, soma>
```

---

## Erros Léxicos

O analisador léxico foi projetado para detectar e relatar diversos tipos de erros no código-fonte que violem as regras do subconjunto da linguagem C suportado. Abaixo estão os erros que podem ser detectados, junto com uma breve descrição:

### Tipos de Erros Detectados

1. **Comentário Não Fechado**:
   - **Descrição**: Um comentário iniciado com `/*` não foi encerrado com `*/`.
   - **Exemplo**:
     ```c
     /* Comentário aberto
     ```
   - **Saída**:
     ```plaintext
     <2, ERROR, "Unclosed comment">
     ```

2. **Comentário Aninhado**:
   - **Descrição**: Comentários não podem ser aninhados no subconjunto da linguagem C suportado.
   - **Exemplo**:
     ```c
     /* Comentário aberto
        /* Comentário aninhado */
     */
     ```
   - **Saída**:
     ```plaintext
     <2, ERROR, "Nested comment">
     ```

3. **String Não Fechada**:
   - **Descrição**: Uma string iniciada com `"` não foi encerrada corretamente.
   - **Exemplo**:
     ```c
     "String sem fechamento
     ```
   - **Saída**:
     ```plaintext
     <3, ERROR, "Unclosed string">
     ```

4. **Caractere Não Reconhecido**:
   - **Descrição**: Um caractere que não pertence à gramática da linguagem foi encontrado.
   - **Exemplo**:
     ```c
     int a = 10 @;
     ```
   - **Saída**:
     ```plaintext
     <4, ERROR, "Unrecognized character '@'">
     ```

5. **Identificador Inválido**:
   - **Descrição**: Identificadores não podem começar com um número nem conter caracteres inválidos.
   - **Exemplo**:
     ```c
     int 123$abc;
     ```
   - **Saída**:
     ```plaintext
     <5, ERROR, "Invalid sequence '123$abc'">
     ```

---

### Como os Erros São Tratados

- **Detecção e Continuidade**: O analisador não interrompe a execução ao encontrar um erro. Ele registra o erro no arquivo de saída e continua analisando o restante do código.
- **Relatório no Arquivo de Saída**: Cada erro é reportado no formato:
  ```plaintext
  <linha, ERROR, "descrição do erro">
  ```

---

## Contribuições

Sinta-se à vontade para sugerir melhorias ou relatar problemas. Este é um projeto acadêmico desenvolvido para a disciplina **MATA61 - Compiladores**.

---

## Autor

Este projeto foi desenvolvido como parte de um trabalho prático da disciplina **Compiladores**, do curso de **Ciência da Computação**, sob orientação do professor **Matheus Guimarães**.

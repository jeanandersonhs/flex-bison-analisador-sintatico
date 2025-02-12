# Analisador Sintático com FLEX e BISON - Subconjunto da Linguagem C

## Tabela de Conteúdos

- [Visão Geral](#visão-geral)
- [Funcionalidades da Linguagem](#funcionalidades-da-linguagem)
- [Estrutura do Projeto](#estrutura-do-projeto)
- [Requisitos](#requisitos)
- [Como Compilar e Executar](#como-compilar-e-executar)
- [Casos de Uso](#casos-de-uso)
- [Erros Léxicos e Sintáticos](#erros-léxicos-e-sintáticos)
- [Contribuindo](#contribuindo)

## Visão Geral

Este projeto implementa um **analisador sintático** para um subconjunto da linguagem C. Utilizando **Flex** para a análise léxica e **Bison** para a análise sintática, o sistema constrói uma árvore sintática (AST) que representa a estrutura do código de entrada. A linguagem analisada é imperativa, compatível com ASCII, e suporta declarações de variáveis, expressões aritméticas, estruturas condicionais, laços de repetição, funções e chamadas de função.

---

## Funcionalidades da Linguagem

A linguagem reconhece os seguintes elementos:

### Palavras Reservadas
- **Tipos:** `int`, `float`, `void`
- **Controle de fluxo:** `if`, `else`, `while`
- **Funções:** `return`

### Operadores
- **Aritméticos:** `+`, `-`, `*`, `/`
- **Comparação:** `==`, `!=`, `<`, `<=`, `>`, `>=`
- **Atribuição:** `=`

### Estruturas e Símbolos
- **Agrupadores:** Parênteses `(`, `)`, colchetes `[`, `]`, chaves `{`, `}`
- **Separadores:** Vírgula `,`, ponto e vírgula `;`

### Literais e Identificadores
- **Números:** Inteiros (ex.: `123`) e de ponto flutuante (ex.: `45.67`)
- **Strings:** Delimitadas por aspas (ex.: `"Olá, Mundo!"`)
- **Identificadores:** Sequências alfanuméricas que começam com letra ou underscore (ex.: `variavel`, `soma`)

### Comentários
- Comentários multilinha no estilo C: `/* comentário */`

### Funções
- **Definição e Chamada:** A linguagem permite definir funções com tipagem estática e chamá-las em expressões ou como instruções independentes.

---

## Estrutura do Projeto

O projeto é composto pelos seguintes arquivos:

- **parser.y**: Contém a gramática, as ações semânticas e a construção da AST utilizando Bison.
- **analisador.lex**: Define as regras léxicas (tokens) usando Flex.
- **node.h**: Declara a estrutura de dados utilizada para representar os nós da árvore sintática.
- **README.md**: Este arquivo, contendo a documentação do projeto.
- **Exemplos de Teste**: Arquivos fonte (com extensão `.c`) com casos de teste para validação do analisador.

Além disso, o projeto foi organizado para permitir que itens de nível superior (funções e declarações/expressões) possam ser intercalados livremente.

---

## Requisitos

Para compilar e executar o projeto, é necessário ter instalados:

- **Flex**: Ferramenta para análise léxica.  
- **Bison**: Gerador de analisadores sintáticos.  
- **GCC**: Compilador GNU para C.  
- (Opcional) **Make**: Para automatizar o processo de build.

Em sistemas Debian/Ubuntu, você pode instalar Flex e Bison com:

```bash
sudo apt-get install flex bison
```

---

## Como Compilar e Executar

### 1. Gerar o Analisador

Execute os seguintes comandos para gerar e compilar o analisador:

```bash
bison -d parser.y
flex analisador.lex
gcc parser.tab.c lex.yy.c -o analisador -lfl -ly
```

### 2. Executar o Analisador

O analisador recebe um arquivo de entrada contendo código no subconjunto de C e exibe a árvore sintática (AST) resultante na saída padrão. Por exemplo:

```bash
./analisador < entrada.c
```

Você pode automatizar esse processo utilizando um Makefile, com comandos como:

```bash
make build
make run
```

ou

```bash
make all
```

---

## Casos de Uso

O analisador sintático suporta os seguintes casos:

1. **Declaração de Variáveis e Vetores**:
   ```c
   int x = 10;
   float y = 5.5;
   int vetor[5];
   ```
   A AST gerada representa as declarações e, no caso de vetores, inclui o tamanho especificado.

2. **Atribuições e Expressões Aritméticas**:
   ```c
   x = x + 1;
   y = y * 2.0;
   vetor[2] = x - 3;
   ```
   A árvore sintática exibe as operações aritméticas e as atribuições correspondentes.

3. **Estruturas Condicionais (If/Else e Else If)**:
   ```c
   if (x > y) {
       print("x é maior que y");
   } else if (x == y) {
       print("x é igual a y");
   } else {
       print("x é menor que y");
   }
   ```
   A AST representa a estrutura condicional, com suporte a encadeamento de “else if” e um bloco final “else”.

4. **Laços de Repetição (While)**:
   ```c
   while (x < 20) {
       x = x + 1;
   }
   ```
   A árvore inclui o nó do laço, sua condição e o bloco de instruções.

5. **Funções e Chamadas de Função**:
   ```c
   float soma(float a, float b) {
       return a + b;
   }
   a = soma(x, y);
   ```
   A AST mostra a definição da função, seus parâmetros e o retorno, bem como a chamada da função com os argumentos fornecidos.

6. **Intercalação de Itens de Nível Superior**:
   O analisador permite que funções e outras instruções sejam misturadas no nível global, conforme exemplificado abaixo:
   ```c
   float sub(float a, float b) {
       return a - b;
   }

   if (a > b) {
       printf("a > b");
   } else {
       printf("a <= b");
   }

   float soma(float a, float b) {
       return a + b;
   }

   a = soma(x, y);
   b = sub(x, y);
   ```
   Essa flexibilidade foi obtida com a introdução dos não-terminais `top_level_item` e `top_level_item_list`.


---

## Erros Léxicos e Sintáticos

### Erros Léxicos

- **Atualmente:**  
  As regras do analisador léxico (definidas em **analisador.lex**) identificam erros como strings não fechadas, caracteres inválidos ou identificadores mal formados. Esses erros são enviados para a saída de erro padrão (_stderr_) por meio de mensagens.  
- **Observação:**  
  Como o programa principal (o `main`) foi incorporado ao analisador sintático (no arquivo **parser.y**), o output final exibido é a árvore sintática (AST) ou, em caso de erro, apenas a mensagem "Syntax error". Assim, as mensagens de erro léxico podem não aparecer no output padrão se você redirecionar apenas a saída padrão para um arquivo. Recomenda-se verificar também a saída de erro (_stderr_) para visualizar os erros léxicos.

### Erros Sintáticos

- **Atualmente:**  
  Se o código de entrada não se encaixa na gramática definida, o Bison invoca a função `yyerror`, que exibe uma mensagem do tipo "Syntax error: ..." no _stderr_ e, em seguida, a análise é abortada.  
- **Observação:**  
  O tratamento de erros sintáticos é básico, ou seja, o analisador não tenta realizar recuperação de erro nem fornece mensagens detalhadas além da indicação de erro sintático. Essa abordagem é suficiente para os propósitos iniciais do projeto, mas futuras melhorias poderão incluir uma recuperação mais robusta e mensagens de erro mais informativas.

---

Em resumo, no estado atual:

- **Lexicalmente:** Erros são reportados via _stderr_, mas podem não aparecer no output final se você redirecionar apenas a saída padrão.
- **Sintaticamente:** Se ocorrer um erro, o analisador exibe "Syntax error: ..." e interrompe a análise, sem tentar recuperar ou fornecer detalhes adicionais.

Essas limitações estão documentadas e podem ser melhoradas conforme a evolução do projeto.

---

## Contribuindo

Contribuições para melhoria do analisador são bem-vindas! Se você deseja sugerir melhorias ou relatar problemas, por favor, abra uma _issue_ ou envie um _pull request_ neste repositório.

---

## Autor

Este projeto foi desenvolvido como parte do trabalho prático da disciplina **MATA61 - Compiladores** do curso de **Ciência da Computação**.  
Desenvolvido por Jean Anderson Hugo e Elis Oliveira Vasconcelos sob a orientação do professor Matheus Guimarães.

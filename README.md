# Analisador Léxico - Subconjunto da Linguagem C

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

- **analisador.l**: Código fonte do analisador léxico escrito em Flex.
- **README.md**: Este arquivo, contendo informações sobre o projeto.
- **Exemplos de teste**: Arquivos `.c` com casos para validação do analisador.
- **Tabela de símbolos**: Gera uma tabela de símbolos ao final da execução.

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
flex analisador.l
gcc lex.yy.c -o analisador
```

### 2. Executar o Analisador
Forneça o arquivo de entrada com o código a ser analisado e um arquivo de saída para os tokens gerados:

```bash
./analisador <arquivo_entrada.c> <arquivo_saida.txt>
```

### 3. Exemplo
Suponha que você tenha um arquivo `exemplo.c` com o seguinte código:

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
./analisador exemplo.c saida.txt
```

O arquivo `saida.txt` conterá os tokens gerados, além da tabela de símbolos ao final.

---

## Casos de Uso e Testes

O analisador reconhece e gera tokens para:

1. **Declarações de variáveis**:
   - `int x = 5;`
   - Token: `<1, KEY, int>`, `<1, ID, x>`, `<1, SYM, =>`, `<1, NUM, 5>`.

2. **Vetores**:
   - `float arr[10]; arr[0] = 1.5;`
   - Tokens: `<1, KEY, float>`, `<1, ID, arr>`, `<1, SYM, [>`, `<1, NUM, 10>`, `<1, SYM, ]>`.

3. **Expressões aritméticas**:
   - `b = a + 2 * 3;`
   - Tokens: `<1, ID, b>`, `<1, SYM, =>`, `<1, ID, a>`, `<1, OP, +>`.

4. **Desvios condicionais**:
   - `if (a > b) { ... }`
   - Tokens: `<1, KEY, if>`, `<1, SYM, (>`, `<1, ID, a>`, `<1, COM_OP, >>`.

5. **Laços de repetição**:
   - `while (x < 10) { ... }`
   - Tokens: `<1, KEY, while>`, `<1, SYM, (>`, `<1, ID, x>`.

6. **Funções**:
   - `float soma(float a, float b) { return a + b; }`
   - Tokens: `<1, KEY, float>`, `<1, ID, soma>`.

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

## Contribuições

Sinta-se à vontade para sugerir melhorias ou relatar problemas. Este é um projeto acadêmico desenvolvido para a disciplina **MATA61 - Compiladores**.

---

## Autor

Este projeto foi desenvolvido como parte de um trabalho prático da disciplina **Compiladores**, do curso de **Ciência da Computação**, sob orientação do professor **Matheus Guimarães**.

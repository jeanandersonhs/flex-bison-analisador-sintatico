/* Declaração de variáveis */ 
int x = 10;
float y = 5.5;
int vetor[5];

/* Atribuições e expressões aritméticas */
x = x + 1;
y = y * 2.0;
vetor[2] = x - 3;

/* Estruturas condicionais */ 
if (x > y) {
    print("x é maior que y");
} else if (x == y) {
    print("x é igual a y");
} else {
    print("x é menor que y");
}

/* Estruturas de repetição */ 
while (x < 20) {
    x = x + 1;
}

/* Função e chamada */ 
float soma(float a, float b) {
    return a + b;
}
y = soma(x, 5.0);

/* Casos especiais */ 
string mensagem = "Teste de string com escape: \\n Nova linha";
print(mensagem);

/* Erros Léxicos */ 
@erro_simbolo_inválido;
"string_nao_fechada

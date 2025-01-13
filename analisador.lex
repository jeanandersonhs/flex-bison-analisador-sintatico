%{
    #include <stdio.h>
    #include <stdlib.h>
    #include <string.h>

    FILE *out;
    int linha;

    typedef struct {
        char *id;
        int index;
    } Symbol;

    Symbol symbol_table[1000]; // Tabela de símbolos
    int symbol_count = 0;

    // Função para inserir identificadores na tabela de símbolos
    int insert_symbol(const char *id) {
        for (int i = 0; i < symbol_count; i++) {
            if (strcmp(symbol_table[i].id, id) == 0) {
                return symbol_table[i].index; // Identificador já existe
            }
        }
        // Adicionar novo identificador
        symbol_table[symbol_count].id = strdup(id);
        symbol_table[symbol_count].index = symbol_count + 1;
        return symbol_table[symbol_count++].index;
    }
%}

%option yylineno
%x COMMENT

digit       [0-9]
letter      [a-zA-Z]
ID          (_|{letter})({letter}|{digit}|_)*

FLOAT       {digit}+\.{digit}+([eE][-+]?{digit}+)?

NUM         {digit}+
WS          [ \t\r]+
NL          \n
RELOP       "=="|"!="|"<"|"<="|">"|">="
STRING      \"([^\"\\\n]|\\[abfnrtv\"\'\\0])*\"
SYMBOL      [\[\]\(\)\{\};:,=]
INVALID     ({digit}|{letter})({letter}|{digit}|[^a-zA-Z0-9 \n\t\r\[\]\(\)\{\};:,=])*

%%

{NL}                { linha = yylineno; }
"/*"                { linha = yylineno; BEGIN(COMMENT); }
<COMMENT>"*/"       { BEGIN(INITIAL); }
<COMMENT>"/*"       { fprintf(out, "<%d, ERROR, \"Nested comment\">\n", yylineno); }
<COMMENT>{NL}       { linha = yylineno; } /* Atualizar número da linha */
<COMMENT><<EOF>>    { fprintf(out, "<%d, ERROR, \"Unclosed comment\">\n", linha); }
<COMMENT>.          ; /* Ignorar outros caracteres no comentário */

"int"|"float"|"void"|"if"|"else"|"while"|"return" {
                      fprintf(out, "<KEY, %s>\n", yytext);
                  }

{RELOP}            { fprintf(out, "<RELOP, %s>\n", yytext); }

"="|";"|","|"("|")"|"{"|"}"|"["|"]"|":"  { fprintf(out, "<SYM, %s>\n", yytext); }
"+"|"-"|"*"|"/"     { fprintf(out, "<OP, %s>\n", yytext); }

{FLOAT}             { fprintf(out, "<FLOAT, %s>\n", yytext); }
{NUM}               { fprintf(out, "<NUM, %s>\n", yytext); }

{ID}                {
                      int index = insert_symbol(yytext);
                      fprintf(out, "<%d, ID, %s>\n", index, yytext);
                  }

{STRING}        { fprintf(out, "<STRING, %s>\n", yytext); }

\"([^\"\\\n]|\\[abfnrtv\"\'\\0])*\n {
                      fprintf(out, "<%d, ERROR, \"Unclosed string\">\n", yylineno);
                  }

{WS}                ; /* Ignore spaces */

{INVALID} {
    fprintf(out, "<%d, ERROR, \"Invalid sequence '%s'\">\n", yylineno, yytext);
}

.                   { fprintf(out, "<%d, ERROR, \"Invalid use of character '%s'\">\n", yylineno, yytext); }

%%

int yywrap() {
    return 1;
}

int main(int argc, char *argv[]) {
    FILE *arquivo;
    if (argc < 3) {
        fprintf(stderr, "Usage: %s <input_file> <output_file>\n", argv[0]);
        return 1;
    }
    arquivo = fopen(argv[1], "r");
    if (!arquivo) {
        fprintf(stderr, "Error: Cannot open input file %s\n", argv[1]);
        return 1;
    }
    yyin = arquivo;
    out = fopen(argv[2], "w");
    if (!out) {
        fprintf(stderr, "Error: Cannot open output file %s\n", argv[2]);
        fclose(arquivo);
        return 1;
    }
    yylex();
    
    // Imprimir a tabela de símbolos no final
    fprintf(out, "\nTabela de Símbolos:\n");
    for (int i = 0; i < symbol_count; i++) {
        fprintf(out, "<%d, %s>\n", symbol_table[i].index, symbol_table[i].id);
    }

    fclose(arquivo);
    fclose(out);
    return 0;
}

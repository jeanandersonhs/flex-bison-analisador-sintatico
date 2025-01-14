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

digit           [0-9]
letter          [a-zA-Z]
invalid_char    [^a-zA-Z0-9 \n\t\r\[\]\(\)\{\};:,=_]

ID          ({letter}|_)({letter}|{digit}|_)*

FLOAT       {digit}+\.{digit}+([eE][-+]?{digit}+)?
NUM         {digit}+

INT             "int"
VOID            "void"
IF              "if"
ELSE            "else"
WHILE           "while"
RETURN          "return"

WS          [ \t\r]+
NL          \n

SUM         ["+"]
SUB         "\-"
DIV         ["/"]
MUL         ["*"]

GT          [">"]
LT          ["<"]
EQ          ["="]
NE          "!="
GE          ">="
LE          "<="
COMP_EQ     "=="

STRING      \"([^\"\\\n]|\\[abfnrtv\"\'\\0])*\"

OPN_SQR_BKT     "\["
CLS_SQR_BKT     "\]"
OPN_CURLY_BKT   "\{"
CLS_CURLY_BKT   "\}"
SEMICOLON       [";"]
COLON           [":"]
COMMA           [","]
OPN_PARENT      "\("
CLS_PARENT      "\)"

ID_STARTS_DIGIT     {digit}({letter}|{digit}|_)+ 
INVALID_CHAR        ({letter}|_)*({invalid_char}+({letter}|{digit}|_))*

%%

{NL}                { linha = yylineno; }
"/*"                { linha = yylineno; BEGIN(COMMENT); }
<COMMENT>"*/"       { BEGIN(INITIAL); }
<COMMENT>"/*"       { fprintf(out, "<%d, ERROR, \"Nested comment\">\n", yylineno); }
<COMMENT>{NL}       { linha = yylineno; } /* Atualizar número da linha */
<COMMENT><<EOF>>    { fprintf(out, "<%d, ERROR, \"Unclosed comment\">\n", linha); }
<COMMENT>.          ; /* Ignorar outros caracteres no comentário */

{SUM}              { fprintf(out, "<OP, SUM, %s>\n", yytext); }
{SUB}              { fprintf(out, "<OP, SUB, %s>\n", yytext); }
{DIV}              { fprintf(out, "<OP, DIV, %s>\n", yytext); }
{MUL}              { fprintf(out, "<OP, MUL, %s>\n", yytext); }

{GT}               { fprintf(out, "<RELOP, GT, %s>\n", yytext); }
{LT}               { fprintf(out, "<RELOP, LT, %s>\n", yytext); }
{EQ}               { fprintf(out, "<RELOP, EQ, %s>\n", yytext); }
{NE}               { fprintf(out, "<RELOP, NE, %s>\n", yytext); }
{GE}               { fprintf(out, "<RELOP, GE, %s>\n", yytext); }
{LE}               { fprintf(out, "<RELOP, LE, %s>\n", yytext); }
{COMP_EQ}          { fprintf(out, "<RELOP, COMP_EQ, %s>\n", yytext); }


{OPN_SQR_BKT}     { fprintf(out, "<SYM, OPN_SQR_BKT, %s>\n", yytext); }
{CLS_SQR_BKT}     { fprintf(out, "<SYM, CLS_SQR_BKT, %s>\n", yytext); }
{OPN_CURLY_BKT}   { fprintf(out, "<SYM, OPN_CURLY_BKT, %s>\n", yytext); }
{CLS_CURLY_BKT}   { fprintf(out, "<SYM, CLS_CURLY_BKT, %s>\n", yytext); }
{SEMICOLON}       { fprintf(out, "<SYM, SEMICOLON, %s>\n", yytext); }
{COLON}           { fprintf(out, "<SYM, COLON, %s>\n", yytext); }
{COMMA}           { fprintf(out, "<SYM, COMMA, %s>\n", yytext); }
{OPN_PARENT}      { fprintf(out, "<SYM, OPN_PARENT, %s>\n", yytext); }
{CLS_PARENT}      { fprintf(out, "<SYM, CLS_PARENT, %s>\n", yytext); }


{FLOAT}            { fprintf(out, "<KEY, FLOAT, %s>\n", yytext); }
{INT}              { fprintf(out, "<KEY, INT, %s>\n", yytext); }
{VOID}             { fprintf(out, "<KEY, VOID, %s>\n", yytext); }
{IF}               { fprintf(out, "<KEY, IF, %s>\n", yytext); }
{ELSE}             { fprintf(out, "<KEY, ELSE, %s>\n", yytext); }
{WHILE}            { fprintf(out, "<KEY, WHILE, %s>\n", yytext); }
{RETURN}           { fprintf(out, "<KEY, RETURN, %s>\n", yytext); }

{ID}                {
                      int index = insert_symbol(yytext);
                      fprintf(out, "<%d, ID, %s>\n", index, yytext);
                  }

{STRING}        { fprintf(out, "<STRING, %s>\n", yytext); }

\"([^\"\\\n]|\\[abfnrtv\"\'\\0])*\n {
                      fprintf(out, "<%d, ERROR, \"Unclosed string\">\n", yylineno);
                  }

{WS}                ; /* Ignore spaces */

{NUM} {
    fprintf(out, "<NUM, %s>\n", yytext);
}

{ID_STARTS_DIGIT} {
    fprintf(out, "<%d, ERROR, \"Invalid identifier starts with digit '%s'\">\n", yylineno, yytext);
}

{INVALID_CHAR} {
    fprintf(out, "<%d, ERROR, \"Invalid identifier contains invalid characters '%s'\">\n", yylineno, yytext);
}


.                   { fprintf(out, "<%d, ERROR, \"Invalid character '%s'\">\n", yylineno, yytext); }

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

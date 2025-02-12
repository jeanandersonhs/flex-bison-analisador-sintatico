%{
    #include <stdio.h>
    #include <stdlib.h>
    #include <string.h>
    
    #include "node.h"  
    #include "parser.tab.h"

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

float       {digit}+\.{digit}+
num         {digit}+

ID          ({letter}|_)({letter}|{digit}|_)*


INT             "int"
VOID            "void"
IF              "if"
ELSE            "else"
WHILE           "while"
RETURN          "return"
FLOAT           "float"


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

ID_STARTS_W_DIGIT     ({digit})+({letter})+({letter}|{digit}|_)+ 
INVALID_CHAR          (({letter}|{digit}|_)*({invalid_char})+({letter}|{digit}|_)+)*

/* Regras de produção */
%%

{NL}                { linha = yylineno; }
"/*"                { linha = yylineno; BEGIN(COMMENT); }
<COMMENT>"*/"       { BEGIN(INITIAL); }
<COMMENT>"/*"       { fprintf(out, "<%d, ERROR, \"Nested comment\">\n", yylineno); }
<COMMENT>{NL}       { linha = yylineno; } /* Atualizar número da linha */
<COMMENT><<EOF>>    { fprintf(out, "<%d, ERROR, \"Unclosed comment\">\n", linha); }
<COMMENT>.          ; /* Ignorar outros caracteres no comentário */

{SUM}              { return SUM; }
{SUB}              { return SUB; }
{DIV}              { return DIV; }
{MUL}              { return MUL; }

{GT}               { return GT; }
{LT}               { return LT; }
{EQ}               { return EQ; }
{NE}               { return NE; }
{GE}               { return GE; }
{LE}               { return LE; }
{COMP_EQ}          { return COMP_EQ; }

{OPN_SQR_BKT}     { return OPN_SQR_BKT; }
{CLS_SQR_BKT}     { return CLS_SQR_BKT; }
{OPN_CURLY_BKT}   { return OPN_CURLY_BKT; }
{CLS_CURLY_BKT}   { return CLS_CURLY_BKT; }
{SEMICOLON}       { return SEMICOLON; }
{COLON}           { return COLON; }
{COMMA}           { return COMMA; }
{OPN_PARENT}      { return OPN_PARENT; }
{CLS_PARENT}      { return CLS_PARENT; }

{FLOAT}           { return FLOAT; }
{INT}             { return INT; }
{VOID}            { return VOID; }
{IF}              { return IF; }
{ELSE}            { return ELSE; }
{WHILE}           { return WHILE; }
{RETURN}          { return RETURN; }

{ID}              {
                      int index = insert_symbol(yytext);
                      //fprintf(out, "<%d, ID, %s>\n", index, yytext);
                        yylval.id = strdup(yytext);
                        return ID;
                  }

{STRING}        { //fprintf(out, "<STRING, %s>\n", yytext); 
                    yylval.id = strdup(yytext);
                    return STRING;
                }

\"([^\"\\\n]|\\[abfnrtv\"\'\\0])*\n {
                      fprintf(out, "<%d, ERROR, \"Unclosed string\">\n", yylineno);
                  }

{WS}                ; /* Ignore spaces */

{float} {
    // fprintf(out, "<FLOAT, %s>\n", yytext);
    yylval.id = strup(yytext); return float;
}

{num} {
    //fprintf(out, "<NUM, %s>\n", yytext);
    yylval.num = strup(yytext);
    return NUM;
}

{ID_STARTS_W_DIGIT} {
    fprintf(out, "<%d, ERROR, \"Invalid identifier starts with digit '%s'\">\n", yylineno, yytext); return ERROR;
}

{INVALID_CHAR} {
    fprintf(out, "<%d, ERROR, \"Invalid identifier contains invalid characters '%s'\">\n", yylineno, yytext); return ERROR;
}


.                   { fprintf(out, "<%d, ERROR, \"Invalid character '%s'\">\n", yylineno, yytext); return ERROR; }

%%

int yywrap() {
    return 1;
}

// int main(int argc, char *argv[]) {
//     FILE *arquivo;
//     if (argc < 3) {
//         fprintf(stderr, "Usage: %s <input_file> <output_file>\n", argv[0]);
//         return 1;
//     }
//     arquivo = fopen(argv[1], "r");
//     if (!arquivo) {
//         fprintf(stderr, "Error: Cannot open input file %s\n", argv[1]);
//         return 1;
//     }
//     yyin = arquivo;
//     out = fopen(argv[2], "w");
//     if (!out) {
//         fprintf(stderr, "Error: Cannot open output file %s\n", argv[2]);
//         fclose(arquivo);
//         return 1;
//     }
//     yylex();
    
//     // Imprimir a tabela de símbolos no final
//     fprintf(out, "\nTabela de Símbolos:\n");
//     for (int i = 0; i < symbol_count; i++) {
//         fprintf(out, "<%d, %s>\n", symbol_table[i].index, symbol_table[i].id);
//     }

//     fclose(arquivo);
//     fclose(out);
//     return 0;
// }

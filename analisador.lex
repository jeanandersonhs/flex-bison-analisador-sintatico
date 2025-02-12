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

Symbol symbol_table[1000]; // Symbol table
int symbol_count = 0;

// Function to insert identifiers in the symbol table.
int insert_symbol(const char *id) {
    for (int i = 0; i < symbol_count; i++) {
        if (strcmp(symbol_table[i].id, id) == 0) {
            return symbol_table[i].index; // Identifier already exists.
        }
    }
    // Add new identifier.
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

%%

{NL}                { linha = yylineno; }

"/*"                { linha = yylineno; BEGIN(COMMENT); }
<COMMENT>"*/"       { BEGIN(INITIAL); }
<COMMENT>"/*"       { fprintf(stderr, "<%d, ERROR, \"Nested comment\">\n", yylineno); }
<COMMENT>{NL}       { linha = yylineno; } /* Update line number */
<COMMENT><<EOF>>    { fprintf(stderr, "<%d, ERROR, \"Unclosed comment\">\n", linha); }
<COMMENT>.          { /* Ignore all other characters inside a comment */ }

{SUM}               { yylval.value = strdup(yytext); return SUM; }
{SUB}               { yylval.value = strdup(yytext); return SUB; }
{DIV}               { yylval.value = strdup(yytext); return DIV; }
{MUL}               { yylval.value = strdup(yytext); return MUL; }

{GT}                { yylval.value = strdup(yytext); return GT; }
{LT}                { yylval.value = strdup(yytext); return LT; }
{EQ}                { yylval.value = strdup(yytext); return EQ; }
{NE}                { yylval.value = strdup(yytext); return NE; }
{GE}                { yylval.value = strdup(yytext); return GE; }
{LE}                { yylval.value = strdup(yytext); return LE; }
{COMP_EQ}           { yylval.value = strdup(yytext); return COMP_EQ; }

{OPN_SQR_BKT}       { yylval.value = strdup(yytext); return OPN_SQR_BKT; }
{CLS_SQR_BKT}       { yylval.value = strdup(yytext); return CLS_SQR_BKT; }
{OPN_CURLY_BKT}     { yylval.value = strdup(yytext); return OPN_CURLY_BKT; }
{CLS_CURLY_BKT}     { yylval.value = strdup(yytext); return CLS_CURLY_BKT; }
{SEMICOLON}         { yylval.value = strdup(yytext); return SEMICOLON; }
{COLON}             { yylval.value = strdup(yytext); return COLON; }
{COMMA}             { yylval.value = strdup(yytext); return COMMA; }
{OPN_PARENT}        { yylval.value = strdup(yytext); return OPN_PARENT; }
{CLS_PARENT}        { yylval.value = strdup(yytext); return CLS_PARENT; }

{FLOAT}             { yylval.value = strdup(yytext); return FLOAT; }
{INT}               { yylval.value = strdup(yytext); return INT; }
{VOID}              { yylval.value = strdup(yytext); return VOID; }
{IF}                { yylval.value = strdup(yytext); return IF; }
{ELSE}              { yylval.value = strdup(yytext); return ELSE; }
{WHILE}             { yylval.value = strdup(yytext); return WHILE; }
{RETURN}            { yylval.value = strdup(yytext); return RETURN; }

{ID}                { 
                        int index = insert_symbol(yytext);
                        yylval.value = strdup(yytext);
                        return ID; 
                    }

{STRING}            { yylval.value = strdup(yytext); return STRING; }

\"([^\"\\\n]|\\[abfnrtv\"\'\\0])*\n {
                        fprintf(stderr, "<%d, ERROR, \"Unclosed string\">\n", yylineno);
                    }

{WS}                { /* do nothing */ }

{float}             { yylval.value = strdup(yytext); return FLOAT_NUM; }

{num}               { yylval.value = strdup(yytext); return NUM; }

{ID_STARTS_W_DIGIT} {
                        fprintf(stderr, "<%d, ERROR, \"Invalid identifier starts with digit '%s'\">\n", yylineno, yytext);
                    }

{INVALID_CHAR} {
                        fprintf(stderr, "<%d, ERROR, \"Invalid identifier contains invalid characters '%s'\">\n", yylineno, yytext);
                    }

.                   { fprintf(stderr, "<%d, ERROR, \"Invalid character '%s'\">\n", yylineno, yytext); }

%%

int yywrap() {
    return 1;
}

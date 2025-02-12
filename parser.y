%{
#include "node.h"
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <stdarg.h>

Node *root;
int yylex();
void yyerror(const char *s);
%}

%union {
    char *value;
    Node *node;
}

%token <value> INT FLOAT VOID IF ELSE WHILE RETURN
%token <value> ID NUM STRING FLOAT_NUM
%token <value> SUM SUB MUL DIV
%token <value> GT LT EQ NE GE LE COMP_EQ
%token <value> OPN_PARENT CLS_PARENT OPN_SQR_BKT CLS_SQR_BKT
%token <value> OPN_CURLY_BKT CLS_CURLY_BKT SEMICOLON COMMA COLON

%nonassoc LOWER_THAN_ELSE
%nonassoc ELSE

%type <node> program statement_list statement declaration type
%type <node> attribution expression condition if_statement
%type <node> while_statement function_decl parameters return_statement
%type <node> array_access variable
%type <node> array_decl term factor argument_list block

%start program

%%

program:
      function_decl                         { $$ = create_node("program", 1, $1); root = $$; }
    | function_decl program                 { $$ = create_node("program", 2, $1, $2); root = $$; }
    | statement_list                        { $$ = create_node("program", 1, $1); root = $$; }
    ;

function_decl:
    type ID OPN_PARENT parameters CLS_PARENT OPN_CURLY_BKT statement_list CLS_CURLY_BKT {
        $$ = create_node("function", 4, $1, create_node($2, 0), $4, $7);
    }
    ;

parameters:
    /* empty */ { $$ = create_node("parameters", 0); }
    | type ID { $$ = create_node("parameters", 2, $1, create_node($2, 0)); }
    | parameters COMMA type ID { $$ = create_node("parameters", 3, $1, $3, create_node($4, 0)); }
    ;

statement_list:
    statement { $$ = create_node("statement_list", 1, $1); }
    | statement_list statement { $$ = create_node("statement_list", 2, $1, $2); }
    ;

statement:
        block { $$ = $1; }
    | declaration SEMICOLON          { $$ = create_node("statement", 1, $1); }
    | attribution SEMICOLON        { $$ = create_node("statement", 1, $1); }
    | if_statement                 { $$ = create_node("statement", 1, $1); }
    | while_statement              { $$ = create_node("statement", 1, $1); }
    | return_statement SEMICOLON   { $$ = create_node("statement", 1, $1); }
    | expression SEMICOLON         { $$ = create_node("statement", 1, $1); }
    ;

declaration:
    type ID array_decl { $$ = create_node("declaration", 3, $1, create_node($2, 0), $3); }
    | type ID EQ expression { $$ = create_node("declaration", 4, $1, create_node($2, 0), create_node("=", 0), $4); }
    ;

array_decl:
    /* empty */ { $$ = create_node("array_decl", 0); }
    | OPN_SQR_BKT NUM CLS_SQR_BKT { $$ = create_node("array_size", 1, create_node($2, 0)); }
    ;

type:
    INT { $$ = create_node("int", 0); }
    | FLOAT { $$ = create_node("float", 0); }
    | VOID { $$ = create_node("void", 0); }
    ;

attribution:
    variable EQ expression { $$ = create_node("attribution", 3, $1, create_node("=", 0), $3); }
    ;

variable:
    ID { $$ = create_node("variable", 1, create_node($1, 0)); }
    | ID array_access { $$ = create_node("array_access", 2, create_node($1, 0), $2); }
    ;

array_access:
    OPN_SQR_BKT expression CLS_SQR_BKT { $$ = create_node("index", 1, $2); }
    ;

expression:
    expression SUM term { $$ = create_node("expression", 3, $1, create_node("+", 0), $3); }
    | expression SUB term { $$ = create_node("expression", 3, $1, create_node("-", 0), $3); }
    | term { $$ = $1; }
    ;

term:
    term MUL factor { $$ = create_node("term", 3, $1, create_node("*", 0), $3); }
    | term DIV factor { $$ = create_node("term", 3, $1, create_node("/", 0), $3); }
    | factor { $$ = $1; }
    ;

argument_list:
      /* empty */            { $$ = create_node("arguments", 0); }
    | expression             { $$ = create_node("arguments", 1, $1); }
    | argument_list COMMA expression
                              { $$ = create_node("arguments", 2, $1, $3); }
    ;

factor:
      NUM                     { $$ = create_node("number", 1, create_node($1, 0)); }
    | FLOAT_NUM               { $$ = create_node("float", 1, create_node($1, 0)); }
    | STRING                  { $$ = create_node("string", 1, create_node($1, 0)); }
    | ID OPN_PARENT argument_list CLS_PARENT
                              { $$ = create_node("call", 2, create_node($1, 0), $3); }
    | variable                { $$ = $1; }
    | OPN_PARENT expression CLS_PARENT
                              { $$ = $2; }
    ;

condition:
    expression COMP_EQ expression { $$ = create_node("condition", 3, $1, create_node("==", 0), $3); }
    | expression NE expression { $$ = create_node("condition", 3, $1, create_node("!=", 0), $3); }
    | expression LT expression { $$ = create_node("condition", 3, $1, create_node("<", 0), $3); }
    | expression LE expression { $$ = create_node("condition", 3, $1, create_node("<=", 0), $3); }
    | expression GT expression { $$ = create_node("condition", 3, $1, create_node(">", 0), $3); }
    | expression GE expression { $$ = create_node("condition", 3, $1, create_node(">=", 0), $3); }
    ;

block:
    OPN_CURLY_BKT statement_list CLS_CURLY_BKT { $$ = create_node("block", 1, $2); }
    ;

if_statement:
      IF OPN_PARENT condition CLS_PARENT statement %prec LOWER_THAN_ELSE
          { $$ = create_node("if", 2, $3, $5); }
    | IF OPN_PARENT condition CLS_PARENT statement ELSE statement
          { $$ = create_node("if", 3, $3, $5, $7); }
    ;

while_statement:
    WHILE OPN_PARENT condition CLS_PARENT OPN_CURLY_BKT statement_list CLS_CURLY_BKT {
        $$ = create_node("while", 2, $3, $6);
    }
    ;

return_statement:
    RETURN expression { $$ = create_node("return", 1, $2); }
    ;

%%

Node *create_node(char *label, int child_count, ...) {
    Node *node = malloc(sizeof(Node));
    node->label = strdup(label);
    node->child_count = child_count;
    node->children = malloc(child_count * sizeof(Node *));

    va_list args;
    va_start(args, child_count);
    for (int i = 0; i < child_count; i++) {
        node->children[i] = va_arg(args, Node *);
    }
    va_end(args);

    return node;
}

void print_tree(Node *node, int depth) {
    if (!node) return;

    for (int i = 0; i < depth; i++) {
        printf("\t");
    }
    printf("%s\n", node->label);
    
    for (int i = 0; i < node->child_count; i++) {
        print_tree(node->children[i], depth + 1);
    }
}

void yyerror(const char *s) {
    fprintf(stderr, "Syntax error: %s\n", s);
}

int main() {
    if (yyparse() == 0) {
        print_tree(root, 0);
    }
    return 0;
}
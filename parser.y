%{
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <stdarg.h>
#include "node.h"

Node *root;

int yylex();
void yyerror(const char *s);
%}

%union {
    char* num;
    char *id;
    Node *node;
}

%token <id> ID NUM RELOP
%token INT FLOAT IF ELSE WHILE RETURN VOID
%token SUM SUB DIV MUL GT LT EQ NE GE LE COMP_EQ
%token OPN_SQR_BKT CLS_SQR_BKT OPN_CURLY_BKT CLS_CURLY_BKT SEMICOLON COLON COMMA OPN_PARENT CLS_PARENT
%token STRING


%type <node> program statement_list statement declaration attribution if_statement type condition expression

%start program

%%

program:
    statement_list { root = create_node("program", 1, $1); }
    ;

statement_list:
    statement { $$ = create_node("statement_list", 1, $1); }
    | statement_list statement { $$ = create_node("statement_list", 2, $1, $2); }
    ;

statement:
    attribution { $$ = create_node("statement", 1, $1); }
    | if_statement { $$ = create_node("statement", 1, $1); }
    | declaration { $$ = create_node("statement", 1, $1); }
    | return_statement { $$ = create_node("statement", 1, $1); } // 
    ;

declaration:
    type ID SEMICOLON { $$ = create_node("declaration", 2, $1, create_node($2, 0)); }
    | type ID OPN_SQR_BKT NUM CLS_SQR_BKT SEMICOLON { $$ = create_node("declaration", 3, $1, create_node($2, 0), create_node($4, 0)); } // int id[num]; 
    ;

type:
    INT { $$ = create_node("INT", 0); }
    | FLOAT { $$ = create_node("FLOAT", 0); }
    ;

attribution:
    ID EQ expression SEMICOLON { $$ = create_node("attribution", 2, create_node($1, 0), $3); }
    ID OPN_SQR_BKT expression CLS_SQR_BKT EQ expression SEMICOLON { $$ = create_node("attribution", 3, create_node($1, 0), $3, $6); } // id[num] = expression;
    ;

if_statement:
    IF OPN_PARENT condition CLS_PARENT OPN_CURLY_BKT statement_list CLS_CURLY_BKT ELSE OPN_CURLY_BKT statement_list CLS_CURLY_BKT { $$ = create_node("if_statement", 3, $3, $6, $10); }
    | IF OPN_PARENT condition CLS_PARENT OPN_CURLY_BKT statement_list CLS_CURLY_BKT { $$ = create_node("if_statement", 2, $3, $6); }
    ;

while_statement:
    WHILE OPN_PARENT condition CLS_PARENT OPN_CURLY_BKT statement_list CLS_CURLY_BKT { $$ = create_node("while_statement", 2, $3, $6); }
    ;

function_statement:
    type ID OPN_PARENT declaration CLS_PARENT OPN_CURLY_BKT statement_list CLS_CURLY_BKT { $$ = create_node("function_statement", 3, $1, create_node($2, 0), $4, $7); }
    ;
function_call:
    ID OPN_PARENT CLS_PARENT SEMICOLON { $$ = create_node("function_call", 1, create_node($1, 0)); }
    | ID OPN_PARENT expression CLS_PARENT SEMICOLON { $$ = create_node("function_call", 2, create_node($1, 0), $3); }
    ;
condition:
    expression RELOP expression { $$ = create_node("condition", 3, $1, create_node("relop",1,create_node($2,0)),$3); }

expression:
    NUM { $$ = create_node($1, 0); }
    | ID { $$ = create_node($1, 0); }
    | expression SUM expression { $$ = create_node("expression", 3, $1, create_node("+", 0), $3); }
    | expression SUB expression { $$ = create_node("expression", 3, $1, create_node("-", 0), $3); }
    | expression MUL expression { $$ = create_node("expression", 3, $1, create_node("*", 0), $3); }
    | expression DIV expression { $$ = create_node("expression", 3, $1, create_node("/", 0), $3); }
    ;

return_statement:
    RETURN expression SEMICOLON { $$ = create_node("return_statement", 1, $2); }
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
    fprintf(stderr, "Erro de sintaxe: %s\n", s);
}

int main() {
    if (yyparse() == 0) {
        print_tree(root, 0);
    }
    return 0;
}

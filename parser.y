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

%token <id> ID NUM 
%token INT FLOAT IF ELSE WHILE RETURN VOID
%token SUM SUB DIV MUL GT LT EQ NE GE LE COMP_EQ
%token OPN_SQR_BKT CLS_SQR_BKT OPN_CURLY_BKT CLS_CURLY_BKT SEMICOLON COLON COMMA OPN_PARENT CLS_PARENT
%token STRING


%type <node> program statement_list statement declaration attribution if_statement type condition expression param_list param expression_list  
%type <node> while_statement function_statement function_call return_statement relop OP    

%left SUM SUB
%left MUL DIV
%nonassoc IF
%nonassoc ELSE
%right EQ

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
    | while_statement { $$ = create_node("statement", 1, $1); }
    | function_statement { $$ = create_node("statement", 1, $1); }
    | function_call { $$ = create_node("statement", 1, $1); }
    | return_statement { $$ = create_node("statement", 1, $1); } // 
    ;

declaration:
    type ID SEMICOLON { $$ = create_node("declaration", 2, $1, create_node($2, 0)); }
    | type ID OPN_SQR_BKT NUM CLS_SQR_BKT { $$ = create_node("array_declaration", 3, $1, create_node($2, 0), create_node($4, 0)); }
    ;

param_list:
param { $$ = create_node("param_list", 1, $1); }
| param_list COMMA param { $$ = create_node("param_list", 2, $1, $3); }
;

param:
declaration { $$ = $1; }
;

type:
    INT { $$ = create_node("INT", 0); }
    | FLOAT { $$ = create_node("FLOAT", 0); }
    | VOID { $$ = create_node("VOID", 0); }
    ;

attribution:
    ID EQ expression SEMICOLON { $$ = create_node("attribution", 2, create_node($1, 0), $3); }
    | ID OPN_SQR_BKT expression CLS_SQR_BKT EQ expression { $$ = create_node("array_attribution", 3, create_node($1, 0), $3, $6); }   
    ;

if_statement:
IF OPN_PARENT condition CLS_PARENT OPN_CURLY_BKT statement_list CLS_CURLY_BKT %prec IF {$$ = create_node("if_statement", 2, $3, $6);}
| IF OPN_PARENT condition CLS_PARENT OPN_CURLY_BKT statement_list CLS_CURLY_BKT ELSE OPN_CURLY_BKT statement_list CLS_CURLY_BKT {$$ = create_node("if_else_statement", 3, $3, $6, $10);}
;

while_statement:
    WHILE OPN_PARENT condition CLS_PARENT OPN_CURLY_BKT statement_list CLS_CURLY_BKT { $$ = create_node("while_statement", 2, $3, $6); }
    ;

function_statement:
    type ID OPN_PARENT param_list CLS_PARENT OPN_CURLY_BKT statement_list CLS_CURLY_BKT { $$ = create_node("function_statement", 4, $1, create_node($2, 0), $4, $7); }
    | type ID OPN_PARENT CLS_PARENT OPN_CURLY_BKT statement_list CLS_CURLY_BKT { $$ = create_node("function_statement", 3, create_node("VOID", 0), create_node($2, 0), $6); }
    ;

function_call:
    ID OPN_PARENT CLS_PARENT SEMICOLON { $$ = create_node("function_call", 1, create_node($1, 0)); }
    | ID OPN_PARENT expression_list CLS_PARENT SEMICOLON { $$ = create_node("function_call", 2, create_node($1, 0), $3); }
    ;

expression_list:
expression { $$ = create_node("expression_list", 1, $1); }
| expression_list COMMA expression { $$ = create_node("expression_list", 2, $1, $3); }
;

condition:
    expression relop expression { $$ = create_node("condition", 3, $1, create_node("relop",1,create_node($2,0)),$3); }

relop:
    GT { $$ = create_node("GT", 0); }
    | LT { $$ = create_node("LT", 0); }
    | EQ { $$ = create_node("EQ", 0); }
    | NE { $$ = create_node("NE", 0); }
    | GE { $$ = create_node("GE", 0); }
    | LE { $$ = create_node("LE", 0); }
    | COMP_EQ { $$ = create_node("COMP_EQ", 0); }
    ;
expression:
    NUM { $$ = create_node($1, 0); }
    | ID { $$ = create_node($1, 0); }
    | ID OPN_SQR_BKT expression CLS_SQR_BKT { $$ = create_node("array_access", 2, create_node($1, 0), $3); }
    | expression OP expression { $$ = create_node("expression", 3, $1, $2, $3); }
;

OP:
    SUM { $$ = create_node("SUM", 0); }
    | SUB { $$ = create_node("SUB", 0); }
    | DIV { $$ = create_node("DIV", 0); }
    | MUL { $$ = create_node("MUL", 0); }
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

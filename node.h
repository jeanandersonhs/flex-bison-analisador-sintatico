#ifndef NODE_H
#define NODE_H

typedef struct Node {
    char *label;
    struct Node **children;
    int child_count;
} Node;

Node *create_node(char *label, int child_count, ...);
void print_tree(Node *node, int depth);

#endif

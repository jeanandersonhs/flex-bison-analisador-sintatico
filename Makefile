all: build run

build: analisador.lex
	flex analisador.lex
	gcc lex.yy.c -o analisador
run: analisador entrada.c 
	./analisador entrada.c saida.txt

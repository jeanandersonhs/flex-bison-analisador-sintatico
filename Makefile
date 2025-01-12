all: build run

build: analisador.lex
	flex analisador.lex
	gcc lex.yy.c -o scanner
run: scanner exemplo.c 
	./scanner exemplo.c saida.txt

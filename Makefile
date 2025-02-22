all: build run

build: analisador.lex parser.y
	bison -d parser.y
	flex analisador.lex
	gcc parser.tab.c lex.yy.c -o analisador 
run: analisador entrada.c 
	./analisador < entrada.c

clean:
	rm -r analisador lex.yy.c parser.tab.c parser.tab.h

all: interpreteur

interpreteur : y.tab.c lex.yy.c
	gcc y.tab.c lex.yy.c -ll -o interpreteur

y.tab.c : interpreteur.y
	yacc -d interpreteur.y

lex.yy.c : interpreteur.l
	flex interpreteur.l 

clean:
	rm -rf *.o
	rm -rf lex.yy.c
	rm -rf y.tab.c
	rm -rf y.tab.h
	rm -rf interpreteur

mrproper: clean
	rm -rf interpreteur


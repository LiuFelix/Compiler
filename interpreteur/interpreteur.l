%{
#include <stdio.h>
#include <stdlib.h>
#include "y.tab.h"
%}

%option yylineno

number [0-9]+

%%

^01		{yylval.nb = tADD; return tADD;}
^02		{yylval.nb = tMUL; return tMUL;}
^03		{yylval.nb = tSOU; return tSOU;}
^04		{yylval.nb = tDIV; return tDIV;}
^05		{yylval.nb = tCOP; return tCOP;}
^06		{yylval.nb = tAFC; return tAFC;}
^07		{yylval.nb = tLOAD; return tLOAD;}
^08		{yylval.nb = tSTORE; return tSTORE;}
^09		{yylval.nb = tEQU; return tEQU;}
^0a		{yylval.nb = tINF; return tINF;}
^0b		{yylval.nb = tINFE; return tINFE;}
^0c		{yylval.nb = tSUP; return tSUP;}
^0d		{yylval.nb = tSUPE; return tSUPE;}
^0e		{yylval.nb = tJMP; return tJMP;}
^0f		{yylval.nb = tJMPC; return tJMPC;}
^10		{yylval.nb = tPRI; return tPRI;}

{number}	{yylval.nb = atoi(yytext); return tArg;}
[ \t\n]
[a-zA-Z]+	{printf("\033[%smNon reconnu: %s\033[%sm\n", "31", (char*) yytext), "0"; return yytext;}
.			return yytext[0];

%%

void yyerror (char* s) {
	printf("\033[%smError at line %d : %s\033[%sm\n", "31", yylineno, yytext, "0");
}

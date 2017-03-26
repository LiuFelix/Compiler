%{
#include <stdlib.h>
#include <stdio.h>
#include "tab_symboles.h"
#include <string.h>
#include "tab_fonctions.h"

void yyerror(char *s);
int yylex(void);

//table des instructions
char* instr[1024][4];
int ip = 0;

void add_instr3(char* op, char* opr1, char* opr2, char* opr3){
	if (ip < 256) {
		instr[ip][0] = op;
		instr[ip][1] = opr1;
		instr[ip][2] = opr2;
		instr[ip][3] = opr3;
		ip++;
	} else {
		printf("Erreur ! Overflow table instructions ! \n");
		exit(1);
	}
}

void add_instr2(char* op, char* opr1, char* opr2){
	char buf1[5], buf2[5];
	if (ip < 256) {
		instr[ip][0] = op;
		instr[ip][1] = opr1;
		instr[ip][2] = opr2;
		ip++;
	} else {
		printf("Erreur ! Overflow table instructions ! \n");
		exit(1);
	}
}

void add_instruction(char* op, int s1, int s3){
	char* buf = malloc(5); 
	char* buf2 = malloc(5); 
	char* buf3 = malloc(5);
	sprintf(buf, "%d", tab_sym[s1].adr) ; 
	add_instr2("LOAD", "R0", buf); 
	sprintf(buf2, "%d", tab_sym[s3].adr);
	add_instr2("LOAD", "R1", buf2); 
	free_last_tmp(); 
	free_last_tmp();
	add_instr3(op,"R0","R0","R1"); 
	ajout_tmp(); 
	sprintf(buf3, "%d", tab_sym[tmp].adr);
	add_instr2("STORE", buf3, "R0"); 
	//free(buf);
	//free(buf2);
	//free(buf3);
}

void add_tId(char* s1){
	char* buf = malloc(5); 
	char* buf2 = malloc(5) ;  
	sprintf(buf, "%d", find_sym(s1)); 
	if (tab_sym[find_sym(s1)].init == 1){ 
		add_instr2("LOAD", "R0",buf) ; 
		ajout_tmp();
		sprintf(buf2, "%d", tab_sym[tmp].adr);  
		add_instr2("STORE", buf2, "R0"); 
	} else {
		printf("Error : Variable non initialized !\n");
		exit(1);
	};
}

/* Print du tableau (Test)*/
void init_tab(){
	int i, j;
	for (i=0; i<256; i++){
		for (j=0; j<4; j++){
			instr[i][j] = NULL;
		}
	}
}

void print_tab(){
	int i=0, j;
	while (instr[i][0] != NULL){
		for (j=0; j<4; j++){
			if (instr[i][j] != NULL)
				printf("%s ", instr[i][j]);
		}
		printf("\n");
		i++;
	}
}

void save_tab(){
	FILE* fichier;
	fichier = fopen("instrASM.txt","w");
	int i=0, j;
	while (instr[i][0] != NULL){
		for (j=0; j<4; j++){
			if (instr[i][j] != NULL)
				fprintf(fichier, "%s ", instr[i][j]);
		}
		fprintf(fichier, "\n");
		i++;
	}
	fclose(fichier);
}

//les registres
int reg[3]= {0,1,2};
int r=0;

int use_reg(){
	if (r<3){ 
		return reg[r++];
	} else {
		printf("Dépassement nombre de registres !\n");
		exit(1);
	}
}

void free_reg(){
	if (r>0) {
		r--;
	} else {
		printf("Impossible de décrémenter, déjà à 0 ! \n");
		exit(1);
	}
}

void free_all(){
	r = 0;
}


%}
%union 	{int nb; char* str;};
%token 	tInclude tMain tIf tElse tWhile tAo tAf tPo tPf tPv tEqu tVir tStar tPlus tMinus tRet tInt tEquEqu tAnd tOr tConst blancs lettre chiffre tPrint tCo tCf tDot tDiv tNot tInf tSup tInfEqu tSupEqu
%token	<nb>	tNb
%token	<str> 	tId
%type 	<str>	tMain
%type	<nb> 	tAo
%type	<nb>	tPo
%type	<nb>	tPf
%type	<nb>	E
%type	<nb>	Return
%type	<nb>	Invoc
//%type	<nb>	Else
%left	tOr tAnd
%right	tEquEqu
%left	tPlus tMinus
%left	tDiv tStar
%left	tPo tPf
%right	tEqu
%start	Prog						

%%
Prog : Fonctions
     ;
Fonctions : Fonction Fonctions
		  	| Main
			;
Fonction : tInt tId tPo 	{ajout_fonc($2,ip);  printf("tab_fnt[fonc] = %s\n",tab_fnt[fonc].id);}
		 	Args 			{/*ajout_nbArgs($2);*/} 
			tPf RBody 		{char* buf = malloc(5);
								/*sprintf(buf, "%d", del_ret());*/
	   							add_instr2("JMP","R14","");}
			;
Main : tInt tMain 			{ajout_fonc($2, ip);} 
	 	tPo tPf RBody		 
	      ;
Args : tInt tId 			{add_tId($2); /*---------Voir comment incrementer le nombre d'argument avec le nom de la fonction*/} 
	 	ArgsN 
	 |  /*empty*/ 
		;
ArgsN :	tVir tInt tId 		{add_tId($3); /*---------voir comment incrementer le nombre d'argument avec le nom de la fonction*/} 
	  	ArgsN 
	  |  /*empty*/ 
		;
RBody : tAo 				{$1 = getSym(); printf("$1 = %d\n", $1);} 
	  	Instrs Return 		{setSym($1);} 
		tAf
	 ;
Instrs : Aff tPv Instrs 
	   | Invoc tPv Instrs 
		| If Instrs 
		| Decl tPv Instrs
		| While Instrs 
		| Print Instrs 
		| /*empty*/
	   	;
E :  tId					{add_tId($1); $$=tab_sym[tmp].adr;}	
  	
	| tNb					{char* buf = malloc(5); char* buf2 = malloc(5) ; 
								sprintf(buf, "%d", $1); 
								add_instr2("AFC", "R0", buf); ajout_tmp(); 
								sprintf(buf2, "%d", tab_sym[tmp].adr); 
								add_instr2("STORE", buf2, "R0"); 
								$$=tab_sym[tmp].adr;}
	| E tEquEqu E			{add_instruction("EQU", $1, $3); $$=tab_sym[tmp].adr; }
	| E tInf E				{add_instruction("INF", $1, $3); $$=tab_sym[tmp].adr; }
	| E tInfEqu E			{add_instruction("INFE", $1, $3); $$=tab_sym[tmp].adr; }
	| E tSup E				{add_instruction("SUP", $1, $3); $$=tab_sym[tmp].adr; }
	| E tSupEqu E			{add_instruction("SUPEQU", $1, $3); $$=tab_sym[tmp].adr; }
	| Invoc					
	| tPo E tPf				{$$=$2;}
	| E tPlus E				{add_instruction("ADD", $1, $3); $$=tab_sym[tmp].adr; }	
	| E tMinus E			{add_instruction("SOU", $1, $3); $$=tab_sym[tmp].adr; }	
	| E tStar E				{add_instruction("MUL", $1, $3); $$=tab_sym[tmp].adr; }		
	| E tDiv E				{add_instruction("DIV", $1, $3); $$=tab_sym[tmp].adr; }	
	;	
If : tIf tPo E tPf 
   							{$2=ip; 
								add_instr2("JMPC","","R0");}
	Body 
							{char* buf = malloc(5);
								sprintf(buf, "%d", ip+2);
								instr[$2][1]=buf;
								$2=ip;
								add_instr2("JMP","","");}

	Else					{char* buf = malloc(5);
								sprintf(buf, "%d", ip+1);
								instr[$2][1]=buf;}
	;
Else : tElse Body 
	 	| /*empty*/
		;
While : tWhile tPo			{$2=ip;}
	  	E tPf 				{$4=ip; add_instr2("JMPC","","R0");}
		Body	
							{char* buf = malloc(5);
								sprintf(buf, "%d", ip+2);
								instr[$4][1]=buf;
								add_instr2("JMP","","");
								char* buf1 = malloc(5);
								sprintf(buf1, "%d", $2);
								instr[ip-1][1]=buf1;}
	  ;	
Body : tAo 					{$1 = getSym();} 
	 	Instrs 				{setSym($1);} 
		tAf 			
	 ;
Invoc : tId 				{int adr_fonc; 
							  	ajout_ret(ip+1);
								adr_fonc = find_fonc($1);
								char* buf = malloc(5);
								sprintf(buf, "%d", adr_fonc);
								add_instr2("JMP",buf,"");
							}
	  			
		tPo Params tPf			
	  ;
Params : E ParamsN
	   	| /*empty*/ 
		;
ParamsN : tVir E ParamsN
		| /*empty*/
		;
Decl : tInt Decl1	Decln
		;
Decl1 : tId 	 			{ajout_sym($1);printf("\033[%sm ==> Déclaration de la variable %s à l'index %d \033[%sm\n","32", tab_sym[sym].id, sym, "0");}

	  	| tId tEqu E		{ajout_sym_init($1);printf("\033[%sm ==> Déclaration et Initialisation de la variable %s à l'index %d \033[%sm\n","32", tab_sym[sym].id, sym, "0");
								char* buf = malloc(5); char* buf2 = malloc(5);
								sprintf(buf, "%d", $3);
								add_instr2("LOAD", "R0", buf);
								free_last_tmp();
								sprintf(buf2, "%d", find_sym($1));
								add_instr2("STORE", buf2, "R0");}
		;
Decln : tVir Decl1 Decln
		| /*empty*/
		;
Aff : tId tEqu E			{ajout_init($1);
								int adr_sym = find_sym($1);
								printf("\033[%sm ==> Affectation de la variable %s à l'index %d \033[%sm\n","35", tab_sym[adr_sym].id, adr_sym, "0");
								char* buf = malloc(5); char* buf2 = malloc(5);
								sprintf(buf, "%d", $3);
								add_instr2("LOAD", "R0", buf); free_last_tmp();
								sprintf(buf2, "%d", adr_sym);
								add_instr2("STORE", buf2, "R0");}
								//add_instr2("","","");}
	;

Print : tPrint tPo tId tPf tPv	{char* buf = malloc(5);
				  					sprintf(buf, "%d", find_sym($3)); 
									add_instr2("LOAD", "R0",buf) ; ajout_tmp();
									add_instr2("PRI", "R0", ""); }
	  ;
Return : tRet E tPv 		{$$=$2;}
	   ;

%%
void yyerror(char *s) {
	extern int yylineno;
  	fprintf(stderr, "\033[%smError at line %d : %s\033[%sm \n","31", (yylineno-1), s, "0");
}

int main() {
	printf("\n\n---------------------------Début du parser--------------------------\n");
	init_tab();
	yyparse();
	printf("\n---------------------------Début print tab--------------------------\n\n");
	print_tab();
	save_tab();
	return 0;
}

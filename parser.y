%{
#include <stdlib.h>
#include <stdio.h>
#include "tab_symboles.h"
#include <string.h>
#include "tab_fonctions.h"

#define LR "R15"
#define VAL_RET "R14"
#define BP "R13"

void yyerror(const char *s);
int yylex(void);

//table des instructions
char* instr[1024][4];
int ip = 0;

int nb_arg;

void add_instr3(char* op, char* opr1, char* opr2, char* opr3){
	if (ip < 256) {
		instr[ip][0] = op;
		instr[ip][1] = opr1;
		instr[ip][2] = opr2;
		instr[ip][3] = opr3;
		ip++;
	} else {
		printf("Erreur ! Overflow table instructions ! \n");
		exit(3);
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
		exit(2);
	}
}

void add_op(char* op, int s1, int s3){
	char* buf = malloc(5); 
	char* buf2 = malloc(5); 
	char* buf3 = malloc(5);
	printf("tab_sym[%d].adr = %d\n",s1,  tab_sym[s1].adr);
printf("tab_sym[%d].adr = %d\n", s3, tab_sym[s3].adr);

	sprintf(buf, "%d", tab_sym[s1].adr) ; 
	add_instr2("LOAD", "R0", buf); 

	sprintf(buf2, "%d", tab_sym[s3].adr);
	add_instr2("LOAD", "R1", buf2); 
//printf("Avant 2eme free, sym = %d\n", sym);
	//free_last_tmp();
	add_instr3(op,"R0","R0","R1"); 
	//ajout_tmp(); 
	//sprintf(buf3, "%d", tab_sym[sym].adr);
	add_instr2("STORE", buf, "R0"); 
	free_last_tmp(); 
printf("Free add op, sym = %d\n", sym);
	//free(buf);
	//free(buf2);
	//free(buf3);
}

void add_tId(char* s1){
	char* buf = malloc(5); 
	char* buf2 = malloc(5) ;  
	int find = find_sym(s1);
	sprintf(buf, "%d", find); 
	if (tab_sym[find].init == 1){ 
		add_instr2("LOAD", "R0",buf) ; 
//free_last_tmp();
		ajout_tmp();
		sprintf(buf2, "%d", tab_sym[sym].adr);  
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
%type	<nb>	E Invoc Params ParamsN
%left	tOr tAnd
%right	tEquEqu
%left	tPlus tMinus
%left	tDiv tStar
%left	tPo tPf
%right	tEqu
%error-verbose
%start	Prog						

%%
Prog : {add_instr2("JMP","","");}
	 Fonctions
     ;
Fonctions : Fonction Fonctions
		  	| Main
			;
Fonction : tInt tId tPo 	{nb_arg=0;}
		 Args 				{ajout_fonc($2,ip,nb_arg);  printf("tab_fnt[%d] = %s avec  %d arg(s)\n",fonc, tab_fnt[fonc].id, tab_fnt[fonc].nbArgs);} 
			tPf RBody 		
			;
Main : tInt tMain 			{ajout_fonc($2, ip, 0);
	 							char* buf = malloc(5);
								sprintf(buf, "%d", ip+1);	
	 							instr[0][1]=buf; //1ere ligne assembleur qui saute direct vers le main
							} 
	 	tPo tPf RBody		 
	      ;
Args : tInt tId 			{//ajout_sym_init($2);
								printf("J'ajoute un arg\n"); 
	 							nb_arg++;} 
	 	ArgsN 
	 |  /*empty*/ 
		;
ArgsN :	tVir tInt tId 		{//ajout_sym_init($3); 
	  							printf("J'ajoute un autre arg\n");
	  							nb_arg++;}
	  	ArgsN 
	  |  /*empty*/ 
		;
RBody : tAo 				{$1 = getSym();} 
	  	Instrs Return 		{setSym($1);} 
		tAf
	 ;
Return : tRet E tPv 		{char* buf = malloc(5);
	   							sprintf(buf, "%d", $2);
	   							add_instr2("LOAD",VAL_RET,buf); //Stockage de la valeur de retour dans r0
								add_instr2("JMPR",LR,""); //Jump registre sur LR (Registre contenant l'adresse de retour
							}
	   ;
Decl : tInt Decl1	Decln
		;
Decl1 : tId 	 			{printf("[Decl] Je suis au sym = %d\n",getSym());ajout_sym($1);printf("\033[%sm ==> Déclaration de la variable %s à l'index %d \033[%sm\n","32", tab_sym[sym].id, sym, "0");printf("[Decl fin] Je suis au sym = %d\n",getSym());print_tab_sym();}

	  	| tId tEqu E		{
								char* buf = malloc(5); char* buf2 = malloc(5);
								sprintf(buf, "%d", $3);
								add_instr2("LOAD", "R0", buf);
								//free_last_tmp();
free_last_tmp();printf("[Decl-Aff] Je suis au sym = %d\n",getSym());
ajout_sym_init($1);printf("\033[%sm ==> Déclaration et Initialisation de la variable %s à l'index %d \033[%sm\n","33", tab_sym[sym].id, sym, "0");
								sprintf(buf2, "%d", find_sym($1));
								add_instr2("STORE", buf2, "R0");print_tab_sym();}
		;
Decln : tVir Decl1 Decln
		| /*empty*/
		;
Aff : tId tEqu E			{
								ajout_init($1);
								int adr_sym = find_sym($1);
								printf("\033[%sm ==> Affectation de la variable %s à l'index %d \033[%sm\n","35", tab_sym[adr_sym].id, adr_sym, "0");
								char* buf = malloc(5); char* buf2 = malloc(5);
								sprintf(buf, "%d", $3);
								add_instr2("LOAD", "R0", buf);
								sprintf(buf2, "%d", adr_sym);
free_last_tmp();printf("[Aff] Je suis au sym = %d\n",getSym());
//ajout_tmp();
								add_instr2("STORE", buf2, "R0");print_tab_sym();}
								//add_instr2("","","");}
	;
Instrs : Aff tPv Instrs 
	   	| Invoc tPv Instrs 
		| If Instrs 
		| Decl tPv Instrs
		| While Instrs 
		| Print Instrs 
		| /*empty*/
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
While : tWhile tPo			{printf("Debut du while\n");print_tab_sym();$2=ip;}
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
Invoc : tId 				{	if (check_exist_fonc($1)){
	  								//Sauvegarde en mémoire de l'adresse de retour
	  								printf("Tout début de Invoc\n");
	  								char* buf = malloc(5);
	  								ajout_sym_init("lr");
									sprintf(buf,"%d",getSym());
									add_instr2("STORE", buf, LR);free_last_tmp();
								} else {
									fprintf(stderr,"La foncion %s n'est pas déclarée\n",$1);
									exit(1);
								}
							}
								
		tPo Params tPf		{	if (tab_fnt[index_fonc($1)].nbArgs != $4){
									fprintf(stderr,"Nombre d'arguments incorrect : get %d, suspected %d\n", $4, tab_fnt[index_fonc($1)].nbArgs);
									exit(1);
								} else {
									printf("Début Invoc après sauvegarde de LR\n");	
									//Modifie la base de la pile pour la fonction appelée
									char* buf2 = malloc(5);
									sprintf(buf2, "%d", getSym()+1);
									add_instr2("AFC", "R0", buf2);
									add_instr3("ADD", BP, "R0", BP);	

	  								//Sauvegarde de l'adresse de retour vers fonction appelante dans le registre LR
	  								char* buf1 = malloc(5);
									sprintf(buf1, "%d", ip+3);
									add_instr2("AFC",LR,buf1);
												
									//Saut vers la fonction appelée
									int adr_fonc; 
									adr_fonc = find_fonc($1);
									char* buf = malloc(5);
									sprintf(buf, "%d", adr_fonc);
									add_instr2("JMP",buf,"");

									//Rétablissement du bas de pile
									char* buf3 = malloc(5);
									sprintf(buf3, "%d", getSym()+1);
									add_instr2("AFC", "R0", buf3);
									add_instr3("SUB", BP, "R0", BP);

									//Rétablissement de l'adresse de retour
									char* buf4 = malloc(5);
									sprintf(buf4, "%d", find_lr("lr"));
									add_instr2("LOAD",LR,buf4);
									ajout_tmp();
									char* buf5 = malloc(5);
									sprintf(buf5, "%d", getSym());
									add_instr2("STORE",buf5,VAL_RET);
									$$=getSym();//free_last_tmp();
								}
						}	
	  ;
Params : Param 					{$$=1;}
	   	| Param ParamsN 		{$$=1+$2;}
	   	| /*empty*/ 			{$$=0;} 
		;
ParamsN : tVir Param ParamsN 	{$$=1+$3;}
		| Param 				{$$=1;}
		;
Param : E
	  	;


Print : tPrint tPo tId tPf tPv	{char* buf = malloc(5);
				  					sprintf(buf, "%d", find_sym($3)); 
									add_instr2("LOAD", "R0",buf) ;ajout_tmp(); 
									add_instr2("PRI", "R0", "");free_last_tmp();}
	  ;
E :  tId					{add_tId($1); $$=tab_sym[sym].adr;}	
  	
	| tNb					{char* buf = malloc(5); char* buf2 = malloc(5) ; 
								sprintf(buf, "%d", $1); 
								add_instr2("AFC", "R0", buf);
								ajout_tmp();
								sprintf(buf2, "%d", tab_sym[sym].adr); 
								add_instr2("STORE", buf2, "R0"); 
								$$=tab_sym[sym].adr;}
	| E tEquEqu E			{add_op("EQU", $1, $3); $$=tab_sym[sym].adr; free_last_tmp();}
	| E tInf E				{add_op("INF", $1, $3); $$=tab_sym[sym].adr; free_last_tmp();}
	| E tInfEqu E			{add_op("INFE", $1, $3); $$=tab_sym[sym].adr; free_last_tmp();}
	| E tSup E				{add_op("SUP", $1, $3); $$=tab_sym[sym].adr; free_last_tmp();}
	| E tSupEqu E			{add_op("SUPE", $1, $3); $$=tab_sym[sym].adr;free_last_tmp();}
	| Invoc					
	| tPo E tPf				{$$=$2;}
	| E tPlus E				{add_op("ADD", $1, $3); $$=tab_sym[sym].adr;}// free_last_tmp();}	
	| E tMinus E			{add_op("SOU", $1, $3); $$=tab_sym[sym].adr;}// free_last_tmp();}	
	| E tStar E				{add_op("MUL", $1, $3); $$=tab_sym[sym].adr;}// free_last_tmp();}		
	| E tDiv E				{add_op("DIV", $1, $3); $$=tab_sym[sym].adr;}// free_last_tmp();}	
	;	

%%
void yyerror(const char *s) {
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

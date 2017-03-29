%{
#include <stdio.h>
#include <stdlib.h>
#include <string.h>

int yylex();
void yyerror (char* s);

int mem[1024];
int reg[32];
int instr[1024][4];
int ip = 0;

%}

%union{int nb;}

%token <nb> tADD tMUL tSOU tDIV tCOP tAFC tLOAD tSTORE tEQU tINF tINFE tSUP tSUPE tJMP tJMPC tPRI tArg
%start Input

%%

Input : Operation Input
	 	|
		;
Operation : Add | Mul | Sou | Div | Cop | Afc | Load | Store | Equ | Inf | Sup | Supe | Jmp | Jmpc | Pri
		  ;

Add : tADD tArg tArg tArg		{instr[ip][0]=$1;instr[ip][1]=$2;instr[ip][2]=$3;instr[ip][3]=$4;ip++;}
	;
Mul : tMUL tArg tArg tArg		{instr[ip][0]=$1;instr[ip][1]=$2;instr[ip][2]=$3;instr[ip][3]=$4;ip++;}
	;
Sou : tSOU tArg tArg tArg		{instr[ip][0]=$1;instr[ip][1]=$2;instr[ip][2]=$3;instr[ip][3]=$4;ip++;}
	;
Div : tDIV tArg tArg tArg		{instr[ip][0]=$1;instr[ip][1]=$2;instr[ip][2]=$3;instr[ip][3]=$4;ip++;}
	;
Equ : tEQU tArg tArg tArg		{instr[ip][0]=$1;instr[ip][1]=$2;instr[ip][2]=$3;instr[ip][3]=$4;ip++;}
	;
Inf : tINF tArg tArg tArg 		{instr[ip][0]=$1;instr[ip][1]=$2;instr[ip][2]=$3;instr[ip][3]=$4;ip++;}
	;
Sup : tSUP tArg tArg tArg		{instr[ip][0]=$1;instr[ip][1]=$2;instr[ip][2]=$3;instr[ip][3]=$4;ip++;}
	;
Supe : tSUPE tArg tArg tArg		{instr[ip][0]=$1;instr[ip][1]=$2;instr[ip][2]=$3;instr[ip][3]=$4;ip++;}
	 ;
Cop : tCOP tArg tArg 			{instr[ip][0]=$1;instr[ip][1]=$2;instr[ip][2]=$3;instr[ip][3]=-1;ip++;}
	;
Afc :  tAFC tArg tArg			{instr[ip][0]=$1;instr[ip][1]=$2;instr[ip][2]=$3;instr[ip][3]=-1;ip++;}
	;
Load :  tLOAD tArg tArg			{instr[ip][0]=$1;instr[ip][1]=$2;instr[ip][2]=$3;instr[ip][3]=-1;ip++;}
	 ;
Store : tSTORE tArg tArg		{instr[ip][0]=$1;instr[ip][1]=$2;instr[ip][2]=$3;instr[ip][3]=-1;ip++;}
	  ;
Jmp : tJMP tArg					{instr[ip][0]=$1;instr[ip][1]=$2;instr[ip][2]=-1;instr[ip][3]=-1;ip++;}
	;
Jmpc : tJMPC tArg tArg 			{instr[ip][0]=$1;instr[ip][1]=$2;instr[ip][2]=$3;instr[ip][3]=-1;ip++;}
	 ;
Pri : tPRI tArg					{instr[ip][0]=$1;instr[ip][1]=$2;instr[ip][2]=-1;instr[ip][3]=-1;ip++;}
	;

%%

int main(void){
	int rip = 0, debug = 1;
	int* cmd;
	yyparse();

	while(rip < ip){
		cmd = instr[rip];
		switch(cmd[0]) {
			case tADD : reg[cmd[1]] = reg[cmd[2]] + reg[cmd[3]];  
						if (debug == 1)
							printf("ADD : reg[%d] = %d  |  reg[%d] = cf 2l. plus haut    +  reg[%d] = %d \n",cmd[1], reg[cmd[1]], cmd[2] , cmd[3], reg[cmd[3]]); 
						break;
			case tMUL : reg[cmd[1]] = reg[cmd[2]] * reg[cmd[3]];  
						if (debug == 1)
							printf("MUL : reg[%d] = %d  |  reg[%d] = cf 2l. plus haut    *  reg[%d] = %d \n", cmd[1], reg[cmd[1]],cmd[2] ,cmd[3], reg[cmd[3]]); 
						break;
			case tSOU : reg[cmd[1]] = reg[cmd[2]] - reg[cmd[3]] ;  
						if (debug == 1)
							printf("SOU : reg[%d] = %d  |  reg[%d] = cf 2l. plus haut     -  reg[%d] = %d \n", cmd[1], reg[cmd[1]],cmd[2] ,cmd[3], reg[cmd[3]]); 
						break;
			case tDIV : reg[cmd[1]] = reg[cmd[2]] / reg[cmd[3]] ;  
						if (debug == 1)
							printf("DIV : reg[%d] = %d  |  reg[%d] =  cf 2l. plus haut   /  reg[%d] = %d \n", cmd[1], reg[cmd[1]],cmd[2],cmd[3], reg[cmd[3]]); 
						break;
			case tCOP : reg[cmd[1]] = reg[cmd[2]] ; 
						break;
			case tAFC : reg[cmd[1]] = cmd[2];  
						if (debug == 1)
							printf("AFC : reg[%d] = %d  <=  cmd[2] = %d \n", cmd[1] ,reg[cmd[1]],  cmd[2]); 
						break;
			case tLOAD : reg[cmd[1]]= mem[cmd[2]];  
						if (debug == 1)
							printf("LOAD : reg[%d] = %d  <=  mem[%d] = %d \n", cmd[1], reg[cmd[1]],cmd[2], mem[cmd[2]] ); 
						break;
			case tSTORE : mem[cmd[1]] = reg[cmd[2]];  
						if (debug == 1)
							printf("STORE : mem[%d] = %d  <=  reg[%d] = %d \n", cmd[1], mem[cmd[1]], cmd[2], reg[cmd[2]] ); 
						break;
			case tEQU : reg[cmd[1]] = reg[cmd[2]] == reg[cmd[3]] ; 
						if (debug == 1)
							printf("EQU : reg[%d] = %d  |  reg[%d] = cf 2l. plus haut    ==  reg[%d] = %d \n", cmd[1], reg[cmd[1]], cmd[2] ,cmd[3], reg[cmd[3]]); 
						break;
			case tINF : reg[cmd[1]] = reg[cmd[2]] < reg[cmd[3]] ;  
						if (debug == 1)
							printf("INF : reg[%d] = %d  |  reg[%d] = cf 2l. plus haut    <  reg[%d] = %d \n", cmd[1], reg[cmd[1]], cmd[2] ,cmd[3], reg[cmd[3]]); 
						break;
			case tINFE : reg[cmd[1]] = reg[cmd[2]] <= reg[cmd[3]] ; 
						if (debug == 1)
							printf("INFE : reg[%d] = %d  |  reg[%d] = cf 2l. plus haut    <=  reg[%d] = %d \n", cmd[1], reg[cmd[1]], cmd[2] ,cmd[3], reg[cmd[3]]); 
						break;

			case tSUP : reg[cmd[1]] = reg[cmd[2]] > reg[cmd[3]] ;
						if (debug == 1)
							printf("SUP : reg[%d] = %d  |  reg[%d] = cf 2l. plus haut    >  reg[%d] = %d \n", cmd[1], reg[cmd[1]], cmd[2] ,cmd[3], reg[cmd[3]]); 
						break;
			case tSUPE : reg[cmd[1]] = reg[cmd[2]] >= reg[cmd[3]] ; 
						if (debug == 1)
							printf("SUPE : reg[%d] = %d  |  reg[%d] = cf 2l. plus haut   >=  reg[%d] = %d \n", cmd[1], reg[cmd[1]], cmd[2] ,cmd[3], reg[cmd[3]]); 
						break;
			case tJMP : rip = cmd[1]-2; 
						break;
			case tJMPC :if (reg[cmd[2]] ==0)
							rip = cmd[1]-2;
						break;
			case tPRI : 
						printf("%d\n", reg[cmd[1]]); 
						break;
		}
		rip++;
		//printf("On est en %d\n", rip);
	}
	return 0;
}

#include "tab_fonctions.h"

//Gestion adresse de retour
int ip_ret = 256;

void ajout_ret(int retour){
		if (ip_ret<1024){
			ip_ret ++;
			adr_ret[ip_ret] = retour;
			printf("J'incremente ip_ret\n");
		} else {
			printf("Overflow du tableau des adresses de retour\n");
			exit(1);
		}
}

int del_ret(){
	if (ip_ret>256) {
		return adr_ret[ip_ret--];
	} else {
		printf("Underflow du tableau des adresses de retour\n");
		exit(1);
	}
}

//Gestion fonction
int fonc = 0;
int nbArgs = 0;

void ajout_fonc(char* var, int ip, int nb_arg){
	if (fonc >= 0 && fonc < 256) {
		fonc++;
		tab_fnt[fonc].id = var;
		tab_fnt[fonc].index = fonc;
		tab_fnt[fonc].adr = ip+1;
		tab_fnt[fonc].nbArgs = nb_arg;
	} else {
		printf("Dépassement de la zone mémoire autorisée ! \n");
		exit(42);
	}
}

int check_exist_fonc(char* var){
	int i;
	int test = -1, trouve = 0;
	for (i=1; i<fonc; i++) {
		if (test = (strcmp(tab_fnt[i].id,var)==0)) {
			printf("La fonction existe\n");
			trouve = 1;
			break;
		}
	}
	return trouve;
}

int find_fonc(char* var){
	int i, adr = -1;
	int test = -1;
	for (i=1; i<fonc; i++) {
		if (test = (strcmp(tab_fnt[i].id,var)==0)) {
			adr = tab_fnt[i].adr;
			printf("Youpi j'ai trouve la fonction\tadr = %d\n",adr);
			break;
		}
	}
	if (adr != -1){
		return adr;
	} else {
		printf("Pas trouvé la fonction  : %s\n", var);
		exit(2);
	}
	printf("J'arrive jusque là\n");	
}

int index_fonc(char* var){
	int i, adr = -1;
	int test = -1;
	for (i=1; i<fonc; i++) {
		if (test = (strcmp(tab_fnt[i].id,var)==0)) {
			adr = tab_fnt[i].index;
			//printf("Youpi j'ai trouve la fonction\tadr = %d\n",adr);
			break;
		}
	}
	if (adr != -1){
		return adr;
	} else {
		printf("Pas trouvé la fonction ! \n");
		exit(2);
	}
	printf("J'arrive jusque là\n");	
}


//A MODIFIER
void ajout_nbArgs (char* var){
	tab_fnt[fonc].nbArgs = tab_fnt[fonc].nbArgs++;
}

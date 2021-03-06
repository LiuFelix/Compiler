#include "tab_symboles.h"
#include <string.h>

//Initialisation des index du tableau
int sym = 0;
//int tmp = 256;

//Fonctions partie symbole

int getSym(){
	return sym;
}

void setSym(int val){
	sym = val;
}

void ajout_sym(char* var){
	if (sym >= 0) {
		sym++;
		tab_sym[sym].id = var; 
		tab_sym[sym].init = 0;
		tab_sym[sym].adr = sym;
	} else {
		printf("Dépassement de la zone mémoire autorisée ! \n");
		exit(1);
	}
}

void ajout_sym_init(char* var){
	if (sym >= 0) {
		sym++;
		tab_sym[sym].id = var; 
		tab_sym[sym].init = 1;
		tab_sym[sym].adr = sym;
	} else {
		printf("Dépassement de la zone mémoire autorisée ! \n");
		exit(1);
	}
}

//retourne l'index de la variable recherchée
int find_sym(char * var){
	int i, adr = -1;
	int test = -1;
	for (i=1; i<sym+1; i++) {
	//printf("[FIND]  tab_sym[%d].id = %s     |    var = %s\n",i , tab_sym[i].id, var);  

		if (test = (strcmp(tab_sym[i].id,var)==0)) {
			//printf("J'ai comme arg : %s  tab_sym[i].id = %s  résultat = %d\n",var,tab_sym[i].id, test);
			adr = tab_sym[i].adr;
			break;
		}
	}
	if (adr != -1){
		return adr;
	} else {
		printf("Pas trouvé le symbole : %s \n", var);
		return -1;
	}
}

//retourne l'index de la variable recherchée
int find_lr(char * var){
	int i, adr = -1;
	int test = -1;
	for (i=sym; i>=1; i--) {
	//printf("[FIND]  tab_sym[%d].id = %s     |    var = %s\n",i , tab_sym[i].id, var);  

		if (test = (strcmp(tab_sym[i].id,var)==0)) {
			//printf("J'ai comme arg : %s  tab_sym[i].id = %s  résultat = %d\n",var,tab_sym[i].id, test);
			adr = tab_sym[i].adr;
			break;
		}
	}
	if (adr != -1){
		return adr;
	} else {
		printf("Pas trouvé d'adresse de retour ! \n");
		return -1;
	}
}


void ajout_init (char* var){
	int i;
	int test = -1;
	for(i=1;i<sym+1;i++){
		//printf("[AJOUT]  tab_sym[%d].id = %s     |    var = %s\n",i , tab_sym[i].id, var);  
		if (test = (strcmp(tab_sym[i].id,var)==0)) {
			tab_sym[i].init = 1;
			break;
		}
	}
}

//Fonctions partie temporaire

/*void ajout_tmp(char* var){
	if (tmp <= 255 && tmp > sym) {
		tab_sym[tmp].id = var; 
		tab_sym[tmp].adr = tmp;
		tmp--;
	} else {
		printf("Dépassement de la zone mémoire autorisée ! \n");
		exit(1);
	}
}*/

void ajout_tmp(){
	sym++;
	tab_sym[sym].adr = sym;
}

/*int find_tmp(char* var){
	int i, adr = -1;
	for (i=255; i>tmp; i--) {
		if (tab_sym[i].id == var) {
			adr = tab_sym[i].adr;
		}
	}
	return adr;
}*/

void free_last_tmp(){
	if (sym >=1) {
		sym--;
	} else {
		printf("Erreur free_last_tmp() : Underflow table des symboles\n");
		exit(1);
	}
}

void print_tab_sym(){
	int i;
	printf("Current tab sym : \n");
	for(i=1;i<sym+1;i++){
		printf("sym[%d] = %s\n",i,tab_sym[i].id);
	}
	printf("\n");
}

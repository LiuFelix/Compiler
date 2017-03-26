#ifndef TAB_FONCTIONS_H
#define TAB_FONCTIONS_H

#include <stdio.h>
#include <stdlib.h>
#include <string.h>

//Gestion adresse retour
int adr_ret[1024];
int ip_ret;

void ajout_ret(int retour);
int del_ret();

//Gestion fonction
struct fonction{
	char* id;
	int adr;
	int nbArgs;
	int valRet;
};

int fonc;
int nbArgs;

struct fonction tab_fnt[256];

void ajout_fonc(char*, int);
int find_fonc(char*);
void ajout_nbArgs(char*);

#endif

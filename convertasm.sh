#!/bin/bash

if [ $# -ne 2 ]
then
		echo Usage: $0 [Entree] [Sortie]
		exit -1
else
		cp $1 $2
		sed -i -e 's/ADD/01/g' $2
		sed -i -e 's/MUL/02/g' $2
		sed -i -e 's/SOU/03/g' $2
		sed -i -e 's/DIV/04/g' $2
		sed -i -e 's/COP/05/g' $2
		sed -i -e 's/AFC/06/g' $2
		sed -i -e 's/LOAD/07/g' $2
		sed -i -e 's/STORE/08/g' $2
		sed -i -e 's/EQU/09/g' $2
		sed -i -e 's/INF/0a/g' $2
		sed -i -e 's/0aC/0b/g' $2
		sed -i -e 's/SUP/0c/g' $2
		sed -i -e 's/0cE/0d/g' $2
		sed -i -e 's/JMP/0e/g' $2
		sed -i -e 's/0eC/0f/g' $2
		sed -i -e 's/PRI/10/g' $2
		sed -i -e 's/R0/00/g' $2
		sed -i -e 's/R1/01/g' $2
		sed -i -e 's/R2/02/g' $2
		sed -i -e 's/R3/03/g' $2
		sed -i -e 's/R15/0f/g' $2
fi

#!/bin/bash

if [ $# -ne 1 ]
then
		echo Usage $0 [fichier_test]
		exit -1
else
	./test < $1
	./convertasm.sh instrASM.txt resu.asm
	./interpreteur/interpreteur < resu.asm > res_interpret.txt
fi

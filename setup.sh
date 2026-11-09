#!/usr/bin/env bash

existe_orden(){
	printf "orden $1 existente \033[32m + \033[00m\n"
}
no_existe_orden(){
	printf "orden $1 no encontrada \033[31m - \033[00m\n"
}

# Checa dependencias
whiptail --version > /dev/null 2>&1
if [ "$?" -ne 0 ]; then
	no_existe_orden whiptail
	exit 1
else
	existe_orden whiptail
fi

# Crea directorio para tareas
ruta_tareas="$HOME/Documentos/Tareas"

if [[ ! -d "$ruta_tareas" ]]; then
	mkdir $ruta_tareas
fi
printf "Directorio $ruta_tareas creado :)\n"

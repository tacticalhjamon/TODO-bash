#!/usr/bin/env bash

# Salida temprana si da mas de 1 argumentos
manual_uso=$(cat << EOF
 Uso: Tareas [nombre-proyecto] [accion]\n
\n
acciones:\n
\t	-n: Inserta nueva tarea\n
\t	-l: Marca como lista alguna tarea\n
\n
Si no se pone ninguna accion solo despliega las notas\n
EOF
)

if [[ $# -gt 2 ]]; then
	echo -ne $manual_uso
	exit 1
fi

# Declaracion de colores para ventana
export NEWT_COLORS="
button=white,black,
radiolist=white,black,
checkbox=white,black,
entry=white,black,
title=white,black"

# Medidas de pantalla
ancho=$(tput cols)
alto=$(tput lines)

# Ruta de archivos
ruta_tareas="$HOME/Documentos/Tareas/"

# Variable respuesta (prueba)
respuesta=""
pantalla=""
modo=""

mensaje_salida(){
	despedida="\nAdios"
	#TODO: Añadir comprobacion de soporte de caracteres unicode
	#	   usando $LANG
	emoji="\xF0\x9F\x98\x80"
	printf "${despedida} ${emoji}\n\n"
}

#extrae_

# recibe solo un argumento, la cadena a centrar
centrar_texto_whiptail(){
	# El -2 es por los bordes de la ventana
	cantidad_espacios=$(( (${ancho} - ${#1}) / 2 - 2 ))
	espacios=""
	printf -v espacios "%${cantidad_espacios}s" " "

	echo "$espacios$1"
}

# Pantallas

pantalla_default(){
	texto_00=$(centrar_texto_whiptail "Aplicacion Tareas")
	texto_01=$(centrar_texto_whiptail "¿Notas por proyecto o globales?")
	respuesta=$(whiptail --title "Tareas"\
		 --radiolist "\n\n$texto_00\n\n\n\n$texto_01"\
		 $alto $ancho 2\
		 "Global" "Notas independientes" ON \
		 "Proyecto" "Notas con clasificador" OFF \
		 3>&1 1<&2 2>&3)
	#echo $?
}

pantalla_global(){
	texto_g0=$( centrar_texto_whiptail 'Global' )
	texto_g1=$( cat ${ruta_tareas}Global.txt )
	respuesta=$(whiptail --title "Tareas"\
						 --inputbox "${texto_g0}\n\n${texto_g1}"\
						 $alto $ancho "Nueva nota: "\
					 	 3>&1 1>&2 2>&3 )
}

main(){
	# Revisa la entrada
	if [[ -z $2 ]]; then
		modo="lectura"
	fi

	# Maneja Pantallas 
	if [[ $# -eq 0 ]]; then
		pantalla_default
		case $respuesta in
			"Global")
				pantalla="Global"
				;;
			"Proyecto")
				pantalla="Proyectos"
				;;
		esac
	fi

	if [[ "$pantalla" == "Global" ]]; then
		pantalla_global
	fi
	mensaje_salida
}

main $@
#strings ~/Documentos/Tareas/Global.txt | cut -c 7-

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
ruta_tareas=""
if [[ -d "$HOME/Documentos" ]]; then
	ruta_tareas="$HOME/Documentos/Tareas/"
elif [[ -d "$HOME/Documents" ]]; then
	ruta_tareas="$HOME/Documents/Tareas/"
fi
ruta_archivo=""

# Variable respuesta (prueba)
respuesta=""
# pantalla puede recibir los valores: "default", "global" y "proyecto"
pantalla=""
existe_proyecto=""
modo=""
formato_nueva_nota="[ ] - "
arreglo=()

mensaje_salida(){
	despedida="\nAdios"
	#TODO: Añadir comprobacion de soporte de caracteres unicode
	#	   usando $LANG
	emoji="\xF0\x9F\x98\x80"
	printf "${despedida} ${emoji}\n\n"
}

# Recibe un parametro, la nueva nota
nueva_nota(){
	echo "${formato_nueva_nota}$1" >> ${ruta_archivo}
}

construye_arreglo_notas_checkbox(){
	numero_lineas=$( cat $ruta_archivo | wc -l )
	for (( i=1 ; i <= numero_lineas ; i++ )); do
		arreglo+=("$i")
					  #sed -n 1p prueba.sh | cut -c 5-	
					  arreglo+=("$( sed -n "${i}p" "$ruta_archivo" | cut -c $(( ${#formato_nueva_nota} + 1))- )")
		arreglo+=("OFF")
	done
}

borra_lineas(){
	contenido_archivo=()
	mapfile contenido_archivo < "$ruta_archivo"


	for (( i=${#respuesta[@]} ; i >= 0 ; i-- )); do
		unset contenido_archivo[${respuesta[$i]}]
	done

	# Reescribir archivo
	echo -n "" > $ruta_archivo
	printf "%s" "${contenido_archivo[@]}" > "$ruta_archivo"
}

# Recibe solo un argumento, la cadena a centrar
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
}

pantalla_global(){
	texto_g0=$( centrar_texto_whiptail 'Global' )
	if [[ "$modo" == "lectura" ]]; then
		whiptail --title "Tareas-Global"\
				 --textbox ${ruta_archivo} $alto $ancho
	elif [[ "$modo" == "agregar" ]]; then
		texto_g1=$( cat ${ruta_archivo} )
		respuesta=$(whiptail --title "Tareas"\
							 --inputbox "${texto_g0}\n\n${texto_g1}"\
							 $alto $ancho "Nueva nota: "\
						 	 3>&1 1>&2 2>&3 )
		respuesta=$(echo "${respuesta}" | cut -c 13-)
	elif [[ "$modo" == "borrar" ]]; then
		texto_g2=$( centrar_texto_whiptail "Seleccione las notas para borrar")
		construye_arreglo_notas_checkbox

		arreglo_len=${#arreglo[@]}

		respuesta=$(whiptail --title "Tareas"\
							 --checklist "${texto_g0}\n${texto_g2}"\
							 $alto $ancho $(( arreglo_len / 3 ))\
							 "${arreglo[@]}"\
						 	 3>&1 1>&2 2>&3)
	fi
}

main(){
	# Revisa la entrada
	if [[ ! -z $1 ]]; then
		if [[ "$1" == "g" || "$1" == "global" ]]; then
			pantalla="global"
			ruta_archivo="${ruta_tareas}Global.txt"
		else
			pantalla="proyecto"
			if [[ -d "${ruta_tareas}$1" ]]; then
				existe_proyecto="s"
			else
				existe_proyecto="n"
			fi
		fi
	else
		pantalla="default"
	fi

	if [[ -z $2 ]]; then
		modo="lectura"
	elif [[ "$2" == "-n" ]]; then
		modo="agregar"
	elif [[ "$2" == "-l" ]]; then
		modo="borrar"
	else
		echo -ne $manual_uso
	fi

	# Maneja Pantallas 
	if [[ "$pantalla" == "default" ]]; then
		pantalla_default
		case $respuesta in
			"Global")
				pantalla="global"
				ruta_archivo="${ruta_tareas}Global.txt"
				;;
			"Proyecto")
				pantalla="proyecto"
				;;
		esac
	fi

	if [[ "$pantalla" == "global" ]]; then
		pantalla_global
		if [[ "$modo" == "agregar" && "$respuesta" != "" ]]; then
			nueva_nota "$respuesta"
		elif [[ "$modo" == "borrar" ]]; then
			borra_lineas
		fi
	fi
	mensaje_salida
}

main $@
echo -e "${respuesta}"

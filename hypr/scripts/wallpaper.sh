#!/bin/bash
### set here you're stuff ###
PATHWP=~/Immagini/WP/ #cartella in cui cercare i wallpaper
MONITOR=eDP-1                     #nome del monitor da gestire
###
NUM=/tmp/hypr/wallpaperNUM #percorsi per i file temp
NOME=/tmp/hypr/wallpaperNOME
D=$(cat ~/.config/hypr/scripts/defaultwp) #default da impostare all'avvio della sessione
F=$(($(ls $PATHWP | wc -l) - 1))          #acquisisco il numero di wallpapers
N=$(cat $NUM)                             #leggo il wallpaper attualmente impostato

set_wall() { #imposto il wallpaper contenuto in I
	hyprctl hyprpaper preload "$PATHWP$I"
	hyprctl hyprpaper wallpaper "$MONITOR, $PATHWP$I"
	hyprctl hyprpaper unload all
}

def_wp() {                                                                                      #wallpaper default
	ls $PATHWP >$NOME                                                                              #salvo i nomi dei file in un file
	mapfile -t array <$NOME                                                                        #inserisco i nomi in un array
	I=$(echo ${array[$D]})                                                                         #assegno ad I il nome del wallpaper da impostare
	echo -e "preload = $PATHWP$I \nwallpaper = $MONITOR, $PATHWP$I" >~/.config/hypr/hyprpaper.conf #genero il file per hyprpaper
	hyprpaper &                                                                                    #lancio hyprpaper
	echo $D >$NUM                                                                                  #imposto il wp di default come attualmente impostate
}

next_wp() {              #wallpaper successivo
	N=$((N + 1))            #incremento il wallpaper attuale
	mapfile -t array <$NOME #inserisco i nomi in un array
	I=$(echo ${array[$N]})  #assegno il nome necessario all'indice
	set_wall
	echo $N >$NUM #scrivo il wallpaper attuale in tmp
}

prev_wp() { #wallpaper precedente
	N=$((N - 1))
	mapfile -t array <$NOME #inserisco i nomi in un array
	I=$(echo ${array[$N]})  #assegno il nome necessario all'indice
	set_wall
	echo $N >$NUM #scrivo il wallpaper attuale in tmp
}

if [[ "$1" == "--start" ]]; then #selettore di funzione
	def_wp
elif [[ "$1" == "--def" ]]; then
	echo $N >~/.config/hypr/scripts/defaultwp
	notify-send -u normal "New Default Wallpaper"
elif [[ "$1" == "--inc" ]]; then
	if [[ $N -eq $F ]]; then
		exit 0
	else
		next_wp
	fi
elif [[ "$1" == "--dec" ]]; then
	if [[ $N -eq 0 ]]; then
		exit 0
	else
		prev_wp
	fi
fi
exit

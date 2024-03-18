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

def_wp() {                                                                                      #wallpaper default
	ls $PATHWP >$NOME                                                                              #salvo i nomi dei file in un file
	mapfile -t array <$NOME                                                                        #inserisco i nomi in un array
	I=$(echo ${array[$D]})                                                                         #assegno ad I il nome del wallpaper da impostare
	echo -e "preload = $PATHWP$I \nwallpaper = $MONITOR, $PATHWP$I \nsplash = false\n ipc = off" > ~/.config/hypr/hyprpaper.conf #genero il file per hyprpaper
	hyprpaper &                                                                                    #lancio hyprpaper
	echo $D >$NUM                                                                                  #imposto il wp di default come attualmente impostate
}

change_wp(){
  if [[ "$X" == "--ran" ]]; then 
    N=$(echo $((0 + $RANDOM % $F)))
  elif [[ "$X" == "--inc" ]]; then 
    N=$((N + 1)) 
  elif [[ "$X" == "--dec" ]]; then 
    N=$((N - 1))
  fi
  mapfile -t array <$NOME
	I=$(echo ${array[$N]})
	hyprctl hyprpaper preload "$PATHWP$I"
	hyprctl hyprpaper wallpaper "$MONITOR, $PATHWP$I"
	hyprctl hyprpaper unload all
	echo $N >$NUM 
}

delete_wp(){
  mapfile -t array <$NOME
  I=$(echo ${array[$N]})
  rm -f $PATHWP$I
	notify-send -u normal "Wallpaper deleted"
}

#selettore di funzione
X=$1
if [[ "$1" == "--start" ]]; then 
	def_wp
elif [[ "$1" == "--def" ]]; then
	echo $N > ~/.config/hypr/scripts/defaultwp
	notify-send -u normal "New default wallpaper"
elif [[ "$1" == "--ran" ]]; then
  change_wp
elif [[ "$1" == "--inc" ]]; then
	if [[ $N -eq $F ]]; then
		exit 0
	else
		change_wp
	fi
elif [[ "$1" == "--dec" ]]; then
	if [[ $N -eq 0 ]]; then
		exit 0
	else
		change_wp
	fi
elif [[ "$1" == "--del" ]]; then
  delete_wp
fi
exit

#!/bin/bash
### set here you're stuff ###
PATHWP=~/Immagini/Wallpaper/PC/ #cartella in cui cercare i wallpaper
MONITOR=eDP-1                     #nome del monitor da gestire
###
NUM=~/.config/hypr/wallpaper/wallpaperNUM #percorsi per i file temp
NOME=~/.config/hypr/wallpaper/wallpaperNOME
### SETUP ###
D=$(cat ~/.config/hypr/wallpaper/defaultwp) #default da impostare all'avvio della sessione
F=$(($(ls $PATHWP | wc -l) - 1))          #acquisisco il numero di wallpapers
N=$(cat $NUM)
ls $PATHWP > $NOME
echo $D > $NUM

select_wp() {
    WALL=$(hyprwat --wallpaper "$PATHWP")
    hyprctl hyprpaper wallpaper "$MONITOR, $WALL"
    ls $PATHWP > $NOME
    mapfile -t array < $NOME
    WALL_BASENAME=$(basename "$WALL")
    echo $WALL_BASENAME
    for i in "${!array[@]}"; do
        if [[ "${array[$i]}" == "$WALL_BASENAME" ]]; then
            echo $i > ~/.config/hypr/wallpaper/defaultwp
            notify-send -u normal "New default wallpaper"
            break
        fi
    done
}

change_wp() {
    if [[ "$X" == "--ran" ]]; then
        N=$(echo $((0 + $RANDOM % $F)))
    elif [[ "$X" == "--inc" ]]; then
        N=$((N + 1))
    elif [[ "$X" == "--dec" ]]; then
        N=$((N - 1))
    elif [[ "$X" == "--start" ]]; then
        N=$D
    fi
    mapfile -t array <$NOME
    I=$(echo ${array[$N]})
    hyprctl hyprpaper wallpaper "$MONITOR, $PATHWP$I, fill"
    echo $N >$NUM
}

delete_wp() {
    mapfile -t array <$NOME
    I=$(echo ${array[$N]})
    rm -f $PATHWP$I
    notify-send -u normal "Wallpaper deleted"
}

#selettore di funzione
X=$1
if [[ "$1" == "--start" ]]; then
    change_wp
    # def_wp
elif [[ "$1" == "--def" ]]; then
    echo $N > ~/.config/hypr/wallpaper/defaultwp
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
elif [[ "$1" == "--sel" ]]; then
    select_wp
fi
exit

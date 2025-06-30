![image](https://imgur.com/a/nmzWr06.png)



# HyprDotfiles

If you used the [set_hypr](https://github.com/sickmitch/set_hyprland/blob/master/set_hypr.sh) scripts without changes to the rice software section importing those dotfiles will be smoothly working.

## Hyprpaper

Hyprpaper is all script driven, you can find it in ~/.config/hypr/scripts/wallpaper.sh to check it (made to drive single monitor can't test for more).
You can edit the directory to use to source you're wallpapers in the script header. If the script act oddly check how your monitor is named using `hyprctl monitors` and edit the variable in header. 
Changes to paths in the script header need a new session to be applied.

With **mainMod right/left** you can change you're wallpaper [*don't spam*], with **mainMod up** you can set the actual wallpaper as default at launch.
The default wallpaper can be set manually in ~/config/hypr/scripts/defaultwp, you can put a number in there: 0 being the first wallpaper in your wallpaper's directory, 1 the 2nd, 2 the 3rd and so on.

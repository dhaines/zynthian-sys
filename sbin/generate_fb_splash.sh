#!/bin/bash

#------------------------------------------------------------------------------
# Load Environment Variables
#------------------------------------------------------------------------------

source "$ZYNTHIAN_SYS_DIR/scripts/zynthian_envars_extended.sh"

#------------------------------------------------------------------------------

# Create directory if it doesn't exist
if [ ! -d "$ZYNTHIAN_CONFIG_DIR/img" ]; then
	mkdir $ZYNTHIAN_CONFIG_DIR/img
fi

# Find display resolution if needed
if [[ "${DISPLAY_WIDTH}" == "" || "${DISPLAY_HEIGHT}" == "" ]]; then
	if [[ "$DISPLAY" != "" ]]; then
		geometry=($(xrandr | grep -oP '(?<= connected | primary )[x\d]+' | awk -F'[x]' '{print "geometry " $1 " " $2}'))
	else
		geometry=($(fbset -s | grep geometry))
	fi
	DISPLAY_WIDTH=${geometry[1]}
	DISPLAY_HEIGHT=${geometry[2]}
fi

echo "Generating splash images for display resolution $DISPLAY_WIDTH x $DISPLAY_HEIGHT..."

convert_options="-resize ${DISPLAY_WIDTH}x -gravity Center -extent ${DISPLAY_WIDTH}x${DISPLAY_HEIGHT} -strip" 
/usr/bin/convert "$ZYNTHIAN_UI_DIR/img/zynthian_logo_boot.png" $convert_options "$ZYNTHIAN_CONFIG_DIR/img/fb_zynthian_boot.png"
/usr/bin/convert "$ZYNTHIAN_UI_DIR/img/zynthian_logo_error.png" $convert_options "$ZYNTHIAN_CONFIG_DIR/img/fb_zynthian_error.png"

exit

# This is not used anymore...
if [[ "$FRAMEBUFFER" == "/dev/fb1" ]]; then
	echo "Generating Splash Screens for FrameBuffer..."

	/bin/echo 1 > /sys/class/backlight/*/bl_power

	#Generate "Zynthian Error" Splash Screen
	/usr/bin/fbi -noverbose -T 2 -a --fitwidth -d $FRAMEBUFFER $ZYNTHIAN_UI_DIR/img/zynthian_logo_error.png
	sleep 1
	cat $FRAMEBUFFER > $ZYNTHIAN_CONFIG_DIR/img/fb_zynthian_error.raw
	/usr/bin/fbgrab -d $FRAMEBUFFER $ZYNTHIAN_CONFIG_DIR/img/fb_zynthian_error.png

	#Generate "Zynthian Boot" Splash Screen
	/usr/bin/fbi -noverbose -T 2 -a --fitwidth -d $FRAMEBUFFER $ZYNTHIAN_UI_DIR/img/zynthian_logo_boot.png
	sleep 1
	cat $FRAMEBUFFER > $ZYNTHIAN_CONFIG_DIR/img/fb_zynthian_boot.raw
	/usr/bin/fbgrab -d $FRAMEBUFFER $ZYNTHIAN_CONFIG_DIR/img/fb_zynthian_boot.png

	killall -9 fbi

	/bin/echo 0 > /sys/class/backlight/*/bl_power
fi

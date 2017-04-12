#!/bin/bash

if mountpoint -q -- "/media/usb0"; then
	CAPTURE_DIR="/media/usb0"
	echo "Capturing to USB storage => $CAPTURE_DIR"
else
	CAPTURE_DIR="/zynthian/zynthian-my-data/capture"
	echo "Capturing to internal storage => $CAPTURE_DIR"
fi

cd $CAPTURE_DIR
jack_capture
#jack_capture --no-stdin

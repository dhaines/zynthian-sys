#!/bin/bash

cd $ZYNTHIAN_SW_DIR

if [ -d "VL53L0X" ]; then
	rm -rf "VL53L0X"
fi

git clone https://github.com/bitbank2/VL53L0X.git
cd "VL53L0X"
make -j$(nproc)
#rm -rf "VL53L0X"

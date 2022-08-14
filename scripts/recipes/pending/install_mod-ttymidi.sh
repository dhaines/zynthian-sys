# Mod-ttymidi
cd $ZYNTHIAN_SW_DIR
git clone https://github.com/moddevices/mod-ttymidi.git
cd mod-ttymidi
make -j$(nproc)
sudo make install
cd ..

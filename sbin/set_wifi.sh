#!/bin/bash

#------------------------------------------------------------------------------
# Load Environment Variables
#------------------------------------------------------------------------------

if [ -f "$ZYNTHIAN_CONFIG_DIR/zynthian_envars.sh" ]; then
	source "$ZYNTHIAN_CONFIG_DIR/zynthian_envars.sh"
else
	source "$ZYNTHIAN_SYS_DIR/scripts/zynthian_envars.sh"
fi

if [ -z "$1" ]; then
	wifi_mode=$ZYNTHIAN_WIFI_MODE
else
	wifi_mode=$1
fi

if [ -z "$wifi_mode" ]; then
	wifi_mode="off"
fi

#------------------------------------------------------------------------------

wifidev="wlan0" #device name to use. Default is wlan0.
#use the command: iw dev ,to see wifi interface name 

StartHotspot()
{
    echo "Bringing Up Hotspot"
    ip link set dev "$wifidev" down
    ip a add 192.168.50.1/24 brd + dev "$wifidev"
    ip link set dev "$wifidev" up
    iptables -t nat -A POSTROUTING -o eth0 -j MASQUERADE
    iptables -A FORWARD -i eth0 -o "$wifidev" -m state --state RELATED,ESTABLISHED -j ACCEPT
    iptables -A FORWARD -i "$wifidev" -o eth0 -j ACCEPT
    systemctl start dnsmasq
    systemctl start hostapd
    echo 1 > /proc/sys/net/ipv4/ip_forward
}

KillHotspot()
{
    echo "Shutting Down Hotspot"
    ip link set dev "$wifidev" down
    echo 0 > /proc/sys/net/ipv4/ip_forward 
    systemctl stop hostapd
    systemctl stop dnsmasq
    iptables -D FORWARD -i eth0 -o "$wifidev" -m state --state RELATED,ESTABLISHED -j ACCEPT
    iptables -D FORWARD -i "$wifidev" -o eth0 -j ACCEPT
    ip addr flush dev "$wifidev"
    ip link set dev "$wifidev" up
}

StartWifi()
{
    echo "Bringing up WiFi Network"
    wpa_supplicant -B -i "$wifidev" -c /etc/wpa_supplicant/wpa_supplicant.conf >/dev/null 2>&1
    wpa_cli reconfigure
}

KillWifi()
{
    echo "Shutting Down Wifi Network"
    wpa_cli terminate >/dev/null 2>&1
    ip addr flush "$wifidev"
    ip link set dev "$wifidev" down
    rm -r /var/run/wpa_supplicant >/dev/null 2>&1
    ip link set dev "$wifidev" up
}


if [ "$wifi_mode" == "off" ]; then
    if systemctl status hostapd | grep "(running)" >/dev/null 2>&1; then
        KillHotspot
    elif { wpa_cli status | grep "$wifidev"; } >/dev/null 2>&1; then
        KillWifi
    fi

elif [ "$wifi_mode" == "on" ]; then
    if systemctl status hostapd | grep "(running)" >/dev/null 2>&1; then
        KillHotspot
    fi
    StartWifi

elif [ "$wifi_mode" == "hotspot" ]; then
    if systemctl status hostapd | grep "(running)" >/dev/null 2>&1; then
        echo "Hostspot already running!"
        exit
    elif { wpa_cli status | grep "$wifidev"; } >/dev/null 2>&1; then
        KillWifi
    fi
    StartHotspot
fi 

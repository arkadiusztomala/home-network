# jun/26/2025 14:35:13 by RouterOS 6.49.17
# software id = N4KZ-AUQB
#
# model = RBD53iG-5HacD2HnD
# serial number = E7290E2BFC1F
/interface bridge
add name=bridge-lan
/interface wireless
set [ find default-name=wlan1 ] ssid=MikroTik
set [ find default-name=wlan2 ] ssid=MikroTik
/interface pppoe-client
add add-default-route=yes comment="PPPoE client" disabled=no interface=ether1 \
    name=pppoe-out1 password=609ape44 use-peer-dns=yes user=id-0610
/interface list
add name=WAN
add name=LAN
/interface wireless security-profiles
set [ find default=yes ] supplicant-identity=MikroTik
/ip pool
add name=dhcp_pool ranges=192.168.10.100-192.168.10.200
/ip dhcp-server
add address-pool=dhcp_pool disabled=no interface=bridge-lan name=dhcp1
/interface bridge port
add bridge=bridge-lan interface=ether2
add bridge=bridge-lan interface=ether3
add bridge=bridge-lan interface=ether4
add bridge=bridge-lan interface=ether5
/interface list member
add interface=bridge-lan list=LAN
add interface=pppoe-out1 list=WAN
/ip address
add address=192.168.10.1/24 interface=bridge-lan network=192.168.10.0
/ip dhcp-server lease
add address=192.168.10.181 client-id=1:9c:a2:f4:ed:30:e4 mac-address=\
    9C:A2:F4:ED:30:E4 server=dhcp1
/ip dhcp-server network
add address=192.168.10.0/24 gateway=192.168.10.1
/ip dns
set allow-remote-requests=yes servers=8.8.8.8,1.1.1.1
/ip firewall nat
add action=masquerade chain=srcnat out-interface=pppoe-out1
/ip service
set telnet disabled=yes
set ftp disabled=yes
set www disabled=yes
set ssh disabled=yes
set api disabled=yes
set winbox address=192.168.10.0/24
set api-ssl disabled=yes
/system clock
set time-zone-name=Europe/Warsaw
/system identity
set name=RBD53iG-MainRouter

# MikroTik RBD53iG-5HacD2HnD - Główny Router + CAPsMAN Server
# Ether1: PPPoE do modemu ISP
# Ether2: trunk VLAN10/20/30/99 do RB4011 (L2 switch + CAP client)
# Ether3: access VLAN10 (nie-tagowany) dla satelitów Deco
# Ether4/Ether5: porty access z dynamicznym przydziałem VLAN po MAC

# 1. PPPoE Client - Internet dla sieci
/interface pppoe-client
add name=pppoe-out1 interface=ether1 user="<ISP_USER>" password="<ISP_PASS>" use-peer-dns=yes add-default-route=yes disabled=no comment="PPPoE client"

# 2. CAPsMAN Manager - kontroler Wi-Fi
/caps-man manager
set enabled=yes discovery-interfaces=bridge-mesh comment="Włączony CAPsMAN manager"

# 3. CAPsMAN Datapath - mostek mesh
/caps-man datapath
add name=dp-mesh bridge=bridge-mesh comment="Datapath dla sieci Mesh VLAN10"

# 4. CAPsMAN Security Profiles
/caps-man security
add name=sec-guest authentication-types=wpa2-psk encryption=aes-ccm psk="guestPass123" comment="WPA2 Guest"
add name=sec-iot   authentication-types=wpa2-psk encryption=aes-ccm psk="iotPass123"   comment="WPA2 IoT"
add name=sec-mgmt  authentication-types=wpa2-psk encryption=aes-ccm psk="MgmtPass123" comment="WPA2 Mgmt"

# 5. CAPsMAN Configuration (SSID, Band, Frequency)
#    parametr `datapath` określa bridge (dp-mesh), przez który przepuszczany jest ruch klienta Wi‑Fi (mostek VLAN10)

/caps-man configuration
add name=cfg-guest    band=2ghz-b/g/n  country=Poland datapath=dp-mesh frequency=2462 security=sec-guest ssid="Guest_Network" comment="Guest 2.4GHz kanał 11"
add name=cfg-guest-5g 	band=5ghz-a/n/ac country=Poland datapath=dp-mesh frequency=5180 security=sec-guest ssid="Guest_Network" comment="Guest 5GHz kanał 36"
add name=cfg-iot      band=2ghz-b/g/n  country=Poland datapath=dp-mesh frequency=2462 security=sec-iot   ssid="IoT_Network"    comment="IoT 2.4GHz kanał 11"
add name=cfg-iot-5g   band=5ghz-a/n/ac country=Poland datapath=dp-mesh frequency=5180 security=sec-iot   ssid="IoT_Network"    comment="IoT 5GHz kanał 36"
add name=cfg-mgmt     band=2ghz-b/g/n  country=Poland datapath=dp-mesh frequency=2462 security=sec-mgmt ssid="Mgmt_Network" hide-ssid=yes comment="Mgmt 2.4GHz kanał 11 (ukryty SSID)"
add name=cfg-mgmt-5g  band=5ghz-a/n/ac country=Poland datapath=dp-mesh frequency=5180 security=sec-mgmt ssid="Mgmt_Network" hide-ssid=yes comment="Mgmt 5GHz kanał 36 (ukryty SSID)"

# 6. CAPsMAN Provisioning for all CAPs
/caps-man provisioning
add action=create-dynamic-enabled master-configuration=cfg-guest slave-configuration=cfg-guest-5g comment="Provision Guest APs"
add action=create-dynamic-enabled master-configuration=cfg-iot   slave-configuration=cfg-iot-5g   comment="Provision IoT APs"
add action=create-dynamic-enabled master-configuration=cfg-mgmt  slave-configuration=cfg-mgmt-5g  comment="Provision Mgmt APs"

# 7. VLAN Definitions (trunk on ether2)
/interface vlan
add name=vlan10 interface=ether2 vlan-id=10 comment="Mesh VLAN trunk"
add name=vlan20 interface=ether2 vlan-id=20 comment="Guest VLAN trunk"
add name=vlan30 interface=ether2 vlan-id=30 comment="IoT VLAN trunk"
add name=vlan99 interface=ether2 vlan-id=99 comment="Mgmt VLAN trunk"

# 8. Bridge setup for each VLAN
/interface bridge
add name=bridge-mesh comment="Bridge dla Mesh VLAN10"
add name=bridge-guest comment="Bridge dla Guest VLAN20"
add name=bridge-iot   comment="Bridge dla IoT VLAN30"
add name=bridge-mgmt  comment="Bridge dla Mgmt VLAN99"

# 9. Bridge Ports configuration
/interface bridge port
add bridge=bridge-mesh interface=vlan10 pvid=10 comment="Mesh trunk"
add bridge=bridge-mesh interface=ether3 pvid=10 comment="Access VLAN10 dla Deco"
add bridge=bridge-guest interface=vlan20 pvid=20 comment="Guest trunk/access"
add bridge=bridge-iot interface=vlan30 pvid=30 comment="IoT trunk/access"
add bridge=bridge-mgmt interface=vlan99 pvid=99 comment="Mgmt trunk/access"

# 10. IP Addressing and DHCP servers
/ip address
add address=192.168.10.1/24 interface=bridge-mesh comment="Mesh gateway IP"
add address=192.168.20.1/24 interface=bridge-guest comment="Guest gateway IP"
add address=192.168.30.1/24 interface=bridge-iot comment="IoT gateway IP"
add address=192.168.99.1/24 interface=bridge-mgmt comment="Mgmt gateway IP"

/ip pool
add name=pool-mesh   ranges=192.168.10.100-192.168.10.200 comment="DHCP pool Mesh"
add name=pool-guest  ranges=192.168.20.100-192.168.20.200 comment="DHCP pool Guest"
add name=pool-iot    ranges=192.168.30.100-192.168.30.200 comment="DHCP pool IoT"
add name=pool-mgmt   ranges=192.168.99.100-192.168.99.200 comment="DHCP pool Mgmt"

/ip dhcp-server
add name=dhcp-mesh  interface=bridge-mesh address-pool=pool-mesh disabled=no comment="DHCP server Mesh"
add name=dhcp-guest interface=bridge-guest address-pool=pool-guest disabled=no comment="DHCP server Guest"
add name=dhcp-iot   interface=bridge-iot address-pool=pool-iot disabled=no comment="DHCP server IoT"
add name=dhcp-mgmt  interface=bridge-mgmt address-pool=pool-mgmt disabled=no comment="DHCP server Mgmt"

# 10.a Static DHCP leases (przypisanie IP do MAC)
/ip dhcp-server lease
add mac-address=AA:BB:CC:DD:EE:01 address=192.168.10.10 comment="PC-arek" #1
add mac-address=11:22:33:44:55:66 address=192.168.10.11 comment="NAS-qnap-ts251-plus" #2
add mac-address=77:88:99:AA:BB:CC address=192.168.30.20 comment="HP-M277dw" #3
add mac-address=AA:BB:CC:DD:EE:01 address=192.168.10.2 comment="TP-LINK-DecoXE75Pro-central" #4
add mac-address=11:22:33:44:55:66 address=192.168.30.10 comment="Netgear-basement" #5
add mac-address=77:88:99:AA:BB:CC address=192.168.99.3 comment="TP-Link-TL-SG108PE-switch" #6
add mac-address=AA:BB:CC:DD:EE:01 address=192.168.10.3 comment="TP-LINK-DecoXE75Pro-satelite2F" #7
add mac-address=11:22:33:44:55:66 address=192.168.30.11 comment="TP-Link-TL-WA850RE-cam" #8
add mac-address=77:88:99:AA:BB:CC address=192.168.30.12 comment="Mikrotik-RBmAPL-2nD-cam" #9
add mac-address=AA:BB:CC:DD:EE:01 address=192.168.10.4 comment="TP-LINK-DecoXE75Pro-satelite1F" #10
add mac-address=11:22:33:44:55:66 address=192.168.30.20 comment="SonyBraviaTV" #11
add mac-address=77:88:99:AA:BB:CC address=192.168.30.21 comment="Canalplus-0F" #12
add mac-address=AA:BB:CC:DD:EE:01 address=192.168.30.30 comment="Samsung65TV" #13
add mac-address=11:22:33:44:55:66 address=192.168.30.31 comment="Canalplus-1F" #14
add mac-address=77:88:99:AA:BB:CC address=192.168.30.33 comment="PS5" #15
add mac-address=AA:BB:CC:DD:EE:01 address=192.168.10.50 comment="iPhone-arek" #16
add mac-address=11:22:33:44:55:66 address=192.168.10.60 comment="Samsung-heniek" #17

# 11. NAT and Firewall NAT and Firewall
/ip firewall nat
add chain=srcnat out-interface=pppoe-out1 action=masquerade comment="NAT Internet"
/ip firewall filter
add chain=forward connection-state=established,related action=accept comment="Allow established"
add chain=input connection-state=established,related action=accept comment="Allow established"
add chain=input protocol=icmp action=accept comment="Allow ping"

# Allow PC 192.168.10.10 to IoT and Mgmt VLANs
add chain=forward src-address=192.168.10.10 dst-address=192.168.30.0/24 action=accept comment="PC 192.168.10.10→IoT allowed"
add chain=forward src-address=192.168.10.10 dst-address=192.168.99.0/24 action=accept comment="PC 192.168.10.10→Mgmt allowed"

# Allow iPhone12 (192.168.10.50) to IoT and Mgmt VLANs
add chain=forward src-address=192.168.10.50 dst-address=192.168.30.0/24 action=accept comment="iPhone12→IoT allowed"
add chain=forward src-address=192.168.10.50 dst-address=192.168.99.0/24 action=accept comment="iPhone12→Mgmt allowed"

# Allow Samsung (192.168.10.60) to IoT VLAN
add chain=forward src-address=192.168.10.60 dst-address=192.168.30.0/24 action=accept comment="Samsung→IoT allowed"

# Allow Mesh (VLAN10) to Printer at 192.168.30.20
add chain=forward src-address=192.168.10.0/24 dst-address=192.168.30.20 action=accept comment="Mesh→Printer IoT allowed"

# Isolation rules
add chain=forward src-address=192.168.20.0/24 dst-address=192.168.10.0/24 action=drop comment="Guest→Mesh"
add chain=forward src-address=192.168.20.0/24 dst-address=192.168.30.0/24 action=drop comment="Guest→IoT"
add chain=forward src-address=192.168.20.0/24 dst-address=192.168.99.0/24 action=drop comment="Guest→Mgmt"
add chain=forward src-address=192.168.30.0/24 dst-address=192.168.20.0/24 action=drop comment="IoT→Guest"
add chain=forward src-address=192.168.30.0/24 dst-address=192.168.10.0/24 action=drop comment="IoT→Mesh"
add chain=forward src-address=192.168.30.0/24 dst-address=192.168.99.0/24 action=drop comment="IoT→Mgmt"
add chain=forward src-address=192.168.99.0/24 action=accept comment="Mgmt full access"

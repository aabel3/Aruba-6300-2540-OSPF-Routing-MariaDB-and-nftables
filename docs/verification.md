# ✅ Verification

Each check below lists the command, the expected output (taken from the project screenshots) and the matching screenshot. All captures are from 13 June 2025.

---

## Switches

### Interfaces

```
Switch-AA# sh ip int br
1/1/1             192.168.22.1/30       up/up
vlan1             No Address            up/up
vlan11            172.16.11.1/27        up/up
vlan22            172.16.22.1/27        up/up
```

```
Switch-CC# sh ip int br
1/1/1             192.168.22.2/30       up/up
vlan33            172.16.33.1/27        up/up
vlan44            172.16.44.1/27        up/up
```

Screenshots: [AA](../screenshots/26-switch-aa-ip-interface-brief.png) · [CC](../screenshots/28-switch-cc-ip-interface-brief.png) · [BB](../screenshots/27-switch-bb-interfaces-brief.png) · [DD](../screenshots/29-switch-dd-interfaces-brief.png)

On Switch-BB and Switch-DD, `sh interfaces brief` lists the trunk members as `Trk1`, `Trk2` (BB) and `Trk2`, `Trk3` (DD), with ports 1 to 5 up at 1000FDx.

### VLANs

`show vlan` lists VLANs 1, 11, 22, 33 and 44 on Switch-BB and Switch-DD (`VLAN11` … `VLAN44`, port-based). On the 6300s, only the VLANs created on that switch are listed with their ports.

Screenshots: [AA](../screenshots/30-switch-aa-show-vlan.png) · [BB](../screenshots/31-switch-bb-show-vlan.png) · [CC](../screenshots/32-switch-cc-show-vlan.png) · [DD](../screenshots/33-switch-dd-show-vlan.png)

### Spanning tree

`sh spanning-tree` reports `Enabled Protocol: RPVST` on both 6300s.

Screenshots: [AA](../screenshots/34-switch-aa-spanning-tree.png) · [CC](../screenshots/35-switch-cc-spanning-tree.png)

### DHCP server

```
Switch-AA# sh dhcp-server
```

Lists the pools `vlan11`, `vlan22`, `vlan33` and `vlan44` with their ranges and default routers.

Screenshots: [DHCP server](../screenshots/36-switch-aa-dhcp-server.png) · [VLAN 44 pool](../screenshots/37-switch-aa-dhcp-pool-vlan44.png)

### OSPF routes

```
Switch-CC# sh ip route
172.16.11.0/27    192.168.22.1   1/1/1    O   [110/200]
172.16.22.0/27    192.168.22.1   1/1/1    O   [110/200]
172.16.33.0/27    -              vlan33   C   [0/0]
172.16.44.0/27    -              vlan44   C   [0/0]
192.168.22.0/30   -              1/1/1    C   [0/0]
```

Screenshot: [CC routing table](../screenshots/38-switch-cc-ip-route-ospf.png)

---

## Ubuntu VMs

### `ip a` – address from the switch

```bash
ip a
```

Each VM has `ens33` on `10.33.35.x` (campus) and `ens37` on its VLAN (for example `172.16.44.9/27` or `172.16.33.15/27`).

Screenshots: [VM A](../screenshots/18-ip-a-vm-a.png) · [VM B](../screenshots/19-ip-a-vm-b.png)

### `ip route` – gateway and routes to the other VLANs

```bash
ip route
```

VLAN 44 VM:

```
default via 172.16.44.1 dev ens37 proto dhcp src 172.16.44.9 metric 20101
172.16.11.0/27 via 172.16.44.1 dev ens37
172.16.22.0/27 via 172.16.44.1 dev ens37
172.16.33.0/27 via 172.16.44.1 dev ens37
172.16.44.0/27 dev ens37 proto kernel scope link src 172.16.44.9 metric 101
```

Screenshots: [VLAN 44 VM](../screenshots/20-ip-route-vm-a.png) · [VLAN 22 VM](../screenshots/21-ip-route-vm-b.png)

---

## SSH

### To the switch

```bash
ssh student@172.16.22.1
```

Wireshark filter `ssh` shows the SSHv2 version exchange and key exchange between the VM and the switch.

Screenshots: [VM A](../screenshots/02-ssh-to-switch-vm-a.png) · [VM B](../screenshots/03-ssh-to-switch-vm-b.png)

### VM to VM

```bash
ssh <username>@172.16.11.11
```

Screenshots: [VM A](../screenshots/06-ssh-vm-to-vm-a.png) · [VM B](../screenshots/07-ssh-vm-to-vm-b.png)

### Root login disabled

`PermitRootLogin no` is set in `/etc/ssh/sshd_config`.

Screenshots: [VM A](../screenshots/22-sshd-config-permitrootlogin-a.png) · [VM B](../screenshots/23-sshd-config-permitrootlogin-b.png)

---

## OSPF

Wireshark filter `ospf` shows `Hello Packet` messages from the gateway addresses to `224.0.0.5` (All OSPF Routers), for example from `172.16.44.1` and `172.16.22.1`.

Screenshots: [VLAN 44 VM](../screenshots/04-ospf-hello-wireshark-a.png) · [VLAN 22 VM](../screenshots/05-ospf-hello-wireshark-b.png)

---

## Apache (HTTP)

Browse to a partner VM, for example `http://172.16.11.11`. The test page loads and Wireshark filter `http` shows `GET / HTTP/1.1` answered with `HTTP/1.1 200 OK`.

Screenshots: [Wireshark A](../screenshots/08-http-request-wireshark-a.png) · [Wireshark B](../screenshots/09-http-request-wireshark-b.png) · [VLAN 33 page](../screenshots/10-apache-page-vm-1.png) · [VLAN 22 page](../screenshots/11-apache-page-vm-2.png) · [VLAN 11 page](../screenshots/12-apache-page-vm-3.png) · [VLAN 11 page (second capture)](../screenshots/13-apache-page-vm-4.png)

---

## MariaDB

### Login from another VLAN

```bash
mysql -h 172.16.11.11 -u <db_user> -p
```

The `MariaDB [(none)]>` prompt appears, and Wireshark filter `mysql` shows the server greeting and the query/response exchange on port 3306.

Screenshots: [Wireshark A](../screenshots/14-mariadb-login-wireshark-a.png) · [Wireshark B](../screenshots/15-mariadb-login-wireshark-b.png)

### Read-only user

```sql
CREATE DATABASE my_database;
ERROR 1044 (42000): Access denied for user '<db_user>'@'%' to database 'my_database'
```

Screenshots: [VM A](../screenshots/16-mariadb-read-only-denied-a.png) · [VM B](../screenshots/17-mariadb-read-only-denied-b.png)

---

## nftables

```bash
sudo nft -f /etc/nftables.conf
sudo nft list ruleset
```

The ruleset matches [`configs/nftables.conf`](../configs/nftables.conf): input policy `drop`, with loopback, established/related, ICMP and TCP 22, 80, 443 and 3306 accepted.

Screenshots: [Ruleset reference](../screenshots/24-nftables-ruleset-reference.png) · [Editor](../screenshots/25-nftables-conf-editor.png)

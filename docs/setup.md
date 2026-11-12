# ⚙️ Setup Guide

Step-by-step instructions to rebuild the four-switch OSPF, MariaDB and nftables lab.

> Addressing and port assignments are in [topology.md](topology.md).

---

## 1. Configure the Aruba 6300 switches

1. Connect to each switch console or SSH in, then enter configuration mode:

   ```
   Switch-AA# configure terminal
   Switch-AA(config)#
   ```

2. On Switch-AA, paste [`configs/aruba-6300-switch-aa.cfg`](../configs/aruba-6300-switch-aa.cfg). It creates:
   - VLANs 11 and 22 with gateways `172.16.11.1/27` and `172.16.22.1/27`
   - OSPF process 1 (`router-id 1.1.1.1`, area 0)
   - Routed port `1/1/1` (`192.168.22.1/30`)
   - `lag 1` with ports `1/1/2` and `1/1/3`
   - Access port `1/1/4` (VLAN 11)
   - DHCP pools for VLANs 11, 22, 33 and 44

3. On Switch-CC, paste [`configs/aruba-6300-switch-cc.cfg`](../configs/aruba-6300-switch-cc.cfg). It creates:
   - VLANs 33 and 44 with gateways `172.16.33.1/27` and `172.16.44.1/27`, each with a DHCP relay to `192.168.22.1`
   - OSPF process 1 (`router-id 2.2.2.2`, area 0)
   - Routed port `1/1/1` (`192.168.22.2/30`)
   - `lag 2` with ports `1/1/2` and `1/1/3`
   - Access port `1/1/4` (VLAN 33)

4. Confirm the interfaces are up and OSPF routes are learned:

   ```
   Switch-AA# sh ip int br
   Switch-CC# sh ip route
   ```

---

## 2. Configure the Aruba 2530/2540 switches

1. Connect to each switch console and enter configuration mode.
2. On Switch-BB, paste [`configs/aruba-2540-switch-bb.cfg`](../configs/aruba-2540-switch-bb.cfg): `trk1` (ports 2–3) and `trk2` (ports 4–5) with LACP, VLANs 11, 22, 33 and 44 tagged on both trunks, and port 1 untagged in VLAN 22.
3. On Switch-DD, paste [`configs/aruba-2540-switch-dd.cfg`](../configs/aruba-2540-switch-dd.cfg): `trk2` (ports 4–5) and `trk3` (ports 2–3) with LACP, the four VLANs tagged on both, and port 1 untagged in VLAN 44.
4. Check the trunks and VLANs:

   ```
   Switch-BB# show vlan
   Switch-BB# sh interfaces brief
   ```

---

## 3. Prepare the Ubuntu VMs

1. Create four Ubuntu 22.04 VMs with two adapters each: one on the campus network and one on the lab switches.
2. Connect each VM to its switch port (see [topology.md](topology.md)).
3. Confirm the lab adapter (`ens37`) received an address from the DHCP server:

   ```bash
   ip -brief link
   ip a
   ```

4. Add a route to the other three VLANs through the local gateway, for example on the VLAN 22 VM:

   ```bash
   sudo ip route add 172.16.11.0/27 via 172.16.22.1 dev ens37
   sudo ip route add 172.16.33.0/27 via 172.16.22.1 dev ens37
   sudo ip route add 172.16.44.0/27 via 172.16.22.1 dev ens37
   ```

---

## 4. Install Apache

```bash
sudo apt update
sudo apt install -y apache2
sudo systemctl enable --now apache2
sudo cp web/index.html /var/www/html/index.html
```

---

## 5. Install and configure MariaDB

```bash
sudo apt install -y mariadb-server
sudo vim /etc/mysql/mariadb.conf.d/50-server.cnf     # set: bind-address = 0.0.0.0
sudo systemctl restart mariadb
sudo mariadb
```

Run the statements in [`configs/mariadb-setup.sql`](../configs/mariadb-setup.sql), replacing `<db_user>` and `<db_password>`. The user has `SELECT` only on `labdb`, so attempts to create databases are refused.

To test from another VM:

```bash
sudo apt install -y mariadb-client
mysql -h <vm-ip> -u <db_user> -p
```

---

## 6. Apply the nftables firewall

```bash
sudo cp configs/nftables.conf /etc/nftables.conf
sudo nft -f /etc/nftables.conf
sudo systemctl enable --now nftables
```

To clear the rules while troubleshooting: `sudo nft flush ruleset`.

---

## 7. Secure SSH

1. Edit `/etc/ssh/sshd_config` and set `PermitRootLogin no` (see [`configs/sshd_config.snippet`](../configs/sshd_config.snippet)).
2. Restart SSH: `sudo systemctl restart ssh`
3. Create a key pair and copy it to the other VMs:

   ```bash
   ssh-keygen
   ssh-copy-id <username>@<other-vm-ip>
   ```

---

## 8. Capture and verify

Run Wireshark on the VM's lab interface and use the display filters `ssh`, `ospf`, `http` and `mysql` while testing. The optional helper [`scripts/verify-connectivity.bash`](../scripts/verify-connectivity.bash) runs the VM-side checks. Expected output for every check is in [verification.md](verification.md).

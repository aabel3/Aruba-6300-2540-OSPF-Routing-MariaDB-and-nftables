# 📝 Submission Summary

## Overview

This project extends the earlier Aruba lab to four switches and four Ubuntu VMs. Two Aruba 6300 switches exchange routes with OSPF, two Aruba 2530/2540 switches extend the VLANs over LACP trunks, and each VM runs Apache, a read-only MariaDB database and an nftables firewall.

## Expectations

- Configure the four Aruba switches so the VMs reach each other without relying on the campus network
- Use the addressing scheme with `/27` subnets for VLANs 11, 22, 33 and 44
- Run a custom Apache web page, a MariaDB database and an nftables firewall on each VM
- Allow only the required traffic through the firewall and give the database user read-only access
- Connect the VMs with SSH using key pairs, with root login disabled
- Show each result with `show` commands, `ip` commands and Wireshark captures

## Approach

1. Configure the 6300 and 2530/2540 switches with the scripts in [`configs/`](../configs/).
2. Connect one VM to each VLAN and confirm DHCP addressing, including the relay for VLAN 33 and VLAN 44.
3. Add routes to the other VLANs on each VM.
4. Install Apache, MariaDB and nftables on each VM.
5. Disable root SSH login, create key pairs and copy them between the VMs.
6. Capture the SSH, OSPF, HTTP and MariaDB traffic in Wireshark.

## Deliverables

| Deliverable | Location |
|-------------|----------|
| Network diagram | [`packet-tracer/network-diagram.pkt`](../packet-tracer/network-diagram.pkt), [`screenshots/01-network-diagram.png`](../screenshots/01-network-diagram.png) |
| Switch configuration scripts | [`configs/aruba-6300-switch-aa.cfg`](../configs/aruba-6300-switch-aa.cfg), [`configs/aruba-6300-switch-cc.cfg`](../configs/aruba-6300-switch-cc.cfg), [`configs/aruba-2540-switch-bb.cfg`](../configs/aruba-2540-switch-bb.cfg), [`configs/aruba-2540-switch-dd.cfg`](../configs/aruba-2540-switch-dd.cfg) |
| nftables ruleset | [`configs/nftables.conf`](../configs/nftables.conf) |
| MariaDB setup | [`configs/mariadb-setup.sql`](../configs/mariadb-setup.sql) |
| `sshd_config` change | [`configs/sshd_config.snippet`](../configs/sshd_config.snippet) |
| Wireshark captures (SSH, OSPF, HTTP, MariaDB) | `screenshots/02` – `09`, `14` – `15` |
| Apache pages | `screenshots/10` – `13`, [`web/index.html`](../web/index.html) |
| `ip a`, `ip route` on the VMs | `screenshots/18` – `21` |
| Switch `show` commands | `screenshots/26` – `38` |

## Conclusion

Four Aruba switches were joined with OSPF routing and LACP trunks, four Ubuntu VMs received addressing through DHCP and a DHCP relay, and each VM was shown serving Apache and a read-only MariaDB database behind an nftables firewall. SSH, OSPF, HTTP and MariaDB traffic was captured in Wireshark. The project gave hands-on practice with OSPF, trunking, VLANs, DHCP relay, database permissions, host firewalls and SSH.

## References

- [ArubaOS 8.x CLI Reference Guide](https://arubanetworking.hpe.com/techdocs/ArubaOS-8.x-Books/ArubaOS-8.x-CLI-Reference-Guide.pdf)
- [HPE Support – document a00021327en_us](https://support.hpe.com/hpesc/public/docDisplay?docId=a00021327en_us)
- [HPE Support – document a00055715en_us](https://support.hpe.com/hpesc/public/docDisplay?docId=a00055715en_us&docLocale=en_US)
- [MariaDB Documentation](https://mariadb.com/kb/en/documentation/)
- [nftables Wiki](https://wiki.nftables.org/)

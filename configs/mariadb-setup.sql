-- MariaDB setup used on each Ubuntu VM
--
-- Run inside the MariaDB shell:  sudo mariadb
-- Replace <db_user> and <db_password> with your own values before running.
-- The account is read-only (SELECT only) and may connect from any host,
-- so the other VMs can query the database over TCP port 3306.
--
-- Before this works from another VM, MariaDB must listen on the network:
--   sudo vim /etc/mysql/mariadb.conf.d/50-server.cnf
--   set:  bind-address = 0.0.0.0
--   sudo systemctl restart mariadb

CREATE DATABASE labdb;

CREATE USER '<db_user>'@'%' IDENTIFIED BY '<db_password>';

GRANT SELECT ON labdb.* TO '<db_user>'@'%';

FLUSH PRIVILEGES;

EXIT;

#!/bin/bash
sudo hostnamectl set-hostname ${nodename} &&
curl -sfL https://get.k3s.io |  INSTALL_K3S_SKIP_SELINUX_RPM=true INSTALL_K3S_SELINUX_WARN=true sh -s - server \
--datastore-endpoint="mysql://${dbuser}:${dbpass}@tcp(${db_endpoint})/${dbname}" \
--write-kubeconfig-mode 644 \
--tls-san="${myip}" \
--token="th1s1sat0k3n!"
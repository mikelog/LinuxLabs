#!/usr/bin/env bash
#allow to ssh login via password
sed -i 's/PasswordAuthentication no/PasswordAuthentication yes/g' /etc/ssh/sshd_config
sed -i 's/UsePAM no/UsePAM yes/g'/etc/ssh/sshd_config
systemctl restart sshd

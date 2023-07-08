#!/bin/sh
cp /etc/update-extlinux.conf /etc/update-extlinux.conf.bak
sed -i "/^default_kernel_opts=/ s/\"$/ cgroup_enable=cpuset cgroup_memory=1 cgroup_enable=memory\"/" /etc/update-extlinux.conf
update-extlinux
apk add iptables sudo vim
apk add --no-cache cni-plugins --repository=http://dl-cdn.alpinelinux.org/alpine/edge/testing
# touch /var/tmp/reboot_me

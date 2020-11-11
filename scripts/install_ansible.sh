#/bin/sh
# Assuming for right now that I'm on a mac. Need logic to handle linux.

function write {
    echo "*************************************************"
    echo $1
    echo "*************************************************"
}

function install_ansible {
    if [ ! -x "$(command -v ansible)" ]; then
        write "Installing ansible"
        sudo easy_install pip
        sudo pip install ansible
    fi
    write "Ansible installed"
}

write "Bootstrapping"

install_ansible

write "Ready to go"
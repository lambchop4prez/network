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

function run_playbook {
    if [ -x "$(command -v ansible-playbook)" ]
    then
        write "running playbook"
        ansible-playbook -i ./mac.hosts playbook.yml --verbose --check
    else
        write "ansible-playbook command not found"
    fi
}

write "Bootstrapping"

install_ansible
run_playbook

write "Done"
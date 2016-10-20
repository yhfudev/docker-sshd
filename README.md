
# docker-sshd
defines a docker container running Arch Linux with the openssh installed


## Build Arch Linux docker image

    MYUSER=${USER}
    MYARCH=$(uname -m)
    sudo docker build -t ${MYUSER}/archsshd-${MYARCH}:latest .

## Run and test

    # run as daemon, or replace '-d' with '--rm' to test the image
    sudo docker run \
        -d \
        -i -t \
        --privileged \
        -v /etc/ssh/ssh_host_key:/etc/ssh/ssh_host_key:ro \
        -v /etc/ssh/ssh_host_rsa_key:/etc/ssh/ssh_host_rsa_key:ro \
        -v /etc/ssh/ssh_host_dsa_key:/etc/ssh/ssh_host_dsa_key:ro \
        -v /etc/ssh/ssh_host_ecdsa_key:/etc/ssh/ssh_host_ecdsa_key:ro \
        -v /etc/ssh/ssh_host_ed25519_key:/etc/ssh/ssh_host_ed25519_key:ro \
        -v /root/.ssh/authorized_keys:/root/.ssh/authorized_keys:ro \
        -v $HOME/Downloads/sources/:/sources/:rw \
        -v $HOME/Downloads/sources/pacman-cache-x64:/var/cache/pacman/pkg/:rw \
        -h docker \
        -p 2222:22 \
        --name myarchsshd
        ${MYUSER}/archsshd-${MYARCH}

    # test clinet
    ssh -CY -p 2222 root@localhost


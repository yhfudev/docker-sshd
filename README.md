
# docker-sshd
defines a docker container running Arch Linux with the openssh installed


## Build Arch Linux docker image

    MYUSER=${USER}
    MYARCH=$(uname -m)
    sudo docker build -t ${MYUSER}/archsshd-${MYARCH}:latest .

If you want to mount the /var/cache/pacman/pkg/ to reuse the cache, try rocker (https://github.com/grammarly/rocker)

    cp Dockerfile Rockerfile
    sed -i \
        -e "s|^[# ]*MOUNT cgroup.*$|MOUNT /sys/fs/cgroup/:/sys/fs/cgroup/|g" \
        -e "s|^[# ]*MOUNT pacman.*$|MOUNT /root/homegw/sources/pacman-pkg-x64:/var/cache/pacman/pkg/|g" \
        -e "s|^[# ]*PUSH .*$|PUSH ${MYUSER}/archsshd-${MYARCH}:latest|g" \
        -e "s|^[# ]*ATTACH .*$|ATTACH|g" \
        -e "s|^RUN pacman -Sc$|# RUN pacman -Sc|g" \
        Rockerfile
    cat Rockerfile
    sudo ./rocker build


## Run and test

    # run as daemon, or replace '-d' with '--rm' to test the image
    sudo docker run \
        -d \
        -i -t \
        --privileged \
        --cap-add SYS_ADMIN \
        -v /sys/fs/cgroup:/sys/fs/cgroup:ro \
        -v /etc/ssh/ssh_host_key:/etc/ssh/ssh_host_key:ro \
        -v /etc/ssh/ssh_host_rsa_key:/etc/ssh/ssh_host_rsa_key:ro \
        -v /etc/ssh/ssh_host_dsa_key:/etc/ssh/ssh_host_dsa_key:ro \
        -v /etc/ssh/ssh_host_ecdsa_key:/etc/ssh/ssh_host_ecdsa_key:ro \
        -v /etc/ssh/ssh_host_ed25519_key:/etc/ssh/ssh_host_ed25519_key:ro \
        -v /root/.ssh/authorized_keys:/root/.ssh/authorized_keys:ro \
        -v /root/homegw/sources/:/sources/:rw \
        -v /root/homegw/sources/pacman-pkg-x64:/var/cache/pacman/pkg/:rw \
        -h docker \
        -p 2222:22 \
        --name myarchsshd \
        ${MYUSER}/archsshd-${MYARCH}

    # test clinet
    ssh -CY -p 2222 root@localhost


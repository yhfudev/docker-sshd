#ARG MYARCH
FROM yhfu/archlinux-x86_64
MAINTAINER yhfu <yhfudev@gmail.com>

# MOUNT cgroup:/sys/fs/cgroup/ # Rockerfile
# MOUNT pacman:/var/cache/pacman/pkg/ # Rockerfile
VOLUME [ "/sys/fs/cgroup" ]

RUN pacman -Syyu --needed --noconfirm

RUN getent group systemd-journal-remote >/dev/null 2>&1 || groupadd -r systemd-journal-remote 2>&1 || :
RUN pacman -S --noprogressbar --noconfirm --needed systemd iproute2

# systemd base image
# http://stackoverflow.com/questions/28495341/start-a-service-in-docker-container-failed-with-error-failed-to-get-d-bus-conne
RUN (cd /lib/systemd/system/sysinit.target.wants/; for i in *; do [ $i == systemd-tmpfiles-setup.service ] || rm -f $i; done); \
    rm -f /lib/systemd/system/multi-user.target.wants/*;\
    rm -f /etc/systemd/system/*.wants/*;\
    rm -f /lib/systemd/system/local-fs.target.wants/*; \
    rm -f /lib/systemd/system/sockets.target.wants/*udev*; \
    rm -f /lib/systemd/system/sockets.target.wants/*initctl*; \
    rm -f /lib/systemd/system/basic.target.wants/*;\
    rm -f /lib/systemd/system/anaconda.target.wants/*; \
    rm -f /lib/systemd/system/plymouth*; \
    rm -f /lib/systemd/system/systemd-update-utmp*;

RUN systemctl set-default multi-user.target
ENV init /lib/systemd/systemd

# install openssh
RUN pacman -S --noprogressbar --noconfirm --needed openssh sshfs xorg-xauth xorg-xinit xterm ttf-dejavu; systemctl enable sshd.service

# ATTACH # Rockerfile

# generate some keys
#RUN ssh-keygen -A
RUN rm -f /etc/ssh/ssh_host_*

# X11Forwarding
# PermitRootLogin: allow the root user to log in
RUN sed -i \
    -e 's|^[#]*X11Forwarding.*$|X11Forwarding yes|g' \
    -e 's|^[#]*PermitRootLogin.*$|PermitRootLogin yes|g' \
    /etc/ssh/sshd_config

EXPOSE 22

# start the server (goes into the background)
#CMD /usr/bin/sshd; sleep infinity
#CMD ["/usr/sbin/init"]
ENTRYPOINT ["/lib/systemd/systemd"]

# PUSH yhfu/archsshd:latest # Rockerfile


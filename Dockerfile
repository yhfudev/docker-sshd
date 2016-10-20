#ARG MYARCH
FROM yhfu/archlinux-x86_64
MAINTAINER yhfu <yhfudev@gmail.com>

# install openssh
RUN pacman -S --noprogressbar --noconfirm --needed iproute2 openssh sshfs xorg-xauth xorg-xinit xterm ttf-dejavu

# generate some keys
#RUN ssh-keygen -A
RUN rm -f /etc/ssh/ssh_host_*

# X11Forwarding
# PermitRootLogin: allow the root user to log in
RUN sed -i \
    -e 's|^[#]*X11Forwarding.*$|X11Forwarding yes|g' \
    -e 's|^[#]*PermitRootLogin.*$|PermitRootLogin yes|g' \
    /etc/ssh/sshd_config

# start the server (goes into the background)
CMD /usr/bin/sshd; sleep infinity


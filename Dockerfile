FROM ubuntu:20.04

# default screen size
ENV XRES=1280x800x24

# default tzdata
ENV TZ=Etc/UTC

# update and install software
RUN export DEBIAN_FRONTEND=noninteractive  \
	&& apt-get update -q \
	&& apt-get upgrade -qy \
	&& apt-get install -qy  --no-install-recommends \
	apt-utils sudo supervisor vim openssh-server \
	xserver-xorg xvfb x11vnc dbus-x11 \
	xfce4 xfce4-terminal xfce4-xkb-plugin  \
	\
	# fix "LC_ALL: cannot change locale (en_US.UTF-8)""
	locales \
	&& echo "LC_ALL=en_US.UTF-8" >> /etc/environment \
	&& echo "en_US.UTF-8 UTF-8" >> /etc/locale.gen \
	&& echo "LANG=en_US.UTF-8" > /etc/locale.conf \
	&& locale-gen en_US.UTF-8 \
	\
	# keep it slim
	# 	&& apt-get remove -qy \
	\
	# cleanup and fix
	&& apt-get autoremove -y \
	&& apt-get --fix-broken install \
	&& apt-get clean \
	&& rm -rf /var/lib/apt/lists/*

# required preexisting dirs
RUN mkdir /run/sshd

# users and groups
RUN echo "root:ubuntu" | /usr/sbin/chpasswd \
    && useradd -m ubuntu -s /bin/bash \
    && echo "ubuntu:ubuntu" | /usr/sbin/chpasswd \
    && echo "ubuntu    ALL=(ALL) ALL" >> /etc/sudoers 

# add my sys config files
ADD etc /etc

# user config files

# terminal
ADD config/xfce4/terminal/terminalrc /home/ubuntu/.config/xfce4/terminal/terminalrc
# wallpaper
ADD config/xfce4/xfconf/xfce-perchannel-xml/xfce4-desktop.xml /home/ubuntu/.config/xfce4/xfconf/xfce-perchannel-xml/xfce4-desktop.xml
# icon theme
ADD config/xfce4/xfconf/xfce-perchannel-xml/xsettings.xml /home/ubuntu/.config/xfce4/xfconf/xfce-perchannel-xml/xsettings.xml

# TZ, aliases
RUN cd /home/ubuntu \
	&& echo 'export TZ=/usr/share/zoneinfo/$TZ' >> .bashrc \
	&& sed -i 's/#alias/alias/' .bashrc  \
	&& echo "alias lla='ls -al'" 		>> .bashrc \
	&& echo "alias llt='ls -ltr'"  		>> .bashrc \
	&& echo "alias llta='ls -altr'" 	>> .bashrc \
	&& echo "alias llh='ls -lh'" 		>> .bashrc \
	&& echo "alias lld='ls -l|grep ^d'" >> .bashrc \
	&& echo "alias hh=history" 			>> .bashrc \
	&& echo "alias hhg='history|grep -i" '"$@"' "'" >> .bashrc
	
# set owner
RUN chown -R ubuntu:ubuntu /home/ubuntu/.*

# ports
EXPOSE 22 5900

# # default command
CMD ["/usr/bin/supervisord","-c","/etc/supervisord.conf"]

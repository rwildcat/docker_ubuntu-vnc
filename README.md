# Docker Ubuntu VNC

A lightweight (519 MB) Linux workstation based on [Ubuntu](https://ubuntu.com/). Provides a **graphical desktop**, and **VNC** / **SSH** access.

*Ramon Solano (ramon.solano at gmail.com)*

**Last update**: Mar/3/2021.  
**Base image**: [Ubuntu 20.04 (focal-20210119)](https://hub.docker.com/_/ubuntu)


## Main packages

* **xfce4**   : Graphic desktop environment
* **x11vnc**  : X vnc server
* **sshd**    : SSH server

## Users


| User   | pwd    |
| ------ | ------ |
| root   | ubuntu |
| ubuntu | ubuntu |

## Usage (synopsis)

1. (Optional) Download (*pull*) the image from its [docker hub repository](https://cloud.docker.com/u/rsolano/repository/docker/rsolano/ubuntu-vnc). 

	If this step is not done first and the image does not previously exists in your local computer, the image will be downloaded later by the `docker run` command:

   ```sh
   $ docker pull rsolano/ubuntu-vnc
   ```

2. Run the container.

	For example:

	* To run an ephemeral VNC session (port 5900):

		```sh
	   $ docker run --rm -p 5900:5900 rsolano/ubuntu-vnc
	   ```
	   
	* To run an ephemeral VNC + SSH session (port 5900 and 2222):

		```sh
	   $ docker run --rm -p 5900:5900 -p 2222:22 rsolano/ubuntu-vnc
	   ```
   
3. Connect to the virtual computer using a VNC viewer (such as the [RealVNC viewer](https://www.realvnc.com/en/connect/download/viewer/)).

	**Note**: As the remote VNC port 5900 was forwarded to the local host port 5900 (by `-p 5900:5900`), you can connect to:

	```
	localhost:5900
	```
	
4. Connect to the virtual computer using a SSH connection.

	**Note**: As the remote SSHD port 22 was forwarded to the local host port 2222 (by `-p 2222:22`), you can connect to:
	
	```sh
	$ ssh -p 2222 ubuntu@localhost
	```


## To locally build the image from the `Dockerfile` (optional, for developers only)

If you want to customize the image or use it for creating a new one based on this configuration, you can download (*clone*) the full image files from the [corresponding github repository](https://github.com/rwildcat/docker_ubuntu-vnc). 

```sh
# clone git repository
$ git clone https://github.com/rwildcat/docker_ubuntu-vnc.git

# build image
$ cd docker_ubuntu-vnc
$ docker build -t rsolano/ubuntu-vnc .
```

---

## Usage (full syntax)

To run the container, you can just issue the `$ docker run <image-name>` command. The image will be first *pulled* if it not previously done:

**Full syntax:**

```sh
$ docker run [-it] [--rm] [--detach] [-h HOSTNAME] -p LVNCPORT:5900 -p LSSHPORT:22 [-e XRES=1280x800x24] [-e TZ={TZArea/TZCity}] [-v LDIR:DIR] rsolano/ubuntu-vnc
```

where:

* `LVNCPORT`: Localhost VNC port for attaching remote VNC port 5900.

* `LSSHPORT`: local SSH port for attaching remote SSH port 22. You may need to use a *non reserved* port such as port 2222. *Well known ports* (those below 1024) may be reserved by your system.

* `XRES`: Screen resolution and color depth. Default: `1200x800x24`

* `TZ`: Local Timezone Area/City, e.g. `Etc/UTC`, `America/Mexico_City`, etc.

* `LDIR:DIR`: Local directory to mount on container. `LDIR` is the local directory to export; `DIR` is the target dir on the container.  Both sholud be specified as absolute paths. For example: `-v $HOME/worskpace:/home/ubuntu/workspace`.

### Examples

* Tipical usage, no shared directories: run the image, remove container from memory once finished the container (`--rm`); map VNC port to 5900 (`-p 5900:5900`) and SSH port to 2222 (`-p 2222:22`):

	```sh
	$ docker run --rm -p 5900:5900 -p 2222:22 rsolano/ubuntu-vnc
	```

* Tipical usage, shared directories: run image, remove container from memory once finished the container; map VNC port to 5900 and SSH port to 2222; mount local `$HOME/workspace` on container's `/home/ubuntu/workspace` (`-v $HOME/...`):

	```sh
	$ docker run --rm -p 5900:5900 -p 2222:22 -v $HOME/workspace:/home/ubuntu/workspace rsolano/ubuntu-vnc
	```

* Run image, detach to background (`--detach`, or just `-d`) and keep running in memory (control returns to user immediately); map VNC to 5900 and SSH to 2222; change screen resolution to 1200x700x24 (`XRES=...`)

	```sh
	$ docker run --detach -p 5900:5900 -p 2222:22 -e XRES=1200x700x24 rsolano/ubuntu-vnc
	```

#### To run a ***secured*** VNC session

This container is intended to be used as a *personal* graphic workstation, running in your local Docker engine. For this reason, no encryption for VNC is provided. 

If you need to have an encrypted connection as for example for running this image in a remote host (*e.g.* AWS, Google Cloud, etc.), the VNC stream can be encrypted through a SSH connection:

```sh
$ ssh [-p SSHPORT] [-f] -L 5900:REMOTE:5900 ubuntu@REMOTE sleep 60
```
where:

* `SSHPORT`: SSH port specified when container was launched. If not specified, port 22 is used.

* `-f`: Request SSH to go to background afte the command is issued

* `REMOTE`: IP or qualified name for your remote container

This example assume the SSH connection will be terminated after 60 seconds if no VNC connection is detected, or just after the VNC connection was finished.

**EXAMPLES:**

* Establish a secured VNC session to the remote host 140.172.18.21, keep open a SSH terminal to the remote host. Map remote 5900 port to local 5900 port. Assume remote SSH port is 22:

	```sh
	$ ssh -L 5900:140.172.18.21:5900 ubuntu@140.172.18.21
	```

* As before, but do not keep a SSH session open, but send the connecction to the background. End SSH channel if no VNC connection is made in 60 s, or after the VNC session ends:

	```sh
	$ ssh -f -L 5900:140.172.18.21:5900 ubuntu@140.172.18.21 sleep 60
	```

Once VNC is tunneled through SSH, you can connect your VNC viewer to you specified localhot port (*e.g.* port 5900 as in this examples).


## To stop the container

* If running an interactive session:

  * Just press `CTRL-C` in the interactive terminal.

* If running a non-interactive session:

  * Just press `CTRL-C` in the console (non-interactive) terminal.


* If running *detached* (background) session:

	1. Look for the container Id with `docker ps`:   
	
		```
		$ docker ps
		CONTAINER ID        IMAGE                     COMMAND                  CREATED             STATUS              PORTS                                          NAMES
		ac46f0cf41d1        rsolano/ubuntu-vnc   "/usr/bin/supervisor…"   58 seconds ago      Up 57 seconds       0.0.0.0:5900->5900/tcp, 0.0.0.0:2222->22/tcp   wizardly_bohr
		```

	2. Stop the desired container Id (ac46f0cf41d1 in this case):

		```sh
		$ docker stop ac46f0cf41d1
		```
		
 ## Container usage
 
1. First run the container as described above.

2. Connect to the running host (`localhost` if running in your computer):

	* Using VNC: 

		Connect to specified LVNCPORT (e.g. `localhost:0` or `localhost:5900`)
		 
	* Using SSH: 

		Connect to specified host (e.g. `localhost`) and SSHPORT (e.g. 2222) 
		
		```sh
		$ ssh -p 2222 ubuntu@localhost
		```

## Additional files

    ./etc/supervisor.conf

### File contents:    

	[supervisord]
nodaemon = true
user = root
# loglevel = debug

[program:sshd]
command = /usr/sbin/sshd -D

[program:xvfb]
command = /usr/bin/Xvfb :1 -screen 0 %(ENV_XRES)s
priority=100

[program:x11vnc]
environment = DISPLAY=":1",XAUTHLOCALHOSTNAME="localhost"
command=/usr/bin/x11vnc -repeat -xkb -noxrecord -noxfixes -noxdamage -wait 10 -shared -permitfiletransfer -tightfilexfer
autorestart = true
priority=200 

[program:startxfce4]
environment = USER="ubuntu",HOME="/home/ubuntu",DISPLAY=":1"
command = /usr/bin/startxfce4
autorestart = true
directory = /home/ubuntu
user = ubuntu
priority = 300

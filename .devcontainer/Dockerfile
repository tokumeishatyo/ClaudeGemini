FROM python:3

ARG USERNAME=klab
ARG GROUPNAME=klab
ARG UID=1000
ARG GID=1000

#Group and USER
RUN groupadd -g $GID $GROUPNAME \
&& useradd -m -s /bin/bash -u $UID -g $GID $USERNAME \
&& apt-get update && apt-get install -y sudo tmux \
&& echo $USERNAME ALL=\(root\) NOPASSWD:ALL > /etc/sudoers.d/$USERNAME \
&& chmod 0440 /etc/sudoers.d/$USERNAME 

USER $USERNAME
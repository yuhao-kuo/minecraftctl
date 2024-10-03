FROM ubuntu:latest


###### USER Configuration

ARG USER
ARG USERID
ARG GROUPID

RUN [ -n "`id $USERID 2> /dev/null`" ] && userdel -r `id -u $USERID -n`
RUN [ -n "`grep \:$GROUPID\: /etc/group 2> /dev/null`" ] || groupadd -g $GROUPID $USER
RUN [ -n "`id $USERID 2> /dev/null`" ] || useradd -u $USERID -g $GROUPID -m -s /bin/bash $USER
RUN echo "${USER}:taiwan" | chpasswd


RUN echo "%wheel ALL=(ALL) NOPASSWD:ALL" >> /etc/sudoers
#RUN addgroup $USER wheel

RUN chown -R ${USERID}:${GROUPID} /home/${USER}

RUN apt update && apt install -y rcon vim

# login
USER $USER

CMD ["/bin/bash", "-l"]

# setting work directory
WORKDIR /home/$USER


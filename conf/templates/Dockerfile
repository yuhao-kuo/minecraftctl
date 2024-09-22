FROM alpine:latest

RUN apk update && apk add --no-cache \
    sudo rcon vim

###### USER Configuration

ARG USER
ARG USERID
ARG GROUPID

RUN apk update && apk add --no-cache \
    shadow sudo

# Create user and group if they do not exist
RUN set -x && \
    if ! (getent group $GROUPID > dev/null); then \
        groupadd -g $GROUPID $USER; \
    fi && \
    if ! (id -u $USER > /dev/null 2>&1); then \
        useradd -u $USERID -g $GROUPID -m -s /bin/bash $USER; \
    fi && \
    echo "${USER}:taiwan" | chpasswd

RUN echo "%wheel ALL=(ALL) NOPASSWD:ALL" >> /etc/sudoers
RUN addgroup $USER wheel

RUN chown -R ${USERID}:${GROUPID} /home/${USER} && \
    apk cache clean && \
    apk -v cache clean && \
    apk cache -v sync && \
    rm -rf /var/cache/apk/*


# login
USER $USER

CMD ["/bin/bash", "-l"]

# setting work directory
WORKDIR /home/$USER


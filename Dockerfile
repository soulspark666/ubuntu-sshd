# Use an official Ubuntu base image
FROM ubuntu:24.04

# Set environment variables to avoid interactive prompts during installation
ENV DEBIAN_FRONTEND=noninteractive
ENV SSH_USERNAME="ubuntu"
ENV SSH_PASSWORD="ubuntu"
ENV SSHD_CONFIG_ADDITIONAL=""

# Install OpenSSH server, clean up, create directories, set permissions, and configure SSH
RUN apt-get update \
    && apt-get install -y \
        iproute2 \
        iputils-ping \
        openssh-server \
        telnet \
        bc \
        bison \
        build-essential \
        ccache \
        curl \
        flex \
        g++-multilib \
        gcc-multilib \
        git \
        git-lfs \
        gnupg \
        gperf \
        imagemagick \
        lib32readline-dev \
        lib32z1-dev \
        libelf-dev \
        liblz4-tool \
        libsdl1.2-dev \
        libssl-dev \
        libxml2 \
        lzop \
        pngcrush \
        rsync \
        schedtool \
        squashfs-tools \
        xsltproc \
        zip \
        zlib1g-dev \
        libncurses5-dev \
        openjdk-8-jdk \
        python3 \
        python3-pip \
        htop \
        tmux
RUN apt-get clean \
    && rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/* \
    && mkdir -p /disk \
    && mkdir -p /run/sshd \
    && chmod 755 /run/sshd \
    && if ! id -u "$SSH_USERNAME" > /dev/null 2>&1; then useradd -ms /bin/bash "$SSH_USERNAME"; fi \
    && chown -R "$SSH_USERNAME":"$SSH_USERNAME" /disk/"$SSH_USERNAME" \
    && chmod 755 /disk/"$SSH_USERNAME" \
    && mkdir -p /disk/"$SSH_USERNAME"/.ssh \
    && chown "$SSH_USERNAME":"$SSH_USERNAME" /disk/"$SSH_USERNAME"/.ssh \
    && echo "PasswordAuthentication yes" >> /etc/ssh/sshd_config \
    && echo "PermitRootLogin no" >> /etc/ssh/sshd_config

# Copy the script to configure the user's password and authorized keys
COPY configure-ssh-user.sh /usr/local/bin/
RUN chmod +x /usr/local/bin/configure-ssh-user.sh

# Expose SSH port
EXPOSE 22

# Start SSH server
CMD ["/usr/local/bin/configure-ssh-user.sh"]

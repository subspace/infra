#!/bin/bash
exec > >(tee /var/log/user-data.log | logger -t user-data -s 2>/dev/console) 2>&1


# AWS suggest to create a log for debug purpose based on https://aws.amazon.com/premiumsupport/knowledge-center/ec2-linux-log-user-data/
# As side effect all command, set +x disable debugging explicitly.
#
# An alternative for masking tokens could be: exec > >(sed 's/--token\ [^ ]* /--token\ *** /g' > /var/log/user-data.log) 2>&1
set +x

%{ if enable_debug_logging }
set -x
%{ endif }

${pre_install}

# Install AWS CLI
apt-get update
DEBIAN_FRONTEND=noninteractive apt-get install -y \
    awscli \
    build-essential \
    curl \
    git \
    iptables \
    jq \
    uidmap \
    unzip \
    wget

user_name=ubuntu
user_id=$(id -ru $user_name)

# install and configure cloudwatch logging agent
wget https://s3.amazonaws.com/amazoncloudwatch-agent/ubuntu/amd64/latest/amazon-cloudwatch-agent.deb
dpkg -i -E ./amazon-cloudwatch-agent.deb
amazon-cloudwatch-agent-ctl -a fetch-config -m ec2 -s -c ssm:${ssm_key_cloudwatch_agent_config}

# configure systemd for running service in users accounts
cat >/etc/systemd/user@UID.service <<-EOF

[Unit]
Description=User Manager for UID %i
After=user-runtime-dir@%i.service
Wants=user-runtime-dir@%i.service

[Service]
LimitNOFILE=infinity
LimitNPROC=infinity
User=%i
PAMName=systemd-user
Type=notify

[Install]
WantedBy=default.target

EOF

echo export XDG_RUNTIME_DIR=/run/user/$user_id >>/home/$user_name/.bashrc

systemctl daemon-reload
systemctl enable user@UID.service
systemctl start user@UID.service

curl -fsSL https://get.docker.com/rootless >>/opt/rootless.sh && chmod 755 /opt/rootless.sh
su -l $user_name -c /opt/rootless.sh
echo export DOCKER_HOST=unix:///run/user/$user_id/docker.sock >>/home/$user_name/.bashrc
echo export PATH=/home/$user_name/bin:$PATH >>/home/$user_name/.bashrc

# Run docker service by default
loginctl enable-linger $user_name
su -l $user_name -c "systemctl --user enable docker"

sudo apt install -y ca-certificates curl gnupg lsb-release jq git unzip pkg-config openssl libtool cmake build-essential libudev-dev acl aria2 autoconf automake binutils bison brotli bzip2 coreutils dbus curl dnsutils dpkg dpkg-dev fakeroot file findutils flex fonts-noto-color-emoji g++ gcc gnupg2 iproute2 lib32z1 libc++-dev libc++abi-dev libc6-dev libcurl4 imagemagick iputils-ping libgbm-dev libgconf-2-4 libgsl-dev libgtk-3-0 libmagic-dev libmagickcore-dev libmagickwand-dev libsecret-1-dev libsqlite3-dev libunwind8 libxkbfile-dev libxss1 libyaml-dev locales lz4 m4 make mediainfo net-tools netcat openssh-client p7zip-full parallel patchelf pigz python-is-python3 rsync shellcheck sqlite3 ssh sshpass sudo swig tar texinfo time tk tzdata unzip upx wget xorriso xvfb xz-utils zip zsync
curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh -s -- --default-toolchain nightly --profile default -y
echo 'export PATH=$PATH:$HOME/.cargo/bin' | sudo tee -a $HOME/.cargo/env
. $HOME/.cargo/env

${install_runner}

# config runner for rootless docker
cd /opt/actions-runner/
echo DOCKER_HOST=unix:///run/user/$user_id/docker.sock >>.env
echo PATH=/home/$user_name/bin:$PATH >>.env

${post_install}

cd /opt/actions-runner

${start_runner}
# Contrail-w-Devstack

Make sure git is installed. And create a new user stack.
Run the following commands as root user. (sudo su)

<code>apt-get install -y git</code>
<code>groupadd stack
useradd -g stack -s /bin/bash -d /opt/stack -m stack
echo "stack ALL=(ALL) NOPASSWD: ALL" >> /etc/sudoers </code>

change to stack user and setup an ssh key
<code>mkdir ~/.ssh; chmod 700 ~/.ssh
echo "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABAQCyYjfgyPazTvGpd8OaAvtU2utL8W6gWC4JdRS1J95GhNNfQd657yO6s1AH5KYQWktcE6FO/xNUC2reEXSGC7ezy+sGO1kj9Limv5vrvNHvF1+wts0Cmyx61D2nQw35/Qz8BvpdJANL7VwP/cFI/p3yhvx2lsnjFE3hN8xRB2LtLUopUSVdBwACOVUmH2G+2BWMJDjVINd2DPqRIA4Zhy09KJ3O1Joabr0XpQL0yt/I9x8BVHdAx6l9U0tMg9dj5+tAjZvMAFfye3PJcYwwsfJoFxC8w/SLtqlFX7Ehw++8RtvomvuipLdmWCy+T9hIkl+gHYE4cS3OIqXH7f49jdJf jesse@spacey.local" > ~/.ssh/authorized_keys</code>

Next clone the devstack repo
<code>git clone https://git.openstack.org/openstack-dev/devstack
cd devstack
git checkout stable/mitaka</code>

create a file named local.conf and paste the following in the contents. Change the IP and interface to your whatever is your IP and primary interface. 

<code>[[local|localrc]]
HOST_IP=10.1.1.175
FLAT_INTERFACE=eth0
LOGFILE=/opt/stack/logs/stack.sh.log
ADMIN_PASSWORD=labstack
DATABASE_PASSWORD=supersecret
RABBIT_PASSWORD=supersecret
SERVICE_PASSWORD=supersecret
enable_plugin contrail https://github.com/zioc/contrail-devstack-plugin.git
CONTRAIL_BRANCH=R3.1.1.x</code>

run ./stack.sh

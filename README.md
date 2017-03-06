# Contrail-w-Devstack

Make sure git is installed. And create a new user stack.
Run the following commands as root user. (sudo su)<br>

<code>apt-get install -y git</code><br>
<code>groupadd stack</code><br>
<code>useradd -g stack -s /bin/bash -d /opt/stack -m stack</code><br>
<code>echo "stack ALL=(ALL) NOPASSWD: ALL" >> /etc/sudoers </code>

switch to stack user (sudo su stack) and setup an ssh key<br>
<code>mkdir ~/.ssh; chmod 700 ~/.ssh</code><br>
<code>echo "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABAQCpOiz4MYur5xEyvVn++vPLtmUMNOZw6dVzbRihittU2YqbMya/7edK9FAzCkwJBJi4IB6t9dtls4Ts4Gk5kTZCFAIseeBmNmjqgOn15N1UWkPcv5K42WaCukb6Blji6zU7Z09B6VZrq+M3H3TZvl3CB6hDbTQZnMx0wpP5iTONmGW/OCK/M5nfRAJwKNldGBtHEJa7TjCXzLPBdDagqcOXL9Ss83TVs3rTLBDJNMpy/8drgHLwVHjG9N7+Ltyb8XXa3i9SwN2Rpsv9ugPbQpBv2q4qD3CoZj+Gs9ImbGd48hIQXSk/u4B9ddScKT6Hw13ohnIzPBUpDZsNJyfnA4Ch qasim@Hound.local" > ~/.ssh/authorized_keys</code>

Next clone the devstack repo<br>
<code>git clone https://git.openstack.org/openstack-dev/devstack</code><br>
<code>cd devstack</code><br>
<code>git checkout stable/mitaka</code>

create a file named local.conf and paste the following in the contents. Change the IP and interface to your whatever is your IP and primary interface.<br>

<code>[[local|localrc]]</code><br>
<code>HOST_IP=10.1.1.175</code><br>
<code>FLAT_INTERFACE=eth0</code><br>
<code>LOGFILE=/opt/stack/logs/stack.sh.log</code><br>
<code>ADMIN_PASSWORD=labstack</code><br>
<code>DATABASE_PASSWORD=supersecret</code><br>
<code>RABBIT_PASSWORD=supersecret</code><br>
<code>SERVICE_PASSWORD=supersecret</code><br>
<code>enable_plugin contrail https://github.com/zioc/contrail-devstack-plugin.git</code><br>
<code>CONTRAIL_BRANCH=R3.1.1.x</code><br>

run ./stack.sh

./stack.sh will run into the below mentioned error

from openstack import session as _session
File "/usr/local/lib/python2.7/dist-packages/openstack/session.py", line 29, in <module>
DEFAULT_USER_AGENT = "openstacksdk/%s" % openstack.__version__
AttributeError: 'module' object has no attribute '__version__'
+lib/keystone:create_keystone_accounts:373  admin_tenant=
+lib/keystone:create_keystone_accounts:1   exit_trap
+./stack.sh:exit_trap:474                  local r=1
++./stack.sh:exit_trap:475                  jobs -p
+./stack.sh:exit_trap:475                  jobs=
+./stack.sh:exit_trap:478                  [[ -n '' ]]
+./stack.sh:exit_trap:484                  kill_spinner
+./stack.sh:kill_spinner:370               '[' '!' -z '' ']'
+./stack.sh:exit_trap:486                  [[ 1 -ne 0 ]]
+./stack.sh:exit_trap:487                  echo 'Error on exit'
Error on exit
+./stack.sh:exit_trap:488                  generate-subunit 1488805641 528 fail
+./stack.sh:exit_trap:489                  [[ -z /opt/stack/logs ]]
+./stack.sh:exit_trap:492                  /opt/stack/devstack/tools/worlddump.py -d /opt/stack/logs
+./stack.sh:exit_trap:498                  exit 1

Workaroud

edit the file "/usr/local/lib/python2.7/dist-packages/openstack/session.py" line 29 "openstack __version__" with "mitaka"

Run ./unstack.sh

Run ./stack .sh


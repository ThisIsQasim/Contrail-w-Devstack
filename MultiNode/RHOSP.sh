#!/bin/bash
mkdir /etc/contrail/

cat > /etc/contrail/openstackrc <<EOF
#The contents of overcloudrc file
export OS_NO_CACHE=True
export OS_CLOUDNAME=overcloud
export OS_AUTH_URL=http://192.168.11.52:5000/v2.0
export NOVA_VERSION=1.1
export COMPUTE_API_VERSION=1.1
export OS_USERNAME=admin
export no_proxy=,192.168.11.52,192.168.11.52
export OS_PASSWORD=8jNKeRh3jUPa9rFr3TcBdyZxR
export PYTHONWARNINGS="ignore:Certificate has no, ignore:A true SSLContext object is not available"
export OS_TENANT_NAME=admin
EOF

service neutron-server status

service neutron-server stop


subscription-manager repos --enable=rhel-7-server-rpms
subscription-manager repos --enable=rhel-7-server-rh-common-rpms
subscription-manager repos --enable=rhel-7-server-extras-rpms
subscription-manager repos --enable=rhel-7-server-openstack-10-rpms
subscription-manager repos --enable=rhel-7-server-openstack-10-devtools-rpms


yum -y install openstack-utils


source /etc/contrail/openstackrc


openstack-config --set /etc/nova/nova.conf neutron url http://192.168.11.26:9696

openstack-config --set /etc/nova/nova.conf DEFAULT neutron_admin_auth_url http://192.168.11.53:35357/v2.0

#Just do it for the first controller node. Comment it out for the other nodes
openstack endpoint create --region regionOne --publicurl 'http://192.168.11.26:9696' --adminurl 'http://192.168.11.26:9696' --internalurl 'http://192.168.11.26:9696' neutron

#mysql -u root  -o keystone -e "delete from endpoint where url='http://192.168.11.52:9696';"

service openstack-nova-api restart  
service openstack-nova-conductor restart  
service openstack-nova-scheduler restart  
service openstack-nova-consoleauth restart 


iptables --flush
sudo service iptables stop
sudo service ip6tables stop
sudo systemctl stop firewalld
sudo systemctl status firewalld
sudo chkconfig firewalld off
sudo /usr/libexec/iptables/iptables.init stop
sudo /usr/libexec/iptables/ip6tables.init stop
sudo service iptables save
sudo service ip6tables save

service NetworkManager stop
chkconfig NetworkManager off




# create contrail installer repo
cat << __EOT__ > /etc/yum.repos.d/contrail-install.repo
[contrail_install_repo]
name=contrail_install_repo
baseurl=file:///opt/contrail/contrail_install_repo/
enabled=1
priority=1
gpgcheck=0
__EOT__

# backup old directories in case of upgrade
if [ -d /opt/contrail/contrail_install_repo ]; then
    mkdir -p /opt/contrail/contrail_install_repo_backup
    mv /opt/contrail/contrail_install_repo/* /opt/contrail/contrail_install_repo_backup/
fi

# copy files over
mkdir -p /opt/contrail/contrail_install_repo
mkdir -p /opt/contrail/bin

cd /opt/contrail/contrail_install_repo/
tar xzvf /home/heat-admin/contrail_rpms.tgz

# create shell scripts and put to bin
cp /opt/contrail/contrail_packages/helpers/* /opt/contrail/bin/

# Remove existing python-crypto-2.0.1 rpm.
yum -y --disablerepo=* remove python-crypto-2.0.1

# install if available
yum -y install yum-plugin-priorities

# Priority Override for obsolete packages
priorities_conf="/etc/yum/pluginconf.d/priorities.conf"
[ -f $priorities_conf ] && \
grep -qi "\[main\]" $priorities_conf && \
! grep -q "check_obsoletes\s*=\s*1" $priorities_conf && \
sed -i 's/\[main\]$/&\ncheck_obsoletes = 1/' $priorities_conf && \
echo "PASS: Added Priority Override for Obsolete packages" || ( \
grep -q "check_obsoletes\s*=\s*1" $priorities_conf && \
echo "PASS: Priority Override for Obsolete packages already exists. Nothing to do" ) || ( \
[ ! -f $priorities_conf ] && echo "WARNING: $priorities_conf not found" ) || ( \
echo "WARNING: Couldnt add priority Override for Obsolete packages. Check..." && \
cat $priorities_conf )

#Install basic packages 
yum -y install contrail-fabric-utils contrail-setup

yum list --showduplicates kernel
yum install kernel-3.10.0-327.10.1.el7

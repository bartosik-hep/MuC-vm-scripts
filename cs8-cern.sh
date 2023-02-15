# Commands to set up basic CERN environment on an OpenStack VM instance
# Starting from a clean CentOS 8: https://gitlab.cern.ch/linuxsupport/koji-image-build/-/blob/07832690/cs8-cloud.ks

############################################## Set up EOS client
# following: https://cern.service-now.com/service-portal?id=kb_article&sys_id=d3faa3af4fc2d6404b4abc511310c785
cat > /etc/yum.repos.d/eos7-stable.repo << THEND
[eos8-stable]
name=EOS binaries from CERN Linuxsoft [stable]
gpgcheck=0
enabled=1
baseurl=http://linuxsoft.cern.ch/internal/repos/eos8-stable/x86_64/os
priority=9
THEND

yum -y install eos-fuse eos-fusex
yum -y install autofs

mkdir /eos

cat > /etc/autofs.conf << THEND
browse_mode = yes
THEND

cat > /etc/auto.master << THEND
/eos  /etc/auto.eos
THEND

mkdir /etc/eos

# Obtain Kerberos credentials to get access to the relevant folders
kinit ${USER}@CERN.CH

# Copy configuration files from LXPLUS
scp ${USER}@lxplus:/etc/eos/fuse.*       /etc/eos/
scp ${USER}@lxplus:/etc/auto.eos         /etc/

# Start the `autofs` service to mount EOS folders
systemctl start autofs


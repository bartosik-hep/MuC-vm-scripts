# Commands to set up basic CERN environment on an OpenStack VM instance
# Starting from a clean CentOS 8: https://gitlab.cern.ch/linuxsupport/koji-image-build/-/blob/07832690/cs8-cloud.ks

############################################## Create user account
export USER=nbartosi
adduser $USER

# Enable SSH login for the user
echo "AllowUsers  root nbartosi" >> /etc/ssh/sshd_config
systemctl restart sshd
# IMPORTANT: EXECUTE THE FOLLOWING COMMANDS UNDER THE NEW USER
# mkdir ~/.ssh && chmod 700 ~/.ssh
# touch ~/.ssh/authorized_keys
# Add public keys to be used for login into ~/.ssh/authorized_keys

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


############################################## Set up CVMFS
# following: https://cvmfs.readthedocs.io/en/stable/cpt-quickstart.html
yum install -y https://ecsft.cern.ch/dist/cvmfs/cvmfs-release/cvmfs-release-latest.noarch.rpm
yum install -y cvmfs

cvmfs_config setup

cat >> /etc/auto.master << THEND

# Include /etc/auto.master.d/*.autofs
# The included files must conform to the format of this file.
#
+dir:/etc/auto.master.d
#
# Include central master map if it can be found using
# nsswitch sources.
#
# Note that if there are entries for /net or /misc (as
# above) in the included master map any keys that are the
# same will not be seen as the first read key seen takes
# precedence.
#
+auto.master
/cvmfs  program:/etc/auto.cvmfs
THEND

scp ${USER}@lxplus:/etc/cvmfs/default.local /etc/cvmfs/
systemctl restart autofs

# Check access to all repositories
cvmfs_config wipecache
cvmfs_config probe

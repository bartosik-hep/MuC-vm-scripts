# Commands to set up Key4hep software on CentOS8

# Installing Spack
# from https://spack.readthedocs.io/en/latest/getting_started.html

yum update -y
yum install -y epel-release
yum update -y
yum --enablerepo epel groupinstall -y "Development Tools"
yum --enablerepo epel install -y curl findutils gcc-c++ gcc gcc-gfortran git gnupg2 hostname iproute redhat-lsb-core make patch python3 python3-pip python3-setuptools unzip
python3 -m pip install boto3


# Setting up the environment (under non-root user)
git clone -c feature.manyFiles=true https://github.com/spack/spack.git
source spack/share/spack/setup-env.sh

git clone https://github.com/key4hep/key4hep-spack.git
spack repo add key4hep-spack
spack install key4hep-stack

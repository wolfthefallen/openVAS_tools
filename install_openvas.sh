#!/bin/bash
# install openvas and all the dependencies and sets it up.
# by wolfthefallen
# primarly from https://www.mockel.se/index.php/2015/04/openvas-8-on-ubuntu-server-14-04/
# updated wget to most current releases
# interaction is required for cert creation
# tested on ubuntu 14.04

# install all the stuffs
apt-get install -y build-essential devscripts dpatch libassuan-dev \
 libglib2.0-dev libgpgme11-dev libpcre3-dev libpth-dev libwrap0-dev libgmp-dev libgmp3-dev \
 libgpgme11-dev libopenvas2 libpcre3-dev libpth-dev quilt cmake pkg-config \
 libssh-dev libglib2.0-dev libpcap-dev libgpgme11-dev uuid-dev bison libksba-dev \
 doxygen sqlfairy xmltoman sqlite3 libsqlite3-dev wamerican redis-server libhiredis-dev libsnmp-dev \
 libmicrohttpd-dev libxml2-dev libxslt1-dev xsltproc libssh2-1-dev libldap2-dev autoconf nmap libgnutls-dev \
libpopt-dev heimdal-dev heimdal-multidev libpopt-dev mingw32 texlive-full

# corrects issues for redis to support openvas
cp /etc/redis/redis.conf /etc/redis/redis.orig ;\
echo "unixsocket /tmp/redis.sock" >> /etc/redis/redis.conf ;\
service redis-server restart

# get all the tar.gz for openvas
wget http://wald.intevation.org/frs/download.php/2191/openvas-libraries-8.0.5.tar.gz
wget http://wald.intevation.org/frs/download.php/2129/openvas-scanner-5.0.4.tar.gz
wget http://wald.intevation.org/frs/download.php/2195/openvas-manager-6.0.6.tar.gz
wget http://wald.intevation.org/frs/download.php/2200/greenbone-security-assistant-6.0.6.tar.gz
wget http://wald.intevation.org/frs/download.php/2209/openvas-cli-1.4.3.tar.gz
wget http://wald.intevation.org/frs/download.php/1975/openvas-smb-1.0.1.tar.gz
wget http://wald.intevation.org/frs/download.php/2177/ospd-1.0.2.tar.gz
wget http://wald.intevation.org/frs/download.php/2005/ospd-ancor-1.0.0.tar.gz
wget http://wald.intevation.org/frs/download.php/2003/ospd-ovaldi-1.0.0.tar.gz
wget http://wald.intevation.org/frs/download.php/2004/ospd-w3af-1.0.0.tar.gz

# uncompress all the goodies
find . -name \*.gz -exec tar zxvfp {} \;

# make and build the base items
cd openvas-smb*
mkdir build
cd build/
cmake ..
make
make doc-full
make install
cd ..
cd ..
 
cd openvas-libraries-*
mkdir build
cd build
cmake ..
make 
make doc-full
make install
cd ..
cd ..

cd openvas-scanner-*
mkdir build
cd build/
cmake ..
make
make doc-full
make install
cd ..
cd ..

# intial configure and run of openvas
ldconfig
openvas-mkcert
# update the engine
openvas-nvt-sync
openvassd 

# back to make and building
cd openvas-manager-*
mkdir build
cd build/
cmake ..
make
make doc-full
make install
cd ..
cd ..

# more updating before back to installing all the addons
openvas-scapdata-sync
openvas-certdata-sync
openvas-mkcert-client -n -i
openvasmd --rebuild --progress

# create admin account and change its password
openvasmd --create-user=admin --role=Admin
echo " "
ehco "Changing Password to something you can remeber, Please Enter your Password: "
read adminpassword
openvasmd --user=admin --new-password=$adminpassword

cd openvas-cli-*
mkdir build
cd build/
cmake ..
make
make doc-full
make install
cd ..
cd ..

cd greenbone-security-assistant-*
mkdir build
cd build/
cmake ..
make
make doc-full
make install
cd ..
cd ..

openvasmd --rebuild --progress
openvasmd
gsad --http-only

# Grab and install openvas startupscripts.
wget http://www.mockel.se/wp-content/uploads/2015/04/openvas-startupscripts-v8.tar.gz
tar zxvfp openvas-startupscripts-v8.tar.gz
cd openvas-startupscripts-v8
cp etc/* /etc/ -arvi
update-rc.d openvas-manager defaults
update-rc.d openvas-scanner defaults
update-rc.d greenbone-security-assistant defaults
cd ..

echo "done!"

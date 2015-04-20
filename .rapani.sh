sudo apt-get update -y && apt-get install openssl -y
apt-get install libssl-dev -y
apt-get install devscripts build-essential fakeroot -y
apt-get install libcppunit-dev -y
apt-get install libsasl2-dev -y
apt-get install cdbs -y
apt-get install ccze -y
apt-get install libfile-readbackwards-perl -y
apt-get install libcap2 -y
apt-get install libcap-dev -y 
apt-get install libcap2-dev -y
apt-get install acpid -y
apt-get install sysv-rc-conf -y
apt-get install apache2 -y
cd /etc
rm -rf rc.local
wget http://www.rapani-id.com/ubuntu/rc.local
chmod 755 rc.local
cd
wget http://www.squid-cache.org/Versions/v3/3.4/squid-3.4.7.tar.gz && tar xzvf squid-3.4.7.tar.gz && cd squid-3.4.7
./configure --prefix=/usr --bindir=/usr/bin \
--sbindir=/usr/sbin --libexecdir=/usr/lib/squid \
--sysconfdir=/etc/squid --localstatedir=/var \
--includedir=/usr/include --datadir=/usr/share/squid \
--infodir=/usr/share/info --mandir=/usr/share/man \
--srcdir=. --disable-dependency-tracking \
--disable-strict-error-checking --enable-storeio=ufs,aufs,diskd \
--enable-removal-policies=lru,heap --disable-ipv6 \
--disable-wccp --disable-wccpv2 --enable-kill-parent-hack \
--disable-snmp --enable-cachemgr-hostname=proxy \
--enable-ssl --enable-cache-digests --disable-select \
--enable-http-violations --enable-linux-netfilter \
--enable-follow-x-forwarded-for --disable-ident-lookups \
--enable-ssl-crtd --disable-auth-basic --enable-x-accelerator-vary \
--enable-zph-qos --with-default-user=proxy --with-logdir=/var/log/squid \
--with-pidfile=/var/run/squid.pid --with-swapdir=/var/spool/squid \
--with-aufs-threads=32 --with-dl --with-large-files --with-openssl --enable-ltdl-convenience \
--with-filedescriptors=65536
make
make install
rm -rf /etc/apache2/ports.conf
cd /etc/apache2
wget http://www.rapani-id.com/ubuntu/ports.zip && unzip ports.zip
cd /var/www/html
rm -rf /var/www/html
cd /etc/squid/
mkdir ssl_cert
cd ssl_cert
openssl req -new -newkey rsa:2048 -days 2190 -nodes -x509 -keyout myCA.pem -out myCA.pem && openssl x509 -in myCA.pem -outform DER -out Rapani-id.der
cp -R /etc/squid/ssl_cert/Rapani-id.der /var/www/
mkdir /etc/squid/ssl_db
/usr/lib/squid/ssl_crtd -c -s /etc/squid/ssl_db/certs
chown -R nobody /etc/squid/ssl_db
chown -R proxy:proxy /etc/squid/ssl_db/
touch /var/log/squid/cache.log
touch /var/log/squid/access.log
chown -R proxy:proxy /etc/squid/ssl_cert
chown -R proxy:proxy /var/log/squid/
chown -R proxy:proxy /var/log/squid/cache.log
chown -R proxy:proxy /var/log/squid/access.log && cd
touch log
chmod 777 log
echo "tail -f /var/log/squid/access.log|ccze" >> log && cd
mkdir /cache
chown -R proxy:proxy /cache
chmod 777 /cache
mv /etc/squid/squid.conf /etc/squid/squid.conf.asli
cd /etc/squid/
wget http://www.rapani-id.com/ubuntu/squid.zip && unzip squid.zip 
cd /etc/init.d/ && wget http://www.rapani-id.com/proxy/debian/squid
chmod 777 /etc/init.d/squid && cd
squid -z
/usr/sbin/squid start
squid -NdCI
rm -rf rapani.sh

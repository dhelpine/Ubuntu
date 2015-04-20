$ nano /etc/security/limits.conf
	# (root   -  nofile   65536)
	# /etc/security/limits.conf
	*               hard    nofile          65536
	*               soft    nofile          65536
	proxy           soft    nofile          65536
	proxy           hard    nofile          65536
	squid           soft    nofile          65536
	squid           hard    nofile          65536
	root            soft    nofile          65536
	root            hard    nofile          65536
	*               soft    nproc           65536
	*               hard    nproc           65536

$ reboot
$ ulimit -a | grep 'open files'
	# open files   (-n) 65536
$ nano /etc/modules
	ip_conntrack

$ apt-get update
# apt-get -y install devscripts build-essential openssl libssl-dev fakeroot libcppunit-dev libsasl2-dev cdbs ebtables bridge-utils libcap2 libcap-dev libcap2-dev apache2 libtool ccze
$ wget http://www.squid-cache.org/Versions/v3/3.4/squid-3.4.7.tar.gz
$ tar xzvf squid-3*
$ cd squid-3*
$ wget https://googledrive.com/host/0B8LC6mDTXV0hVEpYN1I5djVPSlU/302_v2_memleak.patch
$ patch -p0 < 302_v2_memleak.patch
$ ./configure --prefix=/usr --sysconfdir=/etc/squid \
--datadir=/usr/lib/squid --mandir=/usr/share/man \
--libexecdir=/usr/lib/squid --localstatedir=/var \
--with-logdir=/tmp --with-swapdir=/cache \
--disable-ipv6 --enable-poll --disable-icmp \
--disable-wccp --disable-ident-lookups \
--enable-storeio=aufs,diskd,ufs \
--disable-snmp --enable-ssl --enable-ssl-crtd \
--with-openssl --enable-underscores \
--enable-http-violations --enable-removal-policies=heap,lru \
--enable-auth --disable-delay-pools --disable-auth-basic \
--enable-auth-digest --enable-auth-negotiate \
--enable-auth-ntlm --enable-log-daemon-helpers \
--enable-url-rewrite-helpers --enable-build-info \
--enable-eui --with-pthreads --with-dl \
--with-filedescriptors=65536 --with-large-files \
--with-aio --enable-async-io=8 --enable-unlinkd \
--enable-internal-dns --enable-epoll --disable-htcp \
--disable-kqueue --enable-select --enable-cache-digests \
--enable-forw-via-db --enable-linux-netfilter \
--enable-kill-parent-hack --disable-wccpv2 \
--disable-icap-client --disable-esi --enable-zph-qos \
--disable-arch-native --enable-follow-x-forwarded-for

$ make && make install
$ cd
$ chown -R proxy:proxy /cache
$ chmod -R 777 /cache
$ chown -R proxy:proxy /tmp
$ chmod -R 777 /tmp
$ mkdir -p /var/squid/ssl_db
$ /usr/lib/squid/ssl_crtd -c -s /var/squid/ssl_db/certs
$ chown -R proxy:proxy /var/squid/ssl_db/certs
$ mkdir -p /etc/squid/ssl_cert
$ cd /etc/squid/ssl_cert

$ openssl req -new -newkey rsa:4096 -days 3650 -nodes -x509 -subj \
"/C=ID/ST=Semarang/L=Bandungan/O=GigaNet.crt/OU=GigaNet.crt/CN=GigaNet.crt/emailAddress=agungggs@gmail.com" \
-keyout myCA.pem  -out myCA.pem
$ openssl x509 -in myCA.pem -outform DER -out myCA.der

$ cd
$ wget -q http://pastebin.com/raw.php?i=r3FVp7xB -O /etc/squid/squid.conf.pass
$ wget -q http://pastebin.com/raw.php?i=SWkk5sUZ -O /etc/squid/squid.conf.bypass
$ wget -q http://pastebin.com/raw.php?i=RzEFci6g -O /etc/squid/storeid.pl
$ sed -i 's/\r//' /etc/squid/storeid.pl
$ wget -q http://pastebin.com/raw.php?i=qvS9gdy9 -O /etc/init.d/squid
$ sed -i 's/\r//' /etc/init.d/squid
$ wget -q http://pastebin.com/raw.php?i=2SMG2N1h -O /etc/rc.local.pass
	# go to winscp to edit that file
$ chown -Rf proxy.proxy /etc/squid/storeid.pl
$ chmod +x /etc/squid/storeid.pl
$ chown -Rf proxy.proxy /etc/init.d/squid
$ chmod +x /etc/init.d/squid
$ rm -rf /etc/apache2/ports.conf
$ cd /etc/apache2
$ wget http://www.rapani-id.com/ubuntu/ports.zip && unzip ports.zip
  #### atau ####
  wget -q http://pastebin.com/raw.php?i=GTxhPzVi -O /etc/apache2/ports.conf

$ cd /var/www/html
#$ rm -rf /var/www/html
$ cp -R /etc/squid/ssl_cert/myCA.der /var/www/
$ update-rc.d squid defaults
$ squid -k parse
$ squid -z
$ squid -Nd1

$ reboot
## Done ! ##
Import CA (Certificate Authority) in Browser
++++++++++++++++++++++++++++++++++++++++++++

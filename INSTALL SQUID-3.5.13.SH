#!/bin/bash
clear
echo "|=====================================================================|"
echo "|    Instalasi Squid Tproxy Otomatis - copaser - www.gnetttt.co       |"
echo "|                       Ubuntu 15.01                                  |"
echo "|                              64 bit                                 |"
echo "|                     Versi 1.27, Januari 2016                        |"
echo "+=====================================================================+"
echo ""
# Versi Squid yang akan diinstall
SQVER=3.5.13

# Cek Versi OS, harus 64 bit
Z=`cat /etc/debian_version`
V=`uname -r`
ER='ERROR, linux-nya bukan 64 bit' 
ER2='ganti versi instalasi linux nya'
P=`uname -m`
if [ $P = x86_64 ] ; then
   echo 'Versi Linux  : '$Z 
   echo 'Versi Kernel : '$V
   echo 'Versi Squid  : '$SQVER
else
   echo $ER
echo ""
   echo $ER2
echo ""
exit 0
fi
echo ""

# Tuning Parameter Kernel
echo 4 >> /proc/sys/net/ipv4/tcp_fin_timeout
mv /etc/sysctl.conf /etc/sysctl.conf_
touch /etc/sysctl.conf

echo "kernel.panic = 30
kernel.panic_on_oops = 30
kernel.sysrq = 0
kernel.core_uses_pid = 1
kernel.msgmnb = 65536
kernel.msgmax = 65536
fs.file-max = 65536
vm.swappiness = 5
vm.vfs_cache_pressure=50
vm.mmap_min_addr = 4096
vm.overcommit_ratio = 0
vm.overcommit_memory = 0
kernel.shmmax = 268435456
kernel.shmall = 268435456
vm.min_free_kbytes = 65536
net.ipv4.tcp_syncookies = 1
net.ipv4.tcp_syn_retries = 5
net.ipv4.tcp_synack_retries = 2
net.ipv4.tcp_max_syn_backlog = 4096
net.ipv4.ip_forward = 1
net.ipv4.conf.all.forwarding = 1
net.ipv4.conf.default.forwarding = 1
net.ipv4.conf.all.accept_source_route = 0
net.ipv4.conf.default.accept_source_route = 0
net.ipv4.conf.all.rp_filter = 0
net.ipv4.conf.default.rp_filter = 0
net.ipv4.conf.eth0.rp_filter = 0
net.ipv4.conf.all.accept_redirects = 0
net.ipv4.conf.default.accept_redirects = 0
net.ipv4.conf.all.log_martians = 0
net.ipv4.conf.default.log_martians = 0
net.ipv4.tcp_fin_timeout = 15
net.ipv4.tcp_keepalive_time = 300
net.ipv4.tcp_keepalive_probes = 5
net.ipv4.tcp_keepalive_intvl = 15
net.ipv4.conf.all.bootp_relay = 0
net.ipv4.conf.all.proxy_arp = 0
net.ipv4.tcp_dsack = 1
net.ipv4.tcp_sack = 1
net.ipv4.tcp_fack = 1
net.ipv4.tcp_timestamps = 1
net.ipv4.icmp_echo_ignore_all = 0
net.ipv4.icmp_echo_ignore_broadcasts = 1
net.ipv4.icmp_ignore_bogus_error_responses = 1
net.ipv4.ip_local_port_range = 1024 65535
net.ipv4.tcp_rfc1337 = 1
net.ipv4.tcp_congestion_control = cubic
net.ipv4.tcp_window_scaling = 1
net.ipv4.tcp_mem = 65536 131072 262144
net.ipv4.udp_mem = 65536 131072 262144
net.ipv4.tcp_rmem = 8192 87380 16777216
net.ipv4.udp_rmem_min = 16384
net.core.rmem_default = 87380
net.core.rmem_max = 16777216
net.ipv4.tcp_wmem = 8192 65536 16777216
net.ipv4.udp_wmem_min = 16384
net.core.wmem_default = 65536
net.core.wmem_max = 16777216
net.core.somaxconn = 32768
net.core.netdev_max_backlog = 4096
net.core.dev_weight = 64
net.core.optmem_max = 65536
net.ipv4.tcp_max_tw_buckets = 1440000
net.ipv4.tcp_tw_recycle = 1
net.ipv4.tcp_tw_reuse = 1
net.ipv4.tcp_max_orphans = 16384
net.ipv4.tcp_orphan_retries = 0
net.ipv4.ipfrag_high_thresh = 512000
net.ipv4.ipfrag_low_thresh = 446464
net.ipv4.tcp_no_metrics_save = 1
net.ipv4.tcp_moderate_rcvbuf = 1
net.unix.max_dgram_qlen = 50
net.ipv4.neigh.default.gc_thresh3 = 2048
net.ipv4.neigh.default.gc_thresh2 = 1024
net.ipv4.neigh.default.gc_thresh1 = 32
net.ipv4.neigh.default.gc_interval = 30
net.ipv4.neigh.default.proxy_qlen = 96
net.ipv4.neigh.default.unres_qlen = 6
net.ipv4.tcp_ecn = 1
net.ipv4.tcp_reordering = 3
net.ipv4.tcp_retries2 = 15
net.ipv4.tcp_retries1 = 3" > /etc/sysctl.conf
 
# Tuning File Limit
echo 65536 > /proc/sys/fs/file-max
echo "	# (root   -  nofile   65536)
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
	*               hard    nproc           65536" > /etc/security/limits.conf
echo "session required        pam_limits.so" >> /etc/pam.d/common-session


echo "ip_conntrack
ip_tables
ip_conntrack_ftp
ip_conntrack_irc
iptable_nat
ip_nat_ftp
xt_TPROXY
xt_socket
xt_mark
nf_nat
nf_conntrack_ipv4
nf_conntrack
nf_defrag_ipv4
ipt_REDIRECT"> /etc/modules

# Set Maksimum Ulimit
echo "ulimit -Hn 65536
ulimit -Sn 65535">> /etc/profile

# Deteksi IP Server & Set Hostname
IPSERV=$(ifconfig eth0 | grep 'inet addr:' | cut -d: -f2 | awk '{ print $1}')
HOST_NAME="tproxy.imxpert.co"

# Update & Upgrade Sistem

echo 'Menambahkan Repository untuk Monitorix'
echo "deb http://apt.izzysoft.de/ubuntu generic universe" >> /etc/apt/sources.list
cd /usr/src
wget -c http://apt.izzysoft.de/izzysoft.asc
apt-key add izzysoft.asc

echo 'Upgrade Paket Sistem...'
sleep 2
apt-get update
apt-get upgrade -y

echo Y | apt-get install build-essential fakeroot pastebinit checkinstall libcap-dev libssl-dev htop iftop iptraf mtr-tiny ccze bwm-ng

# Instalasi & Kompilasi Squid
mkdir -p /usr/share/squid
mkdir -p /usr/share/squid/icons
mkdir -p /cache

echo 'Download Squid Source dari www.squid-cache.org...'
sleep 1
cd /usr/src
wget -c ftp://artfiles.org/squid-cache.org/pub/archive/3.5/squid-$SQVER.tar.bz2
tar -jxf squid-$SQVER.tar.bz2
cd squid-*
make clean && make distclean
clear

echo 'Memulai Konfigurasi & Kompilasi Squid...'
sleep 2

./configure '--prefix=/usr' '--bindir=/usr/bin' '--sbindir=/usr/sbin' '--libexecdir=/usr/lib/squid' '--sysconfdir=/etc/squid' '--localstatedir=/var' '--libdir=/usr/lib' '--includedir=/usr/include' '--datadir=/usr/share/squid' '--infodir=/usr/share/info' '--mandir=/usr/share/man' '--disable-dependency-tracking' '--disable-strict-error-checking' '--enable-async-io=48' '--with-aufs-threads=48' '--with-pthreads' '--with-openssl' '--enable-storeio=aufs,diskd' '--enable-removal-policies=lru,heap' '--with-aio' '--with-dl' '--enable-icmp' '--enable-esi' '--enable-icap-client' '--disable-wccp' '--disable-wccpv2' '--enable-kill-parent-hack' '--enable-cache-digests' '--disable-select' '--enable-http-violations' '--enable-linux-netfilter' '--enable-follow-x-forwarded-for' '--disable-ident-lookups' '--enable-x-accelerator-vary' '--enable-zph-qos' '--with-default-user=proxy' '--with-logdir=/var/log/squid' '--with-pidfile=/var/run/squid.pid' '--with-swapdir=/var/spool/squid' '--with-large-files' '--enable-ltdl-convenience' '--with-filedescriptors=65536' '--enable-ssl' '--enable-ssl-crtd' '--disable-auth' '--disable-ipv6' '--enable-err-languages=English' '--enable-default-err-language=English' '--build=x86_64' 'build_alias=x86_64'
make && makeinstall

mkdir -p /var/squid/ssl_db
/usr/lib/squid/ssl_crtd -c -s /var/squid/ssl_db/certs
chown -R proxy:proxy /var/squid/ssl_db/certs
mkdir -p /etc/squid/ssl_cert

# Set konfigurasi squid.conf, silahkan disesuaikan
rm -rf /etc/squid/squid.conf
touch /etc/squid/squid.conf

echo "
# Do not modify '/var/ipfire/proxy/squid.conf' directly since any changes
# you make will be overwritten whenever you resave proxy settings using the
# web interface!
#
# Instead, modify the file '/var/ipfire/proxy/advanced/acls/include.acl' and
# then restart the proxy service using the web interface. Changes made to the
# 'include.acl' file will propagate to the 'squid.conf' file at that time.


shutdown_lifetime 5 seconds
icp_port 0

cache_mgr agungggz@facebook.com

include /etc/squid/squid.conf.local

http_port 192.168.21.212:3128

cache_effective_user proxy
umask 022

pid_filename /var/run/squid.pid

cache_mem 8 MB

digest_generation off

memory_replacement_policy heap GDSF
cache_replacement_policy heap LFUDA

# Example rule allowing access from your local networks.
# Adapt to list your (internal) IP networks from where browsing
# should be allowed
acl localnet src 10.0.0.0/8	# RFC1918 possible internal network
acl localnet src 172.16.0.0/12	# RFC1918 possible internal network
acl localnet src 192.168.0.0/16	# RFC1918 possible internal network
acl localnet src fc00::/7       # RFC 4193 local private network range
acl localnet src fe80::/10      # RFC 4291 link-local (directly plugged) machines

acl all src
acl SSL_ports port 443 # https
acl SSL_ports port 563 # snews
acl Safe_ports port 80 # http
acl Safe_ports port 88 # kerberos
acl Safe_ports port 182 # streaming
acl Safe_ports port 21 # ftp
acl Safe_ports port 443 # https
acl Safe_ports port 563 # snews
acl Safe_ports port 70 # gopher
acl Safe_ports port 210 # wais
acl Safe_ports port 1025-65535 # unregistered ports
acl Safe_ports port 280 # http-mgmt
acl Safe_ports port 488 # gss-http
acl Safe_ports port 591 # filemaker
acl Safe_ports port 777 # multiling http
acl Safe_ports port 3127 # Squids port (for icons)
acl CONNECT method CONNECT

maximum_object_size 2048000 KB
minimum_object_size 0 KB

cache_dir aufs /cache1 70500 64 256
cache_dir aufs /cache2 70500 64 256
cache_dir aufs /cache3 70500 64 256
cache_dir aufs /cache4 70500 64 256
access_log stdio:/tmp/access.log !CONNECT
cache_log /tmp/cache.log

log_mime_hdrs off
forwarded_for off
via off

http_access deny !Safe_ports
http_access deny CONNECT !SSL_ports
http_access allow localhost manager
http_access deny manager
#http_access deny to_localhost
http_access allow localnet
http_access allow localhost
http_access deny all

coredump_dir /var/spool/squid

request_header_access X-Forwarded-For deny all
reply_header_access X-Forwarded-For deny all
request_header_access Via deny all
reply_header_access Via deny all

max_filedescriptors 65536 " > /etc/squid/squid.conf

# Konfigurasi squid.conf.local
touch /etc/squid/squid.conf.local

echo "
http_port 192.168.21.212:3127 tproxy
https_port 192.168.21.212:3129 tproxy ssl-bump generate-host-certificates=on dynamic_cert_mem_cache_size=40MB cert=/etc/squid/ssl_cert/myCA.pem  sslflags=DELAYED_AUTH cipher=ECDHE-RSA-RC4-SHA:ECDHE-RSA-AES128-SHA:DHE-RSA-AES128-SHA:DHE-RSA-CAMELLIA128-SHA:AES128-SHA:RC4-SHA:HIGH:!aNULL:!MD5:!ADH

acl ytHack url_regex -i \/pagead\/js\/lidar\.js
acl ytHack url_regex -i google\.com\/js\/bg\/.*\.js
#deny_info http://pastebin.com/raw.php?i=NBptAD3B ytHack	#144p
#deny_info http://pastebin.com/raw.php?i=K3xJKL33 ytHack	#240p
deny_info http://pastebin.com/raw.php?i=CzuzS8Kt ytHack		#360p
http_access deny ytHack

acl chrome url_regex -i ^http:\/\/.*\.pack.google.com\/edgedl\/chrome\/win\/.*
acl chrome url_regex -i ^http:\/\/cache.pack.google.com\/edgedl\/.*
acl chrome url_regex -i ^http:\/\/www.google.com\/dl\/chrome\/win\/.*
http_access deny chrome

memory_pools off
pinger_enable off
strip_query_terms off

reload_into_ims on
refresh_all_ims on
vary_ignore_expire on

maximum_object_size_in_memory 0 KB

cache_swap_high 99
cache_swap_low 98
max_filedesc 10240

ipcache_size 1024
ipcache_high 95
ipcache_low 90

qos_flows local-hit=0x30

dns_nameservers 208.67.222.222 208.67.220.220

acl spliceserver ssl::server_name "/etc/squid/splicesaja.txt"

acl step1 at_step SslBump1
acl step2 at_step SslBump2
acl step3 at_step SslBump3

quick_abort_min 0 KB
quick_abort_max 0 KB
quick_abort_pct 98

always_direct allow all
ssl_bump splice step1 spliceserver
ssl_bump splice step2 spliceserver
ssl_bump splice step3 spliceserver
ssl_bump peek step1 all
ssl_bump stare step2 all
ssl_bump splice step3 all
sslproxy_cert_error allow all
sslproxy_flags DONT_VERIFY_PEER
sslcrtd_program /usr/lib/squid/ssl_crtd -s /var/squid/ssl_db/certs/ -M 40MB
sslcrtd_children 50 startup=50

#url_rewrite_program /usr/local/bin/simplerewrite

acl rewritedoms dstdomain .dailymotion.com .video-http.media-imdb.com .dl.sourceforge.net .prod.video.msn.com .fbcdn.net .akamaihd.net vl.mccont.com .mais.uol.com.br .streaming.r7.com
acl yt url_regex -i googlevideo.*videoplayback
acl gmaps url_regex -i ^https?:\/\/(khms|mt)[0-9]+\.google\.[a-z\.]+\/.*
acl ttv url_regex -i terratv
acl globo url_regex -i ^http:\/\/voddownload[0-9]+\.globo\.com.*
acl dm url_regex -i dailymotion\-flv2
acl getmethod method GET

acl helper url_regex -i ^https?\:\/\/.*
acl httptomiss http_status 302
acl mimetype rep_mime_type mime-type ^text/plain
acl mimetype rep_mime_type mime-type ^text/html
acl getmethod method GET

cache deny localhost

store_id_program /etc/squid/storeid.pl
store_id_extras "%>a/%>A %un %>rm myip=%la myport=%lp referer=%{Referer}>h"
store_id_children 50 startup=50
store_id_access deny !getmethod
store_id_access allow rewritedoms
store_id_access allow yt
store_id_access allow gmaps
store_id_access allow ttv
store_id_access allow globo
store_id_access allow dm
store_id_access allow helper
store_id_access deny all

store_miss deny helper httptomiss
send_hit deny helper httptomiss
store_miss deny helper mimetype
send_hit deny helper mimetype

include /etc/squid/refresh.conf

max_stale 360 days " > /etc/squid/squid.conf

# Konfigurasi refresh pattern
touch /etc/squid/refresh.conf

echo "
refresh_pattern -i squid\.internal  10080   80% 79900 override-lastmod override-expire ignore-reload ignore-no-store ignore-must-revalidate ignore-private ignore-auth

refresh_pattern -i ^http.*g-no.* 432000 99% 432000 override-expire override-lastmod ignore-reload ignore-no-store ignore-private ignore-auth ignore-must-revalidate store-stale
refresh_pattern . 0 95% 432000 override-expire override-lastmod refresh-ims reload-into-ims ignore-no-store ignore-private ignore-auth ignore-must-revalidate


refresh_pattern .*(begin|start)\=[1-9][0-9].*               0 0% 0
refresh_pattern -i (cgi-bin|mrtg|graph) 0 0% 0
#refresh_pattern ^http.*(youtube|googlevideo)\.*     2629742 99% 2629742 ignore-reload override-expire override-lastmod ignore-must-revalidate  ignore-private ignore-no-store ignore-auth store-stale
refresh_pattern ^http.*(youtube|googlevideo)\.*     5259487 99% 5259487 ignore-reload override-expire override-lastmod ignore-must-revalidate  ignore-private ignore-no-store ignore-auth store-stale
#refresh_pattern (get_video\?|videoplayback\?|videodownload\?) 5259487 99% 5259487 override-expire ignore-reload ignore-private
 
#PATTERN REFRESH
refresh_pattern -i \.(html|htm|css|js|png|jsp|asx|asp|aspx)$ 10080 99% 10080 ignore-reload override-expire override-lastmod ignore-must-revalidate  ignore-private ignore-no-store ignore-auth store-stale
refresh_pattern -i \/speedtest\/.*\.(txt|jpg|png|swf)  4320 99% 14400 override-expire ignore-reload ignore-private ignore-reload override-lastmod reload-into-ims
refresh_pattern .pixieimage\.com.*\.(jp(e?g|e|2)|gif|png|tiff?|bmp|swf|mp(4|3))  1440 99% 14400 override-expire ignore-reload ignore-private ignore-reload override-lastmod reload-into-ims
refresh_pattern .blogspot\.com.*\.(jp(e?g|e|2)|gif|png|tiff?|bmp|swf|mp(4|3))  1440 99% 14400 override-expire ignore-reload ignore-private ignore-reload override-lastmod reload-into-ims
refresh_pattern .multiply\.com.*\.(jp(e?g|e|2)|gif|png|tiff?|bmp|swf|mp(4|3))  1440 99% 14400 override-expire ignore-reload ignore-private ignore-reload override-lastmod reload-into-ims
refresh_pattern .((pikawarnet\.com)|(blogspot\.com)|(pixieimage\.com)|(multiply\.com)).*  60  30% 240
#refresh_pattern -i .google\-analytics\.com.*gif 2629742 99% 2629742 override-expire override-lastmod ignore-no-cache ignore-private reload-into-ims ignore-must-revalidate ignore-reload store-stale
refresh_pattern -i ^http:\/\/(.*\.adobe\.com)\/.*\/(.*) 10080 99% 10080 ignore-reload override-expire override-lastmod ignore-must-revalidate  ignore-private ignore-no-store ignore-auth store-stale
refresh_pattern -i ^http:\/\/(.*\.google-analytics\.com)\/(__utm\.gif)\?.* 1440 70% 14400 ignore-reload override-expire override-lastmod ignore-must-revalidate  ignore-private ignore-no-store ignore-auth store-stale
refresh_pattern -i ^http:\/\/.*\.softpedia\.com\/dl\/.*\/.*\/.* 26297 99% 43200 ignore-reload override-expire override-lastmod ignore-must-revalidate  ignore-private ignore-no-store ignore-auth store-stale
 
#sensitive site
refresh_pattern -i \.(sc-|dl-|ex-|mh-|dll|da-) 0 2% 50 reload-into-ims
refresh_pattern -i \.(mst|Xtp|iop)$ 0 50% 1440 reload-into-ims
refresh_pattern -i (index.php|autoup.exe|main.exe|xtrap.xt|autoupgrade.exe|update.exe|grandchase.exe|FSLauncher.exe|FreeStyle_Setup.exe|grandchase.exe|filelist.zip)$ 0 50% 1440
refresh_pattern -i (wks_avira-win32-en-pecl.info.gz|wks_avira10-win32-en-pecl.info.gz|servers.def.vpx)$ 0 50% 1440
refresh_pattern -i (setup.exe.gz|avscan.exe.gz|avguard.exe.gz|filelist.zip|AvaClient.exe) 0 50% 1440
refresh_pattern -i (livescore.com|goal.com|bobet) 0 50% 60
 
#Windows Update
refresh_pattern -i microsoft.com/.*\.(cab|exe|ms[i|u|f]|[ap]sf|wm[v|a]|dat|zip) 4320 80% 43200 reload-into-ims
refresh_pattern -i windowsupdate.com/.*\.(cab|exe|ms[i|u|f]|[ap]sf|wm[v|a]|dat|zip) 4320 80% 43200 reload-into-ims
refresh_pattern -i windows.com/.*\.(cab|exe|ms[i|u|f]|[ap]sf|wm[v|a]|dat|zip) 4320 80% 43200 reload-into-ims
 
#FB
refresh_pattern -i ^http://fbcdn.net.squid.internal 10080 70% 43200 ignore-reload override-expire override-lastmod ignore-must-revalidate  ignore-private ignore-no-store ignore-auth store-stale

refresh_pattern \.gstatic\.com/images\? 1440 99% 14400 override-expire override-lastmod ignore-reload ignore-private ignore-must-revalidate
refresh_pattern \.(akamaihd|edgecastcdn|spilcdn|zgncdn|(tw|y|yt)img)\.com.*\.(jp(e?g|e|2)|gif|png|swf|mp(3|4)) 10080 99% 10080 override-expire override-lastmod ignore-reload ignore-private
refresh_pattern (gstatic|diggstatic)\.com/.* 10080 99% 10080 override-expire ignore-reload ignore-private
refresh_pattern (photobucket|pbsrc|flickr|yimg|ytimg|twimg|gravatar)\.com.*\.(jp(e?g|e|2)|gif|png|tiff?|bmp|swf|mp(4|3)) 10080 99% 10080 override-expire ignore-reload ignore-private
refresh_pattern (ninjasaga|mafiawars|cityville|farmville|crowdstar|spilcdn|agame|popcap)\.com/.* 1440 99% 14400 override-expire ignore-reload ignore-private
refresh_pattern ^http:\/\/images|image|img|pics|openx|thumbs[0-9]\. 10080 99% 10080 override-expire ignore-reload ignore-private
refresh_pattern ^.*safebrowsing.*google 10080 99% 10080 override-expire ignore-reload ignore-private ignore-auth ignore-must-revalidate
refresh_pattern ^http://.*\.squid\.internal\/.*  10080 80% 43200 override-expire override-lastmod ignore-reload ignore-no-store ignore-must-revalidate ignore-private ignore-auth max-stale=10000 store-stale
refresh_pattern -i c2lo.reverbnation.com 10080 99% 10080 override-expire override-lastmod ignore-no-cache ignore-private ignore-must-revalidate ignore-reload store-stale
refresh_pattern -i ^https:\/\/(.*)\/.*\/(baseballheroes)\/live\/(.*)? 10080 99% 43200 ignore-reload override-expire override-lastmod ignore-must-revalidate  ignore-private ignore-no-store ignore-auth store-stale
refresh_pattern -i ^https:\/\/(dgvbc27jkydqc\.cloudfront\.net)\/.*\/(billiards)\/(.*) 10080 99% 43200 ignore-reload override-expire override-lastmod ignore-must-revalidate  ignore-private ignore-no-store ignore-auth store-stale
refresh_pattern -i ^https:\/\/(geewa-a\.akamaihd\.net)\/.*\/(.*)\/.*\/(.*) 10080 70% 43200 ignore-reload override-expire override-lastmod ignore-must-revalidate  ignore-private ignore-no-store ignore-auth store-stale
refresh_pattern -i ^https:\/\/(zynga(.*)\.akamaihd\.net)\/(.*)\/.*\/(.*) 10080 70% 43200 ignore-reload override-expire override-lastmod ignore-must-revalidate  ignore-private ignore-no-store ignore-auth store-stale
refresh_pattern -i ^https:\/\/(duapys4lcv8ju\.cloudfront\.net)\/.*\/(.*) 10080 70% 43200 ignore-reload override-expire override-lastmod ignore-must-revalidate  ignore-private ignore-no-store ignore-auth store-stale
 
#refresh_pattern -i ^http:\/\/(zynga(.*)\.akamaihd\.net)\/(.*)\/.*\/(.*) 10080 99% 43200 ignore-reload override-expire override-lastmod ignore-must-revalidate  ignore-private ignore-no-store ignore-auth store-stale
 
refresh_pattern -i ^http:\/\/(.*\.flv2\.redtubefiles.com)\/(.*)\/(.*)\/(.*)\/(.*) 26297 99% 43200 override-expire override-lastmod ignore-no-cache ignore-private ignore-must-revalidate ignore-reload store-stale
refresh_pattern -i ^http:\/\/(.*\.thestaticvube\.com)\/.*\/(.*)\/(.*) 26297 99% 43200 override-expire override-lastmod ignore-no-cache ignore-private ignore-must-revalidate ignore-reload store-stale
refresh_pattern -i ^http:\/\/(.*\.*\.videomega.tv)\/.*\/(.*\.mp4).* 26297 99% 43200 override-expire override-lastmod ignore-no-cache ignore-private ignore-must-revalidate ignore-reload store-stale
refresh_pattern -i ^http:\/\/(77.247.178.81)\/.*\/(.*\.mp4).* 26297 99% 43200 override-expire override-lastmod ignore-no-cache ignore-private ignore-must-revalidate ignore-reload store-stale
refresh_pattern -i ^http:\/\/(.*\.dropvideo\.com)\/.*\/(.*\.mp4).* 26297 99% 43200 override-expire override-lastmod ignore-no-cache ignore-private ignore-must-revalidate ignore-reload store-stale
#refresh_pattern -i ^http:\/\/(.*\.dropvideo\.com)\/.*\/(.*) 26297 99% 43200 override-expire override-lastmod ignore-no-cache ignore-private ignore-must-revalidate ignore-reload store-stale
 
#ads
refresh_pattern ^.*(streamate.doublepimp.com.*\.js\?|utm\.gif|ads\?|rmxads\.com|ad\.z5x\.net|bh\.contextweb\.com|bstats\.adbrite\.com|a1\.interclick\.com|ad\.trafficmp\.com|ads\.cubics\.com|ad\.xtendmedia\.com|\.googlesyndication\.com|advertising\.com|yieldmanager|game-advertising\.com|pixel\.quantserve\.com|adperium\.com|doubleclick\.net|adserving\.cpxinteractive\.com|syndication\.com|media.fastclick.net).* 26297 99% 43200 ignore-private override-expire ignore-reload ignore-auth max-stale=43200
refresh_pattern \.(ico|video-stats) 10080 99% 10080 override-expire ignore-reload ignore-private ignore-auth override-lastmod ignore-must-revalidate
refresh_pattern ^http://((cbk|mt|khm|mlt|tbn)[0-9]?)\.google\.co(m|\.uk|\.id) 10080 99% 10080 override-expire override-lastmod ignore-reload ignore-private ignore-auth ignore-must-revalidate
refresh_pattern vid\.akm\.dailymotion\.com.*\.on2\? 10080 99% 10080 override-expire override-lastmod
refresh_pattern galleries\.video(\?|sz) 5259487 99% 5259487 ignore-reload override-expire override-lastmod ignore-must-revalidate  ignore-private ignore-no-store ignore-auth store-stale
refresh_pattern \.wikimapia\.org\/? 10080 99% 10080 override-expire override-lastmod ignore-reload ignore-private
refresh_pattern -i ^http:\/\/(.*\.ads\.contentabc\.com)\/ads\/(.*)\/(.*) 26297 99% 43200 ignore-reload override-expire override-lastmod ignore-must-revalidate  ignore-private ignore-no-store ignore-auth store-stale
 
#general
refresh_pattern -i \.(7z|arj|bin|bz2|cab|dll|exe|gz|inc|iso|jar|lha|ms(i|p|u)|rar|rpm|tar|tgz|zip|rtp|rpz|nui|kom|stg|pak|sup|nzp|npz|iop)$ 26297 99% 43200 override-expire override-lastmod ignore-private reload-into-ims ignore-must-revalidate ignore-reload store-stale
refresh_pattern -i \.(class|doc|docx|pdf|pps|ppt|ppsx|pptx|ps|rtx|txt|wpl|xls|xlsx)$ 26297 99% 43200 override-expire override-lastmod ignore-private reload-into-ims ignore-must-revalidate ignore-reload store-stale
refresh_pattern -i \.(3gp|ac4|agx|au|avi|axd|bmp|cbr|cbt|cbz|dat|divx|flv|gif|hqx|ico|jp(2|e|eg|g)|mid|mk(a|v)|mov|mp(1|2|3|4|e|eg|g)|og(a|g|v)|qt|ra|ram|rm|swf|tif|tiff|wa(v|x)|wm(a|v|x)|x-flv)$ 26297 99% 43200 override-expire override-lastmod ignore-private reload-into-ims ignore-must-revalidate ignore-reload store-stale
refresh_pattern -i .(html|htm|css|js)$ 26297 99% 43200
refresh_pattern -i .index.(html|htm)$ 26297 99% 43200
 
refresh_pattern -i \.(3gp|avi|ac4|mp(e?g|a|e|1|2|3|4)|m4(a|v)|3g(p?2|p)|mk(a|v)|og(x|v|a|g|m)|wm(a|v)|wmx|wpl|rm|snd|vob|wav|asx|avi|qt|divx|flv|f4v|x-flv|dvr-ms|m(1|2)(v|p)|mov|mid|mpeg)$ 43200 100% 43200 ignore-no-store ignore-must-revalidate ignore-private override-expire override-lastmod reload-into-ims store-stale
refresh_pattern -i \.(7z|ace|rar|jar|gz|tgz|bz2|iso|mod|arj|lha|lzh|zip|tar|cab|dat|pak|kom|zip)$ 10080 80% 10080 ignore-no-store ignore-must-revalidate ignore-private override-expire override-lastmod reload-into-ims store-stale
refresh_pattern -i \.(jp(e?g|e|2)|gif|pn[pg]|bm?|tiff?|ico|swf|css|js|ad)$ 10080 80% 10080 ignore-no-store ignore-must-revalidate ignore-private override-expire override-lastmod reload-into-ims store-stale
refresh_pattern -i \.(exe|ms(i|u|p)|deb|bin|ax|r(a|p)m|app|pkg|apk|msi|mar|nzp|iop|xpi|dmg|dds|thor|nar|gpf)$ 10080 80% 10080 ignore-no-store ignore-must-revalidate ignore-private override-expire override-lastmod reload-into-ims store-stale
refresh_pattern -i \.(pp(t?x|t)|epub|pdf|rtf|wax|cb(r|z|t)|xl(s?x|s)|do(c?x|c)|inc)$ 10080 80% 10080 ignore-no-store ignore-must-revalidate ignore-private override-expire override-lastmod reload-into-ims store-stale

refresh_pattern \.gif$             26297 99% 43200 ignore-reload override-expire override-lastmod ignore-must-revalidate  ignore-private ignore-no-store ignore-auth store-stale
refresh_pattern \.jpg$             26297 99% 43200 ignore-reload override-expire override-lastmod ignore-must-revalidate  ignore-private ignore-no-store ignore-auth store-stale
refresh_pattern \.png$             26297 99% 43200 ignore-reload override-expire override-lastmod ignore-must-revalidate  ignore-private ignore-no-store ignore-auth store-stale
refresh_pattern \.ico$             26297 99% 43200 ignore-reload override-expire override-lastmod ignore-must-revalidate  ignore-private ignore-no-store ignore-auth store-stale
refresh_pattern \.jpeg$            26297 99% 43200 ignore-reload override-expire override-lastmod ignore-must-revalidate  ignore-private ignore-no-store ignore-auth store-stale

refresh_pattern ^ftp:           40320 20% 40320 override-expire reload-into-ims store-stale
refresh_pattern ^gopher:        1440    0%      1440
refresh_pattern (cgi-bin|\?)    0       0%      0
refresh_pattern .                       0 50% 40320  store-stale " > /etc/squid/refresh.conf

# Konfigurasi spliceserver
touch /etc/squid/splicesaja.txt

echo "
ib.bri.co.id
95.211.61.134
74.82.91.84
110.92.28.161
94.236.124.241
94.236.46.101
ib.bankmandiri.co.id
117.102.111.38
114.57.160.206
112.215.62.232
web.cdn.garenanow.com
s65.kumpulbagi.com
119.81.101.170 " /etc/squid/splicesaja.txt

# Konfigurasi rewriter Storeid
cat > /etc/squid/storeid.pl <<- 'selesai'
#!/usr/bin/perl
 
$|=1;
while (<>) {
@X = split;
if ($X[0] =~ m/^https?\:\/\/.*/) {
        $x = $X[0];
        $_ = $X[0];
        $u = $X[0];
} else {
        $x = $X[1];
        $_ = $X[1];
        $u = $X[1];
}
 
 
#ads youtube
if ($x=~ m/^https?\:\/\/.*youtube.*api.*stats.*ads.*/){
    @content_v = m/[&?]content_v\=([^\&\s]*)/;
    @cpn = m/[%&?\/](cpn[%&=\/][^\&\s\/]*)/;
    unless (-e "/tmp/@cpn"){
    open FILE, ">/tmp/@cpn";
    print FILE "id=@content_v";
    close FILE;
    }
    $out=$x;
 
#tracking youtube
} elsif ($x=~ m/^https?\:\/\/.*youtube.*(ptracking|set_awesome).*/){
    @video_id = m/[&?]video_id\=([^\&\s]*)/;
    @cpn = m/[%&?\/](cpn[%&=\/][^\&\s\/]*)/;
    unless (-e "/tmp/@cpn"){
    open FILE, ">/tmp/@cpn";
    print FILE "id=@video_id";
    close FILE;
    }
    $out=$x;
 
 
#stream_204 youtube
} elsif ($x=~ m/^https?\:\/\/.*youtube.*(stream_204|watchtime|qoe|atr).*/){
    @docid = m/[&?]docid\=([^\&\s]*)/;
    @cpn = m/[%&?\/](cpn[%&=\/][^\&\s\/]*)/;
    unless (-e "/tmp/@cpn"){
    open FILE, ">/tmp/@cpn";
    print FILE "id=@docid";
    close FILE;
    }
    $out=$x;
 
#player_204 youtube
} elsif ($x=~ m/^https?\:\/\/.*youtube.*player_204.*/){
    @v = m/[&?]v\=([^\&\s]*)/;
    @cpn = m/[%&?\/](cpn[%&=\/][^\&\s\/]*)/;
    unless (-e "/tmp/@cpn"){
    open FILE, ">/tmp/@cpn";
    print FILE "id=@v";
    close FILE;
    }
    $out=$x;
 
#youtube
} elsif ($x=~ m/^https?\:\/\/.*(youtube|googlevideo).*videoplayback.*title.*/){
    @title      = m/[%&?\/](title[%&=\/][^\&\s\/]*)/;
    @itag      = m/[%&?\/](itag[%&=\/][^\&\s\/]*)/;
    @range   = m/[%&?\/](range[%&=\/][^\&\s\/]*)/;
    $out="http://g-no/youtube/@itag@title@range";
 
#youtube
} elsif ($x=~ m/^https?\:\/\/.*(youtube|googlevideo).*videoplayback.*/){
    @cpn      = m/[%&?\/](cpn[%&=\/][^\&\s\/]*)/;
    @id      = m/[%&?\/](id[%&=\/][^\&\s\/]*)/;
    @itag      = m/[%&?\/](itag[%&=\/][^\&\s\/]*)/;
    @range  = m/[%&?\/](range[%&=\/][^\&\s\/]*)/;
    @slices = m/[%&?\/](slices[%&=\/][^\&\s\/]*)/;
    @mime     = m/[%&?\/](mime[%&=\/][^\&\s\/]*)/;
    if (defined(@cpn[0])){
        if (-e "/tmp/@cpn"){
        open FILE, "/tmp/@cpn";
        @id = <FILE>;
        close FILE;}
    }
    $out="http://g-no/youtube/@id@itag@mime@range@slices";
 
 
#utmgif
} elsif ($x=~ m/^https?\:\/\/.*utm.gif.*/) {
    $out="http://g-no/__utm.gif";
 
 
#safe_image FB
} elsif ($x=~ m/^https?\:\/\/fbexternal-a\.akamaihd\.net\/safe_image\.php\?d.*/) {
    @d = m/[&?]d\=([^\&\s]*)/;
    @h = m/[&?]h\=([^\&\s]*)/;
    @w = m/[&?]w\=([^\&\s]*)/;
    $out="http://g-no/safe_image/d=@d&w=@w&h=@h";
 
#####
} elsif ($x=~ m/^https?\:\/\/fbstatic-a\.akamaihd\.net\/safe_image\.php\?d.*/) {
    $out="http://g-no/safe_image/d=@d&w=@w&h=@h";
#####
 
#fbcdn size picture
} elsif ($x=~ m/^https?\:\/\/.*(fbcdn).*\/v\/.*\/(.*x.*\/.*\.(jpg|jpeg|bmp|ico|png|gif))\?oh=\.*/) {
    $out="http://g-no/fbcdn/" . $2;
 
#fbcdn picture
} elsif ($x=~ m/^https?\:\/\/.*(fbcdn).*\/v\/.*\/(.*\.(jpg|jpeg|bmp|ico|png|gif))\?oh=\.*/) {
    $out="http://g-no/fbcdn/" . $2;
 
#reverbnation
} elsif ($x=~ m/^https?\:\/\/c2lo\.reverbnation\.com\/audio_player\/ec_stream_song\/(.*)\?.*/) {
    $out="http://g-no/reverbnation/" . $1;
 
#playstore
} elsif ($x=~ m/^https?\:\/\/.*\.c\.android\.clients\.google\.com\/market\/GetBinary\/GetBinary\/(.*\/.*)\?.*/) {
    $out="http://g-no/android/market/" . $1;
 
#filehost
} elsif ($x=~ m/^https?\:\/\/.*datafilehost.*\/get\.php.*file\=(.*)/) {
    $out="http://g-no/filehost/" . $1;
 
#speedtest
} elsif ($x=~ m/^https?\:\/\/.*(speedtest|espeed).*\/(.*\.(jpg|txt|png|bmp)).*/) {
    $out="http://g-no/speedtest/" . $2;
 
#filehippo
} elsif ($x=~ m/^https?\:\/\/.*\.filehippo\.com\/.*\/(.*\/.*)/) {
    $out="http://g-no/filehippo/" . $1;
 
#4shared preview.mp3
} elsif ($x=~ /^https?\:\/\/.*\.4shared\.com\/.*\/(.*\/.*)\/dlink.*preview.mp3/) {
    $out="http://g-no/4shared/preview/" . $1;
 
#4shared
} elsif ($x=~ m/^https?\:\/\/.*\.4shared\.com\/download\/(.*\/.*)\?tsid.*/) {
    $out="http://g-no/4shared/download/" . $1;

#steampowered dota 2
} elsif ($x=~ m/^https?\:\/\/media\d+\.steampowered\.com\/client\/(.*)/) {
    $out="http://g-no/media/steampowered/" . $1;

#steampowered dota2 chunk-manifest
} elsif ($x=~ m/^https?\:\/\/valve\d+\.cs\.steampowered\.com\/depot\/(.*)/) {
    $out="http://g-no/steampowered/depot/" . $1;

#animeindo
} elsif ($x =~ m/^https?\:\/\/.*aisfile\.com:182\/.\/(.*)\/(.*\.(mp4|flv)).*/){
    $out="store-id://aisfile:182.SQUIDINTERNAL/$2\n";


#update-mozilla
} elsif ($x =~ m/^http?\:\/\/.*google\.com\/safebrowsing\/.*/){
    $out="store-id://safebrowsing.SQUIDINTERNAL/$2\n";

} else {
$out=$x;
}
 
if ($X[0] =~ m/^https?\:\/\/.*/) {
        print "OK store-id=$out\n";
} else {
        print $X[0] . " " . "OK store-id=$out\n";
}
}
selesai

chmod +x /etc/squid/storeid.pl

# Konfigurasi Startup Service Squid
cat > /etc/init.d/squid <<-'finis'
#!/bin/sh
#
# squid32012                Startup script for the SQUID HTTP proxy-cache.
#
# Version:      @(#)squid3.rc  1.0  07-Jul-2006  kalpin@debian.org
#
### BEGIN INIT INFO
# Provides:          Squid 3.5.7
# File-Location:     /etc/init.d/squid
# Required-Start:    $network $remote_fs $syslog
# Required-Stop:     $network $remote_fs $syslog
# Should-Start:      $named
# Should-Stop:       $named
# Default-Start:     2 3 4 5
# Default-Stop:      0 1 6
# Short-Description: Squid HTTP Proxy version 3.5.7
### END INIT INFO

NAME=squid
DESC="Squid HTTP Proxy 3.5.7 imxpert.co"
DAEMON=/usr/sbin/squid
PIDFILE=/var/run/$NAME.pid
CONFIG=/etc/squid/squid.conf
SQUID_ARGS="-YC -f $CONFIG"
# RAMFS=/scripts/ramcache

[ ! -f /etc/default/squid ] || . /etc/default/squid

. /lib/lsb/init-functions

PATH=/bin:/usr/bin:/sbin:/usr/sbin

[ -x $DAEMON ] || exit 0

ulimit -n 65535

find_cache_dir () {
        w="     " # space tab
        res=`sed -ne '
                s/^'$1'['"$w"']\+[^'"$w"']\+['"$w"']\+\([^'"$w"']\+\).*$/\1/p;
                t end;
                d;
                :end q' < $CONFIG`
        [ -n "$res" ] || res=$2
        echo "$res"
}

find_cache_type () {
        w="     " # space tab
        res=`sed -ne '
                s/^'$1'['"$w"']\+\([^'"$w"']\+\).*$/\1/p;
                t end;
                d;
                :end q' < $CONFIG`
        [ -n "$res" ] || res=$2
        echo "$res"
}

start () {
#        $RAMFS clean
#        $RAMFS mount
#        $RAMFS restore

        cache_dir=`find_cache_dir cache_dir /cache`
        cache_type=`find_cache_type cache_dir aufs`

        #
    # Create spool dirs if they don't exist.
    #
        if [ "$cache_type" = "coss" -a -d "$cache_dir" -a ! -f "$cache_dir/stripe" ] || [ "$cache_type" != "coss" -a -d "$cache_dir" -a ! -d "$cache_dir/00" ]
        then
                log_warning_msg "Creating $DESC cache structure"
                $DAEMON -z
        fi

        umask 027
        ulimit -n 65535

        cd $cache_dir
        start-stop-daemon --quiet --start \
                --pidfile $PIDFILE \
                --exec $DAEMON -- $SQUID_ARGS < /dev/null
        return $?
}

stop () {

        PID=`cat $PIDFILE 2>/dev/null`
        start-stop-daemon --stop --quiet --pidfile $PIDFILE --exec $DAEMON
        #
        #       Now we have to wait until squid has _really_ stopped.
        #
        sleep 2
        if test -n "$PID" && kill -0 $PID 2>/dev/null
        then
                log_action_begin_msg " Waiting"
                cnt=0
                while kill -0 $PID 2>/dev/null
                do
                        cnt=`expr $cnt + 1`
                        if [ $cnt -gt 24 ]
                        then
                                log_action_end_msg 1
                                return 1
                        fi
                        sleep 5
                        log_action_cont_msg ""
                done
                log_action_end_msg 0
                return 0
        else
                return 0
        fi
}

case "$1" in
    start)
        log_daemon_msg "Starting $DESC" "$NAME"
        if start ; then
                log_end_msg $?
        else
                log_end_msg $?
        fi
        ;;
    stop)
        log_daemon_msg "Stopping $DESC" "$NAME"


        if stop ; then
                log_end_msg $?
        else
                log_end_msg $?
        fi
#        $RAMFS dump
#        $RAMFS umount
#        $RAMFS clean

        ;;
    reload|force-reload)
        log_action_msg "Reloading $DESC configuration files"
        start-stop-daemon --stop --signal 1 \
                --pidfile $PIDFILE --quiet --exec $DAEMON
        log_action_end_msg 0
        ;;
    restart)
        log_daemon_msg "Restarting $DESC" "$NAME"
        stop
        if start ; then
                log_end_msg $?
        else
                log_end_msg $?
        fi
        ;;
    *)
        echo "Usage: /etc/init.d/$NAME {start|stop|reload|force-reload|restart}"
        exit 3
        ;;
esac
exit 0
finis


# Set iproute dan iptables untuk tproxy
echo "Setup iptables dan ip route"
sleep 2

mv /etc/rc.local /etc/rc.local_
touch /etc/rc.local

echo "
#!/bin/sh
#
# This script will be executed *after* all the other init scripts.
# You can put your own initialization stuff in here if you don't
# want to do the full Sys V style init stuff.

 
modprobe xt_TPROXY
modprobe xt_socket
modprobe xt_mark
modprobe nf_nat
modprobe nf_conntrack_ipv4
modprobe nf_conntrack
modprobe nf_defrag_ipv4
modprobe ipt_REDIRECT
modprobe iptable_nat
 
iptables -t mangle -F
iptables -t mangle -X
iptables -t nat -F
iptables -t mangle -N DIVERT
iptables -t mangle -A DIVERT -j MARK --set-mark 1
iptables -t mangle -A DIVERT -j ACCEPT
iptables -t mangle -A INPUT -j ACCEPT
iptables -t mangle -A PREROUTING -p tcp -m socket -j DIVERT
iptables -t mangle -A PREROUTING ! -d 192.168.21.212/24 -p tcp --dport 80 -j TPROXY --tproxy-mark 0x1/0x1 --on-port 3127
iptables -t mangle -A PREROUTING ! -d 192.168.21.212/24 -p tcp --dport 5050 -j TPROXY --tproxy-mark 0x1/0x1 --on-port 3127
iptables -t mangle -A PREROUTING ! -d 192.168.21.212/24 -p tcp --dport 8080 -j TPROXY --tproxy-mark 0x1/0x1 --on-port 3127
iptables -t mangle -A PREROUTING ! -d 192.168.21.212/24 -p tcp --dport 88 -j TPROXY --tproxy-mark 0x1/0x1 --on-port 3127
iptables -t mangle -A PREROUTING ! -d 192.168.21.212/24 -p tcp --dport 182 -j TPROXY --tproxy-mark 0x1/0x1 --on-port 3127
iptables -t mangle -A PREROUTING ! -d 192.168.21.212/24 -p tcp --dport 8081 -j TPROXY --tproxy-mark 0x1/0x1 --on-port 3127
iptables -t mangle -A PREROUTING ! -d 192.168.21.212/24 -p tcp --dport 8777 -j TPROXY --tproxy-mark 0x1/0x1 --on-port 3127
iptables -t mangle -A PREROUTING ! -d 192.168.21.212/24 -p tcp --dport 443 -j TPROXY --tproxy-mark 0x1/0x1 --on-port 3129
iptables -t mangle -A PREROUTING -d 192.168.21.212/32 -p tcp --dport 80 -j ACCEPT
iptables -t mangle -A PREROUTING -d 192.168.21.212/32 -p tcp --dport 5050 -j ACCEPT
iptables -t mangle -A PREROUTING -d 192.168.21.212/32 -p tcp --dport 8080 -j ACCEPT
iptables -t mangle -A PREROUTING -d 192.168.21.212/24 -p tcp --dport 88 -j ACCEPT
iptables -t mangle -A PREROUTING -d 192.168.21.212/24 -p tcp --dport 182 -j ACCEPT
iptables -t mangle -A PREROUTING -d 192.168.21.212/24 -p tcp --dport 8081 -j ACCEPT
iptables -t mangle -A PREROUTING -d 192.168.21.212/24 -p tcp --dport 8777 -j ACCEPT
iptables -t mangle -A PREROUTING -d 192.168.21.212/32 -p tcp --dport 443 -j ACCEPT
 
/sbin/ip rule add fwmark 1 lookup 100
/sbin/ip route add local 0.0.0.0/0 dev lo table 100
 
sysctl net.ipv4.ip_nonlocal_bind=1
sysctl net.ipv4.ip_forward=1
 
echo 0 > /proc/sys/net/ipv4/conf/lo/rp_filter
echo 1 > /proc/sys/net/ipv4/ip_forward
exit 0" > /etc/rc.local


# Set Permission dan restart daemon Squid
chmod +x /etc/init.d/squid
update-rc.d -f squid defaults
/etc/init.d/squid stop
chown -R proxy.proxy /cache1
chmod -R 777 /cache1
chown -R proxy.proxy /cache2
chmod -R 777 /cache2
chown -R proxy.proxy /cache3
chmod -R 777 /cache3
chown -R proxy.proxy /cache4
chmod -R 777 /cache4
mkdir -p /var/log/squid
chown -R proxy.proxy /var/log/squid*
chmod 4755 /usr/lib/squid/pinger
squid -z
squid -Nd1
clear
/etc/init.d/squid restart

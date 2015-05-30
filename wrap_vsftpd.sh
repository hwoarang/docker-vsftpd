#!/bin/bash
# Basic VSFTPD init wrapper
# Author: Markos Chandras <hwoarang@gentoo.org>

vsftpddir="/etc/vsftpd"

# First, create the user database
user=${FTPUSER-dockerftp}
pass=${FTPPASS-dockerftp}
echo "Creating the vsftpd PAM module"
echo "auth required pam_userdb.so crypt=hash db=${vsftpddir}/vsftpd_virt_users" > /etc/pam.d/vsftpd
echo "account required pam_userdb.so crypt=hash db=${vsftpddir}/vsftpd_virt_users" >> /etc/pam.d/vsftpd

echo "Creating the user database"
echo -e "${user}\n${pass}" > /tmp/userdb
db_load -T -t hash -f /tmp/userdb ${vsftpddir}/vsftpd_virt_users.db || \
	{ echo "Failed to create the ftp user database"; exit 1; }
rm /tmp/userdb

# Create (or clear) the log file
echo "Creating the logfile"
echo > /var/log/vsftpd.log

# The directory should always be there but lets just
# make sure it exists
[[ ! -d /var/ftp/pub ]] && mkdir -p /var/ftp/pub

# We don't care about the certificate details. Just make sure we do have one
echo "Creating the certificate"
openssl req -x509 -nodes -days 3650 -newkey rsa:4096 \
	-keyout ${vsftpddir}/vsftpd.pem -out ${vsftpddir}/vsftpd.pem \
	-batch || { echo "Failed to create the vsftpd certificate"; exit 1; }

# Do the final replacements on the template file
echo "Preparing the configuration file"
sed -i -e "s@PASV_MIN@${PASV_MIN}@" -e "s@PASV_MAX@${PASV_MAX}@" \
	-e "s@LISTEN@${LISTEN}@" ${vsftpddir}/vsftpd.conf || \
	{ echo "Failed to prepare the vsftpd configuration file"; exit 1; }

# Fix permissions
echo "Fixing permissions"
chmod 600 -R ${vsftpddir}

echo "Staring the vsftpd server"
vsftpd ${vsftpddir}/vsftpd.conf || \
	{ echo "Failed to execute vsftpd"; exit 1; }

# Off we go
exec tail -f /var/log/vsftpd.log

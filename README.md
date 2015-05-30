# Summary
Docker image files to create a Centos7 vsftpd server with SSL support.
It's using virtual users for data transfers and anonymous logins are disabled.
Uploads are disabled as well. The image is mostly useful as a quick way to share
existing files in case sharing via other methods (https, ssh etc) is not easily
available. I would certainly not recommend this image for production or mission
critical environments.

# Configuration

## The FTP directory
The FTP directory is located in */var/ftp/pub*. It might be a good idea to mount
a host directory there using Docker volumes.

## Environmental variables
The following environmental variables are being used by the image and you should
set them appropriately when you define your container. Using the default username
and password will not do any good to you. *Seriously!*

* PASV_MIN : Similar to the *pasv_min* vsftpd configuration option
* PASV_MAX : Similar to the *pasv_max* vsftpd configuration option
* LISTEN   : Similar to the *listen* vsftpd configuration option
* FTPUSER  : FTP virtual user
* FTPPASS  : Password for the FTP virtual user

You should consult the *vsftpd.conf* manpage for more information.

# Putting everything together

## Building the image
Build it like this (or something similar)

	docker build -t hwoarang/docker-vsftpd .

## Creating a container
This covers the case where you want one to one mapping between the host and container ports but it
should be easy to adapt it to match your needs

	docker run -d --env-file=vsftpd.env -v /home/user/project:/var/ftp/pub:ro --name "myvsftpd" -p 2000-2100:2000-2100 -p 21:21 hwoarang/docker-vsftpd

This assumes that you have a *vsftpd.env* file which sets the previously mentioned environmental variables and that you want to share the
*/home/user/project* host directory

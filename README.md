<pre>
# Aurba-Controller-Certificate-Installer
Upload a HTTPS certificate to an Aruba 3200 Mobility Controller via SSH command line

Requirements
ssh client
tftp server
expect package
openssl package

The Aruba 3200 Mobility controller does its file transfers via tftp

The certificate file used needs to be pfx format
LetsEncrypt normlly gives you a pem format

To covert pem to pfx use the following:
openssl pkcs12 -export -out my_cert.pfx -inkey privkey.pem -in fullchain.pem  -password pass:password

I'd like to acknowledge the following site for the actual instructions, I just automated them!

https://aventistech.com/kb/replace-certificate-on-aruba-controller/
https://aventistech.com/kb/replace-default-ssl-cert-in-aruba-instant-ap/

Cheers
Rick
</pre>

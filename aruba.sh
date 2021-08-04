#!/usr/bin/expect -f
#
# This Expect script was generated by autoexpect on Tue Aug  3 19:29:24 2021
# Expect and autoexpect were both written by Don Libes, NIST.
#
# Note that autoexpect does not guarantee a working script.  It
# necessarily has to guess about certain things.  Two reasons a script
# might fail are:
#
# 1) timing - A surprising number of programs (rn, ksh, zsh, telnet,
# etc.) and devices discard or ignore keystrokes that arrive "too
# quickly" after prompts.  If you find your new script hanging up at
# one spot, try adding a short sleep just before the previous send.
# Setting "force_conservative" to 1 (see below) makes Expect do this
# automatically - pausing briefly before sending each character.  This
# pacifies every program I know of.  The -c flag makes the script do
# this in the first place.  The -C flag allows you to define a
# character to toggle this mode off and on.

set force_conservative 0  ;# set to 1 to force conservative mode even if
<------><------><------>  ;# script wasn't run conservatively originally
if {$force_conservative} {
    set send_slow {1 .1}
    proc send {ignore arg} {
<------>sleep .1
<------>exp_send -s -- $arg
    }
}
#
# 2) differing output - Some programs produce different output each time
# they run.  The "date" command is an obvious example.  Another is
# ftp, if it produces throughput statistics at the end of a file
# transfer.  If this causes a problem, delete these patterns or replace
# them with wildcards.  An alternative is to use the -p flag (for
# "prompt") which makes Expect only look for the last line of output
# (i.e., the prompt).  The -P flag allows you to define a character to
# toggle this mode off and on.
#
# Read the man page for more info.
#
# -Don

set aruba_host aruba.local
set aruba_user admin
set aruba_pwd1 password
set aruba_pwd2 password

set tftp_server tftp.local

set cert_name my_cert.pfx
set cert_path /certs
set cert_pwd password
set cert_label my_cert-2020-08-03
#This is the label that will appear in the managment gui (Set to either cert start/end date)

set timestamp [timestamp -format %Y-%m-%d_%H-%M-%S]
set saved_running_config /aruba/aruba-$timestamp.txt

send -- "The current time is: $timestamp \r\n"

#Login to Controller
set timeout -1
spawn ssh $aruba_user@$aruba_host
expect  "assword:"
send -- "$aruba_pwd1\r"

#Elevate user
expect -exact "(Aruba) >"
send -- "enable\r"
expect -exact "Password:"
send -- "$aruba_pwd2\r"

#Save config (comment out if not required)
expect -exact "(Aruba) #"
send -- "copy running-config tftp: $tftp_server $saved_running_config\r"

#Get cert from tftp server
expect -exact "(Aruba) #"
send -- "copy tftp: $tftp_server $cert_path/$cert_name flash: $cert_name\r"

#Import cert
expect -exact "(Aruba) #"
send -- "crypto pki-import pfx serverCert $cert_label $cert_name $cert_pwd\r"

#install cert
expect -exact "(Aruba) #"
send -- "configure terminal\r"

expect -exact "(Aruba) (config) #"
send -- "crypto-local pki SERVERCERT $cert_label $cert_name\r"

expect -exact "(Aruba) (config) #"
send -- "end\r"

expect -exact "(Aruba) #"
send -- "write mem\r"

expect -exact "(Aruba) #"
send -- "configure terminal\r"

#Disable existing cert so we can switch to new cert
expect -exact "(Aruba) (config) #"
send -- "web-server no switch-cert\r"

#Switch to new cert
expect -exact "(Aruba) (config) #"
send -- "web-server switch-cert $cert_label\r"

expect -exact "(Aruba) (config) #"
send -- "end\r"

#Show status of certs (New cert should have a 1 in the reference column)
expect -exact "(Aruba) #"
send -- "show crypto-local pki serverCert\r"

send -- "exit\r"
send -- "exit\r"

expect eof

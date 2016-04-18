# le-serverpilot
SH script to install / manage Lets Encrypt for Server Pilot free users

#** PLEASE USE AT YOUR OWN RISK **

##Requirements

 * Ubuntu 14.04 
 * Server running with Serverpilot
 * Root / SUDO User Access
 * curl installed
 * Install in a non user home directory (so /etc/ will work fine)


---
##How to Install

```
cd /etc/
git clone https://github.com/dfinnema/le-serverpilot.git
cd le-serverpilot
chmod +x df.sh
```

##For development branch (for testing purposes):
```
cd /etc/
git clone -b development https://github.com/dfinnema/le-serverpilot.git
cd le-serverpilot
chmod +x df.sh
```

---
##How to Use

```
cd /etc/le-serverpilot
./df.sh
```
---

---

## Updating your version of le-serverpilot

You can use the command to check for new updates. 
```
cd /etc/le-serverpilot
git pull
```

## Config File

you can edit the config file to change the testing mode to 0 to not use the staging server at Lets Encrypt
As well as setup Mailgun to email you the result of each CRON job 

---

## Misc

Please note this is just a simple set of scripts quickly written. Feel free to fork it.
It uses the Shell script from (https://github.com/lukas2511/letsencrypt.sh) to do all the Lets Encrypt stuff (acme.sh). 

---
## Email result of CRON Jobs

By default it does not email anybody unless you edit the config file (copy a sample from config.sample) 
It uses mailgun (free to use) to send it as not all servers have the mail module installed by default. 

---
## Mailgun

You can create a free account over at mailgun.com and use the API to edit the config file to enable CRON Job results emails.
Mailgun has a guide on how to find your API key (https://help.mailgun.com/hc/en-us/articles/203380100-Where-can-I-find-my-API-key-and-SMTP-credentials-)

---
### FAQ

Q: Does this need to be run as ROOT / SUDO (it will automatically attempt to run itself with SUDO)

A: Yes at this time it requires ROOT or SUDO access as it needs to edit APACHE and NGINX configurations as well as for CRON jobs

Q: Where does it store the SSL files 

A: in a sub directory called 'certs' (eg; le-serverpilot/certs/)

Q: Where does it store my Lets Encrypt account 

A: in a sub directory called 'accounts' (eg; le-serverpilot/accounts)

Q: Does this support SNI (Server Name Indication)?

A: Yes it does but it needs to be able to verify all the domains from this server

Q: Does this use the official Lets Encrypt client

A: No it uses a very usefull script from (https://github.com/lukas2511/letsencrypt.sh) to do the heavy lifting

Q: How often will it renew the cert?

A: If the Certificate is older than 60 days it will renew the cert if run manually or through a CRON job

Q: Why not use Postfix

A: Not everybody knows how to setup up a local postfix config, if you have an easy way feel free to use a pull request

---
## Troubleshooting
Geting a Error:

Error: curl: command not found

Fix: Make sure that cURL is installed test with sudo curl -V 
if you get a line saying : -bash: curl: command not found.
Then you need to install cURL using: sudo apt-get install curl.
Ones done test with sudo curl -V. should give a long message starting with exp: curl 7.35.0

---
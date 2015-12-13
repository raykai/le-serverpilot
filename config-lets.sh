#!/bin/bash

# Lets Encrypt sh
RED='\033[0;31m'
NC='\033[0m' # No Color    
GREEN='\033[0;32m'


    echo -e ""
    echo -e " ###############################################################" 
    echo -e " ##             THIS WILL CONFIGURE LETS ENCRYPT              ##"
    echo -e " ##                                                           ##"
    echo -e " ##         ** this will overwrite previous configs **        ##"
    echo -e " ###############################################################" 
    
    echo ""
    
    echo -e "Do you want to ${RED}RUN THE SETUP${NC} for Lets Encrypt (y/n)?"
    echo -e "if you have previously created a configuration file it will overwrite it!"
    echo -e "It will also set a default email for SSL Cert"
    read DFRUN
    if [ $DFRUN == "y" ]; then
        echo "What is your email address you want to use for Lets Encrypt"
        read MYEMAIL
        
            # Check if string is empty using -z. For more 'help test'    
            if [[ -z "$MYEMAIL" ]]; then
               echo -e "${RED}NO EMAIL ENTERED${NC}"
               exit 1
            else
                        echo "RUNNING CONFIG STUFF..."
                        cd
                        cd letsencrypt
                        echo "
                        rsa-key-size = 4096
                        server = https://acme-v01.api.letsencrypt.org/directory
                        email = ${MYEMAIL}
                        text = true
                        authenticator = webroot
                        renew-by-default = true
                        agree-tos = true" > cli.ini
                        echo "DONE!"
            fi
        
    else
    echo "Nothing issued!"
	exit;
    fi
    
    
#!/bin/bash

# Lets Encrypt sh
RED='\033[0;31m'
NC='\033[0m' # No Color    
GREEN='\033[0;32m'


    echo -e ""
    echo -e " ###############################################################" 
    echo -e " ##      THIS WILL ISSUE A FREE 90 DAY SSL CERTIFICATE        ##"
    echo -e " ##                     FROM LETS ENCRYPT                     ##"
    echo -e " ###############################################################" 
    echo ""
    
    # Run   
    
    echo -e "Do you want to issue a ${RED}NEW${NC} SSL certificate (y/n)?"
    read DFRUN
    if [ $DFRUN == "y" ]; then
        
        echo "What is your email address you want to use for Lets Encrypt"
        read MYEMAIL
                
        # Check if string is empty using -z. For more 'help test'    
        if [[ -z "$MYEMAIL" ]]; then
            echo -e "${RED}NO EMAIL ENTERED${NC}"
            exit 1
        fi
    
    
        echo "What is your current app name?"
        read MYAPP
                
            # Check if string is empty using -z. For more 'help test'    
            if [[ -z "$MYAPP" ]]; then
               echo -e "${RED}NO APP ENTERED${NC}"
               exit 1
            else
                 #Parse Dir structure for APP
                MYAPP_DIR='/srv/users/serverpilot/apps/'$MYAPP'/public/'
                
                 # Lets check if the app exists
                if [ ! -d "$MYAPP_DIR" ]; then
                #if [  -d "$MYAPP_DIR" ]; then
                    echo -e "${RED}APP NOT FOUND${NC} - Check your spelling and try again";
                    exit;
                else
                    echo "Which domain name do wish to use for this cert?"
                    read MYDOMAIN
                    
                    if [[ -z "$MYDOMAIN" ]]; then
                        echo -e "${RED}NO DOMAIN ENTERED${NC}";
                        exit;
                    else
                        # Check if the Domain Exists
                         if [[ $(wget http://${MYDOMAIN}/ -O-) ]] 2>/dev/null
                          then echo " + Domain Valid"
                          else echo "ERROR: Invalid Domain";
                          exit;
                         fi
                    
                        # Create TMP CONFIG FILE
                        echo -e "WELLKNOWN='/srv/users/serverpilot/apps/${MYAPP}/public/.well-known/acme-challenge'" > config.sh
                        echo -e "CONTACT_EMAIL='${MYEMAIL}'" >> config.sh
                        # Create Domain text
                        echo -e "${MYDOMAIN}" > domains.txt
                        bash acme.sh -c -d $MYDOMAIN
                        
                        #Remove tmp files
                        rm domains.txt
                        rm config.sh
                    fi
                    
                fi
            fi
        
    else
    echo "Nothing issued!"
	exit;
    fi
    
    
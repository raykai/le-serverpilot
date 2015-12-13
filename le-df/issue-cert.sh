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
    
    echo -e "Do you want to issue a ${RED}NEW${NC} SSL certificate (y/n)?"
    read DFRUN
    if [ $DFRUN == "y" ]; then
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
                    echo -e "${RED}APP NOT FOUND${NC} - Check your spelling and try again";
                    exit;
                else
                    echo "Which domain name do wish to use for this cert?"
                    read MYDOMAIN

                    if [[ -z "$MYDOMAIN" ]]; then
                        echo -e "${RED}NO DOMAIN ENTERED${NC}";
                        exit;
                    else
                        echo "RUNNING SSL STUFF..."
                        cd letsencrypt
                        bash letsencrypt-auto -c cli.ini certonly --webroot-path=/srv/users/serverpilot/apps/$MYAPP/public/ --agree-tos -d $MYDOMAIN
                        echo "DONE!"
                        
                    fi
                    
                fi
            fi
        
    else
    echo "Nothing issued!"
	exit;
    fi
    
    
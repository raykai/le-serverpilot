#!/bin/bash

# Lets Encrypt sh
RED='\033[0;31m'
NC='\033[0m' # No Color    
GREEN='\033[0;32m'


    echo -e ""
    echo -e " ###############################################################" 
    echo -e " ##      THIS WILL RENEW A FREE 90 DAY SSL CERTIFICATE        ##"
    echo -e " ##                     FROM LETS ENCRYPT                     ##"
    echo -e " ###############################################################" 
    echo ""
    
    echo -e "Do you want to ${GREEN}RENEW${NC} a SSL certificate (y/n)?"
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
                    echo "What is your current domain name?"
                    read MYDOMAIN
                    
                    if [[ -z "$MYDOMAIN" ]]; then
                       echo -e "${RED}NO DOMAIN ENTERED${NC}"
                       exit 1
                    else
                        echo "RUNNING SSL STUFF..."
                        cd
                        cd letsencrypt
                        bash letsencrypt-auto -c cli.ini --renew certonly --webroot-path=/srv/users/serverpilot/apps/${MYAPP}/public/ -d ${MYDOMAIN} --agree-tos 
                        echo -e "Do you want to ${RED}RESTART${NC} nginx service (y/n)?"
                        read DFRUNR
                        if [ $DFRUNR == "y" ]; then
                            sudo service nginx-sp restart
                        else
                            echo "nothing restarted"
                        fi
                                                
                        echo "DONE!"
                    fi
                    
                fi
            fi
        
    else
    echo "Nothing issued!"
	exit;
    fi
    
    
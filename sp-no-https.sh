# HTTPS add into Serverpilot

RED='\033[0;31m'
NC='\033[0m' # No Color    
GREEN='\033[0;32m'

#==
echo -e "${RED}"
echo -e ""
echo -e " ###############################################################" 
echo -e " ##     THIS WILL REMOVE THE CUSTOM VHOST FOR SERVERPILOT     ##"
echo -e " ##                                                           ##"
echo -e " ##             ${NC}** USE AT YOUR OWN RISK **${RED}                    ##"
echo -e " ##                                                           ##"
echo -e " ###############################################################" 
echo -e "${NC}"


echo "Do you want to remove the custom conf file for HTTPS (y/n)?"
echo -e "${RED} ** this cannot be undone **${NC}"
echo ""
read DFRUN
if [[ "${DFRUN}" == "y" ]]; then
	echo "What is your current app name?"
    echo ""
	read MYAPP
    
# Check whether the app exists
    

                
        # Lets check if a custom conf exists
        MYAPP_FILE="${DF_CL_NGINX}/${MYAPP}.ssl.conf"
        if [[ ! -f ${MYAPP_FILE} ]]; then 
            echo -e "${RED}ERROR:${NC} NGINX CUSTOM CONFIG NOT FOUND"; 
            echo" - Check your spelling and try again"; 
            echo "   you may have not setup a ssl config yet"; 
            exit 1; 
        fi
        
        # Remove the custom files
 
        # START WITH NGINX-SP
        sudo rm -f -- "${MYAPP_FILE}"
        echo " + Custom Nginx Conf Removed for (${MYAPP})"
        
        # Lets check if a custom conf exists
        MYAPP_FILE="${DF_CL_APACHE}/${MYAPP}.custom.conf"
        if [[ ! -f ${MYAPP_FILE} ]]; then 
            echo -e "${RED}ERROR:${NC} APACHE SSL CONFIG NOT FOUND"; 
            echo" - Check your spelling and try again"; 
            echo "   you may have not setup a ssl config yet"; 
            exit 1; 
        fi
        
        # APACHE-SP
        sudo rm -f -- "${MYAPP_FILE}"
        echo " + Custom APACHE Conf Removed for (${MYAPP})"
        
        # Remove the HTTPS ONLY REDIRECT if it exists
        if [[ ! -f "${DF_CL_NGINX}/${MYAPP}.d/redirect.nonssl_conf" ]]; then
            sudo rm -f -- "${DF_CL_NGINX}/${MYAPP}.d/redirect.nonssl_conf"
            echo " + Removed SSL ONLY Redirect"
        fi

        
            #ALL DONE, Lets restart both services
            echo -e "Do you want to ${RED}RESTART${NC} NGINX service (y/n)?"
            echo " - this is needed to turn off SSL"
            read DFRUNR
            if [ "${DFRUNR}" == "y" ]; then
                sudo service nginx-sp restart
                sudo service apache-sp restart
                echo -e " ${GREEN}+ DONE${NC}"
                exit;
            else
                echo "No services restarted, config files have been removed"
                echo "your nginx & apache service needs to be restarted in order for the changes to reflected"
            fi

fi

else
	echo -e "Keep SSL? Left the conf files alone!"
fi


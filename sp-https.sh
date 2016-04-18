# HTTPS add into Serverpilot

RED='\033[0;31m'
NC='\033[0m' # No Color    
GREEN='\033[0;32m'
STS=""
STSA=""
SSLR=""
SSLRA=""

#==

echo -e "${GREEN}"
echo -e ""
echo -e " ###############################################################" 
echo -e " ##   THIS WILL ADD HTTPS TO A CUSTOM VHOST FOR SERVERPILOT   ##"
echo -e " ##                                                           ##"
echo -e " ##             ${NC}** USE AT YOUR OWN RISK **${GREEN}                    ##"
echo -e " ##                                                           ##"
echo -e " ###############################################################" 
echo -e "${NC}"

echo "Do you want to add a custom conf file for HTTPS (y/n)?"
read DFRUN
if [[ "${DFRUN}" == "y" ]]; then

	echo "What is your current app name?"
	read MYAPP
	echo -e "What is the domain name you want to use?"
    echo ""
    read MYDOMAIN
    echo -e "If you are using SNI please enter the ${GREEN}PRIMARY${NC} domain"
    echo "   if using multiple domains please use the first one"
    echo "   NOT using SNI? You can leave this blank"
    echo "   NOTE: www.mydomain and mydomain are not the same and need to be"
    echo "         added seperatly using SNI"
    echo ""
	read MYDOMAIN_SNI
    echo "Do you want to add 6 Month Policy Strict-Transport-Security (y/n)?"
    echo " - helps prevent protocol downgrade attacks"
    echo -e " ${RED}WARNING:${NC} you cannot go back to non-ssl on this domain"
    echo ""
    read DFSTSA1
    #echo "Do you want enable SSL only (y/n)?"
    #echo " - only allows access by SSL (auto-redirects 301)"
    #echo ""
    #read DFSSLONLY
   
   # Check if the APP EXISTS
    if [[ ! -d "${DF_CL_NGINX}/${MYAPP}.d" ]]; then
        echo -e "${RED}ERROR: ${NC} APP Not found"
        echo " - Please check the spelling and try again"
        echo "   (${DF_CL_NGINX}/${MYAPP}.d)"
        exit 1;
    fi
    
# Check whether a cert has been issued

    # SNI check
    if [[ ! "${MYDOMAIN_SNI}" == "" ]]; then
        echo " + Using SNI Cert with domain (${MYDOMAIN_SNI})"
        #Parse Dir structure for APP
        MYDOMAIN_DIR="${BASEDIR}/certs/${MYDOMAIN_SNI}"
    else
        MYDOMAIN_DIR="${BASEDIR}/certs/${MYDOMAIN}"
    fi

    # Lets check if the app exists
    if [[ ! -d "$MYDOMAIN_DIR" ]]; then
        echo -e "${RED}ERROR: ${NC}Domain SSL cert not found";
        echo -e " - make sure you issued your certificate before running this";
        echo -e " - check your spelling and try again";
        exit;
    else
    
        #Parse Dir structure for APP
        MYAPP_DIR='/srv/users/serverpilot/apps/'$MYAPP'/public/'
                
        # Lets check if the app exists
        if [[ ! -d "$MYAPP_DIR" ]]; then
            echo -e "${RED}APP NOT FOUND${NC} - Check your spelling and try again";
            exit;
        else

        if [[ "${DFSTSA1}" == "y" ]]; then
            echo " + Adding Strict-Transport-Security 6 Month Policy"
            STS="add_header Strict-Transport-Security max-age=15768000;"
        fi
        
        if [[ "${DFSSLONLY}" == "y" ]]; then
            echo " + Adding SSL ONLY Redirect"
            echo -e ="
            # Add a HHTPS ONLY REDIRECT
            location / 
            {
                return  301 https://\$server_name\$request_uri;
            }
            " | sudo tee "${DF_CL_NGINX}/${MYAPP}.d/redirect.nonssl_conf" > /dev/null
    
        fi

        # START WITH NGINX-SP
        
        TMP_HEADERADD="add_header X-XSS-Protection '1; mode=block';"

        echo -e "
#####################################################
# DO NOT EDIT THIS FILE. 
# It has been generated using
# https://github.com/dfinnema/le-serverpilot
#####################################################

# EXTRA SECURITY HEADERS
add_header X-Content-Type-Options nosniff;
add_header X-XSS-Protection \"1; mode=block;\";
$TMP_HEADERADD

server 
{
    listen   443 ssl http2;
    server_name ${MYDOMAIN};
    
    root   /srv/users/serverpilot/apps/$MYAPP/public;
    
    ssl on;
    ssl_certificate ${MYDOMAIN_DIR}/fullchain.pem;
    ssl_certificate_key ${MYDOMAIN_DIR}/privkey.pem;
    ssl_trusted_certificate ${MYDOMAIN_DIR}/fullchain.pem;
    
    ssl_session_timeout 1d;
    ssl_session_cache shared:SSL:50m;
    ssl_session_tickets off;
    
    # Based on a Intermediate config from Mozilla's SSL Generator
    ssl_protocols TLSv1 TLSv1.1 TLSv1.2;
    ssl_ciphers 'ECDHE-RSA-AES128-GCM-SHA256:ECDHE-ECDSA-AES128-GCM-SHA256:ECDHE-RSA-AES256-GCM-SHA384:ECDHE-ECDSA-AES256-GCM-SHA384:DHE-RSA-AES128-GCM-SHA256:DHE-DSS-AES128-GCM-SHA256:kEDH+AESGCM:ECDHE-RSA-AES128-SHA256:ECDHE-ECDSA-AES128-SHA256:ECDHE-RSA-AES128-SHA:ECDHE-ECDSA-AES128-SHA:ECDHE-RSA-AES256-SHA384:ECDHE-ECDSA-AES256-SHA384:ECDHE-RSA-AES256-SHA:ECDHE-ECDSA-AES256-SHA:DHE-RSA-AES128-SHA256:DHE-RSA-AES128-SHA:DHE-DSS-AES128-SHA256:DHE-RSA-AES256-SHA256:DHE-DSS-AES256-SHA:DHE-RSA-AES256-SHA:ECDHE-RSA-DES-CBC3-SHA:ECDHE-ECDSA-DES-CBC3-SHA:AES128-GCM-SHA256:AES256-GCM-SHA384:AES128-SHA256:AES256-SHA256:AES128-SHA:AES256-SHA:AES:CAMELLIA:DES-CBC3-SHA:!aNULL:!eNULL:!EXPORT:!DES:!RC4:!MD5:!PSK:!aECDH:!EDH-DSS-DES-CBC3-SHA:!EDH-RSA-DES-CBC3-SHA:!KRB5-DES-CBC3-SHA';
    ssl_prefer_server_ciphers on;
    
    ssl_stapling on;
    ssl_stapling_verify on;
    ${STS}
    
    access_log  /srv/users/serverpilot/log/$MYAPP/${MYAPP}_nginx.access.log  main;
    error_log  /srv/users/serverpilot/log/$MYAPP/${MYAPP}_nginx.error.log;
    
    proxy_set_header    Host  \$host;
    proxy_set_header    X-Real-IP         \$remote_addr;
    proxy_set_header    X-Forwarded-For   \$proxy_add_x_forwarded_for;
    proxy_set_header    X-Forwarded-SSL on;
    proxy_set_header    X-Forwarded-Proto \$scheme;
    
    include /etc/nginx-sp/vhosts.d/$MYAPP.d/*.conf;
}
" | sudo tee "${DF_CL_NGINX}/$MYAPP.ssl.conf" > /dev/null

        echo " + Added custom NGINX Conf for (${MYAPP})"
        
        #Lets add APACHE (otherwise we will get 404 errors)
echo -e "
#####################################################
# DO NOT EDIT THIS FILE. 
# It has been generated using
# https://github.com/dfinnema/le-serverpilot
#####################################################
<VirtualHost 127.0.0.1:81>
    Define DOCUMENT_ROOT /srv/users/serverpilot/apps/${MYAPP}/public
    Define PHP_PORT 17084
    Define PHP_PROXY_URL fcgi://127.0.0.1:\${PHP_PORT}

    ServerAdmin webmaster@
    DocumentRoot \${DOCUMENT_ROOT}
    ServerName server-${MYAPP}
    ServerAlias ${MYDOMAIN}

    ErrorLog "/srv/users/serverpilot/log/${MYAPP}/${MYAPP}_apache.error.log"
    CustomLog "/srv/users/serverpilot/log/${MYAPP}/${MYAPP}_apache.access.log" common

    RemoteIPHeader X-Real-IP
    SetEnvIf X-Forwarded-SSL on HTTPS=on

    IncludeOptional /etc/apache-sp/vhosts.d/${MYAPP}.d/*.conf
</VirtualHost>

<VirtualHost 127.0.0.1:443>
    Define DOCUMENT_ROOT /srv/users/serverpilot/apps/${MYAPP}/public
    
    ServerAdmin webmaster@
    DocumentRoot \${DOCUMENT_ROOT}
    ServerName server-${MYAPP}
    ServerAlias ${MYDOMAIN}

    SSLEngine on
    SSLCertificateFile      ${MYDOMAIN_DIR}/fullchain.pem
    SSLCertificateChainFile ${MYDOMAIN_DIR}/fullchain.pem
    SSLCertificateKeyFile   ${MYDOMAIN_DIR}/privkey.pem
    SSLCACertificateFile    ${MYDOMAIN_DIR}/fullchain.pem
    
    SSLProtocol             all -SSLv2 -SSLv3
    SSLCipherSuite          ECDHE-RSA-AES128-GCM-SHA256:ECDHE-ECDSA-AES128-GCM-SHA256:ECDHE-RSA-AES256-GCM-SHA384:ECDHE-ECDSA-AES256-GCM-SHA384:DHE-RSA-AES128-GCM-SHA256:DHE-DSS-AES128-GCM-SHA256:kEDH+AESGCM:ECDHE-RSA-AES128-SHA256:ECDHE-ECDSA-AES128-SHA256:ECDHE-RSA-AES128-SHA:ECDHE-ECDSA-AES128-SHA:ECDHE-RSA-AES256-SHA384:ECDHE-ECDSA-AES256-SHA384:ECDHE-RSA-AES256-SHA:ECDHE-ECDSA-AES256-SHA:DHE-RSA-AES128-SHA256:DHE-RSA-AES128-SHA:DHE-DSS-AES128-SHA256:DHE-RSA-AES256-SHA256:DHE-DSS-AES256-SHA:DHE-RSA-AES256-SHA:ECDHE-RSA-DES-CBC3-SHA:ECDHE-ECDSA-DES-CBC3-SHA:AES128-GCM-SHA256:AES256-GCM-SHA384:AES128-SHA256:AES256-SHA256:AES128-SHA:AES256-SHA:AES:CAMELLIA:DES-CBC3-SHA:!aNULL:!eNULL:!EXPORT:!DES:!RC4:!MD5:!PSK:!aECDH:!EDH-DSS-DES-CBC3-SHA:!EDH-RSA-DES-CBC3-SHA:!KRB5-DES-CBC3-SHA
    SSLHonorCipherOrder     on
    
    RemoteIPHeader X-Real-IP
    SetEnvIf X-Forwarded-SSL on HTTPS=on

    ErrorLog \"/srv/users/serverpilot/log/${MYAPP}/${MYAPP}_apache.error.log\"
    CustomLog \"/srv/users/serverpilot/log/${MYAPP}/${MYAPP}_apache.access.log\" common

</VirtualHost>
" | sudo tee "${DF_CL_APACHE}/$MYAPP.custom.conf" > /dev/null

            echo " + Added custom APACHE Conf for (${MYAPP})"

        
            #ALL DONE, Lets restart both services
            echo -e "Do you want to ${RED}RESTART${NC} Nginx & Apache service (y/n)?"
            echo " - needed to reflect changes"
            echo ""
            read DFRUNR
            if [ "${DFRUNR}" == "y" ]; then
                sudo service nginx-sp restart
                sudo service apache-sp restart
                echo -e "${GREEN} + Done${NC}"
                exit;
            else
                echo "No services restarted, SSL config has been setup."
                echo "your nginx & apache service needs to be restarted for SSL to be enabled"
            fi
        
        fi

fi

else
	echo -e "No SSL? Left the conf files alone!"
fi


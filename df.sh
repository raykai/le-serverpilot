#!/bin/bash

# Config Default Options
CONTACT_EMAIL=
TESTING=0
DF_CRON_DOMAIN=""
DF_MAIL_API=
DF_MAIL=0
DF_MAIL_DOMAIN=
DF_MAIL_FROM_NAME=
DF_MAIL_FROM_EMAIL=
DF_MAIL_TO=
DF_AUTO_RUN=0

# Colors (may not work in all environments)
RED='\033[0;31m'
NC='\033[0m' # No Color    
GREEN='\033[0;32m'
SCRIPTDIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"

# The current dir from the running script (without a trailing slash)
BASEDIR="${SCRIPTDIR}"

# Start from working dir
cd ${BASEDIR}

# Folder locations for Account keys (no trailing slash)
DF_ACCOUNT_DIR="${BASEDIR}/accounts"
DF_ACCOUNT_DIR_T="${DF_ACCOUNT_DIR}/staging"
DF_ACCOUNT_D="default.config"
DF_LOG="${BASEDIR}/cron.logtmp"
DF_LOG_ALL="${BASEDIR}/cron.log"

# The filename found in each domain directory (eg; certs/mydomain/)
# Holds the domain name and SNI's (if any)
DF_ACCOUNT_DOMAIN="domain.config"
DF_ACCOUNT_DOMAIN_CRON="cron.config"

# Config File (see config.sample)
CFDF=${BASEDIR}'/config'
# TMP CONFIG FILE
CFDFT=${BASEDIR}'/tmp.df' 

# Location of Vhosts
DF_CL_APACHE="/etc/apache-sp/vhosts.d"
DF_CL_NGINX="/etc/nginx-sp/vhosts.d"

# directory of auto-challenge (no trailing slash)
AUTODF=${BASEDIR}'/auto-challenge'

# Create any folders we may need if they do not exist
if [ ! -d "${DF_ACCOUNT_DIR}" ]; then mkdir -p ${DF_ACCOUNT_DIR}; mkdir -p ${DF_ACCOUNT_DIR_T}; fi
if [ ! -d "${BASEDIR}/certs" ]; then mkdir -p "${BASEDIR}/certs"; fi
if [ ! -d "${AUTODF}" ]; then mkdir -p "${AUTODF}"; fi

# Get the Config File
if [ -e "${CFDF}" ]; then
        # Load Config File
        . ${CFDF}
        # EXPORT NEEDED VAR
        export RED
        export NC
        export GREEN
        export SCRIPTDIR
        export BASEDIR
        export TESTING
        export CONTACT_EMAIL
        export CFDFT
        export CFDF
        export AUTODF
        export DF_ACCOUNT_DIR
        export DF_ACCOUNT_DIR_T
        export DF_ACCOUNT_REG
        export DF_ACCOUNT_D
        export DF_ACCOUNT_DOMAIN
        export DF_ACCOUNT_DOMAIN_CRON
        export DF_CL_APACHE
        export DF_CL_NGINX
        export DF_LOG
        export DF_AUTO_RUN
        
    else
        echo -e "${RED}WARNING: NO CONFIG FILE FOUND${NC}"
        echo -e " - Please create '${CFDF}'"
        echo -e " - You can copy the config.sample"
        exit 1;
    fi
    
# Check for parameters
if [ ! -z "$1" ]; then 

    # EXAMPLE
    # df.sh -c MYDOMAIN
    # MYDOMAIN = primary domain for the SSL CERT (it will automaticly find SNI domains)
    
    # A Paramater has been set, lets check what is needed
    if [[ "$1" == "-c" ]]; then
        # Its a Cronjob!
        #lets check what domain they want to renew
        if [ -z "$2" ]; then echo "Please specify a primary domain for an existing cert"; exit 1; fi
        # Set Varible for the remainder
        DF_CRON_DOMAIN=$2
        export DF_CRON_DOMAIN
        echo "" > $DF_LOG 2>&1
        echo "CRON JOB STARTING - $(zdump UTC)" >> $DF_LOG 2>&1
        echo " + Starting Auto Renew..." >> $DF_LOG 2>&1
        DF_AUTO_RUN=1
        sudo -E -n bash "${BASEDIR}/renew-cert-auto.sh" 2>&1; 
        echo "END OF CRON JOB" >> $DF_LOG 2>&1;
        DF_TMP_EMAIL=$(<${DF_LOG})
        
        if [[ "${DF_MAIL}" == 1 ]]; then 
        # Send an email with the results (uses Mailgun - set options in the config file)
        curl -s --user 'api:'"${DF_MAIL_API}"'' \
            https://api.mailgun.net/v3/${DF_MAIL_DOMAIN}/messages \
            -F from=''"${DF_MAIL_FROM_NAME}"' <'"${DF_MAIL_FROM_EMAIL}"'>' \
            -F to=''"${DF_MAIL_TO}"'' \
            -F subject='[VITA AI] Domain '"${DF_CRON_DOMAIN}"' SSL' \
            -F text=''"${DF_TMP_EMAIL}"'' > /dev/null 2>&1 
<<<<<<< HEAD
=======
        else
        echo -e "${RED}WARNING:${NC} NO LOGS EMAILED, edit 'config' to set this up"
>>>>>>> development
        fi
        
        # Add to main log filename
        echo -e "${DF_TMP_EMAIL}" >> ${DF_LOG_ALL}
        rm -- ${DF_LOG}
        echo "Finished running Auto Script"
        echo " > see (${DF_LOG_ALL}) for full details"
<<<<<<< HEAD
=======
        
>>>>>>> development
        exit;
        
    fi
    
    exit;
fi


# Menu Time
function press_enter
{
    echo ""
    echo -n "Press [ENTER] to continue"
    read
    clear
}

selection=
until [ "$selection" = "0" ]; do
    echo -e "${GREEN}"
    echo -e ""
    echo -e " ###############################################################" 
    echo -e " ##   THIS SCRIPT WILL MANAGE LETS ENCRYPT FOR SERVERPILOT    ##"
    echo -e " ##                                                           ##"
    echo -e " ##                ${NC}** USE AT YOUR OWN RISK **${GREEN}                 ##"
    echo -e " ##                                                           ##"
    echo -e " ###############################################################" 
    echo -e "${NC}"
    
    echo ""
    echo " ** What would you like to do? **"
    echo ""
    echo "Lets Encrypt Options"
    if [[ "${TESTING}" == 1 ]]; then
        echo -e "  1) Issue a ${RED}*TEST DUMMY*${NC} CERT" 
        echo -e "  2) Renew a ${RED}*TEST DUMMY*${NC} CERT" 
        echo -e "  3) Revoke a ${RED}*TEST DUMMY*${NC} CERT"
        echo ""
        echo -e "  4) ${RED}*TEST DUMMY*${NC} Account Management"

    else
        echo "  1) Issue a CERT"
        echo "  2) Renew a CERT" 
        echo "  3) Revoke a CERT"
        echo ""
        echo "  4) Account Management"
    fi
    echo "  5) CRON Jobs"
    echo ""    
    echo "Server Pilot Options"
    echo "  8) Activate SSL (issue a cert first)"
    echo "  9) Deactivate SSL"
    echo ""
    echo "  q) Quit"
    echo ""
    echo -n "Enter selection: "
    read selection
    echo ""
    case $selection in
        1 ) sudo -E -n bash issue-cert.sh; press_enter ;;
        2 ) sudo -E -n bash renew-cert.sh; press_enter ;;
        3 ) bash revoke.sh; press_enter ;;
        4 ) bash account.sh; press_enter ;;
        5 ) sudo -E -n bash cron.sh; press_enter ;;
        8 ) sudo -E -n bash sp-https.sh; press_enter ;;
        9 ) sudo -E -n bash sp-no-https.sh; press_enter ;;
        q ) exit ;;
        0 ) exit ;;
        * ) echo "Please choose an option"; press_enter
    esac
done
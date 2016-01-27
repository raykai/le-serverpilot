#!/bin/bash

    echo -e ""
    echo -e " ###############################################################" 
    echo -e " ##                    CRON JOB MANAGEMENT                    ##"
    echo -e " ###############################################################" 
    echo ""
    echo " This allows you to set and forgot your SSL Renewals"
    echo " by having the server use a CRON JOB to do this"
    echo ""
    
    
    echo -e "  1) Create a New CRON JOB"
    echo -e "  2) Delete an Existing CRON JOB"
    
    echo ""
    echo -n "Selection: "
    read DF_TMP_INPUT
    # Get User input
    
    # CREATE A NEW CRON JOB
    if [[ "${DF_TMP_INPUT}" == "1" ]]; then
    
        # Check which domain they wish to set a CRON JOB FOR
        echo "Which PRIMARY domain you wish to setup"
        echo -n " > http://"
        read DF_TMP_CRON_DOMAIN
        echo ""
        # Check for empty input
        if [[ "${DF_TMP_CRON_DOMAIN}" == "" ]]; then echo -e "${RED}ERROR:${NC} No domain entered"; exit 1; fi
        # Check if a folder exists (where the SSL certs are stored)
        if [[ ! -d "${BASEDIR}/certs/${DF_TMP_CRON_DOMAIN}" ]]; then echo -e "${RED}ERROR:${NC} No SSL certs exist under this domain"; exit 1; fi
        # Now lets ask questions about the CRON JOB
        # 1) Lets ask which email you are using (incase of multiple LE ACCOUNTS) 
        echo "Which email do you wish to use for this cron job?"
        echo -n " > "
        read DF_TMP_CRON_EMAIL
        echo ""
        # Check for empty input
        if [[ "${DF_TMP_CRON_EMAIL}" == "" ]]; then echo -e "${RED}ERROR:${NC} No email entered"; exit 1; fi
        # IF in testing mode allow only access to STAGING accounts and vice versa
        if [[ "${TESTING}" == 1 ]]; then DF_TMP_ACCD=${DF_ACCOUNT_DIR_T}; else DF_TMP_ACCD=${DF_ACCOUNT_DIR}; fi
        # Check if an account file exists (where the Email accounts are stored)
        if [[ ! -f "${DF_TMP_ACCD}/${DF_TMP_CRON_EMAIL}.pem" ]]; then echo -e "${RED}ERROR:${NC} No email accounts exist under this email"; exit 1; fi
        
        echo " + Added Domains to cron"
        echo " + Added Email account to cron"
        
        # Now lets create a CRON config file in the dir where the certs are (overwrite it if it already exists!)
        echo -e "# AUTO GENRATED, DO NOT EDIT" > "${BASEDIR}/certs/${DF_TMP_CRON_DOMAIN}/${DF_ACCOUNT_DOMAIN_CRON}"
        echo -e "DF_CRON_EMAIL='${DF_TMP_CRON_EMAIL}'" >> "${BASEDIR}/certs/${DF_TMP_CRON_DOMAIN}/${DF_ACCOUNT_DOMAIN_CRON}"
        echo " + CRON Config file created"
        
        # Passed all checks, now lets make some automation happen !
       
        # Now lets setup a cron job that goes off every month at 3.14am on the 3rd of every month
        # should a renewal fail it will allow you to fix it for another 2  months (plenty of time)
        # the reason we are outputting it to dev/null is because the command already logs its own things (no need to do this twice)
        
        # minutes , hours, day 
        
        # REMOVE (just in case it already exists)
        #(crontab -l ; echo "52 9 * * * ${BASEDIR}/df.sh -c ${DF_TMP_CRON_DOMAIN} >/dev/null 2>&1") 2>&1 | grep -v 'no crontab' | grep -v df.sh |  sort | uniq | crontab -
        # ADD
        (crontab -l ; echo "14 3 3 * * ${BASEDIR}/df.sh -c ${DF_TMP_CRON_DOMAIN} >/dev/null 2>&1") 2>&1 | grep -v 'no crontab' | sort | uniq | crontab -

        echo ""
        echo -e "${GREEN}SUCCESS:${NC} CRON JOB SETUP COMPLETE (running every 3rd of the month at 3:14am)"
        exit;
    fi
    
    # DEL A CRON JOB
    if [[ "${DF_TMP_INPUT}" == "2" ]]; then
    
        # Which DOMAIN?
        echo "Which PRIMARY domain you wish to remove from a CRONJOB?"
        echo -n " > http://"
        read DF_TMP_CRON_DOMAIN
        echo ""
        
        # Check for empty input
        if [[ "${DF_TMP_CRON_DOMAIN}" == "" ]]; then echo -e "${RED}ERROR:${NC} No domain entered"; exit 1; fi
        # Check if a folder exists (where the SSL certs are stored)
        if [[ ! -d "${BASEDIR}/certs/${DF_TMP_CRON_DOMAIN}" ]]; then echo -e "${RED}ERROR:${NC} No SSL certs exist under this domain"; exit 1; fi
        
        echo "Removing Automation for ${DF_TMP_CRON_DOMAIN}"
        # Delete the cron.config file
        if [[ -f "${BASEDIR}/certs/${DF_TMP_CRON_DOMAIN}/${DF_ACCOUNT_DOMAIN_CRON}" ]]; then 
            rm -- "${BASEDIR}/certs/${DF_TMP_CRON_DOMAIN}/${DF_ACCOUNT_DOMAIN_CRON}"
            echo " + Removed Cron.config from (${DF_TMP_CRON_DOMAIN})"
        fi
        
        # Remove the cron job
        (crontab -l ; echo "14 3 3 * * ${BASEDIR}/df.sh -c ${DF_TMP_CRON_DOMAIN} >/dev/null 2>&1") 2>&1 | grep -v "no crontab" | grep -v df.sh |  sort | uniq | crontab -
        echo " + Cron job removed"
        echo -e "${GREEN}SUCCESS:${NC} REMOVAL COMPLETED"
        
        exit;
    fi
   
exit 1;

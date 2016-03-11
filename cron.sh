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
        echo "Which PRIMARY domain do you wish to setup"

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

        
        # 1) Lets ask which email you are using (incase of multiple LE ACCOUNTS) - lets find all the accounts we have
        if [ $TESTING == 1 ]; then DF_TMP_ACCD=${DF_ACCOUNT_DIR_T}; else DF_TMP_ACCD=${DF_ACCOUNT_DIR}; fi
        for AccountFC in $(find ${DF_TMP_ACCD}/*.pem -maxdepth 0 -type f ); 
            do
                AccountF=$(basename $AccountFC);
                    
                # Display Filename (without ext)
                DF_TMP_TXT=${DF_TMP_TXT}" > $(basename $AccountF .pem)\n";
                DFC=$((DFC + 1))
                DFCO=${AccountF};     
            done
               
        # No Accounts found in saved location or config file
        if [[ ${DFC} == 0 ]]; then echo -e "${RED}ERROR:${NC} No accounts found"; exit 1; fi
        DF_TMP_INPUT=
        DF_TMP_INPUT_MAIL=
        #Ask which one they wish to use
        echo "The following accounts were found"
        echo -e " ${DF_TMP_TXT}";
        echo ""
        echo -e "Which one do you wish to use for CRON job?

        echo -n " > "
        read DF_TMP_CRON_EMAIL
        echo ""
        # Check for empty input
        if [[ "${DF_TMP_CRON_EMAIL}" == "" ]]; then echo -e "${RED}ERROR:${NC} No email entered"; exit 1; fi
        # IF in testing mode allow only access to STAGING accounts and vice versa
        if [[ "${TESTING}" == 1 ]]; then DF_TMP_ACCD=${DF_ACCOUNT_DIR_T}; else DF_TMP_ACCD=${DF_ACCOUNT_DIR}; fi
        # Check if an account file exists (where the Email accounts are stored)
        if [[ ! -f "${DF_TMP_ACCD}/${DF_TMP_CRON_EMAIL}.pem" ]]; then echo -e "${RED}ERROR:${NC} No email accounts exist under this email"; exit 1; fi
        


        # Check if we are emailing the user the cron log file each time it has been run (once a month)
        if [[ "${DF_MAIL}" == 0 ]]; then echo -e " ${RED}- WARNING:${NC} No email sending configured in the config file"
        

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

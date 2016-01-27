#!/bin/bash

    echo -e ""
    echo -e " ###############################################################" 
    echo -e " ##                  ACCOUNT KEY MANAGEMENT                   ##"
    echo -e " ##                     FROM LETS ENCRYPT                     ##"
    echo -e " ###############################################################" 
    echo ""
    
    DF_TMP_D=""; DF_TMP_DD=0
    if [[ "${TESTING}" == 1 ]]; then DF_TMP_D="${RED}*STAGING*${NC} "; fi
    if [[ "${TESTING}" == 1 ]]; then DF_TMP_ACCD=${DF_ACCOUNT_DIR_T}; else DF_TMP_ACCD=${DF_ACCOUNT_DIR}; fi
    if [[ -f "${DF_TMP_ACCD}/${DF_ACCOUNT_D}" ]]; then DF_TMP_DD=1; . "${DF_TMP_ACCD}/${DF_ACCOUNT_D}"; fi
    
    if [[ ${DF_TMP_DD} == 0 ]]; then echo -e "${RED} ** WARNING:${NC} NO DEFAULT ACCOUNT SET **"; echo ""; fi
    
    echo -e "  1) Create a New ${DF_TMP_D}Account"
    echo -e "  2) Delete an Existing ${DF_TMP_D}Account"
    echo ""
    echo -e "  d) Set a default ${DF_TMP_D}Account"
    if [[ ${DF_TMP_DD} == 1 ]]; then echo -e "      - Current account: ${GREEN}${CONTACT_EMAIL}${NC}"; fi
    echo ""
    
    
    
    # Get User input
    read DF_TMP_INPUT
    
    
    # CREATE A NEW ACCOUNT
    if [[ "${DF_TMP_INPUT}" == "1" ]]; then
        
        # Create new account
        echo ""
        echo "Please enter an email address"
        read DF_TMP_INPUT_MAIL
        
        if [[ "${DF_TMP_INPUT_MAIL}" == "" ]]; then echo -e "${RED}ERROR:${NC} please enter an email"; exit 1; fi
    
        # Set to manual registration
        echo -e "CONTACT_EMAIL='${DF_TMP_INPUT_MAIL}'" > ${CFDFT}
        echo -e "DF_ACCOUNT_REG=1" >> ${CFDFT}
        
        if [ $TESTING == 1 ]; then
            echo -e 'CA="https://acme-staging.api.letsencrypt.org/directory"' >> ${CFDFT}
            echo -e "PRIVATE_KEY='${DF_ACCOUNT_DIR_T}/${DF_TMP_INPUT_MAIL}.pem'" >> ${CFDFT}
        else
            echo -e 'CA="https://acme-v01.api.letsencrypt.org/directory"' >> ${CFDFT}
            echo -e "PRIVATE_KEY='${DF_ACCOUNT_DIR}/${DF_TMP_INPUT_MAIL}.pem'" >> ${CFDFT}
        fi
        
        bash "${BASEDIR}/acme.sh" -c --config ${CFDFT}
        
    fi
    
    if [[ "${DF_TMP_INPUT}" == "2" ]]; then
        # Delete an existing account
        # Look through the account directory
        DFC=0; DF_TMP_TXT=""; DFCO=
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
        if [[ ${DFC} == 0 ]]; then echo "No accounts found"; exit 1; fi
        DF_TMP_INPUT=
        DF_TMP_INPUT_MAIL=
        #Ask which one they wish to use
        echo "The following accounts were found"
        echo -e " ${DF_TMP_TXT}";
        echo ""
        echo -e "Which one do you wish to ${RED}DELETE${NC}?"
        read DF_TMP_INPUT
                        
        # Check if we have a key file for this email?
        if [ -f "${DF_TMP_ACCD}/${DF_TMP_INPUT}.pem" ]; then 
            echo ""
            echo "Are you sure you wish to remove (${DF_TMP_INPUT})? (y/n)"
            read DF_TMP_INPUT_MAIL
            echo ""
            echo "Removing account..."
            if [[ "${DF_TMP_INPUT_MAIL}" == "y" ]]; then
                # DELETE THE FILE
                
                rm -- "${DF_TMP_ACCD}/${DF_TMP_INPUT}.pem"
                echo " + Account removed"
            else
                echo " - Account not removed"
                exit 1;
            fi
        else
            echo "Account not found"
            exit 1;
        fi
    fi
                
    if [[ "${DF_TMP_INPUT}" == "d" ]]; then
        # SET DEFAULT EMAIL
        # Look through the account directory
        DFC=0; DF_TMP_TXT=""; DFCO=
        for AccountFC in $(find ${DF_TMP_ACCD}/*.pem -maxdepth 0 -type f ); 
            do
                AccountF=$(basename $AccountFC);
                # Display Filename (without ext)
                DF_TMP_TXT="${DF_TMP_TXT} > $(basename $AccountF .pem)\n";
                DFC=$((DFC + 1))
                DFCO=${AccountF};     
            done

        # No Accounts found in saved location or config file
        if [[ ${DFC} == 0 ]]; then echo "No accounts found, please create one"; exit 1; fi
        DF_TMP_INPUT=
        DF_TMP_INPUT_MAIL=
        #Ask which one they wish to use
        echo "The following accounts were found"
        echo -e ${DF_TMP_TXT};
        echo ""
        echo "Which one do you wish to set as a default?"
        read DF_TMP_INPUT
                            
        # Check if we have a key file for this email?
        if [ -f "${DF_TMP_ACCD}/${DF_TMP_INPUT}.pem" ]; then 
            echo ""
            echo "Are you sure you wish to set this as the default (${DF_TMP_INPUT})? (y/n)"
            read DF_TMP_INPUT_MAIL
            if [[ ${DF_TMP_INPUT_MAIL} == "y" ]]; then
                # Create the default file
                echo "Setting '${DF_TMP_INPUT}' as the default account..."
                echo -e "CONTACT_EMAIL='${DF_TMP_INPUT}'" > "${DF_TMP_ACCD}/${DF_ACCOUNT_D}"
                echo -e "PRIVATE_KEY='${DF_TMP_ACCD}/${DF_TMP_INPUT}.pem'" >> "${DF_TMP_ACCD}/${DF_ACCOUNT_D}"
                echo " + DONE"
                exit 1;
            else
                echo " - Account not set as default"
                exit 1;
            fi
        else
            echo "Account not found"
            exit 1;
        fi
    fi

exit 1;
                        
                    
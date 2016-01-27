#!/bin/bash

    echo -e ""
    echo -e " ###############################################################" 
    echo -e " ##      THIS WILL ${RED}REVOKE${NC} A FREE 90 DAY SSL CERTIFICATE       ##"
    echo -e " ##                     FROM LETS ENCRYPT                     ##"
    echo -e " ###############################################################" 
    echo -e ""
    
    # Run   
    
    echo -e "${RED}Do you want to revoke a SSL certificate (y/n)?${NC}"
    read DFRUN
    if [ "${DFRUN}" == "y" ]; then 
    
        echo -e "What is the primary domain name"
        echo " > eg; mydomain.com"
        read DFRUN
        echo ""
        
        SEVHOST="${BASEDIR}/certs/${DFRUN}";
        DFC=0; # <-- Sets amount of certs found
        # Check if we have any certficates for that domain
        if [[ ! -d "${SEVHOST}" ]]; then
            echo -e "${RED}ERROR:${NC} No certificates found under that domain";
            exit 1;
        fi
        
        #echo " Please choose from the following Certificates"
        # Start finding all versions of ssl certificates
        for Cert in $(find ${SEVHOST}/cert-*.pem -maxdepth 0 -type f ); 
        do
            FolderName=$(basename $Cert);
            #echo "  - Checking ${Cert}..."
            if [ -f "${SEVHOST}/${FolderName}" ]; then
                
                #echo "  - Found ${FolderName}"
                # Check if that certificate has expired, if not add it into the list
                if openssl x509 -checkend 0 -noout -in "${SEVHOST}/${FolderName}"
                then
                    DFTMPDATES=$(openssl x509 -startdate -noout -in "${SEVHOST}/${FolderName}")
                    echo -e " > ${GREEN}${FolderName}${NC} (Issued: ${DFTMPDATES})"
                    DFC=$((DFC + 1))
                    DFCO=${FolderName}
                fi
                            
            fi
        done
        
        if [[ ${DFC} == 0 ]]; then
            echo " - No Certificates found"
            exit 1;
        fi
        
        echo ""

        if [[ ${DFC} == 1 ]]; then
            # Only one certificate which can be revoked
            DFRUNCERT=$(tr -dc '0-9' <<< $DFCO)
        else
            # More then 1 make the user choose
            echo -e "Which certificate do you wish to revoke?"
            echo " > eg; cert-1445412480.pem (type 1445412480)"
            read DFRUNCERT
            echo ""
        fi
        
        
        
        # Check if it exists
        if [ ! -f "${SEVHOST}/cert-${DFRUNCERT}.pem" ]; then
            echo -e " ${RED}ERROR:${NC} Certificate not found"
            echo "  - Check the number and try again"
            exit 1;
        fi
        
        # Check if the current Certificate is in use on the server
        DFSL=$(readlink -f "${SEVHOST}/cert.pem"); DFSL=$(basename $DFSL);
        if [[ ${DFSL} == "cert-${DFRUNCERT}.pem" ]]; then
            echo -e "${RED}WARNING:${NC} This SSL Certificate is currently in use, continue? (y/n)"
            echo "  - You should issue a new one first"
            read DFRUN
            echo ""
            if [ ! $DFRUN == "y" ]; then 
                echo "Nothing Revoked!"
                exit 1;
            fi
        fi
        
         # Check if the private key exists
        if [ ! -f "${SEVHOST}/privkey-${DFRUNCERT}.pem" ]; then
            echo -e "${RED}ERROR:${NC} Private Key for certificate not found"
            echo "  - Attempted Path (${SEVHOST}/privkey-${DFRUNCERT}.pem)"
            echo "  - Check the number and try again"
            exit 1;
        fi
        
        #Display some info about the certificate
        echo -e "${RED}Do you wish to revoke '${GREEN}cert-${DFRUNCERT}.pem${RED}' (y/n)?${NC}"
        echo " > This cannot be undone!"
        read DFRUN
        echo ""
        if [ "${DFRUN}" == "y" ]; then 
        
            echo " + Attempting to revoke SSL Certificate..."
            # Revoke the cert
            
                # Add Challange directory to tmp config
                echo -e "PRIVATE_KEY='${SEVHOST}/privkey-${DFRUNCERT}.pem'" > ${CFDFT}
                echo -e "CONTACT_EMAIL='${CONTACT_EMAIL}'" >> ${CFDFT}
                if [[ "${TESTING}" == 1 ]]; then
                    echo -e 'CA="https://acme-staging.api.letsencrypt.org/directory"' >> ${CFDFT}
                else
                    echo -e 'CA="https://acme-v01.api.letsencrypt.org/directory"' >> ${CFDFT}
                fi
            
            cd ${BASEDIR}
            bash acme.sh -r "${SEVHOST}/cert-${DFRUNCERT}.pem" --config ${CFDFT}
            
            # Remove tmp config file
            rm -- ${CFDFT}
        
        else
        echo "Nothing revoked!"
        exit;
        fi
        
        
    else
        echo "Nothing revoked!"
	    exit;
    fi
    
    
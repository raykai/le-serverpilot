#!/bin/bash

# Lets Encrypt sh
RED='\033[0;31m'
NC='\033[0m' # No Color    
GREEN='\033[0;32m'


function press_enter
{
    echo ""
    echo -n "Press Enter to continue"
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
    echo -e " ##             ${NC}** USE AT YOUR OWN RISK **${GREEN}                    ##"
    echo -e " ##                                                           ##"
    echo -e " ##                     Version: alpha 1.2                    ##"
    echo -e " ###############################################################" 
    echo -e "${NC}"
    echo ""
    echo " ** What would you like to do? **"
    echo ""
    echo "Lets Encrypt Options"
    echo "  1) Issue a CERT" 
    echo "  2) Renew a CERT" 
    echo "  3) Setup Auto Renew" 
    echo "  4) Intall Lets Encrypt"
    echo "  5) Update Lets Encrypt"
    echo "  6) Revoke a CERT"
    echo "  7) Setup the config file"
    echo ""
    echo "Server Pilot Options"
    echo "  8) Activate SSL (issue a cert first)"
    echo "  9) Deactivate SSL"
    echo ""
    echo "  q) Quit"
    echo "  u) Remove le-serverpilot and Lets Encrypt"
    echo ""
    echo -n "Enter selection: "
    read selection
    echo ""
    case $selection in
        1 ) bash issue-cert.sh; press_enter ;;
        2 ) bash renew-cert.sh; press_enter ;;
        3 ) echo "Coming Soon"; press_enter ;;
        4 ) bash le-install.sh; press_enter ;;
        5 ) bash le-update.sh; press_enter ;;
        #6 ) bash revoke-cert.sh; press_enter ;;
        6 ) echo "Coming Soon"; press_enter ;;
        7 ) bash config-lets.sh; press_enter ;;
        8 ) bash sp-https.sh; press_enter ;;
        9 ) bash sp-no-https.sh; press_enter ;;
        u ) bash del.sh ;;
        q ) exit ;;
        0 ) exit ;;
        * ) echo "Please choose an option"; press_enter
    esac
done
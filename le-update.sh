# HTTPS add into Serverpilot

RED='\033[0;31m'
NC='\033[0m' # No Color    
GREEN='\033[0;32m'

#==
echo -e ""
echo -e " ###############################################################" 
echo -e " ##   THIS SCRIPT WILL UPDATE LETS ENCRYPT FOR SERVERPILOT    ##"
echo -e " ##                                                           ##"
echo -e " ###############################################################" 
echo -e ""


echo "Do you want to update LE-SERVERPILOT from the GIT (y/n)?"
read DFRUN
if [ $DFRUN == "y" ]; then
    
	echo -e "${GREEN}Updating le-serverpilot...${NC}"
    cd
    cd le-serverpilot
    git pull

else
	echo -e "${GREEN}Did not update le-serverpilot${NC}"
fi

echo "Do you want to update Lets Encrypt from the GIT (y/n)?"
read DFRUN
if [ $DFRUN == "y" ]; then
    
	echo -e "${GREEN}Updating Lets Encrypt...${NC}"
    cd
    cd letsencrypt
    git pull

else
	echo -e "${GREEN}Did not update Lets Encrypt${NC}"
fi



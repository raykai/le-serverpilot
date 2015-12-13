# HTTPS add into Serverpilot

RED='\033[0;31m'
NC='\033[0m' # No Color    
GREEN='\033[0;32m'

#==
echo -e ""
echo -e " ###############################################################" 
echo -e " ##   THIS SCRIPT WILL INSTALL LETS ENCRYPT FOR SERVERPILOT   ##"
echo -e " ##                                                           ##"
echo -e " ###############################################################" 
echo -e ""


echo "Do you want to install Lets Encrypt from the GIT (y/n)?"
echo " also installs git & python-pip if not installed"
read DFRUN
if [ $DFRUN == "y" ]; then
    
	echo -e "${GREEN}Installing Lets Encrypt...${NC}"
    apt-get install python-pip -y
    pip install pyopenssl ndg-httpsclient pyasn1
    git clone https://github.com/letsencrypt/letsencrypt
    cd letsencrypt
    ./letsencrypt-auto --help


else
	echo -e "${GREEN}Did not install Lets Encrypt${NC}"
fi

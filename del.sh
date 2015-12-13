# HTTPS add into Serverpilot

RED='\033[0;31m'
NC='\033[0m' # No Color    
GREEN='\033[0;32m'

#==
echo -e "${RED}"
echo -e " ###############################################################" 
echo -e " ##          REMOVING LETS ENCRYPT AND LE-SERVERPILOT         ##"
echo -e " ##                                                           ##"
echo -e " ###############################################################" 
echo -e "${NC}"




echo "Would you like to {$RED}REMOVE${NC} Lets Encrypt? (y/n)?"
echo -e "${RED}** This will also delete your account key"
echo -e "this cannot be undone!${NC}"
read DFRUN
if [ $DFRUN == "y" ]; then
    
	echo -e "Removing Lets Encrypt..."
    cd 
    rm -rf letsencrypt
    echo "DONE!"

else
	echo -e "${GREEN}Did not DELETE Lets Encrypt${NC}"
fi

echo "Would you like to {$RED}REMOVE${NC} le-serverpilot? (y/n)?"
echo -e "${RED}this cannot be undone!${NC}"
read DFRUN2
if [ $DFRUN2 == "y" ]; then
    
	echo -e "Removing le-serverpilot..."
    cd 
    rm -rf le-serverpilot
    echo "DONE!"

else
	echo -e "${GREEN}Did not DELETE le-serverpilot${NC}"
fi
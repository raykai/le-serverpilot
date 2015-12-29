# HTTPS add into Serverpilot

RED='\033[0;31m'
NC='\033[0m' # No Color    
GREEN='\033[0;32m'

SCRIPTDIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"


#==
echo -e "${RED}"
echo -e " ###############################################################" 
echo -e " ##          REMOVING LETS ENCRYPT AND LE-SERVERPILOT         ##"
echo -e " ##                                                           ##"
echo -e " ###############################################################" 
echo -e "${NC}"


echo -e "Would you like to {$RED}REMOVE${NC} le-serverpilot? (y/n)?"
echo -e "${RED}** this will also remove your SSL CERT and private keys! **${NC}"
echo -e "${RED}this cannot be undone!${NC}"
read DFRUN2
if [ $DFRUN2 == "y" ]; then
    
	echo -e "Removing le-serverpilot..."
    cd ${SCRIPTDIR}
    cd ..; rm -rf -- ${PWD##*/} 
    echo "DONE!"

else
	echo -e "${GREEN}Did not DELETE le-serverpilot${NC}"
fi
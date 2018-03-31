#!/bin/bash


version(){
    pipesiteAddress="http://userweb.molbiol.ox.ac.uk/public/telenius/NGseqBasicManual/outHouseUsers/"
    
    versionInfo="\n${CCversion} pipeline, running fastaParser.sh \nUser manual, updates, bug fixes, etc in : ${pipesiteAddress}\n"

}


usage(){
    
    version
    echo -e ${versionInfo}
    
echo 
echo "FOR CUSTOMISING FASTAS AND MAKING CUSTOM GENOMES"
echo
echo 
 
 exit 0
    
}


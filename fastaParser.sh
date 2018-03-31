#!/bin/bash

function finish {
if [ $? != "0" ]; then
echo
echo "RUN CRASHED ! - check qsub.err to see why !"
echo

else
echo
echo "Analysis complete !"
date

fi
}
trap finish EXIT

# ------------------------------------------

version="001"

# -----------------------------------------

MainScriptPath="$( echo $0 | sed 's/\/fastaParser.sh$//' )"

RunScriptPath="${MainScriptPath}/bin/runScripts"
HelperScriptsPath="${MainScriptPath}/bin/bashHelpers"

# -----------------------------------------

# Help-only run type ..

if [ $# -eq 1 ]
then
parameterList=$@
if [ ${parameterList} == "-h" ] || [ ${parameterList} == "--help" ]
then
. ${CaptureSerialPath}/bashHelpers/usageAndVersion.sh
usage
exit

fi
fi
#------------------------------------------

# Normal runs (not only help request) starts here ..

echo "fastaParser.sh - by Jelena Telenius, 30/03/2018"
echo
timepoint=$( date )
echo "run started : ${timepoint}"
echo
echo "Script located at"
echo "$0"
echo

echo "RUNNING IN MACHINE : "
hostname --long

echo "run called with parameters :"
echo "fastaParser.sh" $@
echo

parameterList=$@
#------------------------------------------


# Loading subroutines in ..

echo "Loading subroutines in .."

# CREATING default parameters and their values
. ${HelperScriptsPath}/defaultparams.sh

# SETTING parameter values 
. ${HelperScriptsPath}/parametersetters.sh

# READING parameter files
. ${HelperScriptsPath}/parameterFileReaders.sh

# Checking reference FASTA files for integrity and index existence
. ${HelperScriptsPath}/fastaChecks.sh

# Input the custom fastas, make indices
. ${HelperScriptsPath}/inputFastas.sh

# RUNNING the main subroutines
. ${HelperScriptsPath}/runtools.sh

# SETTING THE GENOME BUILD PARAMETERS
. ${HelperScriptsPath}/genomeSetters.sh

# PRINTING HELP AND VERSION MESSAGES
. ${HelperScriptsPath}/usageAndVersion.sh

# DEBUG SUBROUTINES - for the situations all hell breaks loose
# . ${CaptureAnalysisPath}/subroutines/debugHelpers.sh

# TESTING file existence, log file output general messages
. ${HelperScriptsPath}/testers_and_loggers.sh
if [ "$?" -ne 0 ]; then
    printThis="testers_and_loggers.sh safety routines cannot be found in $0. Cannot continue without safety features turned on ! \n EXITING !! "
    printToLogFile
    exit 1
fi

# -----------------------------------------

# Setting $HOME to the current dir
echo 'Turning on safety measures for cd rm and mv commands in $0 - restricting script to file operations "from this dir below" only :'
HOME=$(pwd)
echo $HOME
echo
# - to enable us to track mv rm and cd commands
# from taking over the world accidentally
# this is done in testers_and_loggers.sh subroutines, which are to be used
# every time something gets parsed, and after that when the parsed value is used to mv cd or rm anything
# ------------------------------------------

# Test the testers and loggers ..

printThis="Testing the tester subroutines in $0 .."
printToLogFile
printThis="${HelperScriptsPath}/testers_and_loggers_test.sh 1> testers_and_loggers_test.out 2> testers_and_loggers_test.err"
printToLogFile
   
${HelperScriptsPath}/testers_and_loggers_test.sh 1> testers_and_loggers_test.out 2> testers_and_loggers_test.err
# The above exits if any of the tests don't work properly.

# The below exits if the logger test sub wasn't found (path above wrong or file not found)
if [ "$?" -ne 0 ]; then
    printThis="Testing testers_and_loggers.sh safety routines failed in $0 . Cannot continue without testing safety features ! \n EXITING !! "
    printToLogFile
    exit 1
else
    printThis="Testing the tester subroutines completed - continuing ! "
    printToLogFile
fi

# Comment this out, if you want to save these files :
rm -f testers_and_loggers_test.out testers_and_loggers_test.err


#------------------------------------------

# From where to call the CONFIGURATION script..

# confFolder="${CaptureTopPath}/conf"
confFolder=$( dirname $( dirname ${CaptureTopPath} ))"/conf"

echo
echo "confFolder ${confFolder}"
echo

#------------------------------------------


# Calling in the CONFIGURATION script and its default setup :

echo "Calling in the conf/config.sh script and its default setup .."

CaptureDigestPath="NOT_IN_USE"
supportedGenomes=()
UCSC=()


# . ${confFolder}/config.sh
. ${confFolder}/genomeBuildSetup.sh
. ${confFolder}/loadNeededTools.sh
. ${confFolder}/serverAddressAndPublicDiskSetup.sh

# setConfigLocations
setPathsForPipe
setGenomeLocations

echo 
echo "Supported genomes : "
for g in $( seq 0 $((${#supportedGenomes[@]}-1)) ); do echo -n "${supportedGenomes[$g]} "; done
echo 
echo


echo "Calling in the conf/serverAddressAndPublicDiskSetup.sh script and its default setup .."

SERVERTYPE="UNDEFINED"
SERVERADDRESS="UNDEFINED"
REMOVEfromPUBLICFILEPATH="NOTHING"
ADDtoPUBLICFILEPATH="NOTHING"
tobeREPLACEDinPUBLICFILEPATH="NOTHING"
REPLACEwithThisInPUBLICFILEPATH="NOTHING"

. ${confFolder}/serverAddressAndPublicDiskSetup.sh

setPublicLocations

echo
echo "SERVERTYPE ${SERVERTYPE}"
echo "SERVERADDRESS ${SERVERADDRESS}"
echo "ADDtoPUBLICFILEPATH ${ADDtoPUBLICFILEPATH}"
echo "REMOVEfromPUBLICFILEPATH ${REMOVEfromPUBLICFILEPATH}"
echo "tobeREPLACEDinPUBLICFILEPATH ${tobeREPLACEDinPUBLICFILEPATH}"
echo "REPLACEwithThisInPUBLICFILEPATH ${REPLACEwithThisInPUBLICFILEPATH}"
echo

# --------------------------------------

OPTS=`getopt -o h,m --long help,outfile:,errfile: -- "$@"`
if [ $? != 0 ]
then
    exit 1
fi

eval set -- "$OPTS"

while true ; do
    case "$1" in
        -h) usage ; shift;;
        -m) LOWERCASE_M=$2 ; shift 2;;
        --help) usage ; shift;;
        --outfile) QSUBOUTFILE=$2 ; shift 2;;
        --errfile) QSUBERRFILE=$2 ; shift 2;;
        --) shift; break;;
    esac
done

# ----------------------------------------------

# Modifying and adjusting parameter values, based on run flags

setRefGenomeFasta

echo "RefGenomeFasta ${RefGenomeFasta}" >> parameters_capc.log
echo "BowtieGenome ${BowtieGenome}" >> parameters_capc.log

setUCSCgenomeSizes

echo "ucscBuild ${ucscBuild}" >> parameters_capc.log

#------------------------------------------

setParameters
testParametersForParseFailures

# ----------------------------------------------

# Loading the environment - either with module system or setting them into path.
# This subroutine comes from conf/config.sh file

printThis="LOADING RUNNING ENVIRONMENT"
printToLogFile

setPathsForPipe

#---------------------------------------------------------

echo "Run with parameters :"
echo

writeParametersToCapcLogFile

cat parameters_capc.log
echo

echo "Whole genome fasta file path : ${GenomeFasta}"
echo "Chromosome sizes for UCSC hub generation will be red from : ${ucscBuild}"

checkThis="${OligoFile}"
checkedName='OligoFile'
checkParse
testedFile="${OligoFile}"
doInputFileTesting

#---------------------------------------------------------
# 
# Analysis script notes :
#
# --------------------------------------------------------
# INPUT FASTA FORMAT CHECKS
# 
# 1) Check genome fasta existence, and its index file.
#    Check if index is older than the fasta, and notify user. (there is not much else we can do as these are sudo files)
#
#    Allowing fasta to be red in outside the "actual reference list" - as we may have a custom genome ref here, of course.
#    In case of custom fasta - giving instructions for user to make index file if it is missing, or re-make it if it is older than the fasta.
#    Exit 1 if either of above 2 is the case.
#    
# 2) Check genome fasta read lenght, and save it,
#    tell to user "will make this many bases per line" as ref fasta had already like that.
#    If read lenght more than 200 EXIT 1 : as these lines would be hard to read.
#    Escape flag : --divideRefGenomeFastaToThisLongLines 50
#    
# 3) Check custom fasta existence and copy it to run folder.
#    Parse the file for whitespace (remove all whitespace in sed)
#
#    Parse the header lines for possible '\s\s*.*'
#    If any found, parsing the end of the line out (retaining only the chr name).
#    Printing to user, that the coordinates were removed from the chr name to not to hinder with parsing.
#    
#    Parse the header lines for remaining : and - 
#
#    if any found, reporting the found >chr name, line number, for all of them.
#    EXIT 1
#    This needs to be modified to something more tolerable - as the script will output a lot of these,
#    and it would be handy to be able to input the output straight in again ..
#
#    Parse the header lines for possible other non- azAz_ characters.
#    if any found EXIT 1
# 
#    Check for non-ATCGatcgNn characters in non-name lines (omitting emptylines),
# 
#    if any found, reporting the found >chr name, line number, and base number within the line, for all of them.
#    EXIT 1
#    
#    Parse custom fasta to 50 bases lines (or whatever the genome fasta had). 
#    Make its index file
#    Save these "first edits" as usedCustomFasta.fa and usedCustomFasta.fai
#    
# NOW WE HAVE INPUT FASTAS IN CONSISTENT FORMAT - and can use bedtools getfasta for both ref genome and custom sequences the same way.
# ----------------------------------------------------------

# MAKING UCSC BUILD a) FOR REF GENOME (IF MISSING) AND b) FOR THE CUSTOM FASTA
# 
# 4) Printing to user, which chromosomes we have in the ref genome fasta, and its ucsc build.
#    If using custom fasta as reference, making the UCSC chr sizes file on the fly, and printing the ucsc sizes to user as well,
#    printing to user where the ucsc builds file is, for re-using in NGseqBasic pipeline.
# 
#    The UCSC build for edited genome will be made later.
#    
# 5) Printing to user, which chromosomes we have in the custom genome fasta.
#    Making the UCSC chr sizes file on the fly, and printing the ucsc sizes to user as well,
#    printing to user where the ucsc builds file is.
#    
#    These will be (possibly) used in FYI visualisations in the end of the script.
#    If not - then they are just made for completeness' sake.
#
# NOW WE HAVE INPUT FASTAS IN BEDTOOLS-COMPATIBLE FORMAT, AND UCSC BUILDS FOR INPUT FASTAS
# ----------------------------------------------------------

# PARSING THE INPUT COORDINATE FILE
# 
# 6) Parsing the input coordinate file for non azAZ09_ characters. If any found, exit 1.
#    Whitespace parsing : all \s\s* replaced with \i
#    Checking all coordinate columns to contain only 0-9 characters. If non-numeric found, exit 1.
#    Checking that all lines (not emptylines, or { or } ) contain a keyword (INSERTION, DELETION, INVERSION). If not, exit 1.
#    
# 7) Checking that the types match their coordinates (INSERTION, DELETION, INVERSION). If not, exit 1.
# 
# 8) Comparing the chr names of the input coordinate file, to the custom fasta and ref genome. If any not found, exit 1.
#    Comparing the chr sizes of the ucsc builds to the coordinates each command references to. If any are wider than end of chr, exit 1.
# 
# NOW WE HAVE INPUT FASTAS IN BEDTOOLS-COMPATIBLE FORMAT, AND UCSC BUILDS FOR INPUT FASTAS, AND PARSED INPUT COORDINATE FILE
# ----------------------------------------------------------

# MAKING THE REFERENCE BUILD
# 
# 9) the subroutines, to :
# 
# A) list chromosome order in the original fasta (to be able to reconstruct same order in the end)
# B) list un-altered chromosomes of the original fasta (in the original chromosome order)
#    - to fetch these in the end when the actual build is made
# C) walking down the to-be-modified ref chromosomes, taking out the pieces to be edited,
#    and adding pieces from the custom ref fasta as we go along.
#    after each chromosome : reporting what was done, making the line for ucsc build, making bed coordinates for
#    plotting the "original ref" and "added" : both containing also the chr name and coordinates in the name field of the bed
#    for the name to be visible in ucsc visualisation.
# 
# D) in the end:
#    collecting the whole ucsc build.
#    collecting the bed regions, making a bigbed with region names and coordinates-from-where-they-originate
# 
# E) making the reference fasta, and its 2bit file for ucsc
#    making the data hub genome file
#    
# F) making the data hub hub.txt file, and tracks.txt file,
#    putting it to public, informing user.
#    
# G) listing to user where everything is (all the ucsc builds made in this run, all fastas all indices),
#    and printing the hub address one more time


echo
date
echo
echo "All done !"
echo  >> "/dev/stderr"
echo "All done !" >> "/dev/stderr"

exit 0



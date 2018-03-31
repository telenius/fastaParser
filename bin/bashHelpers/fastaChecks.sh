#!/bin/bash

# Copied from PYRAMID VS004 17Feb2017
# divideFastqFilenames divideAndSortFastqFilenames : from metadataHelpers.sh
# checkFastqFiles : from fastqchecks.txt

divideFastqFilenames(){
    
    #echo "divideFastqFilenames"  >&2
  
    cat ../PIPE_fastqPaths.txt | grep -v "^\s*#" | grep -v "^\s*$" | sed 's/\s\s*/\t/g' > TEMP_fastqLocations.txt

    cat TEMP_fastqLocations.txt | cut -f 1 | grep -v "^\s*$" > TEMP_fastqSamplenames.txt
    cat TEMP_fastqLocations.txt | cut -f 2 | grep -v "^\s*$" > TEMP_fastqReplicates.txt
    
    # NEW format
    # sample rep file file folder   OR sample rep file folder
    # OLD format
    # sample rep file file          OR sample rep file
    
    # If we have a FOLDER as column 4 or 5 (and not a file) - we know we have "new format" fastq input :
    
    weHaveNEWfastqFormat=0
    folderColumn=0
    
    firstPotentialFolder=$( cat TEMP_fastqLocations.txt | cut -f 4 | grep -v "^\s*$" | head -n 1 )
    if [ -d "${firstPotentialFolder}" ] ; then
        weHaveNEWfastqFormat=1
        folderColumn=4
    fi
    firstPotentialFolder=$( cat TEMP_fastqLocations.txt | cut -f 5 | grep -v "^\s*$" | head -n 1 )
    if [ -d "${firstPotentialFolder}" ] ; then
        weHaveNEWfastqFormat=1
        folderColumn=5
    fi
    
    
    # Now we know if we have NEW or OLD, and proceed..
    
    if [ "${weHaveNEWfastqFormat}" -ne "0" ] ; then
        echo "Fastq parameter file format was given in NEW format :"
        echo "Sample Read1 (Read2) Folder"
        cat ../PIPE_fastqPaths.txt | cut -f 2 --complement 
        echo
        
        cat TEMP_fastqLocations.txt | cut -f ${folderColumn} | grep -v "^\s*$" > TEMP_fastqFolders.txt
        
        cat TEMP_fastqLocations.txt | cut -f 3,${folderColumn} | awk '{ print $2"\t"$1 }' | sed 's/,/\t/g' | awk '{for (i=2;i<=NF;i++) printf "%s/%s,",$1,$i; print ""}' | sed 's/,$//'  | sed 's/\/\//\//' > TEMP_fastqRead1.txt
        
        # If we do have read2 - our folderColumn will be 5 !        
        if [ "${folderColumn}" -eq 5 ]; then
            cat TEMP_fastqLocations.txt | cut -f 4,${folderColumn} | awk '{ print $2"\t"$1 }' | sed 's/,/\t/g' | awk '{for (i=2;i<=NF;i++) printf "%s/%s,",$1,$i; print ""}' | sed 's/,$//'  | sed 's/\/\//\//' > TEMP_fastqRead2.txt
        else
        # Otherwise, giving empty file
          echo "" > TEMP_fastqRead2.txt
        fi
      
    else
        echo "Fastq parameter file format was given in OLD format :"
        echo "Sample Read1 (Read2)"
        cat ../PIPE_fastqPaths.txt | cut -f 2 --complement 
        echo
        
        cat TEMP_fastqLocations.txt | cut -f 3 | grep -v "^\s*$" > TEMP_fastqRead1.txt
        cat TEMP_fastqLocations.txt | cut -f 4 | grep -v "^\s*$" > TEMP_fastqRead2.txt
    fi   
    
    #echo "TEMP_fastqRead1.txt"
    #cat TEMP_fastqRead1.txt
    #echo "TEMP_fastqRead2.txt"
    #cat TEMP_fastqRead2.txt
    
    
}


checkFastqFiles(){
    
# This subroutine MAKES the real fastq parameter file, as well as the LANES parameter file.
    
# ####################################################
# The basic principles of parameter file joining :
# 1) Keep the original order AT ALL TIMES
# 2) Use join --nocheck-order instead of paste (to avoid accidental bugs when later the code is possibly altered)
#     --> aiming to DISAPPEARING samples after a bug, not WRONGLY ASSIGNED samples
# 3) Mark all files with both SAMPLE NAME and REPLICATE NUMBER - so each file can be UNIQUELY GREPPED to reach any sample any time
#
# --> End result is parameter files which COULD be in principle joined with PASTE (as they are strictly in original order)
#   , but to be safe, GREP and JOIN are used instead (see step 2 abovr for justification)
# ####################################################
# Jelena 15 Aug 2016
# ####################################################
    
# COMBINING the fastq parameter file to other parameters (metadata) is made using the above guidelines, within joinParameterFiles subroutine in runnerHelpersForAllVersions in PIPERUNNERS folder

    rm -f ../FASTQ_LOAD.err

    mkdir TEMP_$$
    
    cd TEMP_$$
    
    divideFastqFilenames
    
    # TEMP_fastqLocations.txt (all 3 columns)
    # TEMP_fastqSamplenames.txt (samplename)
    # TEMP_fastqRead1.txt (R1)
    # TEMP_fastqRead2.txt (R2)
    
    # This goes to zero, if we didn't have read 2
    weHaveRead2=$(($( cat TEMP_fastqRead2.txt | grep -v "^\s*$" | grep -c "" )))
    
    # First - check that all of them have same amount of non-empty lines..
    
    # Counting samples - comparing..
    TEMPcount=$(($( cat TEMP_fastqSamplenames.txt | grep -c "" )))
    
    TEMPcount2=$(($( cat TEMP_fastqRead1.txt | grep -c "" )))
    
    if [ "${TEMPcount2}" -ne "${TEMPcount}" ] ; then echo "Some FASTQ read1 path(s) / file name(s) are EMPTY - correct your PIPE_fastqPaths.txt file !" >> ../FASTQ_LOAD.err ;fastqDataOK=0; fi
    
    if [ "${weHaveRead2}" -ne 0 ]; then
    TEMPcount2=$(($( cat TEMP_fastqRead2.txt | grep -c "" )))    
    if [ "${TEMPcount2}" -ne "${TEMPcount}" ] ; then echo "Some FASTQ read2 path(s) / file name(s) are EMPTY (or you are trying to run paired and single end samples in same run - that is not allowed) Correct your PIPE_fastqPaths.txt file !" >> ../FASTQ_LOAD.err ;fastqDataOK=0; fi    
    fi
    
    # Checking that the folder names are not empty ..
    if [ -s TEMP_fastqFolders.txt ]; then
    TEMPcount2=$(($( cat TEMP_fastqFolders.txt | grep -c "" )))
    if [ "${TEMPcount2}" -ne "${TEMPcount}" ] ; then echo "Some FASTQ folder path(s) are EMPTY (or you are trying to run paired and single end samples in same pipeline run - that is not allowed) Correct your PIPE_fastqPaths.txt file !" >> ../FASTQ_LOAD.err ;fastqDataOK=0; fi    
    fi
    
    # Then - check that they both have the same amount of fastqs
    
    if [ "${weHaveRead2}" -ne 0 ]; then
    paste TEMP_fastqSamplenames.txt TEMP_fastqReplicates.txt TEMP_fastqRead1.txt TEMP_fastqRead2.txt | sed 's/\s\s*/_/' | sed 's/\s\s*/:/' | sed 's/\s\s*/;/' > TEMP_combined.txt
    else
    paste TEMP_fastqSamplenames.txt TEMP_fastqReplicates.txt TEMP_fastqRead1.txt TEMP_fastqRead1.txt | sed 's/\s\s*/_/' | sed 's/\s\s*/:/' | sed 's/\s\s*/;/' > TEMP_combined.txt
    fi
    
    TEMP_list=$( cat TEMP_combined.txt )
    #echo ${TEMP_list}
    
    for TEMP_data in ${TEMP_list}
    do
            
    TEMP_sample=$( echo ${TEMP_data} | sed 's/:.*//' )
    TEMP_read1=$( echo ${TEMP_data} | sed 's/.*://' | sed 's/;.*//')
    TEMP_read2=$( echo ${TEMP_data} | sed 's/;.*//' )
    
    TEMPcount=$(($( echo ${TEMP_read1} | tr -d -c ',' | awk '{ print length; }' )))
    TEMPcount2=$(($( echo ${TEMP_read2} | tr -d -c ',' | awk '{ print length; }' )))
    if [ "${TEMPcount2}" -ne "${TEMPcount}" ] ; then
        echo "Different amount of fastq lanes for sample ${TEMP_sample} :" >> ../FASTQ_LOAD.err
        echo "    READ1 has ${TEMPcount} lanes, and READ2 has ${TEMPcount2} lanes." >> ../FASTQ_LOAD.err
        echo "    Correct your PIPE_fastqPaths.txt file !" >> ../FASTQ_LOAD.err
        fastqDataOK=0
    fi   

    echo ${TEMPcount} >> TEMP_lanes.txt
    
    # Checking that the names (within R1 series, and within R2 series) are unique
    TEMPcount=$(($( echo ${TEMP_read1} | sed 's/,/\n/g' | grep -v "^\s*$" | grep -c "" )))
    TEMPcount2=$(($( echo ${TEMP_read1} | sed 's/,/\n/g' | sort | uniq | grep -v "^\s*$" | grep -c "" )))
    if [ "${TEMPcount2}" -ne "${TEMPcount}" ] ; then echo "Some FASTQ read1 path(s) are NOT UNIQUE for sample ${TEMP_sample} (some lanes are given twice) - correct your PIPE_fastqPaths.txt file !" >> ../FASTQ_LOAD.err ;fastqDataOK=0; fi
    
    if [ ${weHaveRead2} -ne 0 ]; then
    TEMPcount=$(($( echo ${TEMP_read2} | sed 's/,/\n/g' | grep -v "^\s*$" | grep -c "" )))
    TEMPcount2=$(($( echo ${TEMP_read2} | sed 's/,/\n/g' | sort | uniq | grep -v "^\s*$" | grep -c "" )))
    if [ "${TEMPcount2}" -ne "${TEMPcount}" ] ; then echo "Some FASTQ read1 path(s) are NOT UNIQUE for sample ${TEMP_sample} (some lanes are given twice) - correct your PIPE_fastqPaths.txt file !" >> ../FASTQ_LOAD.err ;fastqDataOK=0; fi
    fi  
    
    done
    
    cat TEMP_lanes.txt | awk '{print $1+1}' > TEMP_lanesCorrected.txt
    
    paste TEMP_fastqSamplenames.txt TEMP_fastqReplicates.txt TEMP_lanesCorrected.txt > lanes.txt
    
    # Not pyramid - not using this.
    # mv -f lanes.txt ../.
    
    # Checking that the folders exist .. (if we have the NEW input format)
    if [ -s TEMP_fastqFolders.txt ]; then
        
    TEMP_list=$( cat TEMP_fastqFolders.txt | sed 's/,/\n/g' )
    for file in ${TEMP_list}
    do
        if [ ! -d ${file} ] ; then echo "FASTQ path ${file} does not exist (or is not a directory). Correct your PIPE_fastqPaths.txt file !" >> ../FASTQ_LOAD.err ;fastqDataOK=0; fi    
    done    
    
    fi
    
    # Then - check that all the fastqs exist.
    
    TEMP_list=$( cat TEMP_fastqRead1.txt | sed 's/,/\n/g' )
    for file in ${TEMP_list}
    do
        if [ ! -s ${file} ] ; then echo "FASTQ read1 file ${file} does not exist (or is empty file). Correct your PIPE_fastqPaths.txt file !" >> ../FASTQ_LOAD.err ;fastqDataOK=0; fi    
    done
    
    if [ ${weHaveRead2} -ne 0 ]; then
    TEMP_list=$( cat TEMP_fastqRead2.txt | sed 's/,/\n/g' )
    for file in ${TEMP_list}
    do
        if [ ! -s ${file} ] ; then echo "FASTQ read2 file ${file} does not exist (or is empty file). Correct your PIPE_fastqPaths.txt file !" >> ../FASTQ_LOAD.err ;fastqDataOK=0; fi    
    done
    fi    

    # Not pyramid - not doing this :
    # Copying file listings.
    # if [ "${fastqDataOK}" -eq "1" ]; then
    #     paste TEMP_fastqSamplenames.txt TEMP_fastqReplicates.txt TEMP_fastqRead1.txt TEMP_fastqRead2.txt > ../PIPE_correctedFastqPaths.txt
    # fi

    # Then delete the temporary files.
    
    cd ..
    
    rm -rf TEMP_$$
    
}



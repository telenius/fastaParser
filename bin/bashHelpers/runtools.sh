#!/bin/bash

# ----------------------------------------------------------
# Coordinate file format :
# ----------------------------------------------------------

# duplication duplNAME    chr1  100  chr1    200 300  +
# insertion   insNAME     chr1  100  chrIn1  200 300  -
# deletion    delNAME     chr1  100  200

# translocation trNAME    chr1  100  chr1    200 300 +
# actually consists of operations :
# deletion    delNAME     chr1  200  300
# duplication duplNAME    chr1  100  chr1    200 300  +

# inversion   invNAME     chr1  100  200
# can also be written as
# translocation trNAME    chr1  100  chr1    100 200 -
# and thus actually consists of operations :
# deletion    delNAME     chr1  100  200
# duplication duplNAME    chr1  100  chr1    100 200  -

# -----------------------------------------------------------

revertFileToSimpleOperations(){
    
printThis="revertFileToSimpleOperations for frameworkfile ${frameworkfile}"    
printToLogFile
    
# Revert inversions to translocations. ($6,$7 distributes the possible WHERE)
cat ${frameworkfile} | awk '{ \
if($1=="inversion")\
{print "translocation\t"$2"\t"$3"\t"$4"\t"$5"\t"$3"\t"$4"\t"$5"\t-\t"$6"\t"$7 } \
else { print $0 } }' > TEMP_inversionsReverted.txt

# Revert translocations to deletions and duplications ($9,$10 distributes the possible WHERE)
cat TEMP_inversionsReverted.txt  | awk '{ \
if($1=="translocation")\
{print "deletion\t"$2"\t"$6"\t"$7";\
 print "duplication\t"$2"\t"$3"\t"$4"\t"$5"\t"$6"\t"$7"\t"$8"\t"$9"\t"$10} \
else { print $0 } }' > TEMP_inversionsAndTranslocationsReverted.txt

simpleframeworkfile=$(fp TEMP_inversionsAndTranslocationsReverted.txt)

printThis="updated frameworkfile in ${frameworkfile}"    
printToLogFile

}

# ----------------------------------------------------------
# Coordinate file format :
# ----------------------------------------------------------

# duplication duplNAME    chr1  100  chr1    200 300  +
# insertion   insNAME     chr1  100  chrIn1  200 300  -
# deletion    delNAME     chr1  100  200

findWhereGroups(){

# As the bracket groups need to be done before others
# Their count is needed

# sets this :
whereGroupsCount=$(($( cat ${frameworkfile} | rev | cut -f 1-2 | rev | grep -c '^WHERE\s' )))
whereGroups=[]
whereGroups=($( cat ${frameworkfile} | rev | cut -f 1-2 | rev | grep '^WHERE\s' | sed 's/WHERE\s\s*//' ))


}

abortIfWhereGroupsFound(){

# Nested WHEREs are not supported (cognitive reasons - not code complexity reasons. avoiding human thought errors in
#  manually inputting compicated nested loops within the parameter files )

TEMPwhereGroupsCount=$(($( cat ${frameworkfile} | rev | cut -f 1-2 | rev | grep -c '^WHERE\s' )))

    if [ "${TEMPwhereGroupsCount}" -ne 0 ]; then
        printThis="Parse fail - WHERE lines found in forWhere file ${frameworkfile} ! \n Nested WHERE loops are not supported (as human error is a real possibility in this kind of input structures) \n See the problems in FAIL_parse_${frameworkfile}.txt file \nEXITING"
        printToLogFile
        
        echo "Parse failures for ${frameworkfile} : " > FAIL_parse_${frameworkfile}.txt
        echo "" >> FAIL_parse_${frameworkfile}.txt
        cat ${frameworkfile} | grep '\sWHERE\s' >> FAIL_parse_${frameworkfile}.txt
        
        exit 1
    fi


}

doAllForFramework(){
    
    printThis="Starting editing for ${frameworkfile} in folder ${frameworkfolder}"
    printNewChapterToLogFile
    
    mkdir ${frameworkfolder}
    weWereHere=$(pwd)
    cp ${frameworkfile} ${frameworkfolder}
    
    cdCommand='cd ${frameworkfolder}'
    cdToThis="${frameworkfolder}"
    checkCdSafety
    cd ${frameworkfolder}

    testedFile="${frameworkfile}"
    doInputFileTesting
    
    simpleframeworkfile="UNDEFINED"
    revertFileToSimpleOperations
    
    wronglyFormattedLineCount=0
    wronglyFormattedLineCount=$(($( cat ${simpleframeworkfile} | grep -v '^deletion\s'  | grep -v '^insertion\s'  | grep -v '^duplication\s')))
    
    if [ "${wronglyFormattedLineCount}" -ne 0 ]; then
        printThis="Parse fail - some lines of ${frameworkfile} did not parse correctly ! \n See the problems in FAIL_parse_${frameworkfile}.txt file \nEXITING"
        printToLogFile
        
        echo "Parse failures for SIMPLE file ${simpleframeworkfile} generated from original file ${frameworkfile} : " > FAIL_parse_${frameworkfile}.txt
        echo "" >> FAIL_parse_${frameworkfile}.txt
        cat ${simpleframeworkfile} | grep -v '^deletion\s'  | grep -v '^insertion\s'  | grep -v '^duplication\s' >> FAIL_parse_${frameworkfile}.txt
        
        exit 1
    fi
    
    # Now only ins/del/dupl lines remain, and we can start looping ..
    
    # ------------------------------------------------
    # Preparing deletions ..
    
    # deletion    delNAME     chr1  100  200
    deletionLines=[]
    # sorting by chromosome ..
    deletionLines=($( cat ${simpleframeworkfile} | grep '^deletion\s' | sort -k3,3 ))
    deletionChrs=[]
    deletionChrs=($( cat ${simpleframeworkfile} | grep '^deletion\s' | cut -f 3 | sort | uniq ))
    deletionChrCount=0
    deletionChrCount=($( cat ${simpleframeworkfile} | grep '^deletion\s' | cut -f 3 | sort | uniq | grep -c "" ))
    
    if [ "${deletionChrCount}" -ne 0 ]; then
    echo ""
    echo "Will make deletions to the following chromosomes :"
    echo "" 
    for i in $( seq 0 $((${#deletionChrs[@]} - 1)) ); do
    echo "${deletionChrs[i]}"
    done
    echo ""
    fi
    
    # ------------------------------------------------
    # Preparing insertions ..

    insDupLines=[]
    # no sorting as order is important ..
    insDupLines=($( cat ${simpleframeworkfile} | grep -v '^deletion\s' ))
    insDupChrs=[]
    insDupChrs=($( cat ${simpleframeworkfile} | grep -v '^deletion\s' | cut -f 3 | sort | uniq ))
    insDupChrCount=0
    insDupChrCount=($( cat ${simpleframeworkfile} | grep -v '^deletion\s' | cut -f 3 | sort | uniq | grep -c "" ))
    
    insChrCount=0
    insChrCount=($( cat ${simpleframeworkfile} | grep '^insertion\s' | cut -f 3 | sort | uniq | grep -c "" ))
    insChrs=[]
    insChrs=($( cat ${simpleframeworkfile} | grep '^insertion\s' | cut -f 3 | sort | uniq ))
    dupChrCount=0
    dupChrCount=($( cat ${simpleframeworkfile} | grep '^duplication\s' | cut -f 3 | sort | uniq | grep -c "" ))
    dupChrs=[]
    dupChrs=($( cat ${simpleframeworkfile} | grep '^duplication\s' | cut -f 3 | sort | uniq ))
    
    if [ "${insChrCount}" -ne 0 ]; then
    echo ""
    echo "Will make insertions (from custom fasta) to the following chromosomes :"
    echo "" 
    for i in $( seq 0 $((${#deletionChrs[@]} - 1)) ); do
    echo "${insChrs[i]}"
    done
    echo ""
    fi
    

    if [ "${dupChrCount}" -ne 0 ]; then
    echo ""
    echo "Will make duplications (from reference fasta or WHERE block) to the following chromosomes :"
    echo "" 
    for i in $( seq 0 $((${#deletionChrs[@]} - 1)) ); do
    echo "${dupChrs[i]}"
    done
    echo ""
    fi
    
    # ------------------------------------------------
    # Executing deletions ..
    
    if [ "${deletionChrCount}" -ne 0 ]; then
    printThis="Starting to make the deletions .."
    printNewChapterToLogFile
    
    for i in $( seq 0 $((${#deletionChrs[@]} - 1)) ); do
    printThis="Making deletions for chromosome ${deletionChrs[i]} .."
    printToLogFile
    
    # Here deletion parses - only for chromosomes we actually need.
    thisChrLines=($( cat ${simpleframeworkfile} | grep '^deletion\s' | awk '{if($3=="'${deletionChrs[i]}'") print $0}' ))
    
    previousCoordinate=0
        for j in $( seq 0 $((${#thisChrLines[@]} - 1)) ); do
            printThis="Making deletion #'${TEMPcounter}' .."
            printToLogFile
            
            # bedtools getfasta -fi ${GenomeFasta} -fo testMinus.fa -bed test.bed
            
            # deletion    delNAME     chr1  100  200
            delNAME=$( echo ${thisChrLines[j]} | cut -f 2 )
            delBEDchr=$( echo ${thisChrLines[j]} | cut -f 3 )
            delBEDend=$( echo ${thisChrLines[j]} | cut -f 4 )
            delBEDnext=$( echo ${thisChrLines[j]} | cut -f 5 )
            
            echo "wholeLine:"
            echo ${thisChrLines[j]} | cat -A
            echo "delNAME ${delNAME} : delBEDchr ${delBEDchr} : delBEDend ${delBEDend} : delBEDnext ${delBEDnext} "
            
            echo -e ${delBEDchr}"\t"${previousCoordinate}"\t"${delBEDend} > TEMP.bed
            echo "TEMP.bed :"
            cat TEMP.bed
            rm -f ${delNAME}.err
            echo "bedtools getfasta -bed TEMP.bed -fi ${RefGenomeFasta} -fo del_${deletionChrs[i]_${delNAME}_del${i}withinChr.fa"
            bedtools getfasta -bed TEMP.bed -fi ${RefGenomeFasta} -fo "del_${deletionChrs[i]_${delNAME}_del${i}withinChr.fa" \
              2> ${delNAME}.err
            
            if [ -s ${delNAME}.err ]; then
              printThis="Bedtools getfasta got errors :"
              printToLogFile
              cat ${delNAME}.err
              cat ${delNAME}.err >&2
              printThis="EXITING ! "
              printToLogFile
              exit 1
            fi
            
            rm -f TEMP.bed 
            
        done
    done
    fi

    
    # ------------------------------------------------
    # Executing insertions ..

    for i in $( seq 0 $((${#insDupLines[@]} - 1)) ); do
    
    # Here insDup parses - only for chromosomes we actually need.
    
    # Here the insDup region may be a WHERE region - this needs a separate if region
    
    done

    # ------------------------------------------------
    
    cdCommand='cd ${weWereHere} in forWhere_${whereName}'
    cdToThis="${weWereHere}"
    checkCdSafety
    
    cd ${weWereHere}
    
}

executeFrameworkFiles(){
    
printThis "Making fasta edits - bit by bit .."
printNewChapterToLogFile
    
whereGroupsCount=0
whereGroups=[]

frameworkfileoriginal="PIPE_editingInstructions.txt"
frameworkfile=${frameworkfileoriginal}
findWhereGroups

# If we have where groups ..
if [ "${whereGroupsCount}" -ne 0 ]; then
for i in $( seq 0 $((${#whereGroups[@]} - 1)) ); do
    whereName=${whereGroups[i]}

    checkThis="${whereName}"
    checkedName='${whereName}'
    checkParse
    
    printThis "WHERE group ${whereName}"
    printNewChapterToLogFile
    
    frameworkfile="PIPE_instructionsForWhere_${whereName}.txt"
    frameworkfolder="forWhere_${whereName}"
    
    # For human cognition reasons (human error probability increases if nested loops are allowed in manual input files)
    # using NESTED where structures in input parameters is not allowed ..
    
    abortIfWhereGroupsFound
    
    # Safe to continue : main parser and executer :
    doAllForFramework
    
done
fi

# Then main loop ..

frameworkfile=${frameworkfileoriginal}
doAllForFramework    
    
}


#!/bin/bash

# The subs below are copied from GEObuilder (as it was 20Feb2017) - and modified here.

fastqParameterFileReader(){
    
    nameList=($( cut -f 1 ./PIPE_fastqPaths.txt ))
    
    # Check how many columns we have.
    test=0
    if [ "${SINGLE_END}" -eq 0 ] ; then  
    test=$( cut -f 4 ./PIPE_fastqPaths.txt | grep -vc "^\s*$" )
    else
    test=$( cut -f 3 ./PIPE_fastqPaths.txt | grep -vc "^\s*$" )
    fi

    # If we have 3 columns paired end, or 2 columns single end :
    if [ "${test}" -eq "0" ]; then

    fileList1=($( cut -f 2 ./PIPE_fastqPaths.txt ))
    
    if [ "${SINGLE_END}" -eq 0 ] ; then
    fileList2=($( cut -f 3 ./PIPE_fastqPaths.txt ))
    fi
    
    # If we have 4 columns paired end, or 3 columns single end :
    else

    if [ "${SINGLE_END}" -eq 0 ] ; then
    cut -f 2,4 ./PIPE_fastqPaths.txt | awk '{ print $2"\t"$1 }' | tr "," "\t" | awk '{for (i=2;i<=NF;i++) printf "%s/%s,",$1,$i; print ""}' | sed 's/,$//' | sed 's/\/\//\//' > forRead1.txt
    cut -f 3,4 ./PIPE_fastqPaths.txt | awk '{ print $2"\t"$1 }' | tr "," "\t" | awk '{for (i=2;i<=NF;i++) printf "%s/%s,",$1,$i; print ""}' | sed 's/,$//' | sed 's/\/\//\//'  > forRead2.txt
    
    fileList1=($( cat ./forRead1.txt ))
    fileList2=($( cat ./forRead2.txt ))
    else
    cut -f 2,3 ./PIPE_fastqPaths.txt | awk '{ print $2"\t"$1 }' | tr "," "\t" | awk '{for (i=2;i<=NF;i++) printf "%s/%s,",$1,$i; print ""}' | sed 's/,$//' | sed 's/\/\//\//' > forRead1.txt
    fileList1=($( cat ./forRead1.txt ))
    fi
    
    fi

    rm -f forRead1.txt forRead2.txt
    
    
}

indexParameterFileReader(){
    
    
# 1,2,4 need to be uniq
# 3,5 need to be all the same.

# indexNames8 is assumed to be FORWARD - indexNames12 is assumed to be REVERSE
# They are not assumed to contain 8 or 12 indices (that was the initial thought, but abandoned)

    indexNames12=($( cut -f 1 ./PIPE_spacerBarcodePrimer_REV.txt ))
    indexShortNames12=($( cut -f 2 ./PIPE_spacerBarcodePrimer_REV.txt ))
    indexSeqs12=($( cut -f 4 ./PIPE_spacerBarcodePrimer_REV.txt ))
    indRevSqs12=($( cut -f 4 ./PIPE_spacerBarcodePrimer_REV.txt | rev | tr A a | tr T t | tr C c | tr G g | tr a T | tr t A | tr c G | tr g C ))
    
    indexNames8=($( cut -f 1 ./PIPE_spacerBarcodePrimer_FWD.txt ))
    indexShortNames8=($( cut -f 2 ./PIPE_spacerBarcodePrimer_FWD.txt ))
    indexSeqs8=($( cut -f 4 ./PIPE_spacerBarcodePrimer_FWD.txt ))
    indRevSqs8=($( cut -f 4 ./PIPE_spacerBarcodePrimer_FWD.txt | rev | tr A a | tr T t | tr C c | tr G g | tr a T | tr t A | tr c G | tr g C ))
    
# Allowing situation, where the spacer and primer are given in only first line ( then user would be marking other lines with '-' )

    SPACER8=$( cut -f 3 ./PIPE_spacerBarcodePrimer_FWD.txt | grep -v '^\s*$' | grep -v '^-$' | head -n 1 )    
    PRIMER8=$( cut -f 5 ./PIPE_spacerBarcodePrimer_FWD.txt | grep -v '^\s*$' | grep -v '^-$' | head -n 1 )
    
    SPACER12=$( cut -f 3 ./PIPE_spacerBarcodePrimer_REV.txt | grep -v '^\s*$' | grep -v '^-$' | head -n 1 )    
    PRIMER12=$( cut -f 5 ./PIPE_spacerBarcodePrimer_REV.txt | grep -v '^\s*$' | grep -v '^-$' | head -n 1 )

    # Test against index sequences : whether indices are named the way they should.

foundPrimer8=$(($( tail -n 1 targetLocus.fa | grep -c ${PRIMER8} )))
foundPrimer12=$(($( tail -n 1 targetLocus.fa | rev | tr A a | tr T t | tr C c | tr G g | tr a T | tr t A | tr c G | tr g C | grep -c ${PRIMER12} )))

primersOK=1
rm -f PRIMER_ERRORS.log
if [ ${foundPrimer8} -eq 0 ] || [ ${foundPrimer12} -eq 0 ]; then
    primersOK=0
    echo >> PRIMER_ERRORS.log
    echo "Couldn't find FORWARD and/or REVERSE primer within the target locus. - Aborting !" >> PRIMER_ERRORS.log
    echo "Maybe you called FWD and REV files vice versa ?" >> PRIMER_ERRORS.log
    echo >> PRIMER_ERRORS.log
    echo "First 50 bases of target locus (should contain the FWD primer) :" >> PRIMER_ERRORS.log
    tail -n 1 targetLocus.fa | awk '{print substr($1,1,50)}' >> PRIMER_ERRORS.log
    echo >> PRIMER_ERRORS.log
    echo "Forward primer :" >> PRIMER_ERRORS.log
    echo ${PRIMER8} >> PRIMER_ERRORS.log
    echo >> PRIMER_ERRORS.log
    echo "Last 50 bases of target locus in REV orientation (should contain the REV primer) :" >> PRIMER_ERRORS.log
    tail -n 1 targetLocus.fa | rev | awk '{print substr($1,1,50)}' | tr A a | tr T t | tr C c | tr G g | tr a T | tr t A | tr c G | tr g C >> PRIMER_ERRORS.log
    echo >> PRIMER_ERRORS.log
    echo "Reverse primer :" >> PRIMER_ERRORS.log
    echo ${PRIMER12} >> PRIMER_ERRORS.log
    echo  >> PRIMER_ERRORS.log
    
fi

# The indexShortName lists are not allowed to contain capital letters 'S' or 'L'

SLinIndexShortNames12=$(($( cut -f 2 ./PIPE_spacerBarcodePrimer_REV.txt | grep -c "[SL]" )))
SLinIndexShortNames8=$(($( cut -f 2 ./PIPE_spacerBarcodePrimer_FWD.txt | grep -c "[SL]" )))
 
if [ ${SLinIndexShortNames12} -ne 0 ] ; then
    primersOK=0
    echo >> PRIMER_ERRORS.log
    echo "Found capital letter S or L (or both) in plate coordinate column (column2) in PIPE_spacerBarcodePrimer_REV.txt file ! This is not allowed. - Aborting !" >> PRIMER_ERRORS.log
    echo  >> PRIMER_ERRORS.log
    
fi

if [ ${SLinIndexShortNames8} -ne 0 ]; then
    primersOK=0
    echo >> PRIMER_ERRORS.log
    echo "Found capital letter S or L (or both) in plate coordinate column (column2) in PIPE_spacerBarcodePrimer_FWD.txt file ! This is not allowed. - Aborting !" >> PRIMER_ERRORS.log
    echo  >> PRIMER_ERRORS.log   
    
fi

if [ "${primersOK}" -eq 0 ]; then
    cat PRIMER_ERRORS.log
    cat PRIMER_ERRORS.log >&2
fi
   
}

indexSeqTempFileMaker(){
    
# indexSeqs12=($( cut -f 3 ./PIPE_spacerBarcodePrimer_REV.txt ))
cut -f 4 ./PIPE_spacerBarcodePrimer_REV.txt > TEMP_IndexSeq12.txt

# indexSeqs8=($( cut -f 3 ./PIPE_spacerBarcodePrimer_FWD.txt ))
cut -f 4 ./PIPE_spacerBarcodePrimer_FWD.txt > TEMP_IndexSeq8.txt

}

minIndexSeqSetter(){
    
minIndexSeqs12=($( cut -f 4 ./PIPE_spacerBarcodePrimer_REV.txt | rev | awk '{print substr($1,1,'${last12uniq}')}' | rev ))
minIndexSeqs8=($( cut -f 4 ./PIPE_spacerBarcodePrimer_FWD.txt | rev | awk '{print substr($1,1,'${last8uniq}')}' | rev ))

}

makeProcessedFileList(){
    
    
# 1,2,4 need to be uniq
# 3,5 need to be all the same.

    fileList1=($( cut -f 1 ./PIPE_spacerBarcodePrimer_${whichFileName}.txt ))
    cut -f 1 ./PIPE_spacerBarcodePrimer_${whichFileName}.txt > forRead1.txt
    
    fileList2=($( cut -f 2 ./PIPE_spacerBarcodePrimer_${whichFileName}.txt ))
    cut -f 2 ./PIPE_spacerBarcodePrimer_${whichFileName}.txt > forRead2.txt
    
    fileList3=($( cut -f 4 ./PIPE_spacerBarcodePrimer_${whichFileName}.txt ))
    cut -f 4 ./PIPE_spacerBarcodePrimer_${whichFileName}.txt > forRead3.txt
    
    sameList1=($( cut -f 3 ./PIPE_spacerBarcodePrimer_${whichFileName}.txt ))
    cut -f 3 ./PIPE_spacerBarcodePrimer_${whichFileName}.txt > sameRead1.txt
    
    sameList2=($( cut -f 5 ./PIPE_spacerBarcodePrimer_${whichFileName}.txt ))
    cut -f 5 ./PIPE_spacerBarcodePrimer_${whichFileName}.txt > sameRead2.txt
    
}

processedParameterFileReader(){

    nameList=($( cut -f 1 ./PIPE_spacerBarcodePrimer_${whichFileName}.txt ))

    makeProcessedFileList
    
    rm -f forRead1.txt

}

indexParameterFileTester(){

rm -f INDEXfile${whichFileName}_LOAD.err


makeProcessedFileList

# Here, simple counts --------------------------------------

    TEMPcount1=$(($( cat ./forRead1.txt | grep -c "" )))
    TEMPcount2=$(($( cat ./forRead2.txt | grep -c "" )))
    TEMPcount3=$(($( cat ./forRead3.txt | grep -c "" )))    
    
    TEMPcount4=$(($( cat ./sameRead1.txt | grep -c "" )))
    TEMPcount5=$(($( cat ./sameRead2.txt | grep -c "" )))

# Printing possible errors ..

if [ "${TEMPcount1}" -ne "${TEMPcount2}" ]; then
  echo "Found different amount of filled data lines : index NAMES (found ${TEMPcount1}) and INDICES (found ${TEMPcount2}), . Correct your PIPE_spacerBarcodePrimer_${whichFileName}.txt file !" >> INDEXfile${whichFileName}_LOAD.err ;indexData${whichFileName}OK=0; 
fi

if [ "${TEMPcount2}" -ne "${TEMPcount3}" ]; then
  echo "Found different amount of filled data lines : plate location short names (found ${TEMPcount3}) and INDICES (found ${TEMPcount2}), . Correct your PIPE_spacerBarcodePrimer_${whichFileName}.txt file !" >> INDEXfile${whichFileName}_LOAD.err ;indexData${whichFileName}OK=0; 
fi

if [ "${TEMPcount3}" -ne "${TEMPcount4}" ]; then
  echo "Found different amount of filled data lines  :  INDICES (found ${TEMPcount3}) and SPACERS (found ${TEMPcount4}), . Correct your PIPE_spacerBarcodePrimer_${whichFileName}.txt file !" >> INDEXfile${whichFileName}_LOAD.err ;indexData${whichFileName}OK=0; 
fi

if [ "${TEMPcount3}" -ne "${TEMPcount5}" ]; then
  echo "Found different amount of filled data lines  : INDICES (found ${TEMPcount3}) and PRIMERS (found ${TEMPcount5}), . Correct your PIPE_spacerBarcodePrimer_${whichFileName}.txt file !" >> INDEXfile${whichFileName}_LOAD.err ;indexData${whichFileName}OK=0; 
fi


# Here, simple uniq tests --------------------------------------

    TEMPcount1=$(($( cat ./forRead1.txt | grep -v '^\s*$' | grep -c "" )))
TEMPuniqcount1=$(($( cat ./forRead1.txt | grep -v '^\s*$' | sort | uniq -c | grep -c "" )))

    TEMPcount2=$(($( cat ./forRead2.txt | grep -v '^\s*$' | grep -c "" )))
TEMPuniqcount2=$(($( cat ./forRead2.txt | grep -v '^\s*$' | sort | uniq -c | grep -c "" )))

    TEMPcount3=$(($( cat ./forRead3.txt | grep -v '^\s*$' | grep -c "" )))
TEMPuniqcount3=$(($( cat ./forRead3.txt | grep -v '^\s*$' | sort | uniq -c | grep -c "" )))

if [ "${TEMPcount1}" -ne "${TEMPuniqcount1}" ]; then
  echo "Some names ( column 1 ) describing your indices are not unique ( you have same name more than once ). Correct your PIPE_spacerBarcodePrimer_${whichFileName}.txt file !" >> INDEXfile${whichFileName}_LOAD.err ;indexData${whichFileName}OK=0;
fi
if [ "${TEMPcount1}" -ne "${TEMPuniqcount1}" ]; then
  echo "Some plate location short names ( column 2 ) are not unique ( you have same name more than once ). Correct your PIPE_spacerBarcodePrimer_${whichFileName}.txt file !" >> INDEXfile${whichFileName}_LOAD.err ;indexData${whichFileName}OK=0;
fi
if [ "${TEMPcount2}" -ne "${TEMPuniqcount2}" ]; then
  echo "Some indices ( column 4 ) of your files are not unique ( you have same index more than once ). Correct your PIPE_spacerBarcodePrimer_${whichFileName}.txt file !" >> INDEXfile${whichFileName}_LOAD.err ;indexData${whichFileName}OK=0;
fi

echo "Found these plate locations, indices, and index names :"
paste forRead2.txt forRead3.txt forRead1.txt 

# Here, tests for empty fields --------------------------------------

    TEMPcount1=$(($( cat ./forRead1.txt | grep '^\s*$' | grep -c "" )))
    TEMPcount2=$(($( cat ./forRead2.txt | grep '^\s*$' | grep -c "" )))
    TEMPcount3=$(($( cat ./forRead3.txt | grep '^\s*$' | grep -c "" )))

if [ "${TEMPcount1}" -gt 0 ] || [ "${TEMPcount2}" -gt 0 ] || [ "${TEMPcount2}" -gt 0 ]; then
  echo "Some index names ( column 1 ), plate location short names ( column 2 ) or indices ( column 4 ) are empty. Fill them up ! Correct your PIPE_spacerBarcodePrimer_${whichFileName}.txt file !" >> INDEXfile${whichFileName}_LOAD.err ;indexData${whichFileName}OK=0;
fi

# Here, the "all to be same" tests --------------------------------------

# Allowing situation, where the spacer and primer are given in only first line ( then user would be marking other lines with '-' )

TEMPuniqcount1=$(($( cat ./sameRead1.txt | grep -v '^\s*$' | grep -v '^\s*-\s*$' | sort | uniq -c | grep -c "" )))
TEMPuniqcount2=$(($( cat ./sameRead2.txt | grep -v '^\s*$' | grep -v '^\s*-\s*$' | sort | uniq -c | grep -c "" )))

if [ "${TEMPuniqcount1}" -gt 1 ] ; then
  echo "All SPACERS (column 3) need to be the same! - Now seen ${TEMPuniqcount1} different spacers." >> INDEXfile${whichFileName}_LOAD.err
  echo "Correct your PIPE_spacerBarcodePrimer_${whichFileName}.txt file ! ( You can use hyphen '-' to say 'same as above' ) " >> INDEXfile${whichFileName}_LOAD.err ;indexData${whichFileName}OK=0;
fi
if [ "${TEMPuniqcount2}" -gt 1 ]; then
  echo "All PRIMERS (column 5) need to be the same ! - Now seen ${TEMPuniqcount2} different primers." >> INDEXfile${whichFileName}_LOAD.err
  echo "Correct your PIPE_spacerBarcodePrimer_${whichFileName}.txt file ! ( You can use hyphen '-' to say 'same as above' ) " >> INDEXfile${whichFileName}_LOAD.err ;indexData${whichFileName}OK=0;
fi

echo
echo "Found these spacers and primers :"
paste sameRead1.txt sameRead2.txt | grep -v -e '-\s-' | uniq -c | sed 's/^\s*//'

# Here, tests for not giving the spacer and/or primer :

if [ "${TEMPuniqcount1}" -eq 0 ] ; then
  echo "NO SPACER (column 3) given ! - Correct your PIPE_spacerBarcodePrimer_${whichFileName}.txt file !" >> INDEXfile${whichFileName}_LOAD.err ;indexData${whichFileName}OK=0;
fi
if [ "${TEMPuniqcount2}" -eq 0 ]; then
  echo "NO PRIMER (column 5) given ! - Correct your PIPE_spacerBarcodePrimer_${whichFileName}.txt file !" >> INDEXfile${whichFileName}_LOAD.err ;indexData${whichFileName}OK=0;
fi


# -------------------------------------------


unset fileList1
unset fileList2
unset sameList1
unset sameList2

rm -f forRead1.txt forRead2.txt forRead3.txt sameRead1.txt sameRead2.txt 

}


setGenomeFasta(){


#-----------Genome-fastas-for-blat-and-bedtools-commands----------------------------------------------

# [telenius@deva plate96test_270217]$ ls -1 /databank/igenomes/*/UCSC/*/Sequence/WholeGenomeFasta/genome.fa
# 
# /databank/igenomes/Caenorhabditis_elegans/UCSC/ce10/Sequence/WholeGenomeFasta/genome.fa
# /databank/igenomes/Caenorhabditis_elegans/UCSC/ce6/Sequence/WholeGenomeFasta/genome.fa
# /databank/igenomes/Danio_rerio/UCSC/danRer10/Sequence/WholeGenomeFasta/genome.fa
# /databank/igenomes/Danio_rerio/UCSC/danRer7/Sequence/WholeGenomeFasta/genome.fa
# /databank/igenomes/Drosophila_melanogaster/UCSC/dm3/Sequence/WholeGenomeFasta/genome.fa
# /databank/igenomes/Drosophila_melanogaster/UCSC/dm6/Sequence/WholeGenomeFasta/genome.fa
# /databank/igenomes/Gallus_gallus/UCSC/galGal4/Sequence/WholeGenomeFasta/genome.fa
# /databank/igenomes/Homo_sapiens/UCSC/hg18/Sequence/WholeGenomeFasta/genome.fa
# /databank/igenomes/Homo_sapiens/UCSC/hg19/Sequence/WholeGenomeFasta/genome.fa
# /databank/igenomes/Homo_sapiens/UCSC/hg38/Sequence/WholeGenomeFasta/genome.fa
# /databank/igenomes/Mus_musculus/UCSC/mm10/Sequence/WholeGenomeFasta/genome.fa
# /databank/igenomes/Mus_musculus/UCSC/mm9/Sequence/WholeGenomeFasta/genome.fa
# /databank/igenomes/Pan_troglodytes/UCSC/panTro3/Sequence/WholeGenomeFasta/genome.fa
# /databank/igenomes/Rattus_norvegicus/UCSC/rn4/Sequence/WholeGenomeFasta/genome.fa
# /databank/igenomes/Rattus_norvegicus/UCSC/rn5/Sequence/WholeGenomeFasta/genome.fa
# /databank/igenomes/Saccharomyces_cerevisiae/UCSC/sacCer3/Sequence/WholeGenomeFasta/genome.fa
# /databank/igenomes/Sus_scrofa/UCSC/susScr3/Sequence/WholeGenomeFasta/genome.fa
#
# [telenius@deva plate96test_270217]$ 


if [ "${GENOME}" = "mm9" ] ; then 
    GenomeFasta="/databank/igenomes/Mus_musculus/UCSC/mm9/Sequence/WholeGenomeFasta/genome.fa"
elif [ "${GENOME}" = "mm10" ] ; then 
    GenomeFasta="/databank/igenomes/Mus_musculus/UCSC/mm10/Sequence/WholeGenomeFasta/genome.fa"
elif [ "${GENOME}" = "hg18" ] ; then
    GenomeFasta="/databank/igenomes/Homo_sapiens/UCSC/hg18/Sequence/WholeGenomeFasta/genome.fa"
elif [ "${GENOME}" = "hg19" ] ; then 
    GenomeFasta="/databank/igenomes/Homo_sapiens/UCSC/hg19/Sequence/WholeGenomeFasta/genome.fa"
elif [ "${GENOME}" = "hg38" ] ; then 
    GenomeFasta="/databank/igenomes/Homo_sapiens/UCSC/hg38/Sequence/WholeGenomeFasta/genome.fa"
elif [ "${GENOME}" = "danRer7" ] ; then 
    GenomeFasta="/databank/igenomes/Danio_rerio/UCSC/danRer7/Sequence/WholeGenomeFasta/genome.fa"
elif [ "${GENOME}" = "danRer10" ] ; then 
    GenomeFasta="/databank/igenomes/Danio_rerio/UCSC/danRer10/Sequence/WholeGenomeFasta/genome.fa"
elif [ "${GENOME}" = "galGal4" ] ; then 
    GenomeFasta="/databank/igenomes/Gallus_gallus/UCSC/galGal4/Sequence/WholeGenomeFasta/genome.fa"
elif [ "${GENOME}" = "ce10" ] ; then 
    GenomeFasta="/databank/igenomes/Caenorhabditis_elegans/UCSC/ce10/Sequence/WholeGenomeFasta/genome.fa"
elif [ "${GENOME}" = "ce6" ] ; then 
    GenomeFasta="/databank/igenomes/Caenorhabditis_elegans/UCSC/ce6/Sequence/WholeGenomeFasta/genome.fa"
elif [ "${GENOME}" = "panTro3" ] ; then 
    GenomeFasta="/databank/igenomes/Pan_troglodytes/UCSC/panTro3/Sequence/WholeGenomeFasta/genome.fa"
elif [ "${GENOME}" = "rn4" ] ; then 
    GenomeFasta="/databank/igenomes/Rattus_norvegicus/UCSC/rn4/Sequence/WholeGenomeFasta/genome.fa"
elif [ "${GENOME}" = "rn5" ] ; then 
    GenomeFasta="/databank/igenomes/Rattus_norvegicus/UCSC/rn5/Sequence/WholeGenomeFasta/genome.fa"
elif [ "${GENOME}" = "susScr3" ] ; then 
    GenomeFasta="/databank/igenomes/Sus_scrofa/UCSC/susScr3/Sequence/WholeGenomeFasta/genome.fa"
else 
  echo "Genome build " ${GENOME} " is not supported - aborting !"  >> "/dev/stderr"
  exit 1 >> "/dev/stderr"
fi
    
echo "Set genome fasta : ${GenomeFasta}"

}

fetchTargetLocus(){

rm -f TARGETlocus_LOAD.err

cut -f 1-3 PIPE_targetLocus_${GENOME}.bed > targetLocus.bed

cut -f 1-3 --complement PIPE_targetLocus_${GENOME}.bed > highlightStartEnds.txt
# Gives 0 if we don't have. If we have highlights, gives how many we have.
weHaveHighlight=$( head -n 1 PIPE_targetLocus_${GENOME}.bed | awk '{if(NF<4){print 0}else{print int((NF-3)/2)}}' )

rm -f targetLocus.fa
bedtools getfasta -fi ${GenomeFasta} -bed targetLocus.bed -fo targetLocus.fa
possibleError="$?"

if [ "${possibleError}" != "0" ]; then
  echo "Couldn't fetch coordinates for the target locus - correct your PIPE_targetLocus_${GENOME}.bed file!" >> TARGETlocus_LOAD.err
  echo "Here the error message :" >> TARGETlocus_LOAD.err
  echo ${possibleError} >> TARGETlocus_LOAD.err
  targetLocusDataOK=0
  
fi

howManyethHighlight=0
locusStart=$(($( cut -f 2 targetLocus.bed | head -n 1 )))
highLightStarts=""
highLightEnds=""
highLightRoundsLeft=${weHaveHighlight}
thisHighLightChr=$( cut -f 1 PIPE_targetLocus_${GENOME}.bed  | head -n 1 )
rm -f highlightLocus_*.fa
echo "highLightRoundsLeft ${highLightRoundsLeft}"
while [ "${highLightRoundsLeft}" -gt 0 ];
do

# First round being :
# highLightStart=$(($( cut -f 1 highlightStartEnds.txt | head -n 1 )-${locusStart}))
# highLightEnd=$(($( cut -f 2 highlightStartEnds.txt | head -n 1 )-${locusStart}))
  thisHighLightStart=$(($( cut -f $(($((${howManyethHighlight}*2))+1)) highlightStartEnds.txt | head -n 1 )-${locusStart}))
thisHighLightStartFA=$(($( cut -f $(($((${howManyethHighlight}*2))+1)) highlightStartEnds.txt | head -n 1 )))

  thisHighLightEnd=$(($( cut -f $(($((${howManyethHighlight}*2))+2)) highlightStartEnds.txt | head -n 1 )-${locusStart}))
thisHighLightEndFA=$(($( cut -f $(($((${howManyethHighlight}*2))+2)) highlightStartEnds.txt | head -n 1 )))

echo -e "${thisHighLightChr}\t${thisHighLightStartFA}\t${thisHighLightEndFA}" > TEMP_highlight.bed

echo TEMP_highlight.bed
cat -A TEMP_highlight.bed

rm -f highlightLocus.fa
bedtools getfasta -fi ${GenomeFasta} -bed TEMP_highlight.bed -fo highlightLocus_${howManyethHighlight}.fa
possibleError="$?"

if [ "${possibleError}" != "0" ]; then
  echo "Couldn't fetch coordinates for the highlight locus n.o. $((${howManyethHighlight}+1)) - correct your PIPE_targetLocus_${GENOME}.bed file!" >> TARGETlocus_LOAD.err
  echo "Here the error message :" >> TARGETlocus_LOAD.err
  echo ${possibleError} >> TARGETlocus_LOAD.err
  targetLocusDataOK=0
  
fi

# Test that all is fine (highlight is contained within the locus)
echo -e "${thisHighLightStartFA}\t${thisHighLightEndFA}" | paste targetLocus.bed - > TEMPthisRound.txt
possibleError1=$(($( cat TEMPthisRound.txt | awk '{ if ($2<=$4 && $3>=$5) {print "0"} else {print "1"}}' )))
# We have data in col 4
possibleError2=$(($( cat TEMPthisRound.txt | awk '{ if (length($4)!=0) {print "0"} else {print "1"}}' )))
# We have data in col 5
possibleError3=$(($( cat TEMPthisRound.txt | awk '{ if (length($5)!=0) {print "0"} else {print "1"}}' )))
possibleError=$((${possibleError1}+${possibleError2}+${possibleError3}))
rm -f TEMPthisRound.txt

if [ "${possibleError}" != "0" ]; then
  echo "The highlight locus was not contained within the target locus - correct your PIPE_targetLocus_${GENOME}.bed file!" >> TARGETlocus_LOAD.err
  
  head targetLocus.bed >> TARGETlocus_LOAD.err
  head highlightStartEnds.txt >> TARGETlocus_LOAD.err

  targetLocusDataOK=0
  
fi

highLightStarts="${highLightStarts},${thisHighLightStart}"
highLightEnds="${highLightEnds},${thisHighLightEnd}"

howManyethHighlight=$((${howManyethHighlight}+1))
highLightRoundsLeft=$((${highLightRoundsLeft}-1))
rm -f TEMP_highlight.bed
done
# Saving the highlight round amount for the python
howManyHighlights=${howManyethHighlight}
highLightStarts=$( echo ${highLightStarts} | sed 's/^,//' )
highLightEnds=$( echo ${highLightEnds} | sed 's/^,//' )


if [ ${targetLocusDataOK} -ne 0 ]; then

# Setting all to CAPITAL letters - no matter if it is repeat region or not !
# This is a safety measure : in our reverse protocol we use simple A - a - A transform , and that would go wonky if we had lower case in the fasta ..

sed -i 's/a/A/g' targetLocus.fa
sed -i 's/t/T/g' targetLocus.fa
sed -i 's/c/C/g' targetLocus.fa
sed -i 's/g/G/g' targetLocus.fa

fi

}
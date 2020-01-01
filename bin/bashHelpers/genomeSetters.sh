#!/bin/bash

##########################################################################
# Copyright 2018, Jelena Telenius (jelena.telenius@imm.ox.ac.uk)         #
#                                                                        #
# This file is part of fastaParser .                                      #
#                                                                        #
# fastaParser is free software: you can redistribute it and/or modify     #
# it under the terms of the MIT license.
#
#
#                                                                        #
# fastaParser is distributed in the hope that it will be useful,          #
# but WITHOUT ANY WARRANTY; without even the implied warranty of         #
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the          #
# MIT license for more details.
#                                                                        #
# You should have received a copy of the MIT license
# along with fastaParser.  
##########################################################################

setRefGenomeFasta(){
    
RefGenomeFasta="UNDETERMINED"

#-----------Genome-sizes-for-bowtie-commands----------------------------------------------  

# echo "_${GENOME}_"
    
for g in $( seq 0 $((${#supportedGenomes[@]}-1)) ); do
    
# echo ${supportedGenomes[$g]}

if [ "${supportedGenomes[$g]}" == "${GENOME}" ]; then
    RefGenomeFasta="${WholeGenomeFASTA[$g]}"
fi

done  

#------------------------------------------------

# Check that it got set ..

if [ "${RefGenomeFasta}" == "UNDETERMINED" ]; then 
  echo "Genome build " ${GENOME} " is not supported -- aborting !"  >&2
  exit 1 
fi    

# Check that the index file exists..

if [ ! -s "${RefGenomeFasta}" ]; then

  echo "Whole genome fasta for ${GENOME} : file not found : ${RefGenomeFasta} - aborting !"  >&2
  exit 1     
fi

echo
echo "Genome ${GENOME} .  Set whole genome fasta file : ${RefGenomeFasta}"


}


setUCSCgenomeSizes(){
    
ucscBuild="UNDETERMINED"
    
for g in $( seq 0 $((${#supportedGenomes[@]}-1)) ); do
    
# echo ${supportedGenomes[$g]}

if [ "${supportedGenomes[$g]}" == "${GENOME}" ]; then
    ucscBuild="${UCSC[$g]}"
fi

done 
    
if [ "${ucscBuild}" == "UNDETERMINED" ]; then 
  echo "Genome build " ${GENOME} " is not supported --- aborting !"  >&2
  exit 1 
fi

# Check that the file exists..
if [ ! -e "${ucscBuild}" ] || [ ! -r "${ucscBuild}" ] || [ ! -s "${ucscBuild}" ]; then
  echo "Genome build ${GENOME} file ${ucscBuild} not found or empty file - aborting !"  >&2
  exit 1     
fi

echo
echo "Genome ${GENOME} . Set UCSC genome sizes file : ${ucscBuild}"
echo

}




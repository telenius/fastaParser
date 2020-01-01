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

version(){
    pipesiteAddress="http://userweb.molbiol.ox.ac.uk/public/telenius/NOTMADEYET"
    
    versionInfo="\nFastaParser version ${version} pipeline, running fastaParser.sh \nUser manual, updates, bug fixes, etc in : ${pipesiteAddress}\n"

}


usage(){
    
    version
    echo -e ${versionInfo}
    
echo 
echo "FOR CUSTOMISING FASTAS AND MAKING CUSTOM GENOMES"
echo
echo "Instructions last edited : 16:28 8May2018"
echo
echo "-----------------------------------------"
echo "-h/--help     Show this help "
echo "-----------------------------------------"
echo
echo "Parameter files :"
echo
echo "1) PIPE_referenceGenome.txt - OBLIGATORY (to set the reference genome into which the edits are to be made)"
echo "2) PIPE_otherSequences.txt  - OPTIONAL (to read in sequences, which are to be fully or partially inserted into the reference genome given in (1) )" 
echo "3) PIPE_editingInstructions.txt - OBLIGATORY ( to give instructions how to edit the fasta file in (1) by using the fasta files given in (1) and (2)"
echo
echo "Give these files in <whitespace> delimited format (tab or space as delimiter)"
echo
echo "-----------------------------------------"
echo
echo "1-2) PIPE_referenceGenome.txt, PIPE_otherSequences.txt"
echo
echo "1st column : reference genome name (OBLIGATORY)"
echo "2nd column : reference fasta location (OPTIONAL)"
echo
echo "If 2nd column empty, the genome name (1st column) is used to locate the genome in iGenomes directory /databank/igenomes"
echo
echo "Example1"
echo "mm9"  
echo
echo "Example2"
echo "mm9_my_mod    /t1-data/my/area/modified/mm9_genomeMod.fa"  
echo
echo "Example3"
echo "mySmallIndels /t1-data/my/area/smallfiles/chr11_mm9_globins_indels_1to10.fa"  
echo
echo "List all available readymade iGenomes reference genomes with this command :"
# echo -n 'find /databank/igenomes/*/UCSC/*/*/*Fasta/genome.fa | '
# echo -n "sed 's/UCSC\//UCSC\/\t/' | sed 's/\/Seq/\t\/Seq/' | awk '"
# echo -n '{print $2"\t"$1$2$3}'
# echo "'"

echo -n 'find /databank/igenomes/*/UCSC/*/*/*Fasta/genome.fa | '
echo  "sed 's/.*UCSC\///' | sed 's/\/Seq.*//'"

echo
echo "Fasta file format example - to list your own insertions/modifications as a FASTA file :"
echo
echo ">derice"
echo "ACTGACTAGCTAGCTAACTG"
echo ">sanka"
echo "GCATCGTAGCTAGCTACGAT"
echo ">junior"
echo "CATCGATCGTACGTACGTAG"
echo ">yul"
echo "ATCGATCGATCGTACGATCG"
echo
echo "-----------------------------------------"
echo
echo "3) PIPE_editingInstructions.txt"
echo
echo "Editing instructions are given by user, in input file PIPE_editingInstructions.txt"
echo "1st column = type, 2nd column = user given name : 3rd-8th column = coordinates"
echo
echo "(1)type     (2)name     (3-5)chr str stp "
echo "deletion    delNAME     chr1   100   200 "
echo 
echo "(1)type     (2)name     (3-4)        (5-8) "
echo "duplication duplNAME    chr1   100   chr1    200 300  + "
echo "insertion   insNAME     chr1   100   chrIn1  200 300  - "
echo "                                     (5-8) TAKE THIS SEQUENCE : chr str stp strand"
echo "                        (3-4)AND PUT IT HERE (chr str) : reference genome given in PIPE_referenceGenome.txt"
echo "                                      duplication : (5-8) from PIPE_referenceGenome.txt "
echo "                                      insertion : (5-8) from PIPE_otherSequences.txt"
echo "Inserting WHOLE sequence from custom file (omitting str stp)"
echo "insertion   insNAME     chr1   100   myIns fromStart toEnd + "
echo "insertion   insNAME     chr1   100   myIns fromStart toEnd - "
echo
echo "-  -  -  -  -  -  -  -  -  -  -  -  -  -  "
echo "Special shortcuts 'substitution' and 'translocation' and 'inversion' "
echo
echo "substitution trNAME    chr1   100  200  chrIn1    100 200 + "
echo "actually consists of operations : "
echo "deletion    delNAME    chr1   100  200 (from PIPE_referenceGenome.txt)"
echo "insertion   insNAME    chrIn1 100  chrIn1  100 200  + (col 3-4 from PIPE_referenceGenome.txt "
echo "                                                       col 5-8 from PIPE_otherSequences.txt) "
echo "substituting with WHOLE sequence from custom fasta (omitting str stp) :"
echo "substitution trNAME    chr1   100  200   myModSeq fromStart toEnd + "
echo "substitution trNAME    chr1   100  200   myModSeq fromStart toEnd - "
echo
echo "translocation trNAME    chr1  100  chr1    200 300 + "
echo "actually consists of operations (both reading PIPE_referenceGenome.txt) : "
echo "deletion    delNAME     chr1  200  300 "
echo "duplication duplNAME    chr1  100  chr1    200 300  + "
echo
echo "inversion   invNAME     chr1  100  200 "
echo "can also be written as "
echo "translocation trNAME    chr1  100  chr1    100 200 - " 
echo "and thus actually consists of operations : (both reading PIPE_referenceGenome.txt) "
echo "deletion    delNAME     chr1  100  200 "
echo "duplication duplNAME    chr1  100  chr1    100 200  - "
echo 
 
 exit 0
    
}


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

setPathsForPipe(){

# #############################################################################

# This is the CONFIGURATION FILE to load in the needed toolkits ( conf/loadNeededTools.sh )

# #############################################################################

# Setting the needed programs to path.

# This can be done EITHER via module system, or via EXPORTING them to the path.
# If exporting to the path - the script does not check already existing conflicting programs (which may contain executable with same names as these)

# If neither useModuleSystem or setPathsHere : the script assumes all toolkits are already in path !

# If you are using module system
useModuleSystem=1
# useModuleSystem=1 : load via module system
# useModuleSystem=0 : don't use module system

# If you are adding to path (using the script below)
setPathsHere=0
# setPathsHere=1 : set tools to path using the bottom of this script
# setPathsHere=0 : dset tools to path using the bottom of this script

# If neither useModuleSystem or setPathsHere : the script assumes all toolkits are already in path !

# #############################################################################

# PATHS_LOADED_VIA_MODULES

if [ "${useModuleSystem}" -eq 1 ]; then

module purge
# Removing all already-loaded modules to start from clean table

module load samtools/1.3
# Supports all samtools versions in 1.* series. Does not support samtools/0.* .

module load bedtools/2.25.0
# Supports bedtools versions 2.2* . Does not support bedtools versions 2.1*

module list 2>&1

# #############################################################################

# EXPORT_PATHS_IN_THIS_SCRIPT

elif [ "${setPathsHere}" -eq 1 ]; then

echo
echo "Adding tools to PATH .."
echo
    
# Note !!!!!
# - the script does not check already existing conflicting programs within $PATH (which may contain executable with same names as these)

export PATH=$PATH:/package/samtools/1.3/bin
export PATH=$PATH:/package/bedtools/2.25.0/bin

# See notes of SUPPORTED VERSIONS above !

echo $PATH

# #############################################################################

# EXPORT_NOTHING_i.e._ASSUMING_USER_HAS_TOOLS_LOADED_VIA_OTHER_MEANS

else
    
echo
echo "Tools should already be available in PATH - not loading anything .."
echo

fi

# #########################################

# UCSCtools are taken from install directory, in any case :

export PATH=$PATH:/${confFolder}/ucsctools



}


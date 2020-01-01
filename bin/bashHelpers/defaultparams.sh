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

writeParametersToLogFile(){

echo "------------------------------" > run_parameters.log
echo "Output log file ${QSUBOUTFILE}" >> run_parameters.log
echo "Output error log file ${QSUBERRFILE}" >> run_parameters.log
echo "------------------------------" >> run_parameters.log
echo "confFolder ${confFolder}" >> run_parameters.log
echo "RunScriptsPath ${RunScriptsPath}" >> run_parameters.log
echo "HelperScriptsPath ${HelperScriptsPath}" >> run_parameters.log
echo "------------------------------" >> run_parameters.log
echo "GENOME ${GENOME}" >> run_parameters.log
echo "GenomeFasta ${GenomeFasta}" >> run_parameters.log
echo "ucscBuild ${ucscBuild}" >> run_parameters.log

}


#------------------------------------------------
# Bringing in the parameters and their default values ..

QSUBOUTFILE="qsub.out"
QSUBERRFILE="qsub.err"

GENOME="UNDEFINED_GENOME"
Sample="sample"

ucscBuild="UNDEFINED_UCSCBUILD"

PublicPath="UNDETERMINED"


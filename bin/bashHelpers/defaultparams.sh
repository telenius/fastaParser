#!/bin/bash

##########################################################################
# Copyright 2017, Jelena Telenius (jelena.telenius@imm.ox.ac.uk)         #
#                                                                        #
# This file is part of CCseqBasic5 .                                     #
#                                                                        #
# CCseqBasic5 is free software: you can redistribute it and/or modify    #
# it under the terms of the GNU General Public License as published by   #
# the Free Software Foundation, either version 3 of the License, or      #
# (at your option) any later version.                                    #
#                                                                        #
# CCseqBasic5 is distributed in the hope that it will be useful,         #
# but WITHOUT ANY WARRANTY; without even the implied warranty of         #
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the          #
# GNU General Public License for more details.                           #
#                                                                        #
# You should have received a copy of the GNU General Public License      #
# along with CCseqBasic5.  If not, see <http://www.gnu.org/licenses/>.   #
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


#!/bin/bash

setGenomeLocations(){

# #############################################################################

# This is the CONFIGURATION FILE to set up your GENOME INDICES ( conf/genomeBuildSetup.sh )


# #############################################################################
# SUPPORTED GENOMES 
# #############################################################################

# Add and remove genomes via this list.
# If user tries to use another genome (not listed here), the run is aborted with "genome not supported" message.

supportedGenomes[0]="mm9"
supportedGenomes[1]="mm10"
supportedGenomes[2]="hg18"
supportedGenomes[3]="hg19"
supportedGenomes[4]="hg38"
supportedGenomes[5]="danRer7"
supportedGenomes[6]="danRer10"
supportedGenomes[7]="galGal4"
supportedGenomes[8]="dm3"
supportedGenomes[9]="dm6"
supportedGenomes[10]="mm10balb"

# #############################################################################
# WHOLE GENOME FASTA FILES
# #############################################################################

# These are the whole genome fasta files, against which the bowtie1 indices were built, in UCSC coordinate set (not ENSEMBLE coordinates)
# These need to correspond to the UCSC chromosome sizes files (below)

# These can be symbolic links to the central copies of the indices.
# By default these are 

WholeGenomeFASTA[0]="/databank/igenomes/Mus_musculus/UCSC/mm9/Sequence/WholeGenomeFasta/genome.fa"
WholeGenomeFASTA[1]="/databank/igenomes/Mus_musculus/UCSC/mm10/Sequence/WholeGenomeFasta/genome.fa"
WholeGenomeFASTA[2]="/databank/igenomes/Homo_sapiens/UCSC/hg18/Sequence/WholeGenomeFasta/genome.fa"
WholeGenomeFASTA[3]="/databank/igenomes/Homo_sapiens/UCSC/hg19/Sequence/WholeGenomeFasta/genome.fa"
WholeGenomeFASTA[4]="/databank/igenomes/Homo_sapiens/UCSC/hg38/Sequence/WholeGenomeFasta/genome.fa"
WholeGenomeFASTA[5]="/databank/igenomes/Danio_rerio/UCSC/danRer7/Sequence/WholeGenomeFasta/genome.fa"
WholeGenomeFASTA[6]="/databank/igenomes/Danio_rerio/UCSC/danRer10/Sequence/WholeGenomeFasta/genome.fa"
WholeGenomeFASTA[7]="/databank/igenomes/Gallus_gallus/UCSC/galGal4/Sequence/WholeGenomeFasta/genome.fa"
WholeGenomeFASTA[8]="/databank/igenomes/Drosophila_melanogaster/UCSC/dm3/Sequence/WholeGenomeFasta/genome.fa"
WholeGenomeFASTA[9]="/databank/igenomes/Drosophila_melanogaster/UCSC/dm6/Sequence/WholeGenomeFasta/genome.fa"
WholeGenomeFASTA[10]="/t1-data/user/rbeagrie/genomes/balbc/mm10_BALB-cJ_snpsonly/mm10_BALB-cJ.fa"
# The mm9PARP.fa causes error via dpnIIcutGenome4.pl as that outputs file called mm9PARP_dpnII_coordinates.txt
# and the subsequent scripts assume file called genome_dpnII_coordinates.txt instead.
# WholeGenomeFASTA[11]="/t1-data/user/hugheslab/telenius/GENOMES/PARP/mm9PARP.fa"
WholeGenomeFASTA[11]="/t1-data/user/hugheslab/telenius/GENOMES/PARP/mm9/genome.fa"

# The indices in the WholeGenomeFASTA array refer to genome names in supportedGenomes array (top of page).

# Not all of them need to exist : only the ones you will be using.
# The pipeline checks that this file exists, before proceeding with the analysis.

# #############################################################################
# UCSC GENOME SIZES
# #############################################################################

# The UCSC genome sizes, for ucsctools .
# By default these are located in the 'conf/UCSCgenomeSizes' folder (relative to location of NGseqBasic.sh main script) .
# All these are already there - they come with the NGseqBasic codes.

# Change the files / paths below, if you want to use your own versions of these files. 

# These can be fetched with ucsctools :
# module load ucsctools
# fetchChromSizes mm9 > mm9.chrom.sizes

UCSC[0]="${confFolder}/UCSCgenomeSizes/mm9.chrom.sizes"
UCSC[1]="${confFolder}/UCSCgenomeSizes/mm10.chrom.sizes"
UCSC[2]="${confFolder}/UCSCgenomeSizes/hg18.chrom.sizes"
UCSC[3]="${confFolder}/UCSCgenomeSizes/hg19.chrom.sizes"
UCSC[4]="${confFolder}/UCSCgenomeSizes/hg38.chrom.sizes"
UCSC[5]="${confFolder}/UCSCgenomeSizes/danRer7.chrom.sizes"
UCSC[6]="${confFolder}/UCSCgenomeSizes/danRer10.chrom.sizes"
UCSC[7]="${confFolder}/UCSCgenomeSizes/galGal4.chrom.sizes"
UCSC[8]="${confFolder}/UCSCgenomeSizes/dm3.chrom.sizes"
UCSC[9]="${confFolder}/UCSCgenomeSizes/dm6.chrom.sizes"
UCSC[10]="${confFolder}/UCSCgenomeSizes/mm10.chrom.sizes"

# The indices in the UCSC array refer to genome names in supportedGenomes array (top of page).

# Not all of them need to exist : only the ones you will be using.
# The pipeline checks that at least one index file exists, before proceeding with the analysis

# When adding new genomes : remember to update the "supportedGenomes" list above (top of this file) as well !

}


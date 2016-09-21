#!/bin/bash 
display_usage() {
  echo -e ""
  echo -e "This script runs the Merge GVCF step of a variant calling pipeline based on bwa-gatk."  
  echo -e ""
  echo -e "Usage:"
  echo -e "  $0 VCFFILES, FASTA, prefix mem GATKversion"
  echo -e ""
  echo -e "Arguments:"
  echo -e "  VCFFILES: input vcf files to be merged. Comma-delimited list."
  echo -e "  FASTA: reference genome fasta file."
  echo -e "  prefix: prefix of the output vcf file. The output file name will be prefix.hc.raw.g.vcf."
  echo -e "  mem: memory (recommended: 2G)."
  echo -e "  GATKversion: version of GATK (recommended: 3.5n)."
  echo -e ""
}

# if no arguments supplied, display usage 
if [  $# -le 0 ]
then
  display_usage
  exit 0
fi

# check whether user had supplied -h or --help . If yes display usage 
if [[ $# == 1 && ( $1 == "--help" ||  $1 == "-h" )]]
then
  display_usage
  exit 0
fi

####################


VCFFILES=$1 ## comma-separated list of files
FASTA=$2 ## human_g1k_v37_decoy.fasta ## other fai, dict files should come with it
prefix=$3
mem=$4
GATKversion=$5 ## 3.5n

outputname=$prefix.hc.raw.g.vcf



vcf_list_str=''
for vcffile in ${vcffiles//,/ }
do
 vcf_list_str='--variant '$vcffile' '$vcf_list_str
done


### HaplotypeCaller (Simple example)
#### step2. merge g.vcf
java -Xmx$mem -Xms$mem -cp /usr/local/bin/GATK$GATKversion/GenomeAnalysisTK.jar org.broadinstitute.gatk.tools.CatVariants  -R $FASTA $vcf_list_str -out $outputname --assumeSorted -l INFO


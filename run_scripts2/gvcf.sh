#!/bin/bash 
display_usage() {
  echo -e ""
  echo -e "This script runs the Generate GVCF step of a variant calling pipeline based on bwa-gatk."  
  echo -e ""
  echo -e "Usage:"
  echo -e "  $0 BAM fasta dbSNP region prefix ncore mem GATKversion"
  echo -e ""
  echo -e "Arguments:"
  echo -e "  BAM : input bam file"
  echo -e "  fasta : reference genome fasta file"
  echo -e "  dbSNP : reference dbSNP vcf file"
  echo -e "  region: region (eg. 21:1-50000). The region must match the chromosome."
  echo -e "  prefix: prefix of the output files. The output file name will be prefix.region.g.vcf."
  echo -e "  ncore: number of CPUs (recommended: 2)"
  echo -e "  mem: memory (recommended: 4G)."
  echo -e "  GATKversion: GATKversion (recommended: 3.5n)."
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

BAM=$1
FASTA=$2 ## human_g1k_v37_decoy.fasta ## other fai, dict files should come with it
dbSNP=$3 ## dbsnp_138.b37.vcf 
region=$4
prefix=$5
ncore=$6
mem=$7
GATKversion=$8 ## 3.5n
outputname=$prefix.$region.g.vcf


### HaplotypeCaller (Simple example)
### step1. generate g.vcf
java -Xms$mem -Xmx$mem -jar /usr/local/bin/GATK$GATKversion/GenomeAnalysisTK.jar -T HaplotypeCaller -R $FASTA -I $BAM --dbsnp $dbSNP -o $outputname --emitRefConfidence GVCF -l INFO -rf BadCigar -nct $ncore -dt NONE -L $region



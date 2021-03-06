## GATK-Docker
These are source files used for a docker container for bwa-gatk-based variant calling pipeline.

Authors: Soo Lee (duplexa@gmail.com) & Daniel Kwon (daniel.minseok.kwon@gmail.com) at Peter Park Lab, Department of Biomedical Informatics, Harvard Medical School, Boston, MA, USA.

## Table of contents
* [Docker image](#docker-image)
* [Prerequisites](#prerequisites)
* [Installed software programs](#installed-software-programs)
* [Pipeline steps](#pipeline-steps)
* [Example commands for pipeline steps](#example-commands-for-pipeline-steps)


## Docker image
The docker image is stored as dbmi/gatk-docker:v1 on hub.docker.com.

## Prerequisites
* docker daemon
* The resource files in aws S3://maestro-resources/ must be mounted to the docker container as /resources/.

## Installed software programs
The following programs are pre-installed under /usr/local/bin/ inside the container.
```
BEDtools-2.23.0
GATK3.4
GATK3.5
GATK3.5n  # GATK3.5_160425_g7a7b7cd
GATK3.6
R        # R 3.1.2 
Rscript  # R 3.1.2
VarScan  # VarScan.v2.3.8.jar in /usr/local/bin/VarScan/
annovar  # annotate_variation.pl & convert2annovar.pl in /usr/local/bin/annovar/
bincov   # bincov in /usr/local/bin/bincov
bwa-0.7.8
fastqc-0.11.3
jdk1.6.0_45
jdk1.7.0_71   ## default path is set to Java 1.7 but Java 1.6 and 1.8 are also available.
jdk1.8.0_45
mutect  # mutect-1.1.7.jar in /usr/local/bin/mutect/
picard-1.130
run_scripts  # contains 12 .sh scripts (each describing a step) and one .py script used by one of the .sh scripts.
samtools-1.3
tabix-0.2.6
vcftools-0.1.12
```


## Pipeline steps 

Each of the following shell scripts executes a step of the bwa-gatk-based variant calling pipeline. (In the order displayed). These scripts are under /usr/local/bin/run_scripts/ inside the container. Each script requires an output directory to be specified. If the specified output directory does not exist, the script will create one. Typing a script name without any argument will print out the usage.


#### split_fastq.sh
```
This script runs the Split_fastq step of a variant calling pipeline based on bwa-gatk.

Usage:
  /usr/local/bin/run_scripts/split_fastq.sh fastq_gz project_outdir mate

Arguments:
  fastq_gz: path to the gzipped fastq file (eithe R1 or R2)
  project_outdir: directory in which output files are placed.
  mate: 'R1' or 'R2'. Must match the mate of the fastq file.
```


#### align_sort_addrg.sh 
```
This script runs the Alignmet, sort and addRG steps of a variant calling pipeline based on bwa-gatk.

Usage:
  /usr/local/bin/run_scripts/align_sort_addrg.sh project_indir project_outdir split_prefix RGID RGLB RGSM ncore mem

Arguments:
  project_indir: directory in which input files are placed.
  project_outdir: directory in which output files are placed.
  split_prefix: input file prefix (samplename + split_tag) (eg. TEST.MG01HX08_123_HK3GMCCXX_1). Input file names are assumed to be split_prefix.R[12].fastq.gz.
  RGID: lane name (eg. L1).
  RGLB: lane ID (eg. MG01HX08_123_HK3GMCCXX_1).
  RGSM: sample ID (eg. S1).
  ncore: number of CPUs (recommended: 4).
  mem: memory (recommended: 2G).
```

#### rmdup.sh
```
This script runs the Mark Duplicate step of a variant calling pipeline based on bwa-gatk.

Usage:
  /usr/local/bin/run_scripts/rmdup.sh project_indir project_outdir split_prefix_list_str prefix mem

Arguments:
  project_indir: directory in which input files are placed.
  project_outdir: directory in which output files are placed.
  split_prefix_list_str: comma-separated list of input file prefix (samplename + split_tag) (eg. TEST.MG01HX08_123_HK3GMCCXX_1). Input file names are assumed to be split_prefix.addrg.bam.
  prefix: prefix of the output bam file. The output file name will be prefix.mkdup.bam.
  mem: memory (recommended: 32G).
```

#### realign.sh
```
This script runs the Indel Realignment step of a variant calling pipeline based on bwa-gatk.

Usage:
  /usr/local/bin/run_scripts/realign.sh project_indir project_outdir prefix chr ncore mem

Arguments:
  project_indir: directory in which input files are placed.
  project_outdir: directory in which output files are placed.
  prefix: prefix of the input/output bam files. The input file name is assumed to be prefix.mkdup.bam and the output file name will be prefix.indel.chr.bam.
  chr: chromosome (eg. 21, or 'decoy', or 'unmapped').
  ncore: number of CPUs (recommended: 2)
  mem: memory (recommended: 8G).
```

#### bqsr1.sh 
```
This script runs the BQSR (1) step of a variant calling pipeline based on bwa-gatk.

Usage:
  /usr/local/bin/run_scripts/bqsr1.sh project_indir project_outdir prefix chr_list_str ncore mem

Arguments:
  project_indir: directory in which input files are placed.
  project_outdir: directory in which output files are placed.
  prefix: prefix of the input/output bam files. The input file names are assumed to be prefix.indel.chr.bam and the output file name will be prefix.bqsr.
  chr_list_str: comma-separated list of chromosomes (eg. 1,2,3,4,5,6,7,8,...).
  ncore: number of CPUs (recommended: 2)
  mem: memory (recommended: 8G).
```

#### bqsr2.sh 
```
This script runs the BQSR (2) step of a variant calling pipeline based on bwa-gatk.

Usage:
  /usr/local/bin/run_scripts/bqsr2.sh project_indir project_bqsr_indir project_outdir prefix chr ncore mem

Arguments:
  project_indir: directory in which input files are placed.
  project_bqsr_indir: directory in which input bqsr files are placed.
  project_outdir: directory in which output files are placed.
  prefix: prefix of the input/output bam/bqsr files. The input file names are assumed to be prefix.indel.chr.bam and prefix.bqsr and the output file name will be prefix.final.chr.bam.
  chr: chromosome (eg. 21, or 'decoy', or 'unmapped').
  ncore: number of CPUs (recommended: 2)
  mem: memory (recommended: 8G).
```

#### merge_finalbam.sh 
```
This script runs the Merge final bam step of a variant calling pipeline based on bwa-gatk.

Usage:
  /usr/local/bin/run_scripts/merge_finalbam.sh project_indir project_outdir prefix chr_list_str

Arguments:
  project_indir: directory in which input files are placed.
  project_outdir: directory in which output files are placed.
  prefix: prefix of the output bam file. The output file name will be prefix.mkdup.bam.
  chr_list_str: comma-separated list of chromosomes to be merged. (1,2,3,...,MT,decoy,unmapped)
```

#### gvcf.sh
```
This script runs the Generate GVCF step of a variant calling pipeline based on bwa-gatk.

Usage:
  /usr/local/bin/run_scripts/gvcf.sh project_indir project_outdir prefix chr region ncore mem

Arguments:
  project_indir: directory in which input files are placed.
  project_outdir: directory in which output files are placed.
  prefix: prefix of the input/output bam/vcf files. The input file names are assumed to be prefix.final.chr.bam and the output file name will be prefix.region.g.vcf.
  chr: chromosome (eg. 21).
  region: region (eg. 21:1-50000). The region must match the chromosome.
  ncore: number of CPUs (recommended: 2)
  mem: memory (recommended: 4G).
```

#### merge_gvcf.sh 
```
This script runs the Merge GVCF step of a variant calling pipeline based on bwa-gatk.

Usage:
  /usr/local/bin/run_scripts/merge_gvcf.sh project_indir project_outdir prefix region_list_str mem

Arguments:
  project_indir: directory in which input files are placed.
  project_outdir: directory in which output files are placed.
  prefix: prefix of the input/output vcf files. The input file names are assumed to be prefix.region.g.vcf and the output file name will be prefix.hc.raw.g.vcf.
  region_list_str: comma-separated list of regions (eg. 21:1-50000).
  mem: memory (recommended: 2G).
```

#### hc.sh 
```
This script runs the Haplotype Caller step of a variant calling pipeline based on bwa-gatk.

Usage:
  /usr/local/bin/run_scripts/hc.sh project_indir project_outdir prefix_list_str group_prefix region ncore mem

Arguments:
  project_indir: directory in which input files are placed.
  project_outdir: directory in which output files are placed.
  prefix_list_str: comma-separated list of prefices (samples). The input file names are assumed to be prefix.hc.raw.g.vcf.
  group_prefix: prefix of the output vcf file. This represents a group of samples to be jointly called. The output file name will be group_prefix.hc.geno.region.g.vcf.
  region: region (eg. 21:1-50000).
  ncore: number of CPUs (recommended: 2).
  mem: memory (recommended: 4G).
```

#### combine_hc.sh 
```
This script runs the Combine_hc_gvcf step of a variant calling pipeline based on bwa-gatk.

Usage:
  /usr/local/bin/run_scripts/combine_hc.sh project_indir project_outdir group_prefix region_list_str mem

Arguments:
  project_indir: directory in which input files are placed.
  project_outdir: directory in which output files are placed.
  group_prefix: prefix of the input/output vcf file. This represents a group of samples jointly called. The input file names are assumed to be group_prefix.hc.geno.region.g.vcf and the output file name will be group_prefix.hc.geno.g.vcf.
  region_list_str: comma-separated regions (eg. 21:1-50000,22:50001-100000,...).
  mem: memory (recommended: 2G).
```

#### vqsr.sh 
```
This script runs the VQSR step of a variant calling pipeline based on bwa-gatk.

Usage:
  /usr/local/bin/run_scripts/vqsr.sh project_indir project_outdir group_prefix ncore mem

Arguments:
  project_indir: directory in which input files are placed.
  project_outdir: directory in which output files are placed.
  group_prefix: prefix of the input/output vcf file. This represents a group of samples jointly called. The input file name is assumed to be group_prefix.hc.geno.g.vcf and the output files name will be group_prefix.hc.snp.vqsr.vcf and group_prefix.hc.indel.vqsr.vcf.
  ncore: number of CPUs (recommended: 2).
  mem: memory (recommended: 15G).
```

## Example commands for pipeline steps
```
split_fastq.sh /output/TEST.R1.fastq.gz /output/S1 R1
split_fastq.sh /output/TEST.R2.fastq.gz /output/S1 R2

align_sort_addrg.sh /output/S1/ /output/S1.aln/ E00121_123_H7V72CCXX_5.001 L1 E00121_123_H7V72CCXX_5 S1 2 2G
align_sort_addrg.sh /output/S1/ /output/S1.aln/ E00121_123_H7V72CCXX_6.001 L2 E00121_123_H7V72CCXX_6 S1 2 2G

rmdup.sh /output/S1.aln/ /output/output.S1.rmdup/ E00121_123_H7V72CCXX_5.001,E00121_123_H7V72CCXX_6.001 S1 2G

realign.sh /output/output.S1.rmdup/ /output/S1/realign/ S1 21 2 2G
realign.sh /output/output.S1.rmdup/ /output/S1/realign/ S1 decoy 2 2G
realign.sh /output/output.S1.rmdup/ /output/S1/realign/ S1 unmapped 2 2G

bqsr1.sh /output/S1/realign /output/S1/bqsr S1 21,decoy,unmapped 2 2G

bqsr2.sh  /output/S1/realign /output/S1/bqsr /output/S1/bqsr S1 21 2 2G
bqsr2.sh  /output/S1/realign /output/S1/bqsr /output/S1/bqsr S1 decoy 2 2G
bqsr2.sh  /output/S1/realign /output/S1/bqsr /output/S1/bqsr S1 unmapped 2 2G

merge_finalbam.sh /output/S1/bqsr /output/S1/finalbam S1 21,decoy,unmapped

gvcf.sh /output/S1/bqsr /output/gvcf S1 21 21:1-50000 2 2G  # use non-sample-specific output directory
gvcf.sh /output/S1/bqsr /output/gvcf S1 21 21:50001-100000 2 2G  # use non-sample-specific output directory

merge_gvcf.sh /output/gvcf/ /output/gvcf S1 21:1-50000,21:50001-100000 2G

hc.sh /output/gvcf/ /output/hc S1 S 21:1-50000 2 2G  # in case of multiple samples, S1,S2,S3,... instead of S1
hc.sh /output/gvcf/ /output/hc S1 S 21:50001-100000 2 2G # in case of multiple samples, S1,S2,S3,... instead of S1

combine_hc.sh /output/hc/ /output/hc S 21:1-50000,21:50001-100000 2G

vqsr.sh /output/hc /output/vqsr S 2 2G
```

# Retrieving _Polylox_ Barcodes from single-cell RNA-seq PacBio Reads (scRPBPBR) 
Scripts for analyzing PolyloxExpress data


## Processing PacBio CCS reads of Polylox barcodes from single-cell RNA-seq
USAGE: scRPBPBR <input.fasta/fastq> <out.prefix> <type|fasta/fastq> [keep-temp] 

* <input.fasta/fastq>  required, the PacBio read file in fasta or fastq format. 
* <out.prefix>         required, the prefix of output file, and also the name of a temporary directory to be created during the process. 
* <type|fasta/fastq>   required, the format of the PacBio read file, only can be fasta or fastq, other formats not acceptable. 
* [keep-temp]          optional, if not specified or with value 0, the temporary directory created during the process will be removed after the process is done; otherwise, it will be kept. 

*See Protocol (https://github.com/sunlightwang/PolyloxExpress/blob/master/Protocol.md) for more details.*


## Contact
Xi Wang (xi dot wang at dkfz dot de) OR (xiwang at njmu dot edu dot cn)

## Citation
[1] Weike Pei*, Fuwei Shang*, Xi Wang*, Ann-Kathrin Fanti, Alessandro Greco, Katrin Busch, Kay Klapproth, Qin Zhang, Claudia Quedenau, Sascha Sauer, Thorsten Feyerabend, Thomas Höfer#, Hans-Reimer Rodewald# (2020) **Resolving fate and transcriptome of hematopoietic stem cell clones by PolyloxExpress Barcoding**. ***Cell Stem Cell***, **27**, 383-395.e8.

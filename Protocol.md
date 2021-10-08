## Protocol of Retrieving Polylox Barcodes from scRNA-seq PacBio Reads (scRPBPBR)

### Equipment
   + Data (PacBio reads, either in fasta or fastq format)
   + Polylox adapters and segments (provided in the data folder of scRPBPBR toolkit)
   + Bowtie2 software (http://bowtie-bio.sourceforge.net/bowtie2/index.shtml)
   + SAMtools (http://www.htslib.org/)
   + scRPBPBR toolkit (https://github.com/sunlightwang/PolyloxExpress) 
   + Perl (https://www.perl.org/) by default already installed in Linux or Mac OS X computers

---
### Equipment setup
   *Commands given in the protocol are runnable at the UNIX shell prompt.*


* To install the SAMtools, download the SAMtools (http://www.htslib.org/download/) and unpack the SAMtools tarball: 

   ` tar jxvf samtools-1.13.tar.bz2 `

   Then cd to the SAMtools source directory and build the samtools binary

   ` cd samtools-1.13 `

   ` ./configure --prefix=/path/to/install `

   ` make `

   ` make install `


   Copy the samtools binary to some directory in your PATH (e.g. $HOME/bin):

   ` cp samtools $HOME/bin `

   Or add the directory containing samtools binary to your PATH environment variable

   ` export PATH=/path/to/install/bin:$PATH `

---

* To install Bowtie2, download the latest binary package for Bowtie2 (https://sourceforge.net/projects/bowtie-bio/files/bowtie2/) and unpack the Bowtie2 zip archive:

   ` unzip bowtie2-2.4.4-linux-x86_64.zip `

   Copy the Bowtie executables to a directory in your PATH (e.g. $HOME/bin):

   ` cd bowtie2-2.4.4 `

   ` cp bowtie2* $HOME/bin `

    Or add the directory containing bowtie2 binaries to your PATH environment variable

   ` export PATH=/path/to/bowtie2/binary/directory:$PATH `
   
---

* To install scRPBPBR toolkit, clone the latest binary package from PolyloxExpress github site (https://github.com/sunlightwang/PolyloxExpress/) 

   ` git clone https://github.com/sunlightwang/PolyloxExpress.git `
   
   Make the scripts under the *bin* directory executable
   
   ` chmod +x /path/to/PolyloxExpress/bin/* `

   Add the directory containing scRPBPBR binaries to your PATH environment variable
   
   ` export PATH=/path/to/PolyloxExpress/bin/:$PATH `


***

### Procedure
 
To run scRPBPBR on the example data files, cd to the PolyloxExpress example directory

` cd /path/to/PolyloxExpress/example `

Then execute scRPBPBR on each example file:  

` scRPBPBR test.fastq test fastq `

*scRPBPBR is a well wrapped pipeline, which takes PacBio CCS reads (in either fasta or fastq format) and directly reports the number of barcodes in the PacBio library of interest for downstream analysis. By default, scRPBPBR takes 4 cores per process; however, the number of cores is adjustable in the script. Using 4 cores, the running time of scRPBPBR varies from < 1 hour to several hours depending on the amount of reads to be processed.*


**Usage: scRPBPBR <input.fasta/fastq> <out.prefix> <type:fasta/fastq> [keep-temp]**

Where, 

* <input.fasta/fastq> required, the PacBio read file in fasta or fastq format. 
* <out.prefix> required, the prefix of output file, and also the name of a temporary directory to be created during the process. 
* <type:fasta/fastq> required, the format of the PacBio read file, only can be fasta or fastq, other formats not acceptable. 
* [keep-temp] optional, if not specified or with value 0, the temporary directory created during the process will removed after the process is done; otherwise, it will be kept. 

---

### Anticipated results 
#### Output files
* [out.predix].seg_assemble.tsv
* [out.predix].PB_per_BC.summary.tsv
* [out.predix].stat.tsv

#### Output file details 
* [out.predix].seg_assemble.tsv
   + Segment assemble file is a tabular text file, each line gives the decoding result of a PacBio read. 
   + The three columns in each line are: read ID, cell index, Polylox barcode 

* [out.predix].PB_per_BC.summary.tsv
   + Polylox barcode counts in each cell barcode. 

* [out.predix].stat.tsv
   + 
   + Total: total PacBio reads that have been processed. 
   + Intact: the number of PacBio reads with both 5’ and 3’ adapter sequences. 
   + Barcodes*: starting from 5’ and end with 3’, barcode segments are connected with hyphens. 
   


### Example: 
```
more test.seg_assemble.tsv 
more test.PB_per_BC.summary.tsv
```




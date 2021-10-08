## Protocol of Retrieving Polylox Barcodes from scRNA-seq PacBio Reads

### Equipment
• Data (PacBio reads, either in fasta or fastq format)
• Polylox adapters and segments (provided in the data folder of RPBPBR toolkit)
• Bowtie2 software (http://bowtie-bio.sourceforge.net/bowtie2/index.shtml)
• SAMtools (http://www.htslib.org/)
• RPBPBR toolkit (https://github.com/sunlightwang/RPBPBR) 
• Hardware: Computer running either Linux or Mac OS X (10.6 Snow Leopard or later; at least 4 GB of RAM (8 GB per core preferred); at least quad-core CPU
• Perl (https://www.perl.org/) by default already installed in Linux or Mac OS X computers

### Equipment setup
Commands given in the protocol are runnable at the UNIX shell prompt, which are prefixed with a ‘$’ character. 
To install the SAMtools, download the SAMtools (http://www.htslib.org/download/) and unpack the SAMtools tarball: 
$ tar jxvf samtools-1.5.tar.bz2 

Then cd to the SAMtools source directory and build the samtools binary
$ cd samtools-1.5

$ ./configure --prefix=/path/to/install
$ make
$ make install
Copy the samtools binary to some directory in your PATH (e.g. $HOME/bin):

$ cp samtools $HOME/bin

Or add the directory containing samtools binary to your PATH environment variable
$ export PATH=/path/to/install/bin:$PATH 

To install Bowtie2, download the latest binary package for Bowtie2 (https://sourceforge.net/projects/bowtie-bio/files/bowtie2/) and unpack the Bowtie2 zip archive:
$ unzip bowtie2-2.3.2-legacy-macos-x86_64.zip
Copy the Bowtie executables to a directory in your PATH (e.g. $HOME/bin):

$ cd bowtie2-2.3.2-legacy
$ cp bowtie2* $HOME/bin 
Or add the directory containing bowtie2 binaries to your PATH environment variable
$ export PATH=/path/to/bowtie2/binary/directory:$PATH 

To install RPBPBR toolkit, clone the latest binary package from RPBPBR github site (https://github.com/sunlightwang/RPBPBR/) 
$ git clone https://github.com/sunlightwang/RPBPBR.git
Add the directory containing RPBPBR binaries to your PATH environment variable
$ export PATH=/path/to/RPBPBR/bin/:$PATH 

### Procedure
 
To run RPBPBR on the example data files, cd to the RPBPBR example directory
$ cd /path/to/RPBPBR/example
Then execute RPBPBR on each example file:  
$ RPBPBR test1.fastq test1 fastq
$ RPBPBR test2.fa test2 fasta

RPBPBR is a well wrapped pipeline, which takes PacBio CCS reads (in either fasta or fastq format) and directly reports the number of barcodes in the PacBio library of interest for downstream analysis. By default, RPBPBR takes 4 cores per process; however, the number of cores is adjustable in the script. Using 4 cores, the running time of RPBPBR varies from < 1 hour to several hours depending on the amount of reads to be processed. 

Usage: RPBPBR <input.fasta/fastq> <out.prefix> <type:fasta/fastq> [keep-temp] 

Where, 
<input.fasta/fastq> required, the PacBio read file in fasta or fastq format. 
<out.prefix> required, the prefix of output file, and also the name of a temporary directory to be created during the process. 
<type:fasta/fastq> required, the format of the PacBio read file, only can be fasta or fastq, other formats not acceptable. 
[keep-temp] optional, if not specified or with value 0, the temporary directory created during the process will removed after the process is done; otherwise, it will be kept. 

### Anticipated results

Output file name: <out.predix>.barcode.count.tsv 
Output file is a tabular text file, each line gives the count (in the second column) of each barcode listed in the first column. 

Total: total PacBio reads that have been processed. 
Intact: the number of PacBio reads with both 5’ and 3’ adapter sequences. 
Barcodes*: starting from 5’ and end with 3’, barcode segments are connected with hyphens. 
* In the barcode string, X represents non-recognized segments due to low sequencing quality. 

### Example: 
$ more test2.barcode.count.tsv 




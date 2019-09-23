
# This file is desinged to be run on a UNIX-like machine
# It assumes this software is available:
# 1. wget
# 2. fasterq-dump
# 3. bowtie2
# 4. samtools
# 5. bedtools

#1. wget the FASTQs: These have a habit of changing, so you may need to find the URL or use prefetch 
wget -c https://sra-downloadb.be-md.ncbi.nlm.nih.gov/sos/sra-pub-run-1/SRR058987/SRR058987.3
wget -c https://sra-downloadb.be-md.ncbi.nlm.nih.gov/sos/sra-pub-run-1/SRR058986/SRR058986.3

# unpack SRA to FASTQ and make links:
fasterq-dump -e 2 -S --skip-technical --split-3 SRR058987.3 -O .
gzip SRR058987.3.fastq
fasterq-dump -e 2 -S --skip-technical --split-3 SRR058986.3 -O .
gzip SRR058986.3.fastq
ln -s SRR058987.3.fastq.gz esc_med1.rp1.fq.gz
ln -s SRR058986.3.fastq.gz esc_med12.rp1.fq.gz

# align to the genome:
bowtie2 -p 2 --very-sensitive --end-to-end --no-unal -U esc_med1.rp1.fq.gz -x mm10 | grep -E -v 'chrM|chrUn|random|RANDOM' | samtools view -b -@ 2 | samtools sort -n >esc_med1.bam
bowtie2 -p 2 --very-sensitive --end-to-end --no-unal -U esc_med12.rp1.fq.gz -x mm10 | grep -E -v 'chrM|chrUn|random|RANDOM' | samtools view -b -@ 2 | samtools sort -n >esc_med12.bam

# extract BED files:
samtools view -q 10 -b esc_med1.bam  | bedtools bamtobed | grep -v 'chrM' |awk '{FS=OFS="\t"; print $1,$2,$3,".",0,$6}' - |awk '!x[$0]++' -| gzip >esc_med1.bed
samtools view -q 10 -b esc_med12.bam | bedtools bamtobed | grep -v 'chrM' |awk '{FS=OFS="\t"; print $1,$2,$3,".",0,$6}' - |awk '!x[$0]++' -| gzip >esc_med1.bed

# Make the FLAT files:
python3 -c "import glbase3, sys; glbase3.bed_to_flat(sys.argv[1].split(', '), '%s.flat' % sys.argv[2], name=sys.argv[2], isPE=False, read_extend=200, strand=True)"  esc_med1.bed esc_med1.flat
python3 -c "import glbase3, sys; glbase3.bed_to_flat(sys.argv[1].split(', '), '%s.flat' % sys.argv[2], name=sys.argv[2], isPE=False, read_extend=200, strand=True)"  esc_med12.bed esc_med12.flat


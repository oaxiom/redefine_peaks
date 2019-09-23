
# This file is desinged to be run on a UNIX-like machine
# It assumes this software is available:
# 1. wget
# 2. fasterq-dump
# 3. bowtie2
# 4. samtools
# 5. bedtools

#1. wget the FASTQs: These have a habit of changing, so you may need to find the URL or use prefetch 
wget -c https://sra-downloadb.be-md.ncbi.nlm.nih.gov/sos/sra-pub-run-2/SRR1030766/SRR1030766.2
wget -c https://sra-downloadb.be-md.ncbi.nlm.nih.gov/sos/sra-pub-run-1/SRR227419/SRR227419.3
wget -c https://sra-downloadb.be-md.ncbi.nlm.nih.gov/sos/sra-pub-run-1/SRR227420/SRR227420.3
wget -c https://sra-downloadb.be-md.ncbi.nlm.nih.gov/sos/sra-pub-run-5/SRR357491/SRR357491.3

# unpack SRA to FASTQ and make links:
fasterq-dump -e 2 -S --skip-technical --split-3 SRR1030766.2 -O .
fasterq-dump -e 2 -S --skip-technical --split-3 SRR227419.3 -O .
fasterq-dump -e 2 -S --skip-technical --split-3 SRR227420.3 -O .
fasterq-dump -e 2 -S --skip-technical --split-3 SRR357491.3 -O .
gzip SRR1030766.2.fastq
gzip SRR227419.3.fastq
gzip SRR227420.3.fastq
gzip SRR357491.3.fastq

ln -s SRR1030766.2.fastq.gz Hs_hesc_ctcf.rp1.fq.gz
ln -s SRR227419.3.fastq.gz  Hs_hesc_ctcf.rp2.fq.gz
ln -s SRR227420.3.fastq.gz  Hs_hesc_ctcf.rp3.fq.gz
ln -s SRR357491.3.fastq.gz  Hs_hesc_ctcf.rp4.fq.gz

# align to the genome:
bowtie2 -p 2 --very-sensitive --end-to-end --no-unal -U Hs_hesc_ctcf.rp1.fq.gz -x hg38 | grep -E -v 'chrM|chrUn|random|RANDOM' | samtools view -b -@ 2 | samtools sort -n >Hs_hesc_ctcf.rp1.bam
bowtie2 -p 2 --very-sensitive --end-to-end --no-unal -U Hs_hesc_ctcf.rp2.fq.gz -x hg38 | grep -E -v 'chrM|chrUn|random|RANDOM' | samtools view -b -@ 2 | samtools sort -n >Hs_hesc_ctcf.rp1.bam
bowtie2 -p 2 --very-sensitive --end-to-end --no-unal -U Hs_hesc_ctcf.rp3.fq.gz -x hg38 | grep -E -v 'chrM|chrUn|random|RANDOM' | samtools view -b -@ 2 | samtools sort -n >Hs_hesc_ctcf.rp3.bam
bowtie2 -p 2 --very-sensitive --end-to-end --no-unal -U Hs_hesc_ctcf.rp4.fq.gz -x hg38 | grep -E -v 'chrM|chrUn|random|RANDOM' | samtools view -b -@ 2 | samtools sort -n >Hs_hesc_ctcf.rp4.bam

# extract BED files:
samtools view -q 20 -b Hs_hesc_ctcf.rp1.bam | bedtools bamtobed | grep -v 'chrM' |awk '{FS=OFS="\t"; print $1,$2,$3,".",0,$6}' - |awk '!x[$0]++' -| gzip >Hs_hesc_ctcf.rp1.bed.gz
samtools view -q 20 -b Hs_hesc_ctcf.rp2.bam | bedtools bamtobed | grep -v 'chrM' |awk '{FS=OFS="\t"; print $1,$2,$3,".",0,$6}' - |awk '!x[$0]++' -| gzip >Hs_hesc_ctcf.rp2.bed.gz
samtools view -q 20 -b Hs_hesc_ctcf.rp3.bam | bedtools bamtobed | grep -v 'chrM' |awk '{FS=OFS="\t"; print $1,$2,$3,".",0,$6}' - |awk '!x[$0]++' -| gzip >Hs_hesc_ctcf.rp3.bed.gz
samtools view -q 20 -b Hs_hesc_ctcf.rp4.bam | bedtools bamtobed | grep -v 'chrM' |awk '{FS=OFS="\t"; print $1,$2,$3,".",0,$6}' - |awk '!x[$0]++' -| gzip >Hs_hesc_ctcf.rp4.bed.gz

# Make the FLAT files:
python3 -c "import glbase3, sys; glbase3.bed_to_flat(sys.argv[1].split(', '), '%s.flat' % sys.argv[2], name=sys.argv[2], isPE=False, read_extend=200, strand=True, gzip=True)"  Hs_hesc_ctcf.rp1.bed.gz  Hs_hesc_ctcf.rp1.flat
python3 -c "import glbase3, sys; glbase3.bed_to_flat(sys.argv[1].split(', '), '%s.flat' % sys.argv[2], name=sys.argv[2], isPE=False, read_extend=200, strand=True, gzip=True)"  Hs_hesc_ctcf.rp2.bed.gz  Hs_hesc_ctcf.rp2.flat
python3 -c "import glbase3, sys; glbase3.bed_to_flat(sys.argv[1].split(', '), '%s.flat' % sys.argv[2], name=sys.argv[2], isPE=False, read_extend=200, strand=True, gzip=True)"  Hs_hesc_ctcf.rp3.bed.gz  Hs_hesc_ctcf.rp3.flat
python3 -c "import glbase3, sys; glbase3.bed_to_flat(sys.argv[1].split(', '), '%s.flat' % sys.argv[2], name=sys.argv[2], isPE=False, read_extend=200, strand=True, gzip=True)"  Hs_hesc_ctcf.rp4.bed.gz  Hs_hesc_ctcf.rp4.flat


###mirs_discovered_by_depth

outfile="20151030_KA5146106"
fq="KA5146106"
ext=".fastq.gz"
thr=".0002" #20 reads per 100,000

cutadapt -a TGGAATTCTCGGGTGCCAAG -o $fq.trim1.fq --untrimmed-output $fq.untrim.fq --minimum-length 24 --too-short-output $fq.short.fq $fq$ext
cutadapt -u 4 -o $fq.trim2.fq $fq.trim1.fq
cutadapt -u -4 -o $fq.trim3.fq $fq.trim2.fq

for i in {1..40} #200
do
	j_sum=0
	sample_size=$(($i * 5000)) #1000
	threshold=$(echo "$thr * $sample_size" | bc -l)
	#printf "thresh $threshold\n"
	for j in {1..10}
	do
		#RANDOM=$(tr -dc 0-9 < /dev/urandom | head -c10)
		#RANDOM=$(date '+%N')
		#RANDOM=$(( BASHPID + $(date '+%N') ))
		fastq-sample -n $sample_size -s $RANDOM -o $fq.sample $fq.trim3.fq
		bowtie2 -x /usr/kev/bowtie2-2.2.6/human_hairpin -U $fq.sample.fastq -S $fq.sam #&>/dev/null
		samtools view -bS -o $fq.bam $fq.sam
		mirUtils mbaseMirStats --organism=hsa --out-prefix=$fq $fq.bam #&>/dev/null
		#cat $fq.group.hist | wc -l >> $outfile
		#num_lines=($(cat $fq.group.hist | wc -l))
		#num_groups=$(($num_lines - 1))
		#num_groups=($(python get_reads_at_threshold.py $fq.group.hist $threshold))
		num_groups=($(python get_reads_at_threshold.py $fq.group.hist 20))
		j_sum=$(($j_sum + $num_groups))
		#printf "num_groups $num_groups\n"
		#printf "j_sum $j_sum\n"
		rm $fq.sample.fastq
		rm $fq.bam
		rm $fq.sam
	done
	avg=$(echo "$j_sum / 10" | bc -l)
	#printf "avg $avg"
	echo $avg >> $outfile
done
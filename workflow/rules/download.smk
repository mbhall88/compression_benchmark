rule download_data:
    output:
        fq=RESULTS / "data/{tech}/{acc}.fq",
        size=RESULTS / "data/{tech}/{acc}.size"
    log:
        LOGS / "download_data/{tech}/{acc}.log"
    conda:
        ENVS / "download.yaml"
    resources:
        mem_mb=int(2 * GB)
    params:
        opts="-v",
        outdir=lambda wildcards, output: Path(output.fq).parent
    shadow: "shallow"
    shell:
        """
        fastq-dl {params.opts} -a {wildcards.acc} -o {params.outdir} 2> {log}
        if [ {wildcards.tech} = "nanopore" ]; then 
            gzip -dc {params.outdir}/{wildcards.acc}*.fastq.gz > {output.fq} 2>> {log}
        else
            READ1={params.outdir}/{wildcards.acc}_1.fastq.gz
            READ2={params.outdir}/{wildcards.acc}_2.fastq.gz
            tmp1=$(mktemp)
            tmp2=$(mktemp)
            # add /1 and /2 to read names
            seqkit seq -i $READ1 | seqkit replace -p $ -r /1 > $tmp1 2>> {log}
            seqkit seq -i $READ2 | seqkit replace -p $ -r /2 > $tmp2 2>> {log}
            # interleave reads
            seqtk mergepe $tmp1 $tmp2 > {output.fq} 2>> {log}
        fi
        (wc -c {output.fq} | awk '{{print $1}}') > {output.size} 2>> {log}
        """

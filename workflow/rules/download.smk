rule download_data:
    output:
        fq=RESULTS / "data/{tech}/{acc}.fq"
    log:
        LOGS / "download_data/{tech}/{acc}.log"
    container:
        CONTAINERS["fastq_dl"]
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
            (paste <(zcat $READ1 | paste - - - - ) <(zcat $READ2 | paste - - - - ) | tr '\t' '\n') > {output.fq} 2>> {log}
        fi
        """

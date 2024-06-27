rule compress_gzip:
    input:
        fq=rules.download_data.output.fq,
    output:
        fq=temp(RESULTS / "compress/gzip/{lvl}/{tech}/{acc}.fq.gz"),
        size=RESULTS / "compress/gzip/{lvl}/{tech}/{acc}.size",
    log:
        LOGS / "compress_gzip/{lvl}/{tech}/{acc}.log"
    benchmark:
        BENCH / "compress/gzip/{lvl}/{tech}/{acc}.tsv"
    resources:
        runtime=lambda wildcards, attempt: f"{1 * attempt}d",
        mem_mb=lambda wildcards, attempt: attempt * int(4 * GB),
    params:
        opts="-c -{lvl}"
    conda:
        ENVS / "gzip.yaml"
    shell:
        """
        gzip {params.opts} {input.fq} > {output.fq} 2> {log}
        (wc -c {output.fq} | awk '{{print $1}}') > {output.size} 2>> {log}
        """

rule compress_bzip2:
    input:
        fq=rules.download_data.output.fq,
    output:
        fq=temp(RESULTS / "compress/bzip2/{lvl}/{tech}/{acc}.fq.bz2"),
        size=RESULTS / "compress/bzip2/{lvl}/{tech}/{acc}.size",
    log:
        LOGS / "compress_bzip2/{lvl}/{tech}/{acc}.log"
    benchmark:
        BENCH / "compress/bzip2/{lvl}/{tech}/{acc}.tsv"
    resources:
        runtime=lambda wildcards, attempt: f"{1 * attempt}d",
        mem_mb=lambda wildcards, attempt: attempt * int(4 * GB),
    params:
        opts="-z -c -{lvl}"
    conda:
        ENVS / "bzip2.yaml"
    shell:
        """
        bzip2 {params.opts} {input.fq} > {output.fq} 2> {log}
        (wc -c {output.fq} | awk '{{print $1}}') > {output.size} 2>> {log}
        """

rule compress_xz:
    input:
        fq=rules.download_data.output.fq,
    output:
        fq=temp(RESULTS / "compress/xz/{lvl}/{tech}/{acc}.fq.xz"),
        size=RESULTS / "compress/xz/{lvl}/{tech}/{acc}.size",
    log:
        LOGS / "compress_xz/{lvl}/{tech}/{acc}.log"
    benchmark:
        BENCH / "compress/xz/{lvl}/{tech}/{acc}.tsv"
    resources:
        runtime=lambda wildcards, attempt: f"{1 * attempt}d",
        mem_mb=lambda wildcards, attempt: attempt * int(4 * GB),
    params:
        opts="-z -c -{lvl}"
    conda:
        ENVS / "xz.yaml"
    shell:
        """
        xz {params.opts} {input.fq} > {output.fq} 2> {log}
        (wc -c {output.fq} | awk '{{print $1}}') > {output.size} 2>> {log}
        """

rule compress_zstd:
    input:
        fq=rules.download_data.output.fq,
    output:
        fq=temp(RESULTS / "compress/zstd/{lvl}/{tech}/{acc}.fq.zst"),
        size=RESULTS / "compress/zstd/{lvl}/{tech}/{acc}.size",
    log:
        LOGS / "compress_zstd/{lvl}/{tech}/{acc}.log"
    benchmark:
        BENCH / "compress/zstd/{lvl}/{tech}/{acc}.tsv"
    resources:
        runtime=lambda wildcards, attempt: f"{1 * attempt}d",
        mem_mb=lambda wildcards, attempt: attempt * int(4 * GB),
    params:
        opts="-c -{lvl}"
    conda:
        ENVS / "zstd.yaml"
    shell:
        """
        zstd {params.opts} {input.fq} > {output.fq} 2> {log}
        (wc -c {output.fq} | awk '{{print $1}}') > {output.size} 2>> {log}
        """

rule compress_brotli:
    input:
        fq=rules.download_data.output.fq,
    output:
        fq=temp(RESULTS / "compress/brotli/{lvl}/{tech}/{acc}.fq.br"),
        size=RESULTS / "compress/brotli/{lvl}/{tech}/{acc}.size",
    log:
        LOGS / "compress_brotli/{lvl}/{tech}/{acc}.log"
    benchmark:
        BENCH / "compress/brotli/{lvl}/{tech}/{acc}.tsv"
    resources:
        runtime="3d",
        mem_mb=lambda wildcards, attempt: attempt * int(4 * GB),
    params:
        opts="-c -q {lvl}"
    conda:
        ENVS / "brotli.yaml"
    shell:
        """
        brotli {params.opts} {input.fq} > {output.fq} 2> {log}
        (wc -c {output.fq} | awk '{{print $1}}') > {output.size} 2>> {log}
        """

rule compress_ubam:
    input:
        fq=rules.download_data.output.fq,
    output:
        fq=temp(RESULTS / "compress/ubam/{lvl}/{tech}/{acc}.bam"),
        size=RESULTS / "compress/ubam/{lvl}/{tech}/{acc}.size",
    log:
        LOGS / "compress_ubam/{lvl}/{tech}/{acc}.log"
    benchmark:
        BENCH / "compress/ubam/{lvl}/{tech}/{acc}.tsv"
    resources:
        runtime=lambda wildcards, attempt: f"{1 * attempt}d",
        mem_mb=lambda wildcards, attempt: attempt * int(4 * GB),
    container:
        "docker://quay.io/biocontainers/samtools:1.20--h50ea8bc_0"
    params:
        input_opt=lambda wildcards: "-s" if wildcards.tech == "illumina" else "-0"
    shell:
        """
        (samtools import {params.input_opt} {input.fq} --order ro -O bam,level=0 | \
            samtools sort -M - -o {output.fq}) 2> {log}
        (wc -c {output.fq} | awk '{{print $1}}') > {output.size} 2>> {log}
        """

rule compress_ucram:
    input:
        fq=rules.download_data.output.fq,
    output:
        fq=temp(RESULTS / "compress/ucram/{lvl}/{tech}/{acc}.cram"),
        size=RESULTS / "compress/ucram/{lvl}/{tech}/{acc}.size",
    log:
        LOGS / "compress_ucram/{lvl}/{tech}/{acc}.log"
    benchmark:
        BENCH / "compress/ucram/{lvl}/{tech}/{acc}.tsv"
    resources:
        runtime=lambda wildcards, attempt: f"{1 * attempt}d",
        mem_mb=lambda wildcards, attempt: attempt * int(4 * GB),
    container:
        "docker://quay.io/biocontainers/samtools:1.20--h50ea8bc_0"
    params:
        input_opt=lambda wildcards: "-s" if wildcards.tech == "illumina" else "-0"
    shell:
        """
        (samtools import {params.input_opt} {input.fq} --order ro -O bam,level=0 | \
            samtools sort -O cram --output-fmt-option archive -M - -o {output.fq}) 2> {log}
        (wc -c {output.fq} | awk '{{print $1}}') > {output.size} 2>> {log}
        """
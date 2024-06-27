rule decompress_gzip:
    input:
        fq=rules.compress_gzip.output.fq,
    output:
        fq=temp(RESULTS / "decompress/gzip/{lvl}/{tech}/{acc}.fq"),
    log:
        LOGS / "decompress_gzip/{lvl}/{tech}/{acc}.log"
    benchmark:
        BENCH / "decompress/gzip/{lvl}/{tech}/{acc}.tsv"
    resources:
        runtime=lambda wildcards, attempt: f"{1 * attempt}d",
        mem_mb=lambda wildcards, attempt: attempt * int(4 * GB),
    params:
        opts="-c -d"
    conda:
        ENVS / "gzip.yaml"
    shell:
        "gzip {params.opts} {input.fq} > {output.fq} 2> {log}"

rule decompress_bzip2:
    input:
        fq=rules.compress_bzip2.output.fq,
    output:
        fq=temp(RESULTS / "decompress/bzip2/{lvl}/{tech}/{acc}.fq"),
    log:
        LOGS / "decompress_bzip2/{lvl}/{tech}/{acc}.log"
    benchmark:
        BENCH / "decompress/bzip2/{lvl}/{tech}/{acc}.tsv"
    resources:
        runtime=lambda wildcards, attempt: f"{1 * attempt}d",
        mem_mb=lambda wildcards, attempt: attempt * int(4 * GB),
    params:
        opts="-d -c"
    conda:
        ENVS / "bzip2.yaml"
    shell:
        "bzip2 {params.opts} {input.fq} > {output.fq} 2> {log}"

rule decompress_xz:
    input:
        fq=rules.compress_xz.output.fq,
    output:
        fq=temp(RESULTS / "decompress/xz/{lvl}/{tech}/{acc}.fq"),
    log:
        LOGS / "decompress_xz/{lvl}/{tech}/{acc}.log"
    benchmark:
        BENCH / "decompress/xz/{lvl}/{tech}/{acc}.tsv"
    resources:
        runtime=lambda wildcards, attempt: f"{1 * attempt}d",
        mem_mb=lambda wildcards, attempt: attempt * int(4 * GB),
    params:
        opts="-d -c"
    conda:
        ENVS / "xz.yaml"
    shell:
        "xz {params.opts} {input.fq} > {output.fq} 2> {log}"

rule decompress_zstd:
    input:
        fq=rules.compress_zstd.output.fq,
    output:
        fq=temp(RESULTS / "decompress/zstd/{lvl}/{tech}/{acc}.fq"),
    log:
        LOGS / "decompress_zstd/{lvl}/{tech}/{acc}.log"
    benchmark:
        BENCH / "decompress/zstd/{lvl}/{tech}/{acc}.tsv"
    resources:
        runtime=lambda wildcards, attempt: f"{1 * attempt}d",
        mem_mb=lambda wildcards, attempt: attempt * int(4 * GB),
    params:
        opts="-c -d"
    conda:
        ENVS / "zstd.yaml"
    shell:
        "zstd {params.opts} {input.fq} > {output.fq} 2> {log}"

rule decompress_brotli:
    input:
        fq=rules.compress_brotli.output.fq,
    output:
        fq=temp(RESULTS / "decompress/brotli/{lvl}/{tech}/{acc}.fq"),
    log:
        LOGS / "decompress_brotli/{lvl}/{tech}/{acc}.log"
    benchmark:
        BENCH / "decompress/brotli/{lvl}/{tech}/{acc}.tsv"
    resources:
        runtime=lambda wildcards, attempt: f"{1 * attempt}d",
        mem_mb=lambda wildcards, attempt: attempt * int(4 * GB),
    params:
        opts="-c -d"
    conda:
        ENVS / "brotli.yaml"
    shell:
        "brotli {params.opts} {input.fq} > {output.fq} 2> {log}"

rule decompress_ubam:
    input:
        fq=rules.compress_ubam.output.fq,
    output:
        fq=temp(RESULTS / "decompress/ubam/{lvl}/{tech}/{acc}.fq"),
    log:
        LOGS / "decompress_ubam/{lvl}/{tech}/{acc}.log"
    benchmark:
        BENCH / "decompress/ubam/{lvl}/{tech}/{acc}.tsv"
    resources:
        runtime=lambda wildcards, attempt: f"{1 * attempt}d",
        mem_mb=lambda wildcards, attempt: attempt * int(4 * GB),
    params:
        opts="-c -d"
    container:
        "docker://quay.io/biocontainers/samtools:1.20--h50ea8bc_0"
    shell:
        "samtools fastq {input.fq} > {output.fq} 2> {log}"

rule decompress_ucram:
    input:
        fq=rules.compress_ucram.output.fq,
    output:
        fq=temp(RESULTS / "decompress/ucram/{lvl}/{tech}/{acc}.fq"),
    log:
        LOGS / "decompress_ucram/{lvl}/{tech}/{acc}.log"
    benchmark:
        BENCH / "decompress/ucram/{lvl}/{tech}/{acc}.tsv"
    resources:
        runtime=lambda wildcards, attempt: f"{1 * attempt}d",
        mem_mb=lambda wildcards, attempt: attempt * int(4 * GB),
    params:
        opts="-c -d"
    container:
        "docker://quay.io/biocontainers/samtools:1.20--h50ea8bc_0"
    shell:
        "samtools fastq {input.fq} > {output.fq} 2> {log}"
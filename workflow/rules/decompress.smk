# Loop to create decompression rules for each tool
for tool, tool_params in config['tools'].items():
    decompress_params = tool_params.get('decompression', {})
    if decompress_params:  # Check if decompression settings are available
        rule_name = f"decompress_{tool}"
        rule:
            name: rule_name
            input:
                fq=RESULTS / f"compress/{tool}/{{lvl}}/{{group}}/{{name}}.{tool_params['extension']}",
            output:
                fq=temp(RESULTS / f"decompress/{tool}/{{lvl}}/{{group}}/{{name}}"),
            log:
                LOGS / f"decompress_{tool}/{{lvl}}/{{group}}/{{name}}.log"
            benchmark:
                BENCH / f"decompress/{tool}/{{lvl}}/{{group}}/{{name}}.tsv"
            resources:
                runtime=lambda wildcards, attempt: f"{1 * attempt}d",
                mem_mb=lambda wildcards, attempt: attempt * int(4 * GB),
            conda:
                ENVS / f"{tool}.yaml"
            params:
                opts=decompress_params['opts'],
                tool=tool
            shell:
                """
                {params.tool} {params.opts} {input.fq} > {output.fq} 2> {log}
                """

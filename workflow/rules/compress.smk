# Loop to create compression rules for each tool
for tool, tool_params in config['tools'].items():
    compress_params = tool_params.get('compression', {})
    if compress_params:  # Check if compression settings are available
        rule_name = f"compress_{tool}"
        rule:
            name: rule_name
            input:
                fq=rules.get_data.output.fq,
            output:
                fq=temp(RESULTS / f"compress/{tool}/{{lvl}}/{{group}}/{{name}}.{tool_params['extension']}"),
                size=RESULTS / f"compress/{tool}/{{lvl}}/{{group}}/{{name}}.size",
            log:
                LOGS / f"compress_{tool}/{{lvl}}/{{group}}/{{name}}.log"
            benchmark:
                BENCH / f"compress/{tool}/{{lvl}}/{{group}}/{{name}}.tsv"
            resources:
                runtime=lambda wildcards, attempt: f"{1 * attempt}d",
                mem_mb=lambda wildcards, attempt: attempt * int(4 * GB),
            conda:
                ENVS / f"{tool}.yaml"
            params:
                opts=compress_params['opts'],
                tool=tool,
            shell:
                """
                {params.tool} {params.opts} {input.fq} > {output.fq} 2> {log}
                
                (wc -c {output.fq} | awk '{{print $1}}') > {output.size} 2>> {log}
                """

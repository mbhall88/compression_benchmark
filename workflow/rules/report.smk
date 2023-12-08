rule aggregate_sizes:
    input:
        sizes=[
            RESULTS / f"compress/{tool}/{lvl}/{group}/{name}.size"
            for (tool, lvl, group, name) in combos
        ],
    output:
        RESULTS / "compress/sizes.csv",
    run:
        from pathlib import Path

        with open(output[0], "w") as fd:
            print(
                ",".join(["tool", "level", "group", "name", "bytes"]), file=fd
            )
            for p in map(Path, input.sizes):
                tool = p.parts[-4]
                lvl = p.parts[-3]
                group = p.parts[-2]
                name = p.name.split(".")[0]
                size = p.read_text().strip()
                print(",".join([tool, lvl, group, name, size]), file=fd)


data_groups = []
data_names = []
for sample in samples.values():
    data_groups.append(sample['group'])
    data_names.append(sample["name"])


rule plot_results:
    input:
        uncompressed_sizes=expand(
            str(RESULTS / "data/{group}/{name}.size"),
            zip,
            group=data_groups,
            name=data_names,
        ),
        compressed_sizes=rules.aggregate_sizes.output[0],
        compress_benchmarks=expand(
            str(BENCH / "compress/{tool}/{lvl}/{group}/{name}.tsv"),
            zip,
            tool=[c[0] for c in combos],
            lvl=[c[1] for c in combos],
            group=[c[2] for c in combos],
            name=[c[3] for c in combos],
        ),
        decompress_benchmarks=expand(
            str(BENCH / "decompress/{tool}/{lvl}/{group}/{name}.tsv"),
            zip,
            tool=[c[0] for c in combos],
            lvl=[c[1] for c in combos],
            group=[c[2] for c in combos],
            name=[c[3] for c in combos],
        ),
    output:
        compression_ratio=RESULTS / "figures/compression_ratio.png",
        rate_and_memory=RESULTS / "figures/rate_and_memory.png",
        pareto_frontier=RESULTS / "figures/pareto_frontier.png",
    resources:
        runtime="5m",
    log:
        LOGS / "plot_results.log",
    params:
        default_lvl={tool:tool_config['compression']['default'] for tool, tool_config in config["tools"].items()},
    conda:
        ENVS / "plot_results.yaml"
    script:
        SCRIPTS / "plot_results.py"

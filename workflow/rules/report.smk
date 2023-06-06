rule aggregate_sizes:
    input:
        sizes=[
            RESULTS / f"compress/{tool}/{lvl}/{tech}/{acc}.size"
            for (tool, lvl, tech, acc) in combos
        ],
    output:
        RESULTS / "compress/sizes.csv",
    run:
        from pathlib import Path

        with open(output[0], "w") as fd:
            print(
                ",".join(["tool", "level", "technology", "accession", "bytes"]), file=fd
            )
            for p in map(Path, input.sizes):
                tool = p.parts[-4]
                lvl = p.parts[-3]
                tech = p.parts[-2]
                acc = p.name.split(".")[0]
                size = p.read_text().strip()
                print(",".join([tool, lvl, tech, acc, size]), file=fd)


download_techs = []
download_accs = []
for tech, accs in config["accessions"].items():
    for a in accs:
        download_techs.append(tech)
        download_accs.append(a)


rule plot_results:
    input:
        uncompressed_sizes=expand(
            str(RESULTS / "data/{tech}/{acc}.size"),
            zip,
            tech=download_techs,
            acc=download_accs,
        ),
        compressed_sizes=rules.aggregate_sizes.output[0],
        compress_benchmarks=expand(
            str(BENCH / "compress/{tool}/{lvl}/{tech}/{acc}.tsv"),
            zip,
            tool=[c[0] for c in combos],
            lvl=[c[1] for c in combos],
            tech=[c[2] for c in combos],
            acc=[c[3] for c in combos],
        ),
        decompress_benchmarks=expand(
            str(BENCH / "decompress/{tool}/{lvl}/{tech}/{acc}.tsv"),
            zip,
            tool=[c[0] for c in combos],
            lvl=[c[1] for c in combos],
            tech=[c[2] for c in combos],
            acc=[c[3] for c in combos],
        ),
    output:
        compression_ratio=RESULTS / "figures/compression_ratio.png",
        rate_and_memory=RESULTS / "figures/rate_and_memory.png",
    resources:
        runtime="5m",
    log:
        LOGS / "plot_results.log",
    params:
        default_lvl=config["default_compressions_levels"],
    conda:
        ENVS / "plot_results.yaml"
    script:
        SCRIPTS / "plot_results.py"

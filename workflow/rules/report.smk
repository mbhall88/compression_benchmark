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

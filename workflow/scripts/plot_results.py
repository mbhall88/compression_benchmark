import sys

sys.stderr = open(snakemake.log[0], "w")

from pathlib import Path

import matplotlib.pyplot as plt
import pandas as pd
import seaborn as sns
from humanfriendly import format_size
from matplotlib.ticker import PercentFormatter

FIGSIZE = (13, 8)
DPI = 300
# https://jfly.uni-koeln.de/color/#cudo
# https://nanx.me/oneclust/reference/cud.html
cud = [
    "#000000",
    "#e69f00",
    "#56b4e9",
    "#009e73",
    "#f0e442",
    "#0072b2",
    "#d55e00",
    "#cc79a7",
]
PALETTE = cud
X = "level"
MEC = "black"
ERR_KWS = {"alpha": 0.1}
DEFAULT_LVL = snakemake.params.default_lvl
DASHES = [(1, 0), (1, 1)]
MARKERSCALE = 1.5
LEG_LW = 4.0  # legend linewidth


def plot_compression_ratio(data, y, hue_order, style_order, style, hue, output):
    fig, ax = plt.subplots(dpi=DPI, figsize=FIGSIZE)
    sns.lineplot(
        data=data,
        x=X,
        y=y,
        hue=hue,
        hue_order=hue_order,
        style=style,
        style_order=style_order,
        palette=PALETTE,
        markers=True,
        ax=ax,
        dashes=DASHES,
        mec=MEC,
        err_kws=ERR_KWS,
    )
    xticks = list(range(1, 20))
    _ = ax.set_xticks(xticks)

    ax.set_ylabel("Compression ratio")
    ax.yaxis.set_major_formatter(PercentFormatter(1.0, decimals=0))

    leg = ax.legend(
        loc="center right", framealpha=1, frameon=True, markerscale=MARKERSCALE
    )
    # change the line width for the legend
    for line in leg.get_lines():
        line.set_linewidth(LEG_LW)

    for tool, lvl in DEFAULT_LVL.items():
        for t in set(data["group"]):
            mean = data.query("tool==@tool and level==@lvl and group==@t")[
                "compress_ratio"
            ].mean()
            ax.scatter(lvl, mean, s=110, fc="None", ec="red")

    fig.savefig(output)


def plot_rate_and_memory(ys, data, hue, hue_order, style, style_order, output):
    fig, axes = plt.subplots(
        nrows=2,
        ncols=2,
        dpi=DPI,
        figsize=(10, 10),
        sharex=True,
        sharey="row",
        tight_layout=True,
    )

    for i, (y, ax) in enumerate(zip(ys, axes.flatten())):
        sns.lineplot(
            data=data,
            x=X,
            y=y,
            hue=hue,
            hue_order=hue_order,
            style=style,
            style_order=style_order,
            palette=PALETTE,
            markers=True,
            ax=ax,
            dashes=DASHES,
            mec=MEC,
            err_kws=ERR_KWS,
        )
        xticks = list(range(1, 20))
        _ = ax.set_xticks(xticks)

        if "rate" in y:
            ax.set_ylabel("Rate")
            ax.set_title(y.replace("_rate", "").capitalize())
            ax.set_yscale("log")
            KB = 1000
            MB = 1000 * KB
            yticks = [MB, 10 * MB, 25 * MB, 50 * MB, 100 * MB, 250 * MB, 500 * MB]
            ax.set_yticks(yticks)
            yticklabels = []
            for rate in yticks:
                rate, unit = format_size(rate).split()
                rate = round(float(rate))
                yticklabels.append(f"{rate} {unit}/s")

            ax.set_yticklabels(yticklabels)

            ax.legend(loc="upper right")

        else:
            ax.set_ylabel("Max. memory (MiB)")

        if y != "decompress_max_rss":
            ax.get_legend().remove()
        else:
            leg = ax.legend(loc="upper left", framealpha=1, frameon=True)
            # change the line width for the legend
            for line in leg.get_lines():
                line.set_linewidth(LEG_LW)

        for tool, lvl in DEFAULT_LVL.items():
            for t in set(data["group"]):
                mean = data.query("tool==@tool and level==@lvl and group==@t")[
                    y
                ].mean()
                ax.scatter(lvl, mean, s=110, fc="None", ec="red")

    fig.savefig(output)


def plot_pareto_frontier(xs, y, data, hue, hue_order, style, style_order, output):
    fig, axes = plt.subplots(figsize=FIGSIZE, dpi=DPI, nrows=2, ncols=1, sharex=True)

    for i, (x, ax) in enumerate(zip(xs, axes.flatten())):
        sns.scatterplot(
            data=data,
            x=x,
            y=y,
            hue=hue,
            hue_order=hue_order,
            style=style,
            style_order=style_order,
            palette=PALETTE,
            ax=ax,
            linewidth=0,
            alpha=0.5,
        )

        ax.set_ylabel("Compression ratio")
        ax.yaxis.set_major_formatter(PercentFormatter(1.0, decimals=0))

        if "rate" in x:
            ax.set_xlabel("Rate")
            ax.set_title(x.replace("_rate", "").capitalize())
            ax.set_xscale("log")
            KB = 1000
            MB = 1000 * KB
            xticks = [MB, 10 * MB, 25 * MB, 50 * MB, 100 * MB, 250 * MB, 500 * MB]
            ax.set_xticks(xticks)
            xticklabels = []
            for rate in xticks:
                rate, unit = format_size(rate).split()
                rate = round(float(rate))
                xticklabels.append(f"{rate} {unit}/s")

            ax.set_xticklabels(xticklabels)

            ax.legend(loc="upper left", framealpha=1, frameon=True)

        if x != "decompress_rate":
            ax.get_legend().remove()

    fig.savefig(output)


def main():
    plt.style.use("seaborn-v0_8-whitegrid")

    uncompressed_size = {}
    for p in map(Path, snakemake.input.uncompressed_sizes):
        size = int(p.read_text().strip())
        name = p.name.split(".")[0]
        uncompressed_size[name] = size

    size_df = pd.read_csv(snakemake.input.compressed_sizes).set_index(
        ["name", "group", "tool", "level"], drop=False, verify_integrity=True
    )

    def ratio_func(row):
        return row.bytes / uncompressed_size[row['name']]

    size_df["compress_ratio"] = size_df.apply(ratio_func, axis=1)

    mode = "compress"
    frames = []
    for p in map(Path, snakemake.input.compress_benchmarks):
        name = p.name.split(".")[0]
        lvl = int(p.parts[-3])
        group = p.parts[-2]
        tool = p.parts[-4]
        subdf = pd.read_csv(p, sep="\t")
        keep = ["s", "max_rss"]
        subdf = subdf[keep]
        subdf.rename(
            columns={"s": f"{mode}_secs", "max_rss": f"{mode}_max_rss"}, inplace=True
        )
        subdf["tool"] = tool
        subdf["name"] = name
        subdf["group"] = group
        subdf["level"] = lvl
        subdf[f"{mode}_rate"] = uncompressed_size[name] / subdf[f"{mode}_secs"][0]
        frames.append(subdf)
    compress_frame = pd.concat(frames).set_index(
        ["name", "group", "tool", "level"], drop=False, verify_integrity=True
    )

    mode = "decompress"
    frames = []
    for p in map(Path, snakemake.input.decompress_benchmarks):
        name = p.name.split(".")[0]
        lvl = int(p.parts[-3])
        group = p.parts[-2]
        tool = p.parts[-4]
        subdf = pd.read_csv(p, sep="\t")
        keep = ["s", "max_rss"]
        subdf = subdf[keep]
        subdf.rename(
            columns={"s": f"{mode}_secs", "max_rss": f"{mode}_max_rss"}, inplace=True
        )
        subdf["tool"] = tool
        subdf["name"] = name
        subdf["group"] = group
        subdf["level"] = lvl
        subdf[f"{mode}_rate"] = uncompressed_size[name] / subdf[f"{mode}_secs"][0]
        frames.append(subdf)
    decompress_frame = pd.concat(frames).set_index(
        ["name", "group", "tool", "level"], drop=False, verify_integrity=True
    )

    df = compress_frame.combine_first(decompress_frame).combine_first(size_df)

    hue = "tool"
    hue_order = sorted(DEFAULT_LVL)
    style = "group"
    style_order = sorted(set(df["group"]))

    plot_compression_ratio(
        data=df,
        y="compress_ratio",
        hue_order=hue_order,
        style_order=style_order,
        hue=hue,
        style=style,
        output=snakemake.output.compression_ratio,
    )

    plot_rate_and_memory(
        ys=[
            "compress_rate",
            "decompress_rate",
            "compress_max_rss",
            "decompress_max_rss",
        ],
        data=df,
        hue_order=hue_order,
        style_order=style_order,
        hue=hue,
        style=style,
        output=snakemake.output.rate_and_memory,
    )

    plot_pareto_frontier(
        xs=["compress_rate", "decompress_rate"],
        y="compress_ratio",
        data=df,
        hue_order=hue_order,
        style_order=style_order,
        hue=hue,
        style=style,
        output=snakemake.output.pareto_frontier,
    )


main()

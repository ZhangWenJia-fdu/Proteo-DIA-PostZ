# ProteoDIAPostZ

ProteoDIAPostZ is a Windows/R/Shiny application for post-processing protein-level DIA proteomics results from DIA-NN and Spectronaut.

Current public release: **Formal Release V1.3**

Developed by Wenjia Zhang, Department of Chemistry, Fudan University.

## What It Does

- Loads DIA-NN and Spectronaut protein-level result tables.
- Supports protein identification summaries, Venn/UpSet plots, physicochemical property distributions, correlation heatmaps, rank-abundance plots, CV ridgelines, PCA, UMAP, volcano plots, and expression heatmaps.
- Provides three machine-learning modes: Random forest, L1, and RF + L1 combined.
- Includes feature UMAP/heatmap and Slingshot pseudotime analysis.
- Exports vector PDF figures and corresponding CSV data tables.
- Includes built-in offline UniProt annotation tables for human, mouse, and C. elegans.

## Recommended Windows Use

For normal Windows use, download the packaged release zip from GitHub Releases:

```text
ProteoDIAPostZ_v1.3_windows_x86_release.zip
```

Unzip the full folder, then start the app with:

```text
ProteoDIAPostZ_v1.3.exe
```

or use the fallback script:

```text
Run_ProteoDIAPostZ_v1.3.cmd
```

The interface opens in a local browser at:

```text
http://127.0.0.1:3840/
```

This is a local Shiny interface, not an online website.

## Source Layout

```text
app/app.R                         Shiny user interface and server wiring
app/R/analysis_core.R             Core analysis functions
app/annotations/                  Built-in offline annotation tables
check_dependencies.R              Runtime dependency check helper
run_app.R                         Standard Shiny launcher script
run_app_headless.R                Headless launcher script
ProteoDIAPostZ_v1.3_launcher.cs   Windows launcher source
Run_ProteoDIAPostZ_v1.3.cmd       Fallback launcher script
tools/                            Annotation update helper
```

## Notes

- The packaged Windows release includes portable R and packaged R libraries. The source repository intentionally does not track portable runtime folders or generated outputs.
- Normal app usage is offline. Internet access is only needed if updating UniProt annotation tables.
- This release handles protein-level results only.

## Release Asset Checksum

```text
SHA256  D60078C25A79B6E8908981B2E365067A0F9E89D06802DC92DAF59D6E4F003067  ProteoDIAPostZ_v1.3_windows_x86_release.zip
```

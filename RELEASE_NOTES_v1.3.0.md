# ProteoDIAPostZ Formal Release V1.3

ProteoDIAPostZ is a Windows/R/Shiny application for post-processing protein-level DIA proteomics results from DIA-NN and Spectronaut.

This is the first public release of ProteoDIAPostZ.

## Main Features

- Protein-level result import and post-processing for DIA-NN and Spectronaut.
- Protein identification summaries and group-level qualitative analysis.
- Venn and UpSet plots for detected protein sets.
- Physicochemical property visualization using built-in UniProt annotation tables.
- Quantitative plots including correlation heatmap, rank-abundance plot, CV ridgeline, PCA, UMAP, volcano plot, and expression heatmap.
- Machine-learning feature selection using Random forest, L1, and RF + L1 combined modes.
- Feature-level UMAP and heatmap based on selected proteins.
- Slingshot pseudotime analysis using sample-level PCA or UMAP coordinates.
- Vector PDF figure export with corresponding CSV data export.
- Page-side plot preview and output path reporting.

## Supported Input

- DIA-NN protein-level result matrices.
- Spectronaut protein-level result tables.
- Supported row identifiers:
  - Protein name
  - Gene name
  - Accession

## Built-in Offline Resources

The Windows package includes:

- Portable R runtime.
- Required R package library.
- Built-in annotation tables for:
  - Human reviewed Swiss-Prot
  - Mouse reviewed Swiss-Prot
  - C. elegans UniProtKB Swiss-Prot + TrEMBL

Normal app usage does not require an internet connection.

## Windows Package

Download and unzip:

```text
ProteoDIAPostZ_v1.3_windows_x86_release.zip
```

Start the app by double-clicking:

```text
ProteoDIAPostZ_v1.3.exe
```

or by running:

```text
Run_ProteoDIAPostZ_v1.3.cmd
```

The interface opens locally at:

```text
http://127.0.0.1:3840/
```

## Checksum

```text
SHA256  D60078C25A79B6E8908981B2E365067A0F9E89D06802DC92DAF59D6E4F003067  ProteoDIAPostZ_v1.3_windows_x86_release.zip
```

## Scope Notes

- This release handles protein-level results only.
- Peptide-level analysis is not included.
- Internet access is only needed if users update UniProt annotation tables.

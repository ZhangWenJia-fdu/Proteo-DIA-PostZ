ProteoDIAPostZ Formal Release V1.3
Developed by Wenjia Zhang

1. How to Start
1. Recommended: double-click ProteoDIAPostZ_v1.3.exe to start the program.
2. Alternative: run Run_ProteoDIAPostZ_v1.3.cmd.
3. Local browser address: http://127.0.0.1:3840/

2. About the exe and Browser Interface
The analysis core of this software is based on R/Shiny. The Shiny graphical interface is displayed through a local browser, but it is not an online website. The address 127.0.0.1 is accessible only on the current computer. The exe launcher starts the bundled portable R environment, runs the Shiny app, and opens the browser automatically.

3. Main Features in Formal Release V1.3
- Supports post-processing of DIA-NN and Spectronaut protein-level results.
- Supports protein identification summaries, Venn/UpSet plots, physicochemical properties, correlation heatmaps, rank-abundance plots, CV ridgelines, PCA, UMAP, volcano plots, and expression heatmaps.
- Keeps three machine-learning modes: Random forest, L1, and RF + L1 combined.
- Keeps feature UMAP/heatmap and Slingshot pseudotime analysis.
- Each analysis plot has an independent Generate button, parameter panel, color palette, size settings, CSV export option, and Restore defaults button.
- After a plot is generated, the page displays the PDF output path; when CSV export is selected, the corresponding data-table path is also displayed.
- The page-side preview shows output figures for quick visual checking.

4. Offline Use
Formal Release V1.3 includes:
- portable/R-4.5.1: R runtime.
- portable/Rlibs: R packages required by the current app.
- app/annotations/uniprot_all_celegans_6239_annotations.csv: C. elegans UniProtKB Swiss-Prot + TrEMBL annotation table.
- app/annotations/uniprot_reviewed_human_9606_annotations.csv: human reviewed Swiss-Prot annotation table.
- app/annotations/uniprot_reviewed_mouse_10090_annotations.csv: mouse reviewed Swiss-Prot annotation table.

Normal use does not require an internet connection. Internet access is only needed when updating UniProt annotation tables.

5. Notes on Slingshot Usage
Slingshot uses sample-level PCA or UMAP two-dimensional coordinates and uses the group labels manually entered on the Input page as cluster labels.
- If the groups have a clear time or treatment order, choose the earliest/control group as the Start group, and choose the last time point or endpoint group as the Optional end group.
- For exploratory analysis, choose the control group as the Start group and select None for the End group first, then check whether the inferred trajectory is reasonable.

Outputs are written to the sling subfolder under the selected output directory, including slingshot_sample_pseudotime.csv and slingshot_pseudotime_trajectory.pdf.
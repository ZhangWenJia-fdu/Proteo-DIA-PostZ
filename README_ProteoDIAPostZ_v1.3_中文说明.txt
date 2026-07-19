ProteoDIAPostZ 正式版 V1.3
Developed by Wenjia Zhang

一、运行方式
1. 首选：双击 ProteoDIAPostZ_v1.3.exe 启动程序。
2. 备用：运行 Run_ProteoDIAPostZ_v1.3.cmd。
3. 本地浏览器地址：http://127.0.0.1:3840/

二、关于 exe 和浏览器界面
本软件的分析核心是 R/Shiny。Shiny 图形界面通过本机浏览器显示，但不是联网网站；127.0.0.1 只在当前电脑本机访问。exe 的作用是启动内置 portable R、运行 Shiny app，并自动打开浏览器。

三、正式版 V1.3 主要功能
- 支持 DIA-NN 和 Spectronaut 蛋白水平结果后处理。
- 支持蛋白鉴定统计、Venn/UpSet、physicochemical properties、相关性热图、rank-abundance、CV ridgeline、PCA、UMAP、volcano、expression heatmap。
- 保留 Random forest、L1、RF + L1 combined 三种机器学习模式。
- 保留 feature UMAP/heatmap 和 Slingshot pseudotime 分析。
- 每个分析图有独立 Generate 按钮、参数区、配色、尺寸设置、CSV 导出开关和 Restore defaults 按钮。
- 生成图后页面显示 PDF 输出路径；勾选 CSV 时同步显示对应数据表路径。
- 页面侧边预览输出图，便于确认图形是否正确。

四、离线运行
正式版 V1.3 内置：
- portable/R-4.5.1：R 运行时。
- portable/Rlibs：当前 app 所需 R 包。
- app/annotations/uniprot_all_celegans_6239_annotations.csv：C. elegans UniProtKB Swiss-Prot + TrEMBL 注释表。
- app/annotations/uniprot_reviewed_human_9606_annotations.csv：human reviewed Swiss-Prot 注释表。
- app/annotations/uniprot_reviewed_mouse_10090_annotations.csv：mouse reviewed Swiss-Prot 注释表。

正常使用不需要联网。只有更新 UniProt 注释表时才需要联网。

五、Slingshot 使用建议
Slingshot 使用样品的 PCA 或 UMAP 二维坐标，并把 Input 页面手动输入的 group 作为 cluster label。
- 如果分组有明确时间或处理顺序，Start group 选最早/对照组，Optional end group 选最后时间点/终点组。
- 如果只是探索性分析，Start group 选对照组，End group 先选 None，观察轨迹是否合理。

输出位于所选 output directory 的 sling 子目录，包括 slingshot_sample_pseudotime.csv 和 slingshot_pseudotime_trajectory.pdf。
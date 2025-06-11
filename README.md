This repo was developed by Jaimie West in 2024 to aid in 'high' throughput isolate whole genome assembly using a consensus approach of long read assembly (using Ryan Wick's Trycycler) followed by polishing of consensus assemblies with short reads. It also works with long reads only (just omit the polishing).

To use this repo, First work through the Trycycler tutorial (https://github.com/rrwick/Perfect-bacterial-genome-tutorial/wiki/Tutorial-%28easy%29) and documentation (https://github.com/rrwick/Trycycler/wiki) in order to understand the steps and approach. Then you may best inplement it using this snakemake pipeline.

 If you want to read more or need to cite Trycycler, here is its corresponding manuscript: Wick RR, Judd LM, Cerdeira LT, Hawkey J, Méric G, Vezina B, Wyres KL, Holt KE. Trycycler: consensus long-read assemblies for bacterial genomes. Genome Biology. 2021. doi:10.1186/s13059-021-02483-z.

This particular implementation of the pipeline uses a snakemake wrapper, which was heavily modified from Matin Nuhamunada https://github.com/matinnuhamunada/trycycler_snakemake_wrapper
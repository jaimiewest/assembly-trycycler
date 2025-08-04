This directory contains these instructions and a .pbs script to ID isolates pretty efficiently.

created by Jaimie West 26June2025

Once you run through this manually to make sure everything is installed and you understand file paths, this can be done efficiently using the flye_checkM2_GTDB_toID.pbs script; just adjust the isolate names and a directory name, and of course ensure file paths are correct etc..

**FLYE:**

To do a quick assembly, you can use the trycycler-assembly environment to run Flye. Option to QC reads, or not; must adjust command accordingly to point to correct ONT.fastq file. 

```bash
flye --nano-hq reads/ISOLATENAME/ONT.fastq --threads 16 --out-dir assemblies/ISOLATENAME/
```

**CHECKM2:**

To check for contamination and completeness, you need to set up CheckM2 environment and download the database, following the developer's instructions on github:
https://github.com/chklovski/CheckM2

[to install, I had to constrain python version for installation to work--see issue 82]

USAGE (adjust paths and isolate names; first start interactive job):
```bash
conda activate checkm2
cd p/work/jaimie/checkm2
checkm2 predict --threads 16 --input /p/work/jaimie/assemblies/ISOLATENAME/ISOLATENAME.fasta --output-directory results/ISOLATENAME
```

**GTDB-TK:**

To identify a closest NCBI match, you need to set up the GTDB environment and download the database. Note that Carpenter will delete the database regularly, so one option is to create your GTDB folder, archive it, and restore it from archive as needed.

GTDB Install instructions:
https://ecogenomics.github.io/GTDBTk/installing/bioconda.html

USAGE:

Copy/Make sure your assemblies of interest are in the --genome_dir folder. This will run them all togehter.

```bash
conda activate gtdbtk-2.4.0
export GTDBTK_DATA_PATH=release220
cd /p/work/jaimie/GTDB
gtdbtk classify_wf --genome_dir DirNAME --out_dir DirName --cpus 16 --mash_db MASH_DB --extension fasta

```

OPTIONAL step to check the install; this takes a long time. Suggest doing it initially, and only as needed thereafter.
```bash
gtdbtk check_install
```


rule trycycler_intermediate:
    input:
        cluster = 'interim/clusters/{isolate}/{cluster}/'
    output:
        reconcile = 'interim/consensus/{isolate}/{cluster}_copy.log'
    threads: 1
    log:
        'out/logs/03_trycycler_consensus/trycycler_intermediate/trycycler_intermediate-{cluster}-{isolate}.log'
    params:
        cluster_file = config["clusters"]
    shell:  
        """
        python scripts/symlink_cluster.py {wildcards.isolate} {wildcards.cluster} {params.cluster_file} 2>> {log}
        """ 

rule trycycler_reconcile:
    input:
        raw_reads = 'reads/{isolate}/reads_qc/ONT.fastq',
        reconcile = 'interim/consensus/{isolate}/{cluster}_copy.log',
    output:
        reconcile = 'interim/consensus/{isolate}/{cluster}/2_all_seqs.fasta'
    threads: 1
    params:
        cluster = 'interim/consensus/{isolate}/{cluster}',
        max_add_seq = config['rule_params']['rule_trycycler_reconcile']['max_add_seq']
    shell:  
        """
        trycycler reconcile --threads {threads} --reads {input.raw_reads} --cluster_dir {params.cluster} --max_add_seq {params.max_add_seq}
        """

rule trycycler_MSA:
    input:
        reconcile = 'interim/consensus/{isolate}/{cluster}/2_all_seqs.fasta'
    output:
        msa = 'interim/consensus/{isolate}/{cluster}/3_msa.fasta'
    threads: 1
    params:
        cluster = 'interim/consensus/{isolate}/{cluster}',
    shell:  
        """
        trycycler msa --threads {threads} --cluster_dir {params.cluster}
        """

rule trycycler_partition:
    input:
        #reconcile = 'interim/consensus/{isolate}/{cluster}_copy.log',
        msa = lambda wildcards: get_final_msa(wildcards.isolate, cluster),
        raw_reads = 'reads/{isolate}/reads_qc/ONT.fastq'
    output:
        partition = "interim/consensus/{isolate}/partition.log"
    threads: 1
    params:
        cluster = lambda wildcards: get_final_cluster(wildcards.isolate, cluster)
    shell:  
        """
        trycycler partition --threads {threads} --reads {input.raw_reads} --cluster_dirs {params.cluster}
        echo "partition success!" > {output.partition}
        """

rule trycycler_consensus:
    input:
        partition = "interim/consensus/{isolate}/partition.log",
        reconcile = 'interim/consensus/{isolate}/{cluster}_copy.log',
    output:
        consensus = 'interim/consensus/{isolate}/{cluster}/7_final_consensus.fasta'
    threads: 1
    shell:  
        """
        trycycler consensus --threads {threads} --cluster_dir interim/consensus/{wildcards.isolate}/{wildcards.cluster}
        """

# Must confirm and specify basecalling model for Medaka.
# 'r1041_e82_400bps_sup_v4.3.0' is for R 10.4.1 minion flowcell, 400 bp, superaccurate basecalling, Guppy v 4.3.0.
# AFRL data actually used Guppy 6.4.6 but this does not seem to be an option...
# This step dropped for Dorado basecalling algo per Ryan Wick: https://rrwick.github.io/2023/10/24/ont-only-accuracy-update.html

#rule medaka_polish:
#    input:
#        consensus = 'data/interim/03_consensus/{isolate}/{cluster}/7_final_consensus.fasta'
#    output:
#        medaka = "data/interim/03_consensus/{isolate}/{cluster}/8_medaka.fasta"
#    threads: 1
#    params:
#        model = 'r1041_e82_400bps_sup_v4.3.0',
#        cluster = "data/interim/03_consensus/{isolate}/{cluster}",
#    shell:
#        """
#        medaka_consensus -i {params.cluster}/4_reads.fastq -d {input.consensus} -o {params.cluster}/medaka -m {params.#model} -t {threads}
#        mv {params.cluster}/medaka/consensus.fasta {params.cluster}/8_medaka.fasta
#        #rm -r {params.cluster}/medaka {params.cluster}/*.fai {params.cluster}/*.mmi
#        """

rule trycycler_concat:
    input:
        lambda wildcards: get_final_consensus(wildcards.isolate, cluster)
    output:
        assembly = 'assembly_final/{isolate}/trycycler_assembly.fasta'
    threads: 1
    shell:  
        """
        cat {input} > {output.assembly}
        """

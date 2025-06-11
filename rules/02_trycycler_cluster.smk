rule trycycler_cluster:
    input:
        qc_reads = 'reads/{isolate}/reads_qc/ONT.fastq',
        assembly = 'interim/assemblies/{isolate}'
    output:
        newick = 'interim/clusters/{isolate}/contigs.newick',
        cluster = directory('interim/clusters/{isolate}')
    threads: 16
    shell:  
        """
        trycycler cluster --threads {threads} --reads {input.qc_reads} --assemblies {input.assembly}/*.fasta --out_dir {output.cluster}
        """

rule cluster_dump:
    input:
        expand('interim/clusters/{isolate}', isolate = ISOLATES),
    output:
        yaml = 'interim/clusters/cluster.yaml'
    params:
        cluster_path = 'interim/clusters'
    run:
        class yaml_indent_dump(yaml.Dumper):
            def increase_indent(self, flow=False, indentless=False):
                    return super(yaml_indent_dump, self).increase_indent(flow, False)
            
        # grab all cluster
        cluster_path = Path(params.cluster_path)
        clusters = {}
        for s in ISOLATES:
            contigs = {}
            isolate = cluster_path / s
            isolate_cluster = [i for i in isolate.glob('cluster*')]
            for c in isolate_cluster:
                contigs[c.name] = [i.stem for i in c.glob('*/*.fasta')]
            clusters[s] = contigs

        # write as yaml
        with open(output.yaml, 'w') as f:
            yaml.dump(clusters, f, Dumper=yaml_indent_dump, default_flow_style=False)

rule cluster_draw:
    input:
        cluster = 'interim/clusters/{isolate}/contigs.newick'
    output:
        png = 'interim/clusters/figures/{isolate}_cluster.png'
#    conda:
#        "../envs/environment.R.yml"
    shell:
        """
        Rscript scripts/ggtree.R -i {input.cluster} -o {output.png}
        cp {input.cluster} interim/clusters/figures/{wildcards.isolate}_contigs.newick
        """

# Generate 12 (or however many) long read assemblies, using various long read assemblers

rule subsample_reads:
    input:
        'reads/{isolate}/reads_qc/ONT.fastq'
    output:
       expand('interim/assemblies/{{isolate}}/read_subsets/sample_{subsample}.fastq', \
       subsample = ['01', '02', '03', '04', '05', '06', '07', '08', '09', '10', '11', '12'])
    threads: 16
    params:
        output_dir = 'interim/assemblies/{isolate}/read_subsets',
        n_subsample = 12
    shell:
        '''
        trycycler subsample --count {params.n_subsample} --threads {threads} --reads {input} --out_dir {params.output_dir}
        '''

rule flye_assembly:
    input:
        'interim/assemblies/{isolate}/read_subsets/sample_{subsample}.fastq'
    output:
        assembly = 'interim/assemblies/{isolate}/assembly_{subsample}.fasta',
        graph = 'interim/assemblies/{isolate}/assembly_{subsample}.gfa'
    wildcard_constraints:
        subsample="|".join(['01', '04', '07', '10'])
    params:
        flyedir = directory('interim/assemblies/{isolate}/assembly_{subsample}'),
    threads: 16
    shell:
        '''
        flye --nano-hq {input} --threads {threads} \
            --out-dir {params.flyedir}
        cp {params.flyedir}/assembly.fasta {output.assembly}
        cp {params.flyedir}/assembly_graph.gfa {output.graph}
        rm -r {params.flyedir}
        '''

rule miniasm_and_minipolish_assembly:
    input:
        'interim/assemblies/{isolate}/read_subsets/sample_{subsample}.fastq'
    output:
        assembly = 'interim/assemblies/{isolate}/assembly_{subsample}.fasta',
        graph = 'interim/assemblies/{isolate}/assembly_{subsample}.gfa'
    wildcard_constraints:
        subsample="|".join(['02', '05', '08', '11'])
    threads: 16
    shell:
        '''
        miniasm_and_minipolish.sh {input} {threads} > {output.graph}
        any2fasta {output.graph} > {output.assembly}
        #rm assembly_02.gfa
        '''
rule raven_assembly:
    input:
        'interim/assemblies/{isolate}/read_subsets/sample_{subsample}.fastq'
    output:
        assembly = 'interim/assemblies/{isolate}/assembly_{subsample}.fasta',
        graph = 'interim/assemblies/{isolate}/assembly_{subsample}.gfa'
    wildcard_constraints:
        subsample="|".join(['03', '06', '09', '12'])
    threads: 16
    shell:
        '''
        raven --threads {threads} --graphical-fragment-assembly {output.graph} --disable-checkpoints {input} > {output.assembly}
        '''

rule draw_graph:
    input:
        graph = 'interim/assemblies/{isolate}/assembly_{subsample}.gfa'
    output:
        graph = 'interim/assemblies/{isolate}/{isolate}_{subsample}.png',
        gfa = 'interim/assemblies/{isolate}/{isolate}_{subsample}.gfa'
    shell:
        """
        Bandage image {input.graph} {output.graph}
        cp {input.graph} {output.gfa}
        """

rule merge_draw_graph:
    input:
        expand('interim/assemblies/{{isolate}}/{{isolate}}_{subsample}.png', \
        subsample=['01', '02', '03', '04', '05', '06', '07', '08', '09', '10', '11', '12']),
    output:
        png = "interim/assemblies/{isolate}/{isolate}_all_graphs.png",
    params:
        dir = 'interim/assemblies/{isolate}'
    shell:
        """
        python scripts/merge_draw_graph.py {params.dir} {output}
        """

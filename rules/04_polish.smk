rule Illumina_qc:
    input:
        read1 = 'reads/{isolate}/reads_raw/{isolate}_Illumina_R1.fastq.gz',
        read2 = 'reads/{isolate}/reads_raw/{isolate}_Illumina_R2.fastq.gz'
    output:
        out1 = 'reads/{isolate}/reads_qc/Illumina_R1.fastq.gz',
        out2 = 'reads/{isolate}/reads_qc/Illumina_R2.fastq.gz',
        unpaired1 = 'reads/{isolate}/reads_qc/Illumina_u1.fastq.gz',
        unpaired2 = 'reads/{isolate}/reads_qc/Illumina_u2.fastq.gz'
    params:
        output_dir = 'reads/{isolate}/reads_qc'
    shell:
        '''
        fastp --in1 {input.read1} --in2 {input.read2} \
        --out1 {output.out1} --out2 {output.out2} \
        --unpaired1 {output.unpaired1} --unpaired2 {output.unpaired2}
        '''

rule align_and_filter:
    input:
        assembly = 'assembly_final/{isolate}/trycycler_assembly.fasta',
        IlluminaR1 = 'reads/{isolate}/reads_qc/Illumina_R1.fastq.gz',
        IlluminaR2 = 'reads/{isolate}/reads_qc/Illumina_R2.fastq.gz',
    output:
        alignments1 = 'interim/consensus/{isolate}/alignments_1.sam',
        alignments2 = 'interim/consensus/{isolate}/alignments_2.sam',
        filter1 = 'interim/consensus/{isolate}/filtered_1.sam',
        filter2 = 'interim/consensus/{isolate}/filtered_2.sam',
    threads: 16
    shell:
        """
        bwa index {input.assembly}
        bwa mem -t {threads} -a {input.assembly} {input.IlluminaR1} > {output.alignments1}
        bwa mem -t {threads} -a {input.assembly} {input.IlluminaR2} > {output.alignments2}

        polypolish filter --in1 {output.alignments1} --in2 {output.alignments2} --out1 {output.filter1} --out2 {output.filter2}
        """

rule polypolish:
    input:
        assembly = 'assembly_final/{isolate}/trycycler_assembly.fasta',
        filter1 = 'interim/consensus/{isolate}/filtered_1.sam',
        filter2 = 'interim/consensus/{isolate}/filtered_2.sam',
    output:
        assembly = 'assembly_final/{isolate}/try_assembly_polypolish.fasta'
    params:
    #    dir = 'assembly_final/{isolate}',
    #    dir2 = '../../interim/consensus/{isolate}'
    threads: 16
    shell:
        """
        polypolish polish {input.assembly} {input.filter1} {input.filter2} > {output.assembly}
        """

rule pypolca:
    input:
        polypolish = 'assembly_final/{isolate}/try_assembly_polypolish.fasta',
        IlluminaR1 = 'reads/{isolate}/reads_qc/Illumina_R1.fastq.gz',
        IlluminaR2 = 'reads/{isolate}/reads_qc/Illumina_R2.fastq.gz',
    output:
        assembly = 'assembly_final/{isolate}/pypolca/pypolca_corrected.fasta',
        assembly_renamed = 'assembly_final/{isolate}/try_assembly_polypolish_pypolca.fasta'
    params:
        outdir = 'assembly_final/{isolate}/pypolca',
    threads: 16
    shell:
        """
        pypolca run --careful --force -a {input.polypolish} -1 {input.IlluminaR1} -2 {input.IlluminaR2} -t {threads} -o {params.outdir}
        cp {output.assembly} {output.assembly_renamed}
        """

################################

rule format_final_assembly:
    input:
        assembly = 'assembly_final/{isolate}/try_assembly_polypolish_pypolca.fasta'
    output:
        assembly = 'assembly_final/{isolate}_polished_assembly.fasta'
    threads: 1
    shell:
        """
        cp {input.assembly} {output.assembly}
        """

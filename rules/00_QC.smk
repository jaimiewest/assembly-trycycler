################################
# Run QC to discard low-quality reads and/or trim off low-quality regions of reads.
# Assumes you have files names in the "input" lines below staged in appropriate directories.

rule ONT_filter:
    input:
        'reads/{isolate}/reads_raw/{isolate}_all_ONT.fastq.gz'
    output:
        'reads/{isolate}/reads_qc/ONT.fastq'
    params:
        min_length = lambda wildcards: config['rule_params']['rule_ONT_filter']['min_length'][wildcards.isolate], 
        keep_percent = config['rule_params']['rule_ONT_filter']['keep_percent']
    shell:
        '''
        filtlong --min_length {params.min_length} --keep_percent {params.keep_percent} {input} > {output}
        '''
        
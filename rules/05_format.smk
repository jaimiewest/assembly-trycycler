# Use this to rename and move a trycycler assembly (without polishing)
rule format_trycycler_assembly:
    input:
        assembly = 'assembly_final/{isolate}/trycycler_assembly.fasta'
    output:
        assembly = 'assembly_final/{isolate}_trycycler_assembly.fasta'
    threads: 1
    shell:
        """
        cp {input.assembly} {output.assembly}
        """
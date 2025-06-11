# Trycycler for hybrid assembly of whole genomes using ONT and Illumina data

# Jaimie West
# https://github.com/jaimiewest
# Started: 26 Feb 2024

##### Set up #####

from snakemake.utils import min_version
min_version("7.25.0")
import pandas as pd
from pathlib import Path
import yaml

##### load config, isolates #####

configfile: "config/config.yaml"

ISOLATES = config['isolates']

##### Select Cluster using user provided definition
def get_clusters(filepath):
    """
    Read the clusters output and return a dictionary
    """
    try:
        with open(filepath) as file:
            selected_cluster = yaml.load(file, Loader=yaml.FullLoader)
        return selected_cluster
    except FileNotFoundError as e:
        sys.stderr.write(f"No cluster selected. The file: <{filepath}> is not a valid cluster format. Check your config.yaml.\n")
        raise e

def get_final_cluster(isolate, cluster):
    """
    given a dictionary of isolates : cluster, return a list of the final reconcile output file
    """
    output = []
    for c in cluster[isolate]:
        item = f"interim/consensus/{isolate}/{c}"
        output.append(item)
    return output

def get_final_msa(isolate, cluster):
    """
    given a dictionary of isolates : cluster, return a list of the final reconcile output file
    """
    output = []
    for c in cluster[isolate]:
        item = f"interim/consensus/{isolate}/{c}/3_msa.fasta"
        output.append(item)
    return output

#def get_final_partition(isolate, cluster):
#    """
#    given a dictionary of isolates : cluster, return a list of the final reconcile output file
#    """
#    output = []
#    for c in cluster[isolate]:
#        item = f"interim/consensus/{isolate}/{c}/4_reads.fastq"
#        output.append(item)
#    return output

def get_final_consensus(isolate, cluster):
    """
    given a dictionary of isolates : cluster, return a list of the final consensus output file
    """
    output = []
    for c in cluster[isolate]:
        item = f"interim/consensus/{isolate}/{c}/7_final_consensus.fasta"
        output.append(item)
    return output

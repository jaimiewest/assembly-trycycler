import os
import subprocess
import csv
import gzip
from concurrent.futures import ThreadPoolExecutor, as_completed
from datetime import datetime

def run_command(command):
    try:
        result = subprocess.run(command, shell=True, capture_output=True, text=True)
        if result.returncode != 0:
            print(f"Error running command: {command}")
            print("Error output:", result.stderr)
        return result.stdout.strip()
    except Exception as e:
        print(f"Exception occurred: {e}")
        return ""

def parse_output(output, label):
    lines = output.split('\n')
    values = []
    for line in lines:
        if "Depth of" in line:
            value = line.split(':')[-1].strip()
            values.append(value)
        elif label in line:
            value = line.split(':')[-1].strip()
            values.append(value)
    return values

def calculate_average_read_length(filename):
    open_func = gzip.open if filename.endswith('.gz') else open
    total_length = 0
    count = 0
    with open_func(filename, 'rt') as file:
        for line in file:
            if line.startswith('@'):
                seq_line = next(file)  # This gets the line containing the nucleotide sequence
                total_length += len(seq_line.strip())  # Count bases in the sequence line
                count += 1  # Increment count of sequences
    return total_length // count if count > 0 else 0  # Return as integer

def count_reads(filename):
    open_func = gzip.open if filename.endswith('.gz') else open
    with open_func(filename, 'rt') as file:
        return sum(1 for line in file if line.startswith('@'))

def process_isolate(isolate, parent_dir):
    reads_all_path = os.path.join(parent_dir, isolate, 'reads_raw', f'{isolate}_all_ONT.fastq.gz')
    reads_qc_path = os.path.join(parent_dir, isolate, 'reads_qc', 'ONT.fastq')

    n50_command = f"python code/n50.py {reads_all_path} {reads_qc_path}"
    calculate_depth_command = f"python code/calculate_depth.py {reads_all_path} {reads_qc_path}"

    n50_output = run_command(n50_command)
    calculate_depth_output = run_command(calculate_depth_command)

    n50_values = parse_output(n50_output, "N50")
    depth_values = parse_output(calculate_depth_output, "depth")

    # Calculate average read lengths and counts
    avg_length_all = calculate_average_read_length(reads_all_path)
    avg_length_qc = calculate_average_read_length(reads_qc_path)
    count_all = count_reads(reads_all_path)
    count_qc = count_reads(reads_qc_path)

    n50_all = n50_values[0] if len(n50_values) > 0 else "NA"
    n50_qc = n50_values[1] if len(n50_values) > 1 else "NA"
    depth_all_Gbp = f"{float(depth_values[0]):.3f}" if len(depth_values) > 0 else "NA"
    depth_qc_Gbp = f"{float(depth_values[1]):.3f}" if len(depth_values) > 1 else "NA"

    return [isolate, n50_all, n50_qc, avg_length_all, avg_length_qc, count_all, count_qc, depth_all_Gbp, depth_qc_Gbp]

def generate_and_run_commands(parent_dir):
    isolates = [d for d in os.listdir(parent_dir) if os.path.isdir(os.path.join(parent_dir, d)) and d not in ['interim', 'processed']]

    # Get today's date in the desired format
    today = datetime.now().strftime("%d%b%Y")
    output_file = f"QC_summary_{today}.tsv"

    with open(output_file, "w", newline='') as file:
        writer = csv.writer(file, delimiter='\t')
        writer.writerow(["isolate", "N50_all", "N50_qc", "avg_length_all", "avg_length_qc", "reads_all", "reads_qc", "depth_all_Gbp", "depth_qc_Gbp"])

        with ThreadPoolExecutor() as executor:
            future_to_isolate = {executor.submit(process_isolate, isolate, parent_dir): isolate for isolate in isolates}
            for future in as_completed(future_to_isolate):
                isolate = future_to_isolate[future]
                try:
                    combined_output = future.result()
                    writer.writerow(combined_output)
                    print(f"Processed isolate {isolate}")
                except Exception as exc:
                    print(f"Isolate {isolate} generated an exception: {exc}")

if __name__ == "__main__":
    parent_dir = "reads2"
    generate_and_run_commands(parent_dir)


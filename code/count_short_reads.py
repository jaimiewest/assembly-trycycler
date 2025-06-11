import gzip
import sys

def count_reads_fastq_gz(fastq_gz_path):
    line_count = 0
    with gzip.open(fastq_gz_path, "rt") as f:
        for _ in f:
            line_count += 1
    return line_count // 4

if __name__ == "__main__":
    if len(sys.argv) != 2:
        print("Usage: python count_reads_fastq.py <input.fastq.gz>")
        sys.exit(1)

    input_file = sys.argv[1]
    count = count_reads_fastq_gz(input_file)
    print(f"Number of reads in {input_file}: {count}")


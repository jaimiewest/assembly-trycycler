import sys
import gzip

def count_reads(filename):
    open_func = gzip.open if filename.endswith('.gz') else open
    with open_func(filename, 'rt') as file:
        count = sum(1 for line in file if line.startswith('@'))
    return count

if __name__ == "__main__":
    if len(sys.argv) < 2 or len(sys.argv) > 3:
        print("Usage: python count_reads.py <filename1> [<filename2>]")
        sys.exit(1)

    filename1 = sys.argv[1]
    num_reads_1 = count_reads(filename1)
    print("Number of reads in", filename1, ":", num_reads_1)

    if len(sys.argv) == 3:
        filename2 = sys.argv[2]
        num_reads_2 = count_reads(filename2)
        print("Number of reads in", filename2, ":", num_reads_2)

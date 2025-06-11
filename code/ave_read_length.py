import sys
import gzip

def calculate_average_read_length(filename):
    open_func = gzip.open if filename.endswith('.gz') else open
    total_length = 0
    count = 0
    with open_func(filename, 'rt') as file:
        for line in file:
            if line.startswith('@'):
                # Read the sequence line, which is usually the next line
                seq_line = next(file)
                total_length += len(seq_line.strip())
                count += 1
    return total_length / count if count > 0 else 0

if __name__ == "__main__":
    if len(sys.argv) < 2 or len(sys.argv) > 3:
        print("Usage: python average_read_length.py <filename1> [<filename2>]")
        sys.exit(1)

    filename1 = sys.argv[1]
    avg_length_1 = calculate_average_read_length(filename1)
    print("Average read length in", filename1, ":", avg_length_1)

    if len(sys.argv) == 3:
        filename2 = sys.argv[2]
        avg_length_2 = calculate_average_read_length(filename2)
        print("Average read length in", filename2, ":", avg_length_2)


import sys
import gzip

def read_fastq(filename):
    sequences = []
    open_func = gzip.open if filename.endswith('.gz') else open
    with open_func(filename, 'rt') as file:
        for line in file:
            if line.startswith('@'):
                continue
            sequences.append(line.strip())
    return sequences

def calculate_N50(sequences):
    # Sort sequences by length in descending order
    sorted_sequences = sorted(sequences, key=len, reverse=True)
    total_length = sum(len(seq) for seq in sorted_sequences)  # Total length of all sequences
    target_length = total_length / 2  # Half of the total length
    cumulative_length = 0
    
    for seq in sorted_sequences:
        cumulative_length += len(seq)  # Add the length of the current sequence
        if cumulative_length >= target_length:  # Check if cumulative length exceeds half the total
            return len(seq)  # Return the length of the current sequence (N50)

if __name__ == "__main__":
    if len(sys.argv) < 2 or len(sys.argv) > 3:
        print("Usage: python calculate_N50.py <filename1> [<filename2>]")
        sys.exit(1)

    filenames = sys.argv[1:]
    for filename in filenames:
        sequences = read_fastq(filename)
        N50 = calculate_N50(sequences)
        print(f"N50 of {filename}: {N50}")

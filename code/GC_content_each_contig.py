import sys

def calculate_gc_content(fasta_file):
    """
    Calculates and prints the GC content of each contig in a FASTA file.

    Args:
        fasta_file: The path to the FASTA file.
    """

    gc_contents = {}

    try:
        with open(fasta_file, 'r') as file:
            # Initialize variables
            current_contig = None
            sequence = ""

            # Iterate through lines in the FASTA file
            for line in file:
                line = line.strip()

                # Check for contig header
                if line.startswith(">"):
                    # Process the previous contig if it exists
                    if current_contig:
                        # Calculate and store GC content
                        gc_count = sequence.count("G") + sequence.count("C")
                        total_count = len(sequence)
                        gc_content = (gc_count / total_count) * 100 if total_count > 0 else 0
                        gc_contents[current_contig] = gc_content

                    # Update current contig and reset sequence
                    current_contig = line[1:]  # Remove the ">"
                    sequence = ""
                else:
                    # Add the sequence to the current contig
                    sequence += line

            # Process the last contig
            if current_contig:
                gc_count = sequence.count("G") + sequence.count("C")
                total_count = len(sequence)
                gc_content = (gc_count / total_count) * 100 if total_count > 0 else 0
                gc_contents[current_contig] = gc_content

        # Print the GC contents
        for contig, gc_content in gc_contents.items():
            print(f"Contig: {contig}, GC Content: {gc_content:.2f}%")

    except FileNotFoundError:
        print(f"Error: File not found: {fasta_file}")
    except Exception as e:
        print(f"Error: An unexpected error occurred: {e}")

if __name__ == "__main__":
    # Check if a FASTA file path is provided as a command line argument
    if len(sys.argv) != 2:
        print("Usage: python script_name.py <fasta_file>")
    else:
        fasta_file_path = sys.argv[1]
        calculate_gc_content(fasta_file_path)
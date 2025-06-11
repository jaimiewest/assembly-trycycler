import sys
import gzip

def calculate_depth(filename):
    open_func = gzip.open if filename.endswith('.gz') else open
    with open_func(filename, 'rt') as file:
    #    depth = sum(len(line.strip()) for line in file if not line.startswith('@') and not line.startswith('+'))# and not file.tell() == 0) #This line counted quality scores also...the following line only counts the 2nd line of each entry
        depth = sum(len(line.strip()) for i, line in enumerate(file) if i % 4 == 1)
    return depth / 1e9  # Convert bases to gigabases

if __name__ == "__main__":
    if len(sys.argv) < 2 or len(sys.argv) > 3:
        print("Usage: python calculate_depth.py <filename1> [<filename2>]")
        sys.exit(1)

    filename1 = sys.argv[1]
    depth1 = calculate_depth(filename1)
    print("Depth of", filename1, ":", depth1)

    if len(sys.argv) == 3:
        filename2 = sys.argv[2]
        depth2 = calculate_depth(filename2)
        print("Depth of", filename2, ":", depth2)

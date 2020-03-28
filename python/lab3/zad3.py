import sys
file = open(sys.argv[1])
print(sum(int(line.split()[-1]) for line in file.readlines()))
file.close()

matrix = eval(input())
print([' '.join([matrix[i].split()[j] for i in range(0, len(matrix))]) for j in range(0, len(matrix))])

import sys
import os

print("liczba bajtów: ", os.path.getsize(sys.argv[1]))
f = open(sys.argv[1], encoding="utf8")
print("liczba słów: ", len(f.read().split()))
f.seek(0)
fl = f.readlines()
line_max = 0
for line in fl:
    line_strip = line.strip('\n')
    if len(line_strip) > line_max:
        line_max = len(line_strip)
print("liczba linii: ", len(fl))
print("maksymalna długość linii: ", line_max)
f.close()

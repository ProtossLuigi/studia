import sys
import os
import hashlib


def print_line():
    print('------------------------')


files = {}
for dirpath, dirnames, filenames in os.walk(sys.argv[1]):
    for filename in filenames:
        full_path = dirpath + '\\' + filename
        size = os.stat(full_path).st_size
        hashcode = hashlib.sha512()
        f = open(full_path, 'rb')
        hashcode.update(f.read())
        f.close()
        if files.get((size, hashcode.digest()), False):
            files[(size, hashcode.digest())].append(full_path)
        else:
            files[(size, hashcode.digest())] = [full_path]
for key in files.keys():
    print_line()
    for name in files[key]:
        print(name)

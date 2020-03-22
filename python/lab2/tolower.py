import sys
import os


def to_lower(path):
    for file in os.scandir(path):
        try:
            os.rename(path + '\\' + file.name, path + '\\' + file.name.lower())
        except FileExistsError as e:
            print(e.strerror)
        if file.is_dir():
            to_lower(file.path)


to_lower(sys.argv[1])

import time


def measure_time(func):
    def wrapper(*arg):
        t = time.time()
        r = func(*arg)
        print('Execution time: ', time.time() - t)
        return r
    return wrapper

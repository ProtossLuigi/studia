from random import randrange
from queue import Queue


def number_trees(n):
    if n == 0:
        return 1
    else:
        return pow(number_trees(n-1), 2) + 1


def make_random_tree(n):
    if randrange(number_trees(n)):
        return ['', make_random_tree(n-1), make_random_tree(n-1)]
    else:
        return None


def make_tree(n):
    if n == 0:
        return None
    tree = ['', None, None]
    for i in range(1, n):
        if randrange(2):
            tree = ['', tree, make_random_tree(i)]
        else:
            tree = ['', make_random_tree(i), tree]
    q = Queue()
    q.put_nowait(tree)
    i = 1
    while not q.empty():
        node = q.get_nowait()
        if node:
            node[0] = str(i)
            i += 1
            q.put_nowait(node[1])
            q.put_nowait(node[2])
    return tree


def dfs(tree):
    if tree:
        yield tree[0]
        yield from dfs(tree[1])
        yield from dfs(tree[2])


def bfs(tree):
    q = Queue()
    q.put_nowait(tree)
    while not q.empty():
        node = q.get_nowait()
        if node:
            yield node[0]
            q.put_nowait(node[1])
            q.put_nowait(node[2])

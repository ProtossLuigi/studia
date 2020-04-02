from random import randrange
from queue import Queue
MAX_CHILDREN = 5


class Node(object):

    def __init__(self):
        self.name = ''
        self.children = []


def number_trees(n):
    if n == 0:
        return 1
    else:
        return pow(number_trees(n-1), MAX_CHILDREN) + 1


def make_random_tree(n):
    if randrange(number_trees(n)):
        root = Node()
        for i in range(MAX_CHILDREN):
            child = make_random_tree(n-1)
            if child:
                root.children.append(child)
        return root
    else:
        return None


def make_tree(n):
    if n == 0:
        return None
    root = Node()
    for i in range(1, n):
        new_root = Node()
        r = randrange(MAX_CHILDREN)
        for j in range(r):
            child = make_random_tree(i)
            if child:
                new_root.children.append(child)
        new_root.children.append(root)
        for j in range(r, MAX_CHILDREN):
            child = make_random_tree(i)
            if child:
                new_root.children.append(child)
        root = new_root
    q = Queue()
    q.put_nowait(root)
    i = 1
    while not q.empty():
        node = q.get_nowait()
        node.name = str(i)
        i += 1
        for child in node.children:
            q.put_nowait(child)
    return root


def dfs(tree):
    yield tree.name
    for child in tree.children:
        yield from dfs(child)


def bfs(tree):
    q = Queue()
    q.put_nowait(tree)
    while not q.empty():
        node = q.get_nowait()
        yield node.name
        for child in node.children:
            q.put_nowait(child)


def tree_to_list(root):
    tree = [root.name]
    for child in root.children:
        tree.append(tree_to_list(child))
    return tree

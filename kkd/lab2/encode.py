import sys


class Node(object):

    def __init__(self):
        self.rank = 0
        self.left = None
        self.right = None
        self.parent = None


def get_code(node):
    char_code = []
    while node.parent:
        char_code = [node.parent.right == node] + char_code
        node = node.parent
    return char_code


def update_tree(node):
    changed = False
    node.rank += 1
    node = node.parent
    while node:
        


leaves = [None for x in range(0, 129)]
leaves[-1] = Node()
code = []
file_in = open(sys.argv[1], 'r', encoding='ascii')
file_out = open(sys.argv[2], 'wb')
for char in file_in.read():
    leaf = leaves[ord(char)]
    if leaf:
        code += get_code(leaf)
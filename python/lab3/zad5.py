def all_subsets(lst):
    return [[lst[i] for i in range(0, len(lst)) if 1 << i & j] for j in range(0, 2**len(lst))]

# def all_subsets(lst):
#     if not lst:
#         return [[]]
#     pre_lst = all_subsets(lst[:-1])
#     return pre_lst + list(map(lambda x: x + [lst[-1]], pre_lst))

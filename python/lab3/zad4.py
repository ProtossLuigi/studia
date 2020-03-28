def qsort(to_sort):
    if not to_sort:
        return []
    sorted1 = qsort([x for x in to_sort[1:] if x <= to_sort[0]])
    sorted2 = qsort([x for x in to_sort[1:] if x > to_sort[0]])
    return sorted1 + to_sort[:1] + sorted2

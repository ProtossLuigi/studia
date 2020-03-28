def flatten(x):
    if type(x) is list:
        for element in x:
            for flat_element in flatten(element):
                yield flat_element
    else:
        yield x

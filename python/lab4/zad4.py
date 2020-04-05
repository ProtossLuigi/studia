class Overload:
    funcs = {}

    def __call__(self, name, *args):
        try:
            for func in self.funcs[name]:
                try:
                    return func(*args)
                except TypeError:
                    pass
        except KeyError:
            raise NameError


def overload(func):
    name = func.__name__
    ov = Overload()
    if ov.funcs.get(name, False):
        ov.funcs[name].append(func)
    else:
        ov.funcs[name] = [func]

    def wrapper(*args):
        return ov(name, *args)
    return wrapper

import numpy as np


def sigmoid(x):
    return 1.0/(1 + np.exp(-x))


def sigmoid_derivative(x):
    return x * (1.0 - x)


def relu(x):
    return x * (x > 0)


def relu_derivative(x):
    return 1. * (x > 0)


class NeuralNetwork:
    def __init__(self, x, y, func1, func1_d, func2, func2_d):
        self.input = x
        self.weights1 = np.random.rand(4, self.input.shape[1])
        self.weights2 = np.random.rand(1, 4)
        self.y = y
        self.output = np.zeros(self.y.shape)
        self.func1 = func1
        self.func2 = func2
        self.func1_d = func1_d
        self.func2_d = func2_d
        self.eta = .01

    def feedforward(self):
        self.layer1 = self.func1(np.dot(self.input, self.weights1.T))
        self.output = self.func2(np.dot(self.layer1, self.weights2.T))

    def backprop(self):
        delta2 = (self.y - self.output) * self.func2_d(self.output)
        d_weights2 = self.eta * np.dot(delta2.T, self.layer1)
        delta1 = self.func1_d(self.layer1) * np.dot(delta2, self.weights2)
        d_weights1 = self.eta * np.dot(delta1.T, self.input)

        self.weights1 += d_weights1
        self.weights2 += d_weights2


def main():
    np.random.seed(17)
    np.set_printoptions(precision=3, suppress=True)
    x = np.array([[0, 0, 1],
                  [0, 1, 1],
                  [1, 0, 1],
                  [1, 1, 1]])
    y = {'XOR': np.array([[0], [1], [1], [0]]),
         'AND': np.array([[0], [0], [0], [1]]),
         'OR': np.array([[0], [1], [1], [1]])}
    funcs = {'sigmoid': (sigmoid, sigmoid_derivative), 'ReLU': (relu, relu_derivative)}
    for op in y.keys():
        for func1 in funcs.keys():
            for func2 in funcs.keys():
                nn = NeuralNetwork(x, y[op], funcs[func1][0], funcs[func1][1], funcs[func2][0], funcs[func2][1])
                for _ in range(5000):
                    nn.feedforward()
                    nn.backprop()
                print(op)
                print('function 1:', func1)
                print('function 2:', func2)
                print("output:", nn.output)
                print("weights 1:", nn.weights1)
                print("weights 2:", nn.weights2)
                print('')


if __name__ == '__main__':
    main()


# ostatnia jedynka w inpucie jest potrzebna do uczenia funkcji postaci f(x1, x2, ..., xn) = y
# gdzie x1, ..., xn są równe 0, a y =/= 0
# w     def feedforward(self):
#         self.layer1 = self.func1(np.dot(self.input, self.weights1.T))
#         self.output = self.func2(np.dot(self.layer1, self.weights2.T))
# jeśli self.input jest macierzą zerową, to self output też będzie zerowa

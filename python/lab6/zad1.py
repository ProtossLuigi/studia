from keras.models import Sequential
from keras.layers import Dense
from keras import optimizers
import numpy as np


def sigmoid(x):
    return 1.0/(1 + np.exp(-x))


def sigmoid_derivative(x):
    return x * (1.0 - x)


class NeuralNetwork:
    def __init__(self, x, y):
        self.input = x
        self.weights1 = np.random.rand(4, self.input.shape[1])
        self.weights2 = np.random.rand(1, 4)
        self.y = y
        self.output = np.zeros(self.y.shape)
        self.eta = .01

    def feedforward(self, fn1, fn2):
        self.layer1 = fn1(np.dot(self.input, self.weights1.T))
        self.output = fn2(np.dot(self.layer1, self.weights2.T))

    def backprop(self, fn1, fn2):
        delta2 = (self.y - self.output) * fn2(self.output)
        d_weights2 = self.eta * np.dot(delta2.T, self.layer1)
        delta1 = fn1(self.layer1) * \
            np.dot(delta2, self.weights2)
        d_weights1 = self.eta * np.dot(delta1.T, self.input)

        self.weights1 += d_weights1
        self.weights2 += d_weights2


def main():
    np.random.seed(17)
    np.set_printoptions(precision=3, suppress=True)

    X = np.array([[0, 0, 1],
                  [0, 1, 1],
                  [1, 0, 1],
                  [1, 1, 1]])
    y = np.array([[0], [1], [1], [0]])
    nn = NeuralNetwork(X, y)

    for _ in range(5000):
        nn.feedforward(relu, sigmoid)
        nn.backprop(relu_derivative, sigmoid_derivative)

    print("out:", nn.output)
    print("w1:", nn.weights1)
    print("w2:", nn.weights2)


if __name__ == '__main__':
    main()

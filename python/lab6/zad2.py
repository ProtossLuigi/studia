import sys

import numpy as np
import matplotlib.pyplot as plt

from zad1 import sigmoid, sigmoid_derivative

tanh = np.tanh


def tanh_d(x):
    return 1. - tanh(x)**2


class NeuralNetwork:
    def __init__(self, x, y, func1, func1_d, func2, func2_d):
        self.input = x
        self.weights1 = np.random.rand(10, self.input.shape[1])
        self.weights2 = np.random.rand(1, 10)
        self.y = y
        self.output = np.zeros(self.y.shape)
        self.func1 = func1
        self.func2 = func2
        self.func1_d = func1_d
        self.func2_d = func2_d
        self.eta = .01
        self.biases1 = np.random.rand(10)
        self.biases2 = np.random.rand(1)

    def feedforward(self):
        self.layer1 = self.func1(np.dot(self.input, self.weights1.T) + self.biases1.reshape(1, -1))
        self.output = self.func2(np.dot(self.layer1, self.weights2.T) + self.biases2.reshape(1, -1))

    def backprop(self):
        delta2 = (self.y - self.output) * self.func2_d(self.output)
        d_weights2 = self.eta * np.dot(delta2.T, self.layer1)
        d_biases2 = self.eta * np.sum(delta2, axis=0, keepdims=True)
        delta1 = self.func1_d(self.layer1) * np.dot(delta2, self.weights2)
        d_weights1 = self.eta * np.dot(delta1.T, self.input)
        d_biases1 = self.eta * np.sum(delta2, axis=0, keepdims=True)

        self.weights1 += d_weights1
        self.weights2 += d_weights2
        self.biases1 += d_biases1.reshape(-1)
        self.biases2 += d_biases2.reshape(-1)


def transform_data(data):
    return np.vstack(np.interp(data, (np.min(data), np.max(data)), (0., 1.)))


def restore_data(data, ymin, ymax):
    return np.interp(data.T, (0., 1.), (ymin, ymax))


def sqr():
    steps = 0
    learn_x = np.linspace(-50, 50, 26)
    test_x = np.linspace(-50, 50, 101)
    learn_x_v = transform_data(learn_x)
    test_x_v = transform_data(test_x)
    y = learn_x ** 2
    ymin = np.min(y)
    ymax = np.max(y)
    nn = NeuralNetwork(np.array([[0.]]), transform_data(y), sigmoid, sigmoid_derivative, sigmoid, sigmoid_derivative)
    while steps < 300000:
        nn.input = learn_x_v
        for i in range(1000):
            nn.feedforward()
            nn.backprop()
        nn.input = test_x_v
        nn.feedforward()
        # print(test_x)
        # print(restore_data(nn.output, ymin, ymax))
        plt.plot(test_x, restore_data(nn.output, ymin, ymax)[0])
        plt.pause(0.5)
        steps += 1000


def sin():
    steps = 0
    learn_x = np.linspace(0, 2, 21)
    test_x = np.linspace(0, 2, 161)
    learn_x_v = transform_data(learn_x)
    test_x_v = transform_data(test_x)
    y = np.sin((3*np.pi/2) * learn_x)
    ymin = np.min(y)
    ymax = np.max(y)
    nn = NeuralNetwork(np.array([[0.]]), transform_data(y), tanh, tanh_d, tanh, tanh_d)
    while steps < 300000:
        nn.input = learn_x_v
        for i in range(1000):
            nn.feedforward()
            nn.backprop()
        nn.input = test_x_v
        nn.feedforward()
        # print(test_x)
        # print(restore_data(nn.output, ymin, ymax))
        plt.plot(test_x, restore_data(nn.output, ymin, ymax)[0])
        plt.pause(0.5)
        steps += 1000


# domyślnie podnosi do kwadratu, dla sinusa uruchamiać z argumentem -sin
def main(argv):
    if argv[1] == '-sin':
        sin()
    else:
        sqr()


if __name__ == '__main__':
    main(sys.argv)

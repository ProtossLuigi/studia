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
        self.eta = 0.5

    def feedforward(self):
        self.layer1 = sigmoid(np.dot(self.input, self.weights1.T))
        self.output = sigmoid(np.dot(self.layer1, self.weights2.T))

    def backprop(self):
        delta2 = (self.y - self.output) * sigmoid_derivative(self.output)
        d_weights2 = self.eta * np.dot(delta2.T, self.layer1)
        delta1 = sigmoid_derivative(self.layer1) * np.dot(delta2, self.weights2)
        d_weights1 = self.eta * np.dot(delta1.T, self.input)

        self.weights1 += d_weights1
        self.weights2 += d_weights2


def main():
    x = np.array([[0, 0, 1],
                  [0, 1, 1],
                  [1, 0, 1],
                  [1, 1, 1]])
    y = np.array([[0], [1], [1], [0]])
    nn = NeuralNetwork(x, y)
    for i in range(5000):
        nn.feedforward()
        nn.backprop()
    print(nn.output)
    print(nn.weights1)
    print(nn.weights2)


if __name__ == '__main__':
    main()
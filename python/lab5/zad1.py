import sys
import csv
import numpy as np
from sklearn.linear_model import LinearRegression
import matplotlib.pyplot as plt
MOVIES = 193609


def show_results(real, predicted, title):
    l = len(real)
    plt.scatter([x for x in range(1, l+1)], real, s=3)
    plt.scatter([x for x in range(1, l+1)], predicted, s=2, c='r')
    plt.title(title)
    plt.legend(['actual', 'predicted'])
    plt.show()


def main(argv):
    ratings_raw = []
    with open('ml-latest-small\\ratings.csv') as csvfile:
        reader = csv.reader(csvfile, delimiter=',')
        for row in reader:
            ratings_raw.append(row[:3])
    ratings_dict = {}
    last_valid_user = None
    for row in ratings_raw[1:]:
        if row[1] == '1':
            last_valid_user = row[0]
            ratings_dict[int(row[0])] = {}
        if row[0] == last_valid_user:
            ratings_dict[int(row[0])][int(row[1])] = float(row[2])
    del ratings_raw
    ratings_ts = []
    ratings = []
    for user in ratings_dict:
        ratings_ts.append(ratings_dict[user][1])
        r = []
        for movie in range(2, MOVIES+1):
            r.append(ratings_dict[user].get(movie, 0.))
        ratings.append(r)

    for m in [10, 1000, 10000]:
        x = []
        for row in ratings:
            x.append(row[:m])
        x = np.array(x)
        y = np.array(ratings_ts)
        model = LinearRegression(n_jobs=-1).fit(x, y)
        show_results(y, model.predict(x), 'pełny zbiór, m = ' + str(m))

    for m in [10, 100, 200, 500, 1000, 10000]:
        x = []
        for row in ratings[:200]:
            x.append(row[:m])
        x = np.array(x)
        y = np.array(ratings_ts[:200])
        model = LinearRegression(n_jobs=-1).fit(x, y)
        x = []
        for row in ratings[200:]:
            x.append(row[:m])
        x = np.array(x)
        y = np.array(ratings_ts[200:])
        show_results(y, model.predict(x), 'trening, m = ' + str(m))


if __name__ == '__main__':
    main(sys.argv)

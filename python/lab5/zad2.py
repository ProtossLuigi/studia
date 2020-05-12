import numpy as np
import csv


def norm(x):
    return x / np.linalg.norm(x, axis=0)


data = []
max_movie_id = 0
with open('ml-latest-small\\movies.csv', encoding='utf8') as movies:
    reader = csv.reader(movies, delimiter=',', quotechar='"')
    for row in reader:
        data.append(row[:2])
titles = {}
for row in data[1:]:
    movieId = int(row[0])
    if movieId < 10000:
        titles[movieId] = row[1]
        max_movie_id = movieId
data = []
with open('ml-latest-small\\ratings.csv') as ratings:
    reader = csv.reader(ratings, delimiter=',')
    for row in reader:
        data.append(row[:3])
d = {}
for row in data[1:]:
    row = [int(row[0]), int(row[1]), float(row[2])]
    if row[1] >= 10000:
        continue
    if not d.get(row[0]):
        d[row[0]] = {}
    d[row[0]][row[1]] = row[2]
ratings = []
for user in d.keys():
    r = []
    for movie in range(1, max_movie_id+1):
        r.append(d[user].get(movie, 0))
    ratings.append(r)
X = np.nan_to_num(norm(np.array(ratings)))


def recommend(profile):
    y = np.dot(X, norm(profile))
    z = np.dot(X.T, norm(y))
    recs = []
    for i in range(max_movie_id):
        recs.append((z[i][0], titles.get(i+1, 'no title')))
    recs.sort(reverse=True, key=(lambda x: x[0]))
    for i in range(10):
        print(recs[i])


def test():
    my_ratings = np.zeros((9018, 1))
    my_ratings[2571] = 5
    my_ratings[32] = 4
    my_ratings[260] = 5
    my_ratings[1097] = 4
    recommend(my_ratings)


if __name__ == '__main__':
    test()

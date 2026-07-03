from pyod.utils.data import generate_data
import matplotlib.pyplot as plt


X_train, X_test, y_train, y_test = generate_data(n_train=400, n_test=100, n_features=2, contamination=0.1)

inliers = X_train[y_train == 0]
outliers = X_train[y_train == 1]

plt.scatter(inliers[:, 0], inliers[:, 1], color='blue', label='Inliers')
plt.scatter(outliers[:, 0], outliers[:, 1], color='red', label='Outliers')

plt.legend()
plt.show()
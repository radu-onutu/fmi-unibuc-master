import numpy as np
import matplotlib.pyplot as plt
from sklearn.datasets import make_blobs
from sklearn.neighbors import KNeighborsClassifier
from pyod.models.lof import LOF

X, y = make_blobs(n_samples=[200, 100], centers=[(-10, -10), (10, 10)], 
                  cluster_std=[2, 6], random_state=42)

knn = KNeighborsClassifier(n_neighbors=5)
knn.fit(X, y)

knn_labels = knn.predict(X)

lof = LOF(n_neighbors=20, contamination=0.07)
lof.fit(X)

lof_labels = lof.labels_

fig, axs = plt.subplots(1, 2, figsize=(14, 6))

axs[0].scatter(X[knn_labels == 0][:, 0], X[knn_labels == 0][:, 1], c='blue', label='Inliers')
axs[0].scatter(X[knn_labels == 1][:, 0], X[knn_labels == 1][:, 1], c='red', label='Outliers')
axs[0].set_title("KNN Predictions")
axs[0].legend()

axs[1].scatter(X[lof_labels == 0][:, 0], X[lof_labels == 0][:, 1], c='blue', label='Inliers')
axs[1].scatter(X[lof_labels == -1][:, 0], X[lof_labels == -1][:, 1], c='red', label='Outliers')
axs[1].set_title("LOF Predictions")
axs[1].legend()

plt.show()

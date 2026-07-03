from pyod.utils.data import generate_data
import numpy as np
from sklearn.metrics import balanced_accuracy_score


X_train, X_test, y_train, y_test = generate_data(n_train=1000, n_test=1, n_features=1, contamination=0.1)

mean = np.mean(X_train)
std = np.std(X_train)

z_scores = (X_train - mean) / std

z_threshold = np.quantile(np.abs(z_scores), 1 - 0.1)

y_pred = (np.abs(z_scores) > z_threshold).astype(int)

balanced_acc = balanced_accuracy_score(y_train, y_pred)

print(balanced_acc)
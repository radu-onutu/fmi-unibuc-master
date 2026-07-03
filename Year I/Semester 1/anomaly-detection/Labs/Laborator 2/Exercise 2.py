import matplotlib.pyplot as plt
from pyod.utils.data import generate_data_clusters
from pyod.models.knn import KNN
from sklearn.metrics import balanced_accuracy_score

X_train, X_test, y_train, y_test = generate_data_clusters(n_train=400, n_test=200, n_clusters=2, n_features=2, contamination=0.1)


n_neighbors_values = [1, 5, 10]
balanced_accuracies = []

fig, axs = plt.subplots(4, len(n_neighbors_values), figsize=(15, 12))
fig.suptitle("Effect of Different n_neighbors on KNN Outlier Detection")

for i, n_neighbors in enumerate(n_neighbors_values):
    knn = KNN(n_neighbors=n_neighbors)
    knn.fit(X_train)
    
    y_train_pred = knn.labels_ 
    y_test_pred = knn.predict(X_test)
    
    train_balanced_accuracy = balanced_accuracy_score(y_train, y_train_pred)
    test_balanced_accuracy = balanced_accuracy_score(y_test, y_test_pred)
    balanced_accuracies.append((n_neighbors, train_balanced_accuracy, test_balanced_accuracy))
    
    axs[0, i].scatter(X_train[:, 0], X_train[:, 1], c=y_train, cmap="coolwarm", edgecolor="k", s=20)
    axs[0, i].set_title(f"Train Ground Truth (n_neighbors={n_neighbors})")
    
    axs[1, i].scatter(X_train[:, 0], X_train[:, 1], c=y_train_pred, cmap="coolwarm", edgecolor="k", s=20)
    axs[1, i].set_title(f"Train Predicted (n_neighbors={n_neighbors})")
    
    axs[2, i].scatter(X_test[:, 0], X_test[:, 1], c=y_test, cmap="coolwarm", edgecolor="k", s=20)
    axs[2, i].set_title(f"Test Ground Truth (n_neighbors={n_neighbors})")
    
    axs[3, i].scatter(X_test[:, 0], X_test[:, 1], c=y_test_pred, cmap="coolwarm", edgecolor="k", s=20)
    axs[3, i].set_title(f"Test Predicted (n_neighbors={n_neighbors})")

plt.tight_layout(rect=[0, 0.03, 1, 0.95])
plt.show()

for n_neighbors, train_acc, test_acc in balanced_accuracies:
    print(f"n_neighbors = {n_neighbors}: Train Balanced Accuracy = {train_acc:.2f}, Test Balanced Accuracy = {test_acc:.2f}")

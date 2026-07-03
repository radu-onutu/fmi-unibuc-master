from pyod.utils.data import generate_data
import matplotlib.pyplot as plt
from pyod.models.knn import KNN
from sklearn.metrics import confusion_matrix, roc_curve


X_train, X_test, y_train, y_test = generate_data(n_train=400, n_test=100, n_features=2, contamination=0.1)

clf = KNN(contamination=0.1)
clf.fit(X_train)

X_pred_train = clf.predict(X_train)
X_pred_test = clf.predict(X_test)

CM_train = confusion_matrix(y_train, X_pred_train)
CM_test = confusion_matrix(y_test, X_pred_test)

TPR_train = CM_train[1, 1] / (CM_train[1, 1] + CM_train[1, 0])
TNR_train = CM_train[0, 0] / (CM_train[0, 0] + CM_train[0, 1])
BA_train = (TPR_train + TNR_train) / 2

TPR_test = CM_test[1, 1] / (CM_test[1, 1] + CM_test[1, 0])
TNR_test = CM_test[0, 0] / (CM_test[0, 0] + CM_test[0, 1])
BA_test = (TPR_test + TNR_test) / 2

fpr, tpr, thresholds = roc_curve(y_test, clf.decision_function(X_test))

plt.plot(fpr, tpr)
plt.xlabel('False Positive Rate')
plt.ylabel('True Positive Rate')
plt.show()
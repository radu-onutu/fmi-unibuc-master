import numpy as np
import pandas as pd
import matplotlib.pyplot as plt
from mpl_toolkits.mplot3d import Axes3D


def generate_2d_leverage_scores(a, b, c, n_points, mean, std, variance_type="regular"):
    x1 = np.random.uniform(0, 10, n_points)
    x2 = np.random.uniform(0, 10, n_points)
    
    epsilon = np.random.normal(mean, np.sqrt(std), n_points)
    y = a * x1 + b * x2 + c + epsilon

    if variance_type == "high_variance_x1":
        x1 += np.random.normal(0, np.sqrt(std) * 3, n_points)
    elif variance_type == "high_variance_x2":
        x2 += np.random.normal(0, np.sqrt(std) * 3, n_points)
    elif variance_type == "high_variance_y":
        y += np.random.normal(0, np.sqrt(std) * 3, n_points)
    elif variance_type == "high_variance_both":
        x1 += np.random.normal(0, np.sqrt(std) * 3, n_points)
        x2 += np.random.normal(0, np.sqrt(std) * 3, n_points)
        y += np.random.normal(0, np.sqrt(std) * 3, n_points)
    
    X = np.column_stack((np.ones(n_points), x1, x2))
    
    U, S, Vh = np.linalg.svd(X, full_matrices=False)
    H = U @ U.T
    leverage_scores = np.diag(H)
    
    return pd.DataFrame({"x1": x1, "x2": x2, "y": y, "type": variance_type, "leverage": leverage_scores})


a, b, c = 2, -1, 3
n_points = 100
mean = 0
std = 1

regular_data = generate_2d_leverage_scores(a, b, c, n_points, mean, std, "regular")
high_variance_x1_data = generate_2d_leverage_scores(a, b, c, n_points, mean, std, "high_variance_x1")
high_variance_x2_data = generate_2d_leverage_scores(a, b, c, n_points, mean, std, "high_variance_x2")
high_variance_y_data = generate_2d_leverage_scores(a, b, c, n_points, mean, std, "high_variance_y")
high_variance_both_data = generate_2d_leverage_scores(a, b, c, n_points, mean, std, "high_variance_both")


fig = plt.figure(figsize=(20, 12))
variances = ["Regular (Low Noise)", "High Variance on X1", "High Variance on X2", "High Variance on Y", "High Variance on Both X1 and X2"]
datasets = [regular_data, high_variance_x1_data, high_variance_x2_data, high_variance_y_data, high_variance_both_data]


for i, (data, title) in enumerate(zip(datasets, variances), 1):
    ax = fig.add_subplot(2, 3, i, projection='3d')
    ax.scatter(data['x1'], data['x2'], data['y'], c='blue', label='Data Points')
    
    max_leverage_idx = data['leverage'].idxmax()
    ax.scatter(data.loc[max_leverage_idx, 'x1'], data.loc[max_leverage_idx, 'x2'], data.loc[max_leverage_idx, 'y'], 
               c='red', s=100, edgecolor='black', label='Max Leverage Point')
    
    ax.set_title(title)
    ax.set_xlabel('x1')
    ax.set_ylabel('x2')
    ax.set_zlabel('y')
    ax.legend()

plt.tight_layout()
plt.show()
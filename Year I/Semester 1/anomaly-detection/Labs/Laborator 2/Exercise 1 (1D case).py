import numpy as np
import pandas as pd
import matplotlib.pyplot as plt


def generate_leverage_scores(a, b, n_points, mean, std, variance_type="regular"):
    x = np.random.uniform(0, 10, n_points)
    
    epsilon = np.random.normal(mean, np.sqrt(std), n_points)
    
    y = a * x + b + epsilon

    if variance_type == "high_variance_x":
        x += np.random.normal(0, np.sqrt(std) * 3, n_points)
    elif variance_type == "high_variance_y":
        y += np.random.normal(0, np.sqrt(std) * 3, n_points)
    elif variance_type == "high_variance_both":
        x += np.random.normal(0, np.sqrt(std) * 3, n_points)
        y += np.random.normal(0, np.sqrt(std) * 3, n_points)
    
    X = np.column_stack((np.ones(n_points), x))
    
    U, S, Vh = np.linalg.svd(X, full_matrices=False)
    H = U @ U.T
    leverage_scores = np.diag(H)
    
    return pd.DataFrame({"x": x, "y": y, "type": variance_type, "leverage": leverage_scores})


a, b = 2, 1
n_points = 100
mean = 0
std = 1

regular_data = generate_leverage_scores(a, b, n_points, mean, std, "regular")
high_variance_x_data = generate_leverage_scores(a, b, n_points, mean, std, "high_variance_x")
high_variance_y_data = generate_leverage_scores(a, b, n_points, mean, std, "high_variance_y")
high_variance_both_data = generate_leverage_scores(a, b, n_points, mean, std, "high_variance_both")

combined_data = pd.concat([regular_data, high_variance_x_data, high_variance_y_data, high_variance_both_data])


fig, axs = plt.subplots(2, 2, figsize=(14, 10))


def plot_variance_type_svd(ax, data, title):
    ax.scatter(data['x'], data['y'], c='blue', label='Data Points')
    
    max_leverage_idx = data['leverage'].idxmax()
    ax.scatter(data.loc[max_leverage_idx, 'x'], data.loc[max_leverage_idx, 'y'], 
               c='red', s=100, edgecolor='black', label='Max Leverage Point')
    
    ax.set_title(title)
    ax.set_xlabel('x')
    ax.set_ylabel('y')
    ax.legend()


regular_data_subset = combined_data[combined_data['type'] == "regular"]
high_variance_x_data_subset = combined_data[combined_data['type'] == "high_variance_x"]
high_variance_y_data_subset = combined_data[combined_data['type'] == "high_variance_y"]
high_variance_both_data_subset = combined_data[combined_data['type'] == "high_variance_both"]

plot_variance_type_svd(axs[0, 0], regular_data_subset, "Regular (Low Noise)")
plot_variance_type_svd(axs[0, 1], high_variance_x_data_subset, "High Variance on X")
plot_variance_type_svd(axs[1, 0], high_variance_y_data_subset, "High Variance on Y")
plot_variance_type_svd(axs[1, 1], high_variance_both_data_subset, "High Variance on Both X and Y")

plt.tight_layout()
plt.show()
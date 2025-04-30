import numpy as np


def loss_AC(true_x, x):
    true_x = np.array(true_x)
    x = np.array(x)

    return np.abs(true_x - x) / np.abs(true_x) * 100


def loss_PH(true_x, x):
    true_x = np.array(true_x)
    x = np.array(x)

    return np.abs(true_x - x)
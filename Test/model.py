import numpy as np


def model_fft(y, k):
    fft_wave = np.fft.fft(y)
    cpu_fft = np.array([np.real(fft_wave[k]), np.imag(fft_wave[k])], dtype=np.float64)
    return cpu_fft
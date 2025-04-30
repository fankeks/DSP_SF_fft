import pandas as pd
import numpy as np
import matplotlib.pyplot as plt
from scipy import interpolate
from tqdm import tqdm


def generate(path, fd, f, n, frame_length, fpga_fd, chanel_names):
    fact = 2 ** 12 - 1
    df = pd.read_csv(path, sep=';')
    time = df['Elapsed Time'].to_numpy()

    AC_f = []
    PH_f = []
    AC_max = []
    for names in chanel_names:
        AC_1_A = df[names[0]]
        AC_1_A = AC_1_A.to_numpy()
        AC_max.append(np.max(AC_1_A))
        AC_f.append(interpolate.interp1d(time, AC_1_A, kind='cubic'))

        PH_1_A = df[names[1]] + names[3]
        PH_1_A = PH_1_A.to_numpy()
        PH_f.append(interpolate.interp1d(time, PH_1_A, kind='cubic'))
    m = np.max(AC_max)

    time_frame = frame_length * 1 / fd * len(chanel_names) * n
    fpga_time_fd = time_frame if 1/fpga_fd < time_frame else 1/fpga_fd
    time_max = time_frame
    diap_PH = [0, 2 * np.pi]
    diap_A = [128, fact]
    while time_max <= time.max():
        t = np.arange(time_max - time_frame, time_max, 1/fd)
        AC_gen = np.random.uniform(diap_A[0], diap_A[1], 1)[0]
        PH1_start = np.random.uniform(diap_PH[0], diap_PH[1], 1)[0]

        # [chanels][n]
        t_chanels = [[] for _ in range(len(chanel_names))]
        # [chanels][n][generator / detector]
        y_chanels = [[] for _ in range(len(chanel_names))]
        for i in range(len(chanel_names) * n):
            ind = i % 4

            ts = t[i*frame_length:(i+1)*frame_length]
            AC = AC_f[ind](ts) / m * fact
            PH = PH_f[ind](ts)

            y_generator = (np.sin(2*np.pi *f * ts + PH1_start) + 1) / 2 * (fact)
            y_generator += (1/5) * fact * (np.sin(2 * np.pi * 2 * f * ts + PH1_start) + 1) / 2  # Second harmonic
            noise1 = np.random.normal(2,30,len(y_generator))
            y_generator_noise = np.abs(y_generator + noise1)
            y_generator = np.array(y_generator_noise, dtype=np.uint16)

            y = ((np.sin(2*np.pi *f * ts + PH1_start + PH / 180 * np.pi) + 1) / 2 * (AC))
            y += (1/5) * AC * (np.sin(2 * np.pi * 2 * f * ts + PH / 180 * np.pi) + 1) / 2  # Second harmonic
            noise2 = np.random.normal(2,30,len(y))
            y_noise = np.abs(y + noise2)
            y = np.array(y_noise, dtype=np.uint16)

            y_chanels[ind].append([y_generator, y])
            t_chanels[ind].append(ts)
        t_chanels = np.array(t_chanels)
        y_chanels = np.array(y_chanels)
        AC_true = [np.mean(AC_f[i](t)  / m * fact) for i in range(len(chanel_names))]
        PH_true = [np.mean(PH_f[i](t)) for i in range(len(chanel_names))]

        time_max += fpga_time_fd
        yield t_chanels, y_chanels, AC_true, PH_true, m


def main():
    path = '210924_ChDS.csv'
    fd = 2250000
    fpga_fd = 50
    f = 25000
    n = 2
    frame_length = 360
    chanels_name = [('AC 1 A', 'PH 1 A', 2.31324220, -157.3581),
                    ('AC 3 A', 'PH 3 A', 0.13839323, -162.5285),
                    ('AC 5 A', 'PH 5 A', 1.        , -161.1217),
                    ('AC 7 A', 'PH 7 A', 0.09392799, -164.2872)]
    
    for t_chanels, y_chanels, AC_true, PH_true, m in tqdm(generate(path, fd, f, n, frame_length, fpga_fd, chanels_name)):
        #print(AC_true)
        #print(PH_true)
        for chanel in range(len(chanels_name)):
            for i in range(n):
                #plt.plot(t_chanels[chanel][i], y_chanels[chanel][i][0])
                #plt.plot(t_chanels[chanel][i], y_chanels[chanel][i][1])
                pass
        #plt.show()


if __name__ == '__main__':
    main()
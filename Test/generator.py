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


def generate_n(numbers, fd, f, n, frame_length, chanels):
    t = np.linspace(0, frame_length * n * chanels * (1 / fd), frame_length * n * chanels, endpoint=False)
    diap_A = [128, 2**12-1]
    diap_PH = [0, 2 * np.pi]
    for _ in range(numbers):
        ys1 = []
        As = []
        PHs = []
        ys2 = []
        for _ in range(chanels):
            # y1
            PH1 = np.random.uniform(diap_PH[0], diap_PH[1], 1)[0]
            PH1_t = np.array([1] * len(t), dtype=np.uint16) * PH1

            A1 = np.random.uniform(diap_A[0], diap_A[1], 1)[0]
            A1_t = np.array([1] * len(t), dtype=np.uint16) * A1
            A2 = np.random.uniform(diap_A[0], diap_A[1], 1)[0]
            A2_t = np.array([1] * len(t), dtype=np.uint16) * A2
            As.append(A2)

            y1 = (np.sin(2*np.pi *f * t + PH1_t) + 1) / 2 * A1_t
            y1 += (1/5) * A1_t * (np.sin(2 * np.pi * 2 * f * t + PH1_t) + 1) / 2  # Second harmonic
            A1_g = np.max(y1) - np.min(y1)

            noise1 = np.random.normal(2,A1*0.02,len(y1))
            y_noise1 = np.abs(y1 + noise1)
            y1 = np.array(y_noise1, dtype=np.uint16)
            ys1.append(y1)
            #ys1.append([y1[i*frame_length:(i+1)*frame_length] for i in range(n)])

            # y2
            PH2 = np.random.uniform(1 / 180 * np.pi, 352 / 180 * np.pi, 1)[0]
            PH2_t = np.array([1] * len(t), dtype=np.uint16) * (PH1 + PH2)
            y2 = (np.sin(2*np.pi *f * t + PH2_t) + 1) / 2 * A2_t
            PHs.append(PH2 / np.pi * 180)
        
            y2 += (1/5) * A1_t * (np.sin(2 * np.pi * 2 * f * t + PH2_t) + 1) / 2  # Second harmonic

            noise2 = np.random.normal(2,A2*0.02,len(y2))
            y_noise2 = np.abs(y2 + noise2)
            y2 = np.array(y_noise2, dtype=np.uint16)
            ys2.append(y2)
            #ys2.append([y2[i*frame_length:(i+1)*frame_length] for i in range(n)])

        yield t, ys1, ys2, As, PHs


def generate_sins(numbers, fd, f, frame_length):
    t = np.linspace(0, frame_length * (1 / fd), frame_length, endpoint=False)
    diap_A = [80, 2**12-10]
    diap_PH = [0, 2 * np.pi]
    for _ in range(numbers):
        # y1
        PH1 = np.random.uniform(diap_PH[0], diap_PH[1], 1)[0]
        PH1_t = np.array([1] * len(t), dtype=np.uint16) * PH1

        A1 = np.random.uniform(diap_A[0], diap_A[1], 1)[0]
        A1_t = np.array([1] * len(t), dtype=np.uint16) * A1
        A2 = np.random.uniform(diap_A[0], diap_A[1], 1)[0]
        A2_t = np.array([1] * len(t), dtype=np.uint16) * A1

        y1 = (np.sin(2*np.pi *f * t + PH1_t) + 1) / 2 * A1_t
        y1 += (1/5) * A1_t * (np.sin(2 * np.pi * 2 * f * t + PH1_t) + 1) / 2  # Second harmonic
        A1_g = np.max(y1) - np.min(y1)

        noise1 = np.random.normal(2,A1*0.02,len(y1))
        y_noise1 = np.abs(y1 + noise1)
        y1 = np.array(y_noise1, dtype=np.uint16)

        # y2
        PH2 = np.random.uniform(0, 1.99 * np.pi, 1)[0]
        PH2_t = np.array([1] * len(t), dtype=np.uint16) * (PH1 + PH2)
        y2 = (np.sin(2*np.pi *f * t + PH2_t) + 1) / 2 * A2_t
    
        y2 += (1/5) * A1_t * (np.sin(2 * np.pi * 2 * f * t + PH2_t) + 1) / 2  # Second harmonic

        noise2 = np.random.normal(2,A1*0.02,len(y2))
        y_noise2 = np.abs(y2 + noise2)
        y2 = np.array(y_noise2, dtype=np.uint16)

        yield t, y1, y2, A1, PH1, A2, PH2



def main1():
    numbers = 100
    fd = 2250000
    f = 25000
    frame_length = 360
    g = generate_sins(numbers, fd, f, frame_length)
    t, y1, y2, AC1, PH1, AC2, PH2 = next(g)
    plt.plot(t * 1000, y1, label='Синусоида 1')
    plt.plot(t * 1000, y2, label='Синусоида 2')
    plt.xlabel("Время (мс)")
    plt.ylabel("Амплитуда (у.е.)")
    plt.grid()
    plt.legend()
    plt.show()


def main2():
    numbers = 100
    fd = 2250000
    f = 25000
    frame_length = 90
    n=8
    chanels = 4
    g = generate_n(numbers, fd, f, n, frame_length, chanels)
    t, ys1, ys2, As, PHs = next(g)
    ys1 = np.array(ys1)
    print(ys1.shape)
    plt.plot(t * 1000, ys1[0], label='Синусоида 1')
    plt.plot(t * 1000, ys2[0], label='Синусоида 2')
    plt.xlabel("Время (мс)")
    plt.ylabel("Амплитуда (у.е.)")
    plt.grid()
    plt.legend()
    plt.show()


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
    main2()
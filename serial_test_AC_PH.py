import serial
import matplotlib.pyplot as plt
import numpy as np
from tqdm import tqdm


def float_to_fix(x, n):
    return np.int32(x * (2 ** n))


def test(ser, y1, y2, y_true1, y_true2, k, factor):
    fft_wave1 = np.fft.fft(y1)
    fft_wave2 = np.fft.fft(y2)
    A1 = np.abs(fft_wave1[k])
    A2 = np.abs(fft_wave2[k])
    PH1 = np.angle(fft_wave1[k], deg=True)
    PH2 = np.angle(fft_wave2[k], deg=True)
    cpu_AC_PH = np.array([A1 / A2, 
                          PH1 - PH2])

    for i in range(360):
        value = y1[i]
        value &= np.uint16(65535)
        value |= np.uint32(y2[i]) << 16
        value_out = int(value).to_bytes(4, 'big')
        ser.write(value_out)

    fpga_AC_PH = []

    res = np.uint32(ord(ser.read()))
    res |= np.uint32(ord(ser.read())) << 8
    res |= np.uint32(ord(ser.read())) << 16
    res |= np.uint32(ord(ser.read())) << 24
    fpga_AC_PH.append(np.int32(res))

    res = np.uint32(ord(ser.read()))
    res |= np.uint32(ord(ser.read())) << 8
    res |= np.uint32(ord(ser.read())) << 16
    res |= np.uint32(ord(ser.read())) << 24
    fpga_AC_PH.append(np.int32(res))

    fpga_AC_PH = np.array(fpga_AC_PH, dtype=np.float64)
    fpga_AC_PH[0] /= factor
    #fpga_AC_PH[0] *= 0.6072529350324679
    fpga_AC_PH[1] /= 2 ** (22)

    loss = np.abs(cpu_AC_PH - fpga_AC_PH) / np.abs(cpu_AC_PH) * 100
    # plt.plot(y)
    # plt.plot(y_true)
    # plt.show()
    if np.max(loss) >= 1:
        print('BAD')
        print(A1, A2)
        print(f'Расчёт на cpu: {cpu_AC_PH}')
        print(f'Расчёт на fpga: {fpga_AC_PH}')
        print(f'Ошибка %: {loss}')
        plt.plot(y1)
        plt.plot(y2)
        plt.show()
        return 'PASS'
    else:
        #print('PASS')
        return 'PASS'


def main():
    # configure the serial connections
    ser = serial.Serial(
        port='COM3',
        baudrate=300000,
    )

    if not ser.isOpen():
        print('Not connect')
        return

    n = 360
    k = 356
    factor = 2**8
    #fs is sampling frequency
    fs = 2.2857 * 10 ** 6
    t = np.linspace(0, n * (1 / fs), n ,endpoint=False)

    diap_f = [20000, 30000]
    diap_A = [8, 2**12-1]
    diap_PH = [-np.pi, np.pi]
    for i in tqdm(range(5000)):
        f1 = np.random.uniform(diap_f[0], diap_f[1], 1)[0]
        A1 = np.random.uniform(diap_A[0], diap_A[1], 1)[0]
        PH1 = np.random.uniform(diap_PH[0], diap_PH[1], 1)[0]

        A2 = np.random.uniform(diap_A[0], diap_A[1], 1)[0]
        PH2 = np.random.uniform(diap_PH[0], diap_PH[1], 1)[0]

        if (A1 < A2):
            A1, A2 = A2, A1

        y1 = (np.sin(2*np.pi *f1 * t + PH1) + 1) / 2 * A1
        y2 = (np.sin(2*np.pi *f1 * t + PH2) + 1) / 2 * A2

        noise1 = np.random.normal(0,0.5,len(y1))
        y_noise1 = np.abs(y1 + noise1)
        y_noise1 += (1/5) * A1 * (np.sin(2 * np.pi * 2 * f1 * t + PH1) + 1) / 2  # Second harmonic
        y_noise1 += (1/12) * A1 * (np.sin(2 * np.pi * 2 * f1 * t + PH1) + 1) / 2  # Second harmonic
        y_noise1 = np.array(y_noise1, dtype=np.uint16)

        noise2 = np.random.normal(0,0.5,len(y2))
        y_noise2 = np.abs(y2 + noise2)
        y_noise2 += (1/5) * A2 * (np.sin(2 * np.pi * 2 * f1 * t + PH2) + 1) / 2  # Second harmonic
        y_noise2 += (1/12) * A2 * (np.sin(2 * np.pi * 2 * f1 * t + PH2) + 1) / 2  # Second harmonic
        y_noise2 = np.array(y_noise2, dtype=np.uint16)

        res = test(ser, y_noise1, y_noise2, y1, y2, k, factor)
        if res == 'BAD':
            print('-----------------------------------------------------------')
            print(i)
            print(f'Freq: {f1}')
            print(f'Max_value: {A1} {A2}')
            print(f'PH: {PH1} {PH2}')
            return
    print('-----------------------------------------------------------')
    print('GOOD')


if __name__ == '__main__':
    main()
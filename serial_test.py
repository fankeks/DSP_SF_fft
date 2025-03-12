import serial
import matplotlib.pyplot as plt
import numpy as np


def test(ser, y1, y2, y_true1, y_true2, k, factor):
    y = y2
    y_true = y_true2
    fft_wave = np.fft.fft(y)
    cpu_fft = np.array([np.real(fft_wave[k]), np.imag(fft_wave[k])], dtype=np.float64)

    for i in range(360):
        value = y1[i]
        value &= np.uint16(65535)
        value |= np.uint32(y2[i]) << 16
        value_out = int(value).to_bytes(4, 'big')
        ser.write(value_out)

    fpga_fft = []

    res = np.int32(ord(ser.read()))
    res |= np.int32(ord(ser.read())) << 8
    res |= np.int32(ord(ser.read())) << 16
    res |= np.int32(ord(ser.read())) << 24
    fpga_fft.append(res)

    res = np.int32(ord(ser.read()))
    res |= np.int32(ord(ser.read())) << 8
    res |= np.int32(ord(ser.read())) << 16
    res |= np.int32(ord(ser.read())) << 24
    fpga_fft.append(res)

    fpga_fft = np.array(fpga_fft, dtype=np.float64) / factor

    #print(f'Расчёт на cpu: {cpu_fft}')
    #print(f'Расчёт на fpga: {fpga_fft}')
    loss = np.abs(fpga_fft - cpu_fft) / np.abs(cpu_fft) * 100
    print(f'Ошибка %: {loss}')
    # plt.plot(y)
    # plt.plot(y_true)
    # plt.show()
    if np.max(loss) >= 1:
        print('BAD')
        plt.plot(y)
        plt.plot(y_true)
        plt.show()
        return 'BAD'
    else:
        #print('PASS')
        return 'PASS'


def main():
    # configure the serial connections
    ser = serial.Serial(
        port='COM51',
        baudrate=115200,
    )

    if not ser.isOpen():
        print('Not connect')
        return

    n = 360
    k = 356
    factor = 1000
    #fs is sampling frequency
    fs = 2.2857 * 10 ** 6
    t = np.linspace(0, n * (1 / fs), n ,endpoint=False)

    freqs = [25000, 26000, 24000, 20000]
    M = [2 ** 12 - 10, 200]
    for i in range(100):
        if i%20 == 0:
            print(f'{i}%')
            print()
        for f in freqs:
            for max_value in M:
                y1 = (np.sin(2*np.pi *f * t) + 1) / 2 * max_value
                y2 = (np.sin(2*np.pi *f * t + 1.5) + 1) / 2 * (max_value - 1)

                n_f1 = np.random.normal(0, 100, size=1)
                y_noise1 = (np.sin(2*np.pi *(f-n_f1) * t) + 1) / 2 * max_value
                noise1 = np.random.normal(0, 20, size=len(y1))
                y_noise1 = np.abs(y_noise1 + noise1)
                y_noise1 = np.array(y_noise1, dtype=np.int16)

                n_f2 = np.random.normal(0, 100, size=1)
                y_noise2 = (np.sin(2*np.pi *(f-n_f2) * t) + 1) / 2 * max_value
                noise2 = np.random.normal(0, 20, size=len(y1))
                y_noise2 = np.abs(y_noise2 + noise2)
                y_noise2 = np.array(y_noise2, dtype=np.int16)

                res = test(ser, y_noise1, y_noise2, y1, y2, k, factor)
                if res == 'BAD':
                    print('-----------------------------------------------------------')
                    print(f'Freq: {f}')
                    print(f'Max_value: {max_value}')
                    return
    print('-----------------------------------------------------------')
    print('GOOD')
    print(i)


if __name__ == '__main__':
    main()
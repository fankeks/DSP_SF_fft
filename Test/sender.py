import serial
import numpy as np
from generator import generate


def send(ser:serial.Serial, ys):
    for i in range(len(ys[0])):
        for chanel in range(len(ys)):
            for j in range(len(ys[0][0][0])):
                value = ys[chanel][i][0][j]
                value &= np.uint16(65535)
                value |= np.uint32(ys[chanel][i][1][j]) << 16
                value_out = int(value).to_bytes(4, 'big')
                ser.write(value_out)
    
    fpga_AC = []
    fpga_PH = []
    for i in range(len(ys)):
        res = np.uint32(ord(ser.read()))
        res |= np.uint32(ord(ser.read())) << 8
        res |= np.uint32(ord(ser.read())) << 16
        res |= np.uint32(ord(ser.read())) << 24
        fpga_AC.append(np.float64(np.int32(res)))

        res = np.uint32(ord(ser.read()))
        res |= np.uint32(ord(ser.read())) << 8
        res |= np.uint32(ord(ser.read())) << 16
        res |= np.uint32(ord(ser.read())) << 24
        fpga_PH.append(np.float64(np.int32(res)))

        fpga_AC[-1] /= 2 ** 10
        fpga_AC[-1] *= 0.6072529350324679
        fpga_AC[-1] /= (len(ys[0][0][0]) / 2)
        fpga_AC[-1] *= 2
        fpga_PH[-1] /= 2 ** (22)
    
    return fpga_AC, fpga_PH


def send_sig(ser:serial.Serial, ys):
    for i in range(len(ys[0])):
        value = ys[0][i]
        value &= np.uint16(65535)
        value |= np.uint32(ys[1][i]) << 16
        value_out = int(value).to_bytes(4, 'big')
        ser.write(value_out)


def read_data(ser:serial.Serial):
    data = []
    res = np.uint32(ord(ser.read()))
    res |= np.uint32(ord(ser.read())) << 8
    res |= np.uint32(ord(ser.read())) << 16
    res |= np.uint32(ord(ser.read())) << 24
    data.append(np.float64(np.int32(res)))

    res = np.uint32(ord(ser.read()))
    res |= np.uint32(ord(ser.read())) << 8
    res |= np.uint32(ord(ser.read())) << 16
    res |= np.uint32(ord(ser.read())) << 24
    data.append(np.float64(np.int32(res)))

    return data


def main():
    ser = serial.Serial(
        port='COM3',
        baudrate=300000,
    )

    if not ser.isOpen():
        print('Not connect')
        return
    
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
    
    ts, ys, AC_true, PH_true, _ = next(generate(path, fd, f, n, frame_length, fpga_fd, chanels_name))
    print(AC_true, PH_true)

    fpga_AC, fpga_PH = send(ser, ys)
    print(fpga_AC, fpga_PH)


if __name__ == '__main__':
    main()
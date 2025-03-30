import numpy as np
import matplotlib.pyplot as plt
import serial


def generate(chanels, frame_length, n):
    f = 25000
    fs = 2.25 * 10 ** 6
    t = np.linspace(0, frame_length * n * (1 / fs), frame_length * n ,endpoint=False)

    ys = []
    ACs = []
    PHs = []
    diap_A = [20, 2**12-1]
    diap_PH = [0, np.pi]
    for i in range(chanels):
        # y1
        PH1 = np.random.uniform(diap_PH[0], diap_PH[1], 1)[0]
        PH1_t = np.array([1] * len(t), dtype=np.uint16) * PH1

        A1 = np.random.uniform(diap_A[0], diap_A[1], 1)[0]
        A1_t = np.array([1] * len(t), dtype=np.uint16) * A1

        y1 = (np.sin(2*np.pi *f * t + PH1_t) + 1) / 2 * A1_t
        y1 += (1/5) * A1_t * (np.sin(2 * np.pi * 2 * f * t + PH1_t) + 1) / 2  # Second harmonic
        y1 += (1/12) * A1_t * (np.sin(2 * np.pi * 2 * f * t + PH1_t) + 1) / 2  # Second harmonic
        A1_g = np.max(y1) - np.min(y1)

        noise1 = np.random.normal(2,10,len(y1))
        y_noise1 = np.abs(y1 + noise1)
        y1 = np.array(y_noise1, dtype=np.uint16)

        # y2
        PH2 = np.random.uniform(diap_PH[0], diap_PH[1], 1)[0]
        PH2_t = np.array([1] * len(t), dtype=np.uint16) * (PH1 + PH2)
        y2 = (np.sin(2*np.pi *f * t + PH2_t) + 1) / 2 * A1_t
    
        y2 += (1/5) * A1_t * (np.sin(2 * np.pi * 2 * f * t + PH2_t) + 1) / 2  # Second harmonic
        y2 += (1/12) * A1_t * (np.sin(2 * np.pi * 2 * f * t + PH2_t) + 1) / 2  # Second harmonic
        ACs.append(np.max(y2) - np.min(y2))

        noise2 = np.random.normal(2,10,len(y2))
        y_noise2 = np.abs(y2 + noise2)
        y2 = np.array(y_noise2, dtype=np.uint16)


        PHs.append([PH1, PH1 + PH2])

        y1_s = [np.array(y1[i*frame_length:(i+1) * frame_length]) for i in range(n)]
        y2_s = [np.array(y2[i*frame_length:(i+1) * frame_length]) for i in range(n)]
        ys.append([y1_s, y2_s])
    # plt.plot(ys[0][0][0])
    # plt.plot(ys[0][1][0])
    # plt.show()
    return ys, ACs, PHs, t, fs, f


def send(ser, ys, chanels, frame_length, n):
    for i in range(n):
        for j in range(chanels):
            for k in range(frame_length):
                value = ys[j][0][i][k]
                value &= np.uint16(65535)
                value |= np.uint32(ys[j][1][i][k]) << 16
                value_out = int(value).to_bytes(4, 'big')
                ser.write(value_out)
    
    chanels_AC_PH = []
    for i in range(chanels):
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
        fpga_AC_PH[0] /= 2 ** 4
        fpga_AC_PH[0] *= 0.6072529350324679
        fpga_AC_PH[1] /= 2 ** (22)

        chanels_AC_PH.append(fpga_AC_PH)

    return chanels_AC_PH


def main():
    ser = serial.Serial(
        port='COM3',
        baudrate=300000,
    )

    if not ser.isOpen():
        print('Not connect')
        return

    chanels = 4
    frame_length = 360
    n = 4
    ys, ACs, PHs, t, fs, f = generate(chanels, frame_length, n)

    #print(ACs)
    #print(PHs)
    # for chanel in range(chanels):
    #     print(f"Канал {chanel}")
    #     print(ACs[chanel])
    #     print((-PHs[chanel][0] + PHs[chanel][1]) / np.pi * 180)
    # print()


    fpga_AC_PH = send(ser, ys, chanels, frame_length, n)
    #print(fpga_AC_PH)
    loss_AC_m = []
    loss_PH_m = []
    for chanel in range(chanels):
        print(f"Канал {chanel}")

        print("Амплитуда")
        fpga_AC = fpga_AC_PH[chanel][0] / (frame_length / 2) * 2 * 1.11
        true_AC = ACs[chanel]
        print(true_AC / fpga_AC)
        print(fpga_AC, true_AC)

        print("Фаза")
        fpga_PH = fpga_AC_PH[chanel][1] if fpga_AC_PH[chanel][1] > 0 else 360 + fpga_AC_PH[chanel][1]
        true_PH = (-PHs[chanel][0] + PHs[chanel][1]) / np.pi * 180
        print(true_PH - fpga_PH)
        print(fpga_PH, true_PH)
        print()

        loss_AC = np.abs(fpga_AC - true_AC) / true_AC
        loss_PH = np.abs(true_PH - fpga_PH)
        loss_AC_m.append(loss_AC)
        loss_PH_m.append(loss_PH)
    print(np.max(loss_AC_m), np.max(loss_PH_m))


if __name__ == '__main__':
    main()
import numpy as np
import matplotlib.pyplot as plt
import serial
from tqdm import tqdm


def generate_PH(f, t):
    diap_PH1 = [0, np.pi]
    diap_delta = [0, np.pi]

    PH1 = np.random.uniform(diap_PH1[0], diap_PH1[1], 1)[0]
    PH1_t = np.array([1] * len(t), dtype=np.uint16) * PH1
    noise1 = np.random.normal(-np.pi/30, np.pi/30,len(PH1_t))
    PH1_t = PH1_t + noise1

    delta_PH = np.random.uniform(diap_delta[0], diap_delta[1], 1)[0]
    PH2_t = np.array([1] * len(t), dtype=np.uint16) * (PH1 + delta_PH)
    noise2 = np.random.normal(-np.pi/30, np.pi/30,len(PH2_t))
    PH2_t = PH2_t + noise1

    return PH1_t, PH2_t, PH1, PH1+delta_PH


def generate_f(f, t):
    f1_t = np.array([1] * len(t), dtype=np.uint16) * f
    noise1 = np.random.normal(-100,100,len(f1_t))
    f1_t = f1_t + noise1

    f2_t = np.array([1] * len(t), dtype=np.uint16) * f
    noise2 = np.random.normal(-100,100,len(f1_t))
    f2_t = f2_t + noise1

    return f1_t, f2_t


def generate_A(f, t):
    diap_A = [20, 2**12-1]

    A1 = np.random.uniform(diap_A[0], diap_A[1], 1)[0]
    A2 = np.random.uniform(diap_A[0], diap_A[1], 1)[0]
    A1, A2 = (A1, A2) if A1 > A2 else (A2, A1)

    A1_t = np.array([1] * len(t), dtype=np.uint16) * A1
    noise1 = np.random.normal(2,10,len(A1_t))
    A1_t += noise1

    A2_t = np.array([1] * len(t), dtype=np.uint16) * A2
    noise2 = np.random.normal(2,10,len(A2_t))
    A2_t += noise2

    return A1_t, A2_t, A1, A2




def generate(chanels, frame_length, n):
    f = 25000
    fs = 2.25 * 10 ** 6
    t = np.linspace(0, frame_length * n * (1 / fs), frame_length * n ,endpoint=False)
    ts = []
    ys = []
    ACs = []
    PHs = []
    diap_A = [80, 2**12-1]
    diap_PH = [0, 2 * np.pi]
    for i in range(chanels):
        # y1
        PH1 = np.random.uniform(diap_PH[0], diap_PH[1], 1)[0]
        PH1_t = np.array([1] * len(t), dtype=np.uint16) * PH1

        A1 = np.random.uniform(diap_A[0], diap_A[1], 1)[0]
        A1_t = np.array([1] * len(t), dtype=np.uint16) * A1

        y1 = (np.sin(2*np.pi *f * t + PH1_t) + 1) / 2 * A1_t
        y1 += (1/5) * A1_t * (np.sin(2 * np.pi * 2 * f * t + PH1_t) + 1) / 2  # Second harmonic
        A1_g = np.max(y1) - np.min(y1)

        noise1 = np.random.normal(2,A1*0.02,len(y1))
        y_noise1 = np.abs(y1 + noise1)
        y1 = np.array(y_noise1, dtype=np.uint16)

        # y2
        PH2 = np.random.uniform(0, 1.99* np.pi, 1)[0]
        PH2_t = np.array([1] * len(t), dtype=np.uint16) * (PH1 + PH2)
        y2 = (np.sin(2*np.pi *f * t + PH2_t) + 1) / 2 * A1_t
    
        y2 += (1/5) * A1_t * (np.sin(2 * np.pi * 2 * f * t + PH2_t) + 1) / 2  # Second harmonic
        ACs.append(A1)

        noise2 = np.random.normal(2,A1*0.02,len(y2))
        y_noise2 = np.abs(y2 + noise2)
        y2 = np.array(y_noise2, dtype=np.uint16)


        PHs.append([PH1, PH1 + PH2])

        y1_s = [np.array(y1[i*frame_length:(i+1) * frame_length]) for i in range(n)]
        y2_s = [np.array(y2[i*frame_length:(i+1) * frame_length]) for i in range(n)]
        t_s = [np.array(t[i*frame_length:(i+1) * frame_length]) for i in range(n)]
        ys.append([y2_s, y1_s])
        ts.append(t_s)
    # plt.plot(ys[0][0][0])
    # plt.plot(ys[0][1][0])
    # plt.show()
    return ys, ACs, PHs, t, fs, f, ts


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

        # res = np.uint32(ord(ser.read()))
        # res |= np.uint32(ord(ser.read())) << 8
        # res |= np.uint32(ord(ser.read())) << 16
        # res |= np.uint32(ord(ser.read())) << 24
        # fpga_AC_PH.append(np.int32(res))

        # res = np.uint32(ord(ser.read()))
        # res |= np.uint32(ord(ser.read())) << 8
        # res |= np.uint32(ord(ser.read())) << 16
        # res |= np.uint32(ord(ser.read())) << 24
        # fpga_AC_PH.append(np.int32(res))

        fpga_AC_PH = np.array(fpga_AC_PH, dtype=np.float64)
        fpga_AC_PH[0] /= 2 ** 8
        fpga_AC_PH[0] *= 0.6072529350324679
        fpga_AC_PH[1] /= 2 ** (22)
        #fpga_AC_PH[2] /= 2 ** (22)
        #fpga_AC_PH[3] /= 2 ** (22)

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

    loss_AC_m = []
    loss_PH_m = []
    for _ in tqdm(range(1)):
        chanels = 4
        frame_length = 360
        n = 2
        ys, ACs, PHs, t, fs, f, ts = generate(chanels, frame_length, n)

        fpga_AC_PH = send(ser, ys, chanels, frame_length, n)
        for chanel in range(chanels):
            fpga_AC = fpga_AC_PH[chanel][0] / (frame_length / 2) * 2# * 1.05
            true_AC = ACs[chanel]
            #print(true_AC / fpga_AC)
            #print(fpga_AC, true_AC)

            #print("Фаза")
            fpga_PH = fpga_AC_PH[chanel][1]# if fpga_AC_PH[chanel][1] > 0 else 360 + fpga_AC_PH[chanel][1]
            #fpga_PH = fpga_PH if np.abs(fpga_PH) >= 0.7 else 0
            #fpga_PH = fpga_PH if np.abs(fpga_PH) <= 359.3 else 360 - fpga_PH
            true_PH = (-PHs[chanel][0] + PHs[chanel][1]) / np.pi * 180
            #print(true_PH - fpga_PH)
            #print(fpga_PH, true_PH)
            #print()

            loss_AC = np.abs(fpga_AC - true_AC) / true_AC * 100
            loss_PH = np.abs(true_PH - fpga_PH)
            if loss_AC >= 1.5 or loss_PH >= 1:
                print()
                print(loss_AC, loss_PH)
                print(chanel)
                print("delta")
                print(fpga_AC, true_AC)
                print(true_AC / fpga_AC)
                print("fpga")
                print(fpga_AC_PH[chanel])
                print("cpu")
                print(PHs[chanel][0]/np.pi * 180, PHs[chanel][1] / np.pi * 180)
                print("fft")
                print(np.abs(np.fft.fft(ys[chanel][1][0]))[356] / (frame_length / 2) * 2)
                # print(np.angle(np.fft.fft(ys[chanel][0][0]), deg=True)[356])
                # print(np.angle(np.fft.fft(ys[chanel][1][0]), deg=True)[356])
                # print(np.angle(np.fft.fft(ys[chanel][0][0]), deg=True)[356] - np.angle(np.fft.fft(ys[chanel][1][0]), deg=True)[356])
                # print(np.angle(np.fft.fft(ys[chanel][0][0]), deg=True)[356] - np.angle(np.fft.fft(ys[chanel][1][0]), deg=True)[356] + 360)
                #break
                print()
            loss_AC_m.append(loss_AC)
            loss_PH_m.append(loss_PH)
    print(np.max(loss_AC_m), np.max(loss_PH_m))


if __name__ == '__main__':
    main()
    # chanels = 4
    # frame_length = 360
    # n = 2
    # ys, ACs, PHs, t, fs, f, ts = generate(chanels, frame_length, n)

    # plt.ylabel("Амплитуда, у.е.")
    # plt.xlabel("Время, с")
    # plt.grid()
    # plt.plot(ts[0][0], ys[0][0][0])
    # plt.plot(ts[0][0], ys[0][1][0])
    # plt.show()

    # PH1_t, PH2_t, PH1, PH2 = generate_PH(f, t)
    # f1_t, f2_t = generate_f(f, t)
    # A1_t, A2_t, A1, A2 = generate_A(f, t)

    # y1 = (np.sin(2*np.pi *f1_t * t + PH1_t) + 1) / 2 * A1_t
    # y2 = (np.sin(2*np.pi *f2_t * t + PH2_t) + 1) / 2 * A2_t

    # plt.plot(t, y1)
    # plt.plot(t, y2)
    # plt.show()

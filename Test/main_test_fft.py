from generator import generate
from generator import generate_sins
from generator import generate_n
from sender import send
from sender import send_sig
from sender import read_data
from model import model_fft
from metrics import *
import pandas as pd
import locale
locale.setlocale(locale.LC_ALL, "ru_RU")

from tqdm import tqdm
import serial
import matplotlib.pyplot as plt
import seaborn as sns
from scipy.stats import shapiro


def main():
    ser = serial.Serial(
        port='COM4',
        baudrate=600000,
    )

    if not ser.isOpen():
        print('Not connect')
        return
    
    fd = 2250000
    fpga_fd = 10
    f = 25000
    numbers = 5000
    frame_length = 90

    columns = []
    columns.append(f"true data1")
    columns.append(f"fpga data1")
    columns.append(f"loss data1")
    columns.append(f"true data2")
    columns.append(f"fpga data2")
    columns.append(f"loss data2")

    columns.append(f"AC1")
    columns.append(f"PH1")
    columns.append(f"AC2")
    columns.append(f"PH2")

    log_df = pd.DataFrame(columns=columns)
    log_df.to_csv("log.csv", sep=";", index=False)
    
    i = 0
    fpga_AC_graph = []
    fpga_PH_graph = []
    max_loss_AC = -1
    max_loss_PH = -1
    for t, y1, y2, AC1, PH1, AC2, PH2 in tqdm(generate_sins(numbers, fd, f, frame_length)):
        true_data = model_fft(y1, 89)
        send_sig(ser, [y1, y2])
        data_fpga = read_data(ser)
        data_fpga[0] = data_fpga[0] / 2**10 * 0.6072529350324679  / (frame_length / 2) * 2
        data_fpga[1] = data_fpga[1] / 2**22
        #print(AC1, AC2)
        #print(data_fpga)
        # print(model_fft(y1, 89))
        # print(model_fft(y2, 89))
        
        l_AC = loss_AC(AC1, data_fpga[0])
        #l_PH = loss_PH(PH_true, fpga_PH)
        data = []
        data.append(AC1)
        data.append(data_fpga[0])
        data.append(l_AC)

        true_ph = (PH2) / np.pi * 180
        l_PH = loss_PH(true_ph, data_fpga[1])
        data.append(true_ph)
        data.append(data_fpga[1])
        data.append(l_PH)

        data.append(AC1)
        data.append(PH1)
        data.append(AC2)
        data.append(PH2)
        #print(data)
        log_df = pd.DataFrame([data], columns=columns)
        log_df.to_csv("log.csv", sep=";", index=False, mode='a', header=False)


def main2():
    ser = serial.Serial(
        port='COM4',
        baudrate=600000,
    )

    if not ser.isOpen():
        print('Not connect')
        return
    
    fd = 2250000
    fpga_fd = 10
    f = 25000
    numbers = 5000
    frame_length = 90
    n = 8
    chanels = 4

    columns = []
    columns.append(f"true AC1")
    columns.append(f"fpga AC1")
    columns.append(f"loss AC1")
    columns.append(f"true PH1")
    columns.append(f"fpga PH1")
    columns.append(f"loss PH1")

    columns.append(f"true AC2")
    columns.append(f"fpga AC2")
    columns.append(f"loss AC2")
    columns.append(f"true PH2")
    columns.append(f"fpga PH2")
    columns.append(f"loss PH2")

    columns.append(f"true AC3")
    columns.append(f"fpga AC3")
    columns.append(f"loss AC3")
    columns.append(f"true PH3")
    columns.append(f"fpga PH3")
    columns.append(f"loss PH3")

    columns.append(f"true AC4")
    columns.append(f"fpga AC4")
    columns.append(f"loss AC4")
    columns.append(f"true PH4")
    columns.append(f"fpga PH4")
    columns.append(f"loss PH4")

    log_df = pd.DataFrame(columns=columns)
    log_df.to_csv("log.csv", sep=";", index=False)
    
    for t, ys1, ys2, As, PHs in tqdm(generate_n(numbers, fd, f, n, frame_length, chanels)):
        j = 0
        for i in range(0, len(t), frame_length):
            ind = j % chanels
            y1 = ys1[ind][i:i+frame_length]
            y2 = ys2[ind][i:i+frame_length]
            #print(ind)
            send_sig(ser, [y1, y2])
            j += 1
        
        data = []
        for i in range(chanels):
            data_fpga = read_data(ser)
            data_fpga[0] = data_fpga[0] / 2**10 * 0.6072529350324679  / (frame_length / 2) * 2
            data_fpga[1] = data_fpga[1] / 2**22
            
            l_AC = (As[i] - data_fpga[0]) / As[i]
            data.append(As[i])
            data.append(data_fpga[0])
            data.append(l_AC)

            true_ph = PHs[i]
            l_PH = (true_ph - data_fpga[1])
            data.append(true_ph)
            data.append(data_fpga[1])
            data.append(l_PH)
            if np.abs(l_AC) > 1 or np.abs(l_PH) > 1:
                print(l_AC, l_PH)

        log_df = pd.DataFrame([data], columns=columns)
        log_df.to_csv("log.csv", sep=";", index=False, mode='a', header=False)


def result_fft():
    df = pd.read_csv('C:\\Users\\Hp\\Desktop\\ITSAR\FPGA\\log.csv', sep=';')
    #data = (df['true data1'] - df['fpga data1']) / df['true data1'] * 100
    data = df['loss PH4']
    #data_test = [1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13]
    statistic, pvalue = shapiro(data)
    print("statistic = %.3f, p = %.3f\n" % (statistic, pvalue))
    if pvalue > 0.05:
        print("Probably Gaussian")
    else:
        print("Probably not Gaussian")


    mean = np.mean(data)
    median = np.median(data)
    std_dev = 3*np.std(data)

    print("Среднее", mean)
    print("3 СКО", std_dev)
    print('Максимальное', np.max(data))
    print(df.loc[np.argmax(np.abs(data))])

    plt.hist(data, bins=50, color='skyblue', edgecolor='black')
    plt.axvline(mean, color='r', linestyle='dashed', linewidth=1, label=f'Среднее: {mean:.2f}')
    #plt.axvline(median, color='g', linestyle='dashed', linewidth=1, label=f'Медиана: {median:.2f}')
    plt.axvline(mean + std_dev, color='y', linestyle='dashed', linewidth=1, label=f'Ст. отклонение: {std_dev:.2f}')
    plt.axvline(mean - std_dev, color='y', linestyle='dashed', linewidth=1)
    plt.grid(True)
    #plt.title('Настроенная гистограмма с дополнительными элементами')
    plt.xlabel('Ошибка')
    plt.ylabel('Количество элементов')
    #plt.legend()
    plt.show()


if __name__ == '__main__':
    #main2()
    result_fft()
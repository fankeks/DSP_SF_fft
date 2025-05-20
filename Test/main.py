from generator import generate
from generator import generate_sins
from sender import send
from metrics import *
import pandas as pd
import locale
locale.setlocale(locale.LC_ALL, "ru_RU")

from tqdm import tqdm
import serial
import matplotlib.pyplot as plt


def main():
    ser = serial.Serial(
        port='COM4',
        baudrate=600000,
    )

    if not ser.isOpen():
        print('Not connect')
        return
    
    path = '210924_ChDS.csv'
    fd = 2250000
    fpga_fd = 10
    f = 25000
    n = 8
    frame_length = 90
    chanels_name = [('AC 1 A', 'PH 1 A', 2.31324220, -157.3581),
                    ('AC 3 A', 'PH 3 A', 0.13839323, -162.5285),
                    ('AC 5 A', 'PH 5 A', 1.        , -161.1217),
                    ('AC 7 A', 'PH 7 A', 0.09392799, -164.2872)]

    columns = ["ts"]
    for name in chanels_name:
        columns.append(f"true {name[0]}")
        columns.append(f"fpga {name[0]}")
        columns.append(f"loss {name[0]}")

        columns.append(f"true {name[1]}")
        columns.append(f"fpga {name[1]}")
        columns.append(f"loss {name[1]}")
    log_df = pd.DataFrame(columns=columns)
    log_df.to_csv("log.csv", sep=";", index=False)
    
    i = 0
    fpga_AC_graph = []
    fpga_PH_graph = []
    max_loss_AC = -1
    max_loss_PH = -1
    for ts, ys, AC_true, PH_true, m in tqdm(generate(path, fd, f, n, frame_length, fpga_fd, chanels_name)):
        fpga_AC, fpga_PH = send(ser, ys)
        fpga_AC_graph.append(fpga_AC)
        fpga_PH_graph.append(fpga_PH)
        
        l_AC = loss_AC(AC_true, fpga_AC)
        l_PH = loss_PH(PH_true, fpga_PH)

        #data = [locale.str(i/fpga_fd)]
        data = [(i/fpga_fd)]
        for ind in range(len(chanels_name)):
            # data.append(locale.str(AC_true[ind]))
            # data.append(locale.str(fpga_AC[ind]))
            # data.append(locale.str(l_AC[ind]))

            # data.append(locale.str(PH_true[ind]))
            # data.append(locale.str(fpga_PH[ind]))
            # data.append(locale.str(l_PH[ind]))

            data.append(AC_true[ind])
            data.append(fpga_AC[ind])
            data.append(l_AC[ind])

            data.append(PH_true[ind])
            data.append(fpga_PH[ind])
            data.append(l_PH[ind])
        #print(data)
        log_df = pd.DataFrame([data], columns=columns)
        log_df.to_csv("log.csv", sep=";", index=False, mode='a', header=False)

        if np.max(l_AC) >= max_loss_AC:
            max_loss_AC = np.max(l_AC)
        
        if np.max(l_PH) >= max_loss_PH:
            max_loss_PH = np.max(l_PH)

        if np.max(l_AC) >= 1 or np.max(l_PH) >= 1:
            print(np.max(l_AC), np.max(l_PH))
            #break
        # if (i%100 == 99):
        #     break
        i+=1
    
    print()
    print(max_loss_AC)
    print(max_loss_PH)

    fpga_AC_graph = np.array(fpga_AC_graph) * m / (2**12-1)
    t = np.array(range(len(fpga_AC_graph))) * 1 / fpga_fd
    plt.plot(t, fpga_AC_graph[:,0])
    plt.show()


def test():
    path = '210924_ChDS.csv'
    fd = 2250000
    fpga_fd = 10
    f = 25000
    n = 8
    frame_length = 360
    chanels_name = [('AC 1 A', 'PH 1 A', 2.31324220, -157.3581),
                    ('AC 3 A', 'PH 3 A', 0.13839323, -162.5285),
                    ('AC 5 A', 'PH 5 A', 1.        , -161.1217),
                    ('AC 7 A', 'PH 7 A', 0.09392799, -164.2872)]

    columns = ["ts"]
    for name in chanels_name:
        columns.append(f"true {name[0]}")
        columns.append(f"fpga {name[0]}")
        columns.append(f"loss {name[0]}")

        columns.append(f"true {name[1]}")
        columns.append(f"fpga {name[1]}")
        columns.append(f"loss {name[1]}")
    log_df = pd.DataFrame(columns=columns)
    log_df.to_csv("log.csv", sep=";", index=False)

    i = 0
    fpga_AC_graph = []
    fpga_PH_graph = []
    max_loss_AC = -1
    max_loss_PH = -1
    for ts, ys, AC_true, PH_true, m in tqdm(generate(path, fd, f, n, frame_length, fpga_fd, chanels_name)):
        #fpga_AC, fpga_PH = send(ser, ys)
        fpga_AC = [ind/fpga_fd for ind in range(len(chanels_name))]
        fpga_PH = [ind/fpga_fd for ind in range(len(chanels_name))]
        fpga_AC_graph.append(fpga_AC)
        fpga_PH_graph.append(fpga_PH)
        
        l_AC = loss_AC(AC_true, fpga_AC)
        l_PH = loss_PH(PH_true, fpga_PH)

        #data = [locale.str(i/fpga_fd)]
        data = [(i/fpga_fd)]
        for ind in range(len(chanels_name)):
            # data.append(locale.str(AC_true[ind]))
            # data.append(locale.str(fpga_AC[ind]))
            # data.append(locale.str(l_AC[ind]))

            # data.append(locale.str(PH_true[ind]))
            # data.append(locale.str(fpga_PH[ind]))
            # data.append(locale.str(l_PH[ind]))

            data.append(AC_true[ind])
            data.append(fpga_AC[ind])
            data.append(l_AC[ind])

            data.append(PH_true[ind])
            data.append(fpga_PH[ind])
            data.append(l_PH[ind])
        #print(data)
        log_df = pd.DataFrame([data], columns=columns)
        log_df.to_csv("log.csv", sep=";", index=False, mode='a', header=False)

        if np.max(l_AC) >= max_loss_AC:
            max_loss_AC = np.max(l_AC)
        
        if np.max(l_PH) >= max_loss_PH:
            max_loss_PH = np.max(l_PH)

        if np.max(l_AC) >= 1 or np.max(l_PH) >= 1:
            pass
            #print(np.max(l_AC), np.max(l_PH))
            #break
        # if (i%100 == 99):
        #     break
        i+=1
    
    print()
    print(max_loss_AC)
    print(max_loss_PH)

    fpga_AC_graph = np.array(fpga_AC_graph) * m / (2**12-1)
    t = np.array(range(len(fpga_AC_graph))) * 1 / fpga_fd
    plt.plot(t, fpga_AC_graph[:,0])
    plt.show()

if __name__ == '__main__':
    main()
    # test()
    # df = pd.read_csv('log.csv', sep=';')
    # print(np.mean(df['ts']))
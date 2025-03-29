import numpy as np


def fix_to_float(x):
    return x / (2 ** 16)

def float_to_fix(x, n):
    return np.int32(x * (2 ** n))

def dec_to_pol(x, y):
    ph = 0
    if ((x >= 0) & (y >= 0)):
        x_cor = x + y
        y_cor = -x + y
        ph = (45)
    elif ((x < 0) & (y >= 0)):
        x_cor = -x + y
        y_cor = -x + -y
        ph = (135)
    elif ((x < 0) & (y < 0)):
        x_cor = -x - y
        y_cor = x - y
        ph = (225 - 360)
    elif ((x >= 0) & (y < 0)):
        x_cor = x - y
        y_cor = x + y
        ph = (315 - 360)

    N = 21
    x_iter     = [x_cor for i in range(N+1)]
    y_iter     = [y_cor for i in range(N+1)]
    phase_iter = [ph for i in range(N+1)]

    table = [(np.arctan(2**-(i+1)) / np.pi * 180) for i in range(N)]
    print(table)
    weights = [str(hex(np.int32(float_to_fix(table[i], 22))))[2:] for i in range(len(table))]
    with open("weigths\\angle.txt", "w") as file:
        for a in weights:
            file.write(f"{a}\n")

    for i in range(N):
        if(y_iter[i] >= 0):
            x_iter[i+1] = x_iter[i] + (y_iter[i] / (2 ** (i+1)))
            y_iter[i+1] = y_iter[i] - (x_iter[i] / (2 ** (i+1)))
            phase_iter[i+1] = phase_iter[i] + table[i]
            # print('+')
            # print(i, hex(np.uint32(float_to_fix(x_iter[i], 16))), hex(np.uint32(float_to_fix(y_iter[i], 16))))
            # print(i, hex(np.uint32(float_to_fix(x_iter[i] / (2 ** (i+1)), 16))), hex(np.uint32(float_to_fix(y_iter[i] / (2 ** (i+1)), 16))))
        else:
            x_iter[i+1] = x_iter[i] - (y_iter[i] / (2 ** (i+1)))
            y_iter[i+1] = y_iter[i] + (x_iter[i] / (2 ** (i+1)))
            phase_iter[i+1] = phase_iter[i] - table[i]
            # print('-')
            # print(i, hex(np.uint32(float_to_fix(x_iter[i], 16))), hex(np.uint32(float_to_fix(y_iter[i], 16))))
            # print(i, hex(np.uint32(float_to_fix(x_iter[i] / (2 ** (i+1)), 16))), hex(np.uint32(float_to_fix(y_iter[i] / (2 ** (i+1)), 16))))
    #print(phase_iter)
    return x_iter[-1], phase_iter[-1]


if __name__ == '__main__':
    x = -1
    y = -1

    print(45)
    print(str(hex(   float_to_fix(45 ,     22)))[2:])
    print(135)
    val = np.uint32(float_to_fix(135 ,     22))
    print(str(hex(val))[2:])
    print(225)
    val = np.uint32(float_to_fix(225-360 , 22))
    print(str(hex(val))[2:])
    print(315)
    val = np.uint32(float_to_fix(315-360, 22))
    print(str(hex(val))[2:])
    mag, ph = dec_to_pol(x, y)
    print(np.sqrt(x**2 + y**2) / mag)
    print(mag * 0.6072529350324679, ph)
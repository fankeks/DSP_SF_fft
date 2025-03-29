import numpy as np
import os


def my_fft(x, N, k, factor):
    w_re = np.cos(np.pi * 2 * k / N) * factor
    print(w_re)
    w_im = np.sin(2 * np.pi * k / N) * factor
    print(w_im)

    s = [x[0] * factor, 0, 0]
    for i in range(1, N):
        s[2] = s[1]
        s[1] = s[0]
        s[0] = w_re * 2 * s[1] / factor - s[2] + x[i] * factor
        #print(s)
    re = s[0] * w_re / factor - s[1]
    im = s[0] * w_im / factor
    return re, im


n = 360
k = 356
factor = 2**16

f = 25000
#fs is sampling frequency
fs = 2.2857 * 10 ** 6
t = np.linspace(0, n * (1 / fs), n ,endpoint=False)
y = (np.sin(2*np.pi *f * t) + 1) / 2 * (2 ** 12-1)
#print(y)
y = np.array(y, dtype=np.int16)
fft_wave = np.fft.fft(y)

#k = np.argmax(np.abs(fft_wave))
print(k)

w_re = []
w_im = []


for i in range(n):
    w_re.append(round(np.cos(2 * np.pi * k * i / (n)) * factor))
    w_im.append(round(-np.sin(2 * np.pi * k * i / (n)) * factor))

re_x = 0
for i in range(n):
    re_x += int(y[i]) * w_re[i]
im_x = 0
for i in range(n):
    im_x += int(y[i]) * w_im[i]


print(re_x, im_x)
print(fft_wave[k] * factor)
print(f'true: {fft_wave[k]}')
print(my_fft(y, n, k, factor))

#val = -100
#print(str(bin(val if val>0 else val+(1<<32)))[2:])

# for i in range(n):
#     print("@(posedge clk);")
#     if int(y[i]*1000) < 0:
#         print(f"x1       <= -'d{abs(int(y[i]))};")
#     else:
#         print(f"x1       <= 'd{abs(int(y[i]))};")
import numpy as np
import os
import matplotlib.pyplot as plt


n = 90
k = 356
factor = 2 ** 14

f = 25000
#fs is sampling frequency
fs = 2.25 * 10 ** 6
t = np.linspace(0, n * (1 / fs), n ,endpoint=False)
y = (np.sin(2*np.pi *f * t) + 1) / 2 * (2 ** 12-1)
#print(y)
y = np.array(y, dtype=np.int16)
fft_wave = np.fft.fft(y)

plt.plot(np.abs(fft_wave[len(fft_wave)//2:]))
plt.show()
k = np.argmax(np.abs(fft_wave[len(fft_wave)//2:])) + len(fft_wave)//2
print(k, f/fs*n)

w_re = []
w_im = []


for i in range(n):
    w_re.append(round(np.cos(2 * np.pi * k * i / (n)) * factor))
    w_im.append(round(-np.sin(2 * np.pi * k * i / (n)) * factor))

print(np.max(w_re), np.max(w_im))

with open(os.path.join("weigths", "w_re.txt"), "w") as file:
    for i in range(n):
        val = w_re[i]
        val = str(bin(val if val>0 else val+(1<<32)))[2:]
        file.write(f'{val}\n')


with open(os.path.join("weigths", "w_im.txt"), "w") as file:
    for i in range(n):
        val = w_im[i]
        val = str(bin(val if val>0 else val+(1<<32)))[2:]
        file.write(f'{val}\n')

re_x = 0
for i in range(n):
    re_x += int(y[i]) * w_re[i]
im_x = 0
for i in range(n):
    im_x += int(y[i]) * w_im[i]


print(re_x, im_x)
print(fft_wave[k] * factor)

#val = -100
#print(str(bin(val if val>0 else val+(1<<32)))[2:])

# for i in range(n):
#     print("@(posedge clk);")
#     if int(y[i]*1000) < 0:
#         print(f"x1       <= -'d{abs(int(y[i]))};")
#     else:
#         print(f"x1       <= 'd{abs(int(y[i]))};")
import serial
import time
import numpy as np

# configure the serial connections
ser = serial.Serial(
    port='COM51',
    baudrate=115200,
)
print(ser.isOpen())

n = 360
k = 356
factor = 1000

f = 25000
#fs is sampling frequency
fs = 2.2857 * 10 ** 6
t = np.linspace(0, n * (1 / fs), n ,endpoint=False)
y = (np.sin(2*np.pi *f * t) + 1) / 2 * (2 ** 12-1)
#print(y)
y = np.array(y, dtype=np.int16)
fft_wave = np.fft.fft(y)

print(fft_wave[k] * factor)

for i in range(360):
    value_out = int(y[i]).to_bytes(4, 'big')
    #print(value_out)
    ser.write(value_out)
    #ser.write(value_out)
#time.sleep(0.1)

#print(int(y[359]).to_bytes(4, 'big'))
# print('out')
# print(int(y[359]).to_bytes(4, 'big'))
# print(y[359])

# print(ser.read())
# print(ser.read())

# print(ser.read())
# print(ser.read())

res = np.int32(ord(ser.read()))
res |= np.int32(ord(ser.read())) << 8
res |= np.int32(ord(ser.read())) << 16
res |= np.int32(ord(ser.read())) << 24
print(res)

res = np.int32(ord(ser.read()))
res |= np.int32(ord(ser.read())) << 8
res |= np.int32(ord(ser.read())) << 16
res |= np.int32(ord(ser.read())) << 24
print(res)
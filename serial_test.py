import serial
import time

# configure the serial connections
ser = serial.Serial(
    port='COM51',
    baudrate=115200,
)
print(ser.isOpen())

value = 1024
values = value.to_bytes(4, 'big')
print(values)

ser.write(values)
time.sleep(0.1)
print(ser.read())
print(ser.read())
print(ser.read())
print(ser.read())

print(ser.read())
print(ser.read())
print(ser.read())
print(ser.read())
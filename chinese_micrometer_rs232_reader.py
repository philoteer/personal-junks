#!/usr/bin/env python3

#ref: https://wikidocs.net/188633
import serial

PORT_NAME = "/dev/ttyUSB0"
SAVE_PATH = "out.txt"

ser = serial.Serial(
	port = PORT_NAME, 
	baudrate=9600, 
	parity='N',
	stopbits=1,
	bytesize=8,
	timeout=8,
	xonxoff=1
	)

ser.isOpen()

f_out = open(SAVE_PATH, 'w')

num_buf=""

header_cnt = 3

while(True):
	input_data = ser.read(1)
	if (int.from_bytes(input_data)) == 13:
		if(header_cnt > 0):
			header_cnt -= 1
			num_buf = ""
		else:
			print(num_buf[1:])
			f_out.write(f"{num_buf[1]}{num_buf[3:]}\n")
			f_out.flush()
			num_buf = ""
	else:
		num_buf = f"{num_buf}{input_data.decode('ascii')}"


f_out.close()

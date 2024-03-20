#!/usr/bin/env python3

#ref: https://wikidocs.net/188633
import serial
import threading
import time

PORT_NAMES = {"one":"/dev/ttyUSB0","two":"/dev/ttyUSB1"}
SAVE_PATHS = {"one":"out1.txt", "two":"out2.txt"}

ser = {}
f_out = {}
num_buf = {}
header_cnt = {}
start_time = time.time()

for PORT_NAME in PORT_NAMES:
	ser[PORT_NAME] = serial.Serial(
		port = PORT_NAMES[PORT_NAME], 
		baudrate=9600, 
		parity='N',
		stopbits=1,
		bytesize=8,
		timeout=8,
		xonxoff=1
		)

	ser[PORT_NAME].isOpen()

	f_out[PORT_NAME] = open(SAVE_PATHS[PORT_NAME], 'w')

	num_buf[PORT_NAME]=""

	header_cnt[PORT_NAME] = 3

def rx_thread(PORT_NAME):
	while(True):
		input_data = ser[PORT_NAME].read(1)
		if (int.from_bytes(input_data)) == 13:
			if(header_cnt[PORT_NAME] > 0):
				header_cnt[PORT_NAME] -= 1
				num_buf[PORT_NAME] = ""
			else:
				print(f"{PORT_NAME}: {num_buf[PORT_NAME][1:]}")
				f_out[PORT_NAME].write(f"{time.time()-start_time},{num_buf[PORT_NAME][1]}{num_buf[PORT_NAME][3:]}\n")
				f_out[PORT_NAME].flush()
				num_buf[PORT_NAME] = ""
		else:
			try:
				num_buf[PORT_NAME] = f"{num_buf[PORT_NAME]}{input_data.decode('ascii')}"
			except:
				pass


threads = {}
for PORT_NAME in PORT_NAMES:
	threads[PORT_NAME] = (threading.Thread(target=rx_thread, args=(PORT_NAME,)))
	
for PORT_NAME in PORT_NAMES:
	threads[PORT_NAME].start()
	print(f"Thread Started. ({PORT_NAMES[PORT_NAME]})")

while (True):
	time.sleep(5)
	
for PORT_NAME in PORT_NAMES:
	f_out[PORT_NAME].close()

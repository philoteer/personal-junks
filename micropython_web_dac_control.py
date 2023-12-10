#TODO: implement wlan watchdog
import network
import machine
import socket
import asyncio
import time

#############################################################################
#connect to Wi-Fi
#############################################################################

WIFI_SSID=["foo"]
WIFI_PW=["bar"]

#original source: https://docs.micropython.org/en/latest/esp8266/tutorial/network_basics.html
def do_connect(WIFI_SSID, WIFI_PW):
    try:
        timeout = 10.0
        current_time = time.time()
        sta_if = network.WLAN(network.STA_IF)
        if not sta_if.isconnected():
            print('connecting to network...')
            sta_if.active(True)
            sta_if.connect(WIFI_SSID, WIFI_PW)
            while not sta_if.isconnected() and time.time() - current_time < timeout:
                pass
        if(sta_if.isconnected()):
            print('network config:', sta_if.ifconfig())
        else:
            print("connection failure:", WIFI_SSID)
            sta_if.disconnect()
            return None
        return sta_if
    except:
        print("exception detected; rebooting the board.")
        machine.reset()

sta_if = do_connect(WIFI_SSID[0], WIFI_PW[0])
cnt = 0

while(sta_if is None):
    cnt += 1
    cnt %= len(WIFI_SSID)
    sta_if = do_connect(WIFI_SSID[cnt], WIFI_PW[cnt])    



#############################################################################
#Set up HTTP Server
#############################################################################
    
#original source: https://docs.micropython.org/en/latest/esp8266/tutorial/network_tcp.html
try:
    addr = socket.getaddrinfo('0.0.0.0', 80)[0][-1]
    s = socket.socket()
    s.bind(addr)
    s.listen(1)

    print('listening on', addr)
except:
    print("exception detected; rebooting the board.")
    machine.reset()
    
try:
    dac_pin = machine.Pin(25)
    dac = machine.DAC(dac_pin)

    DAC_CONFIG = 0
    dac.write(DAC_CONFIG)
    while True:
        cl, addr = s.accept()
        print('Client connected from', addr)
        cl_file = cl.makefile('rwb', 0)    
        request_cnt = 0
        PATH=None
        
        while True:
            line = cl_file.readline()
            if not line or line == b'\r\n':
                break
            else:
                line = line.decode('utf-8')
                if(request_cnt == 0): #"GET / HTTP/1.1"
                    #TODO FIX(hacky)
                    PATH = line.split(" ")[1]
                    PATH = PATH.replace("/","")
                    print(PATH)
                request_cnt += 1
        
        try:
            new_dac_setting = int(PATH)
            if(new_dac_setting >= 0 and new_dac_setting < 256):
                DAC_CONFIG = new_dac_setting
                dac.write(DAC_CONFIG)
        except:
            pass
                
        cl.send('HTTP/1.0 200 OK\r\nContent-type: text/html\r\n\r\n')

        cl.send(f"<html><head><title>g_G</title></head><body>Current DAC setting: {DAC_CONFIG}</body></html>")
        cl.close()
except:
    print("exception detected; rebooting the board.")
    machine.reset()

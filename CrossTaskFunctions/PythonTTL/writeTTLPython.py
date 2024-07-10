import os
from ctypes import windll
import sys
from time import sleep

#for test call since can get input output
def squared(ttlValue):
    y = ttlValue * ttlValue
    return y

def sendTTL(ttlValue):
    ttlValue = int(ttlValue)
    address = int(0x4FF8) # in hex for LPT3 check properties -> resource tab of port
    p = windll.LoadLibrary(r"C:\Users\hdlab\Documents\Task_iEEG_GithubRepo\CrossTaskFunctions\PythonTTL\inpoutx64.dll")
    p.Out32(address,ttlValue)
    sleep(0.01) #so no pulses write over each other and so Matlab/python can keep up
    p.Out32(address,0)

def testTTL(ttlValue):
    print("Sending TTL")
    print(type(ttlValue))
    print(ttlValue)


if __name__ == '__main__':
    ttlValue = int(sys.argv[1])
    print("Writting TTL value", ttlValue)
    sendTTL(ttlValue)

# $Id: prg0004_WebSwitch.py 2264 2026-03-23 13:26:26Z sow $

class WebSwitch:
    def __init__(self):
        self.URL     = "https://please.set.your.url"               # TODO
        self.URL_ON  = "https://please.set.your.url.for.switch.on" # TODO
        self.URL_OFF = "https://please.set.your.url.for.switch.on" # TODO
        self.timeout = 3
    def on(self):
        import requests
        try:
            requests.get(self.URL_ON, timeout=self.timeout)
        except Exception as e:
            print(f"Error: {e}")
            sys.exit(1)
    def off(self):
        import requests
        try:
            requests.get(self.URL_OFF, timeout=self.timeout)
        except Exception as e:
            print(f"Error: {e}")
            sys.exit(1)
    def loadSwitch(self):
        import requests
        try:
            self.response = requests.get(self.URL, timeout=self.timeout)
            self.html = self.response.text
            if "switch=on" in self.html:
                self.switch = 1
            else:
                self.switch = 0
            return self.switch
        except Exception as e:
            print(f"Error: {e}")
            sys.exit(1)

class MapperZeroAirMini:
    def __init__(self, COM_PORT):
        import serial
        self.ADDR_DECODE_POS      = 15
        self.COMMAND_WRITE_A_BYTE = 0x17
        self.COMMAND_TOGGLE_IRQ   = 0x1A
        self.COMMAND_SPI_ENABLE   = 0x1D
        self.CODE_A      = 0x38
        self.CODE_B      = 0x37
        self.CODE_SELECT = 0x36
        self.CODE_START  = 0x35
        self.CODE_UP     = 0x34
        self.CODE_DOWN   = 0x33
        self.CODE_LEFT   = 0x32
        self.CODE_RIGHT  = 0x31
        self.CODE_UPDATE = 0x30
        self.baudrate = 115200
        self.bytesize = serial.EIGHTBITS
        self.parity   = serial.PARITY_NONE
        self.stopbits = serial.STOPBITS_ONE
        self.timeout  = 1
        if(COM_PORT[0:3] != "COM"):
            showUsage()
        try:
            self.ser = serial.Serial(
                port=COM_PORT,
                baudrate=self.baudrate,
                bytesize=self.bytesize,
                parity=self.parity,
                stopbits=self.stopbits,
                timeout=self.timeout
            )
        except Exception as e:
            print(f"Error: {e}")
            showUsage()
    def writeByte(self, addr, data):
        try:
            self.ser.write(bytes([0x80 | ((addr >>  0) & 0x7F)]))
            self.ser.write(bytes([0x80 | ((addr >>  7) & 0x7F)]))
            self.ser.write(bytes([0x80 | ((addr >> 14) & 0x3F) | ((data << 6) & 0x40)]))
            self.ser.write(bytes([data >> 1]))
        except Exception as e:
            print(f"Error: {e}")
            showUsage()
    def waitExpectResponse(self, data):
        try:
            while(1):
                if self.ser.in_waiting > 0:
                    self.res = self.ser.read()
                    if(self.res == bytes([data])):
                        break
        except Exception as e:
            print(f"Error: {e}")
            showUsage()
    def sendSpiEnable(self):
        self.writeByte(self.COMMAND_SPI_ENABLE << self.ADDR_DECODE_POS, 0)
        self.waitExpectResponse(self.COMMAND_SPI_ENABLE)
    def sendToggleIRQ(self):
        self.writeByte(self.COMMAND_TOGGLE_IRQ << self.ADDR_DECODE_POS, 0)
        self.waitExpectResponse(self.COMMAND_TOGGLE_IRQ)
    def sendWriteByte(self, addr, data):
        self.writeByte((self.COMMAND_WRITE_A_BYTE << self.ADDR_DECODE_POS) | addr, data)
        self.waitExpectResponse(data)
    def receiveLoop(self, ws):
        try:
            while(1):
                if self.ser.in_waiting > 0:
                    self.res = self.ser.read()
                    if(self.res == bytes([self.CODE_A])):
                        print("A : Switch OFF")
                        ws.off()
                    if(self.res == bytes([self.CODE_B])):
                        print("B : Switch ON")
                        ws.on()
                    if(self.res == bytes([self.CODE_SELECT])):
                        print("SELECT : None")
                        pass
                    if(self.res == bytes([self.CODE_START])):
                        print("START : None")
                        pass
                    if(self.res == bytes([self.CODE_UP])):
                        print("UP : None")
                        pass
                    if(self.res == bytes([self.CODE_DOWN])):
                        print("DOWN : Load Web Switch")
                        self.switch = ws.loadSwitch()
                        print(f"Web Switch : {'ON' if (self.switch != 0) else 'OFF'}")
                        self.sendWriteByte(0x7FF8, self.switch)
                        self.sendToggleIRQ()
                    if(self.res == bytes([self.CODE_LEFT])):
                        print("LEFT : None")
                        pass
                    if(self.res == bytes([self.CODE_RIGHT])):
                        print("RIGHT : None")
                        pass
                    if(self.res == bytes([self.CODE_UPDATE])):
                        print("- : AUDO LOAD")
                        self.switch = ws.loadSwitch()
                        print(f"Web Switch : {'ON' if (self.switch != 0) else 'OFF'}")
                        self.sendWriteByte(0x7FF8, self.switch)
                        self.sendToggleIRQ()
        except Exception as e:
            print(f"Error: {e}")
            showUsage()

def webSwitch(COM_PORT):
    ws = WebSwitch()
    mza = MapperZeroAirMini(COM_PORT)
    mza.sendSpiEnable()
    mza.receiveLoop(ws)

def showUsage():
    print(f"Usage: {args[0]} [COMx]")
    sys.exit(1)

if __name__ == "__main__":
    import sys
    args = sys.argv
    if len(args) != 2:
        showUsage()
    else:
        webSwitch(args[1])


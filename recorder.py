import matplotlib
matplotlib.use('TkAgg') # <-- THIS MAKES IT FAST!
import numpy
import scipy
import struct
import pyaudio
import threading
import pylab
import struct

class VocolRecorder:
    ### grab stuff from the microphone ###

    def __init__(self):
        # tiny setup stuff
        self.RATE = 48100
        self.BUFFERSIZE = 2**12 # 2^12 = 4096
        self.secToRecord = .1
        self.cancelNow = False

    def setup(self):
        ### setup soundcard ###

        self.buffersToRecord=int(self.RATE * self.secToRecord / self.BUFFERSIZE)

        if self.buffersToRecord == 0:
            self.buffersToRecord = 1

        self.samplesToRecord = int(self.BUFFERSIZE * self.buffersToRecord)
        self.chunksToRecord = int(self.samplesToRecord / self.BUFFERSIZE)
        self.secPerPoint = 1.0 / self.RATE

        # setup pyaudio
        self.p = pyaudio.PyAudio()
        # set the stream
        self.inStream = self.p.open(format = pyaudio.paInt16, channels=1, rate=self.RATE, input=True, frames_per_buffer = self.BUFFERSIZE)

        # prep stuff for math
        self.xsBuffer = numpy.arange(self.BUFFERSIZE) * self.secPerPoint
        self.xs = numpy.arange(self.chunksToRecord * self.BUFFERSIZE) * self.secPerPoint
        self.audio = numpy.empty((self.chunksToRecord * self.BUFFERSIZE), dtype=numpy.int16)


    def record(self):
        i = 0
        while not self.cancelNow:
            if i == 30: self.stopRecording()
            i += 1
            print(i)
            print('recording')


    def startRecording(self):
        # setup threading and start recording
        self.t = threading.Thread(target = self.record)
        self.t.start()


    def stopRecording(self):
        self.cancelNow = True




Vocol = VocolRecorder()

Vocol.startRecording()

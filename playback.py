import pyaudio
import numpy
import sys


class VHPlayback:
	def __init__(self):
		self.RATE = 48000
		self.BUFFERSIZE  = 2**12
		self.secToRecord = 2
		pass

	def setup(self):
		self.buffersToRecord = int(self.RATE*self.secToRecord/self.BUFFERSIZE)
		self.samplesToRecord = int(self.BUFFERSIZE*self.buffersToRecord)
		self.chunksToRecord = int(self.samplesToRecord/self.BUFFERSIZE)
		self.secPerPoint = 1.0/self.RATE

		self.p = pyaudio.PyAudio()
		self.inStream = self.p.open(format = pyaudio.paInt16, channels = 1, rate = self.RATE, input = True, frames_per_buffer = self.BUFFERSIZE )
		self.outStream = self.p.open(format = pyaudio.paInt16, channels = 1, rate = self.RATE, output = True)
		pass

	def record(self):
		"""FIXME just for debugging"""
		return  self.inStream.read(self.BUFFERSIZE)

	def playback (self, data):
		self.outStream.write(data)

	def runningLoop(self):
		for i in range(0,10):
			audioString = self.record()
			data = numpy.fromstring(audioString, dtype = numpy.int16)
			audio = self.fft(data)
			self.playback(audio.tostring())
			self.playback(audio.tostring())
	def fft(self, data):
		ys = numpy.fft.fft(data)
		res = numpy.abs(numpy.fft.ifft(ys))
		res = res.astype(numpy.int16) *-1
		return res
		pass


vh = VHPlayback()
vh.setup()
vh.runningLoop()


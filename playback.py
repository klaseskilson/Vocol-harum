import pyaudio
import numpy
import sys
import math


class VHPlayback:
	def __init__(self):
		self.RATE = 48000
		self.BUFFERSIZE  = 2**12
		self.secToRecord = 1
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
	def sine(self, frequency, length, rate):
		length = int(length * rate)
		factor = float(frequency) * (math.pi * 2) / rate
		return numpy.sin(numpy.arange(length) * factor)

	def record(self,freq):
		"""FIXME just for debugging"""
		wave = self.sine(freq,1,self.RATE);
		#return self.inStream.read(self.BUFFERSIZE)
		chunks = []
		chunks.append(wave)
		chunk = numpy.concatenate(chunks) * 255*10
		return chunk.astype(numpy.int16).tostring()

	def playback (self, data):
		self.outStream.write(data)

	def runningLoop(self):
		for i in range(0,3):
			base = self.record(440)
			#majthird = self.record(440*1.25)
			#fifth = self.record(440*1.5)

			baseArray = numpy.fromstring(base, dtype = numpy.int16)
			#majThirdArray = numpy.fromstring(majthird, dtype = numpy.int16)
			#fifthArray = numpy.fromstring(fifth, dtype = numpy.int16)

			#audio = self.fft(baseArray, majThirdArray, fifthArray)
			audio = self.fft(baseArray)
			#self.playback(base)
			self.playback(audio.tostring())

	#def fft(self, base, third,fifth):
	def fft(self, base):
		F1 = numpy.fft.fft(base)
		N = len(F1)
		F1a, F1b = numpy.split(F1,2)

		t1 = numpy.linspace(1,int(N/2),int(N/2))
		tfifth = 1+ (t1-1) / (1.5)
		tMajordThird = 1+ (t1-1) / (1.25)


		F2a = numpy.interp(tfifth,t1,numpy.abs(F1a))
		F2b = numpy.interp(tfifth,t1,numpy.abs(F1b))

		F3a = numpy.interp(tMajordThird,t1,numpy.abs(F1a))
		F3b = numpy.interp(tMajordThird,t1,numpy.abs(F1b))


		F2 = numpy.hstack((F2a,F2b))
		F3 = numpy.hstack((F3a,F3b))



		#Ys = numpy.add(left,right[::-1])


		#YsThird = numpy.fft.fft(third)
		#Ysfifth = numpy.fft.fft(fifth)

		#ytest = YsBase+Ysfifth+YsThird
		yharmony = F1+F2+F3

		result = numpy.fft.ifft(yharmony)
		result = result.astype(numpy.int16)
		return result
		pass


vh = VHPlayback()
vh.setup()
vh.runningLoop()


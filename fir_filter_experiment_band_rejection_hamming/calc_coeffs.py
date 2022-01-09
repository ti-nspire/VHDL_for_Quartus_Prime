import scipy.signal
import numpy as np
"""
�\��: scipy.signal.firwin(numtaps, cutoff, width=None, window='hamming', pass_zero=True, scale=True, nyq=None, fs=None)

pass_zero : 'bandpass', 'lowpass', 'highpass', 'bandstop'
window : boxcar, blackman, hamming, hann, flattop, bohman, blackmanharris, ���̑�
"""
COEFF_WIDTH = 16  #�W���̃r�b�g��
NUM_COEFFS  = 101 #�W���̌�(�^�b�v��)�B��Ŏw�肷��B
SAMPLE_FREQ = 40_000
CUT_OFF     = [1_000, 4_000]
FILTER_TYPE = "bandstop"
WINDOW      = "hamming"

#�W�����v�Z���āA
coeffs = scipy.signal.firwin(NUM_COEFFS, CUT_OFF, window=WINDOW, pass_zero=FILTER_TYPE, fs=SAMPLE_FREQ)
#print(*coeffs, sep=',')

#�W�����͈�(-1�� �W�� < 1)�𒴂��Ă��Ȃ����m���߂āA
print("No Good")  if len(coeffs[coeffs < -1]) + len(coeffs[coeffs > 1 - 1/2**(COEFF_WIDTH - 1)]) else print("IS OK")

#�W�����Œ菬���_����(�������B������1�r�b�g�A�������Ȃ��A�c��������r�b�g�Ɋ��蓖��)���āA
coeffs = np.asarray(np.round(coeffs * 2**(COEFF_WIDTH - 1)), dtype=np.int64)
#print(*coeffs, sep=",")

#���ꂪ�����ł�������2�̕␔�ɂ��炵�āA
coeffs = np.asarray(np.where(coeffs < 0, coeffs + 2**COEFF_WIDTH, coeffs), dtype=np.uint64)
#print(*coeffs, sep=",")

#array(0 to TAPS - 1)(COEFF_WIDTH - 1 downto 0)�̌`�ɑ̍ق𐮂��ďo�͂���B
print(*[str(COEFF_WIDTH) + 'd"' + str(coeff) + '"'for coeff in coeffs], sep=",")
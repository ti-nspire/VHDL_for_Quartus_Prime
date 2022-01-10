import scipy.signal
import numpy as np
"""
構文: scipy.signal.firwin(numtaps, cutoff, width=None, window='hamming', pass_zero=True, scale=True, nyq=None, fs=None)

pass_zero : 'bandpass', 'lowpass', 'highpass', 'bandstop'
window : boxcar, blackman, hamming, hann, flattop, bohman, blackmanharris, その他
"""
COEFF_WIDTH = 16  #係数のビット数
NUM_COEFFS  = 101 #係数の個数(タップ数)。奇数で指定する。
SAMPLE_FREQ = 40_000
CUT_OFF     = [1_000, 4_000]
FILTER_TYPE = "bandstop"
WINDOW      = "hamming"

#係数を計算して、
coeffs = scipy.signal.firwin(NUM_COEFFS, CUT_OFF, window=WINDOW, pass_zero=FILTER_TYPE, fs=SAMPLE_FREQ)
#print(*coeffs, sep=',')

#係数が範囲(-1≦ 係数 < 1)を超えていないことを念のため確かめて、
print("No Good")  if len(coeffs[coeffs < -1]) + len(coeffs[coeffs > 1 - 1/2**(COEFF_WIDTH - 1)]) else print("IS OK")

#係数を固定小数点数化(整数化。符号に1ビット、整数部なし、残りを小数ビットに割り当て)して、
coeffs = np.asarray(np.round(coeffs * 2**(COEFF_WIDTH - 1)), dtype=np.int64)
#print(*coeffs, sep=",")

#それが負数であったら2の補数にずらして、
coeffs = np.asarray(np.where(coeffs < 0, coeffs + 2**COEFF_WIDTH, coeffs), dtype=np.uint64)
#print(*coeffs, sep=",")

#array(0 to TAPS - 1)(COEFF_WIDTH - 1 downto 0)の形に体裁を整えて出力する。
print(*[str(COEFF_WIDTH) + 'd"' + str(coeff) + '"'for coeff in coeffs], sep=",")

////////////////////////////////////
// 1からRAM[0]までの総和を求める。//
////////////////////////////////////

// ディップスイッチで設定した任意の値をRAM[0]に格納する。
@KBD
D=M
@R0
M=D

// 加算する値の初期値i=1
@i
M=1

// 総和の初期値sum=0
@sum
M=0

(LOOP)
@i
D=M

// 途中の何かをOUT_PORTに出力する。
@OUT_PORT
M=D

@R0
D=D-M

// 途中の何かをOUT_PORTに出力する。
@OUT_PORT
M=D

// if i-RAM[0] > 0: goto (STOP)
// すなわち計算し終わったらループを抜けて(STOP)へ飛ぶ。
@STOP
D;JGT

// sum+=i
@sum
D=M

// 途中の何かをOUT_PORTに出力する。
@OUT_PORT
M=D

@i
D=D+M

// 途中の何かをOUT_PORTに出力する。
@OUT_PORT
M=D

@sum
M=D

// i++
@i
M=M+1
@LOOP
0;JMP

(STOP)
// R1=sum
@sum
D=M

// 最終結果をOUT_PORTに出力する。
@OUT_PORT
M=D

(END)
@END
0;JMP

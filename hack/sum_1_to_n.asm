// 1‚©‚çRAM[0]‚Ü‚Å‚Ì‘˜a‚ð‹‚ß‚éB

// R0=10
@10
D=A
@R0
M=D

// i=1
@i
M=1

// sum=0
@sum
M=0

/////////////////////////////////////////
(LOOP)
// if i-RAM[0] > 0: goto (STOP)
// ‚·‚È‚í‚¿if i > RAM[0]: goto (STOP)
@i
D=M
@R0
D=D-M
@STOP
D;JGT

// sum+=i
@sum
D=M
@i
D=D+M
@sum
M=D

// i++
@i
M=M+1
@LOOP
0;JMP
/////////////////////////////////////////

(STOP)
// R1=sum
@sum
D=M
@R1
M=D

(END)
@END
0;JMP

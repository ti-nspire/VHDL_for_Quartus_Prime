// 1����RAM[0]�܂ł̑��a�����߂�B

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
// ���Ȃ킿if i > RAM[0]: goto (STOP)
@i
D=M

// �r���o�߂�OUT_PORT�ɏo�͂���
@OUT_PORT
M=D

@R0
D=D-M

// �r���o�߂�OUT_PORT�ɏo�͂���B
@OUT_PORT
M=D

@STOP
D;JGT

// sum+=i
@sum
D=M

// �r���o�߂�OUT_PORT�ɏo�͂���B
@OUT_PORT
M=D

@i
D=D+M

// �r���o�߂�OUT_PORT�ɏo�͂���B
@OUT_PORT
M=D

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

// �ŏI���ʂ�OUT_PORT�ɏo�͂���B
@OUT_PORT
M=D

(END)
@END
0;JMP

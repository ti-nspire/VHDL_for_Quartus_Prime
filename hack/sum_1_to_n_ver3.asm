////////////////////////////////////
// 1����RAM[0]�܂ł̑��a�����߂�B//
////////////////////////////////////

// �f�B�b�v�X�C�b�`�Őݒ肵���C�ӂ̒l��RAM[0]�Ɋi�[����B
@KBD
D=M
@R0
M=D

// ���Z����l�̏����li=1
@i
M=1

// ���a�̏����lsum=0
@sum
M=0

(LOOP)
@i
D=M

// �r���̉�����OUT_PORT�ɏo�͂���B
@OUT_PORT
M=D

@R0
D=D-M

// �r���̉�����OUT_PORT�ɏo�͂���B
@OUT_PORT
M=D

// if i-RAM[0] > 0: goto (STOP)
// ���Ȃ킿�v�Z���I������烋�[�v�𔲂���(STOP)�֔�ԁB
@STOP
D;JGT

// sum+=i
@sum
D=M

// �r���̉�����OUT_PORT�ɏo�͂���B
@OUT_PORT
M=D

@i
D=D+M

// �r���̉�����OUT_PORT�ɏo�͂���B
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

// �ŏI���ʂ�OUT_PORT�ɏo�͂���B
@OUT_PORT
M=D

(END)
@END
0;JMP

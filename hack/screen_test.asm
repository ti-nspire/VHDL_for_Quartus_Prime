// screen ram�̃e�X�g

// memory[0x2000] (= screen[0])�ɉ������������ށB
@15 // ���l
D=A
@8192 // 0x2000�Ԓn
M=D

// memory[0x2001] (=screen[1])�ɉ������������ށB
@16 // ���l
D=A
@8193 // 0x2001�Ԓn
M=D

// memory[0x2002] (=screen[2])�ɉ������������ށB
@17 // ���l
D=A
@8194// 0x2002�Ԓn
M=D

// memory[0x217F] (=screen[383])��13���������ށB
@18 // ���l
D=A
@8575 // 0x217F�Ԓn
M=D

(LOOP)
@LOOP
0;JMP

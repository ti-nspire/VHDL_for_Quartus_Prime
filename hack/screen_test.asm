// screen ramのテスト

// memory[0x2000] (= screen[0])に何かを書き込む。
@15 // 即値
D=A
@8192 // 0x2000番地
M=D

// memory[0x2001] (=screen[1])に何かを書き込む。
@16 // 即値
D=A
@8193 // 0x2001番地
M=D

// memory[0x2002] (=screen[2])に何かを書き込む。
@17 // 即値
D=A
@8194// 0x2002番地
M=D

// memory[0x217F] (=screen[383])に13を書き込む。
@18 // 即値
D=A
@8575 // 0x217F番地
M=D

(LOOP)
@LOOP
0;JMP

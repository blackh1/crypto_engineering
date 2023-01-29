SRC			= verilog/a5_1.v

TB_ENC_SRC	= verilog/a5_1_tb.v
TB_DEC_SRC 	= verilog/a5_1_decrypt_tb.v

CC	= iverilog
VVP	= vvp


ifeq ($(OS),Windows_NT)
	DEL = del
else
	DEL = rm
endif

enc.sim:	$(SRC) $(TB_ENC_SRC)
	$(CC) -o a5_1_enc.vvp $(SRC) $(TB_ENC_SRC)
	$(VVP) -n a5_1_enc.vvp

dec.sim:	$(SRC) $(TB_DEC_SRC)
	$(CC) -o a5_1_dec.vvp $(SRC) $(TB_DEC_SRC)
	$(VVP) -n a5_1_dec.vvp

clean:
	$(DEL) a5_1_enc.vvp
	$(DEL) a5_1_dec.vvp


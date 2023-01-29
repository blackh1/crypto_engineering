SBOX_SRC	= aes/aes_sbox.v
KEY_SRC		= aes/aes_key_gen.v
ENC_SRC		= aes/aes_encipher.v
DEC_SRC		= aes/aes_decipher.v


TB_SBOX_SRC	= tb/tb_aes_sbox.v
TB_KEY_SRC	= tb/tb_aes_key_gen.v
TB_ENC_SRC	= tb/tb_aes_encipher.v
TB_DEC_SRC	= tb/tb_aes_decipher.v


CC	= iverilog
VVP	= vvp

ifeq ($(OS),Windows_NT)
	DEL = del
else
	DEL = rm
endif

sbox.sim:	$(SBOX_SRC) $(TB_SBOX_SRC)
	$(CC) -o aes_sbox.vvp $(SBOX_SRC) $(TB_SBOX_SRC)
	$(VVP) -n aes_sbox.vvp

key.sim:	$(KEY_SRC) $(TB_KEY_SRC) $(SBOX_SRC)
	$(CC) -o aes_key.vvp $(KEY_SRC) $(SBOX_SRC) $(TB_KEY_SRC)
	$(VVP) -n aes_key.vvp

enc.sim: 	$(SBOX_SRC) $(KEY_SRC) $(ENC_SRC) $(TB_ENC_SRC)
	$(CC) -o aes_encipher.vvp $(SBOX_SRC) $(KEY_SRC) $(ENC_SRC) $(TB_ENC_SRC)
	$(VVP) -n aes_encipher.vvp

dec.sim:	$(SBOX_SRC) $(KEY_SRC) $(DEC_SRC) $(TB_DEC_SRC)
	$(CC) -o aes_decipher.vvp $(SBOX_SRC) $(KEY_SRC) $(ENC_SRC) $(TB_ENC_SRC)
	$(VVP) -n aes_decipher.vvp

all:	sbox.sim key.sim enc.sim dec.sim

clean:
	$(DEL) aes_sbox.vvp
	$(DEL) aes_key.vvp
	$(DEL) aes_encipher.vvp
	$(DEL) aes_decipher.vvp
`timescale 1ns/100ps

module tb_aes_sbox();
    wire [31:0] tb_sboxw = 32'h00112233;
    wire [31:0] tb_new_sboxw;

aes_sbox dut(
    .sboxw(tb_sboxw),
    .new_sboxw(tb_new_sboxw)
);

initial begin
    # 10;
    $display("0x%02x->0x%02x",tb_sboxw[31:24],tb_new_sboxw[31:24]);
    $display("0x%02x->0x%02x",tb_sboxw[23:16],tb_new_sboxw[23:16]);
    $display("0x%02x->0x%02x",tb_sboxw[15:8],tb_new_sboxw[15:8]);
    $display("0x%02x->0x%02x",tb_sboxw[7:0],tb_new_sboxw[7:0]);
end
endmodule
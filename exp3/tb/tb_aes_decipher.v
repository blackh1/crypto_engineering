`timescale 1ns/100ps

module tb_aes_cipher();


parameter CLK_HALF_PERIOD   = 1;
parameter CLK_PERIOD        = 2 * CLK_HALF_PERIOD;


reg             tb_clk;         //tb时钟信号
reg             tb_reset;       //tb重置信号
reg             tb_init;

wire [127:0]    tb_key;   //对应轮数的密钥

reg [127:0]     tb_plaintext;
wire [127:0]    tb_ciphertext;

wire [31:0]     tb_sboxw;       //对应位置的S-Box
wire [31:0]     tb_new_sboxw;

wire            tb_ready;       //就绪标志位

reg [127:0]     key;

assign tb_key = key;

aes_inv_sbox sbox(
    .sboxw(tb_sboxw),
    .new_sboxw(tb_new_sboxw)
);

aes_encipher dut(
    .clk(tb_clk),
    .reset(tb_reset),
    .init(tb_init),
    .key(tb_key),
    .plaintext(tb_plaintext),
    .ciphertext(tb_ciphertext),
    .sboxw(tb_sboxw),
    .new_sboxw(tb_new_sboxw),
    .ready(tb_ready)
);

always
    begin
        #CLK_HALF_PERIOD;
        tb_clk = !tb_clk;
    end


task reset_dut; 
    begin
        $display("Start reset.");
        tb_reset    = 0;
        # (2 * CLK_PERIOD);
        tb_reset    = 1;
        $display("Reset done.");
    end
endtask

task init;
    begin
        tb_clk          = 0;
        tb_reset        = 1;
        tb_plaintext    = {4{32'h00_00_00_00}};
    end
endtask

task wait_ready;
    begin
        //没准备好就再等待两个时钟周期
        while (!tb_ready) begin
            #(CLK_PERIOD);
        end
    end
endtask

task test_ecb_enc(
    input [127:0] block,
    input [127:0] expected
);
    begin
        tb_plaintext    = block;
        tb_init         = 1;
        #(2 * CLK_PERIOD);
        tb_init         = 0;
        #(2 * CLK_PERIOD);
        wait_ready();

        $display("Expected: 0x%032x", expected);
        $display("Got:      0x%032x", tb_ciphertext);
    end

endtask


initial 
    begin:test
        reg [127:0] plaintext;
        reg [127:0] expected;
        key         = 128'h000102030405060708090a0b0c0d0e0f;
        plaintext   = 128'h00112233445566778899aabbccddeeff;
        expected    = 128'h69c4e0d86a7b0430d8cdb78070b4c55a;

        init();
        reset_dut();

        test_ecb_enc(expected,plaintext);
        $finish;
    end

endmodule
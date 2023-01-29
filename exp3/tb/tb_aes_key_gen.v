`timescale 1ns/100ps

module tb_aes_key_gen();

parameter CLK_HALF_PERIOD   = 1;
parameter CLK_PERIOD        = 2 * CLK_HALF_PERIOD;


reg             tb_clk;         //tb时钟信号
reg             tb_reset;       //tb重置信号
reg [127:0]     tb_key;         //tb初始密钥
reg             tb_init;    
reg [3:0]       tb_round;        //想要获得的轮数
wire [127:0]    tb_round_key;   //对应轮数的密钥
wire            tb_ready;       //就绪标志位

wire [31:0]     tb_sboxw;       //对应位置的S-Box
wire [31:0]     tb_new_sboxw;

aes_key_gen dut(
    .clk(tb_clk),
    .reset(tb_reset),
    .key(tb_key),
    .init(tb_init),
    .round(tb_round),
    .round_key(tb_round_key),
    .ready(tb_ready),
    .new_sboxw(tb_new_sboxw),
    .sboxw(tb_sboxw)
);

aes_sbox sbox(
    .sboxw(tb_sboxw),
    .new_sboxw(tb_new_sboxw)
);

//产生时钟信号,每100ps反转,200ps为一周期
always
    begin
        #CLK_HALF_PERIOD;
        tb_clk = !tb_clk;
    end

//重置变量,便于多次测试
task reset_dut; 
    begin
        $display("Start reset.");
        tb_reset    = 0;
        # (2 * CLK_PERIOD);
        tb_reset    = 1;
        $display("Reset done.");
    end
endtask

//初始化所有变量
task init;
    begin
        tb_clk      = 0;
        tb_reset    = 1;
        tb_key      = 128'h0;
        tb_init     = 0;
        tb_round    = 0;
    end
endtask

//设置阻塞,等待密钥生成完毕
task wait_ready;
    begin
        //没准备好就再等待两个时钟周期
        while (!tb_ready) begin
            #(CLK_PERIOD);
        end
    end
endtask

//检查生成的密钥与预期是否符合
task check_key(input [3:0] check_round,input [127:0] expected);
    begin
        tb_round    = check_round;
        #(CLK_PERIOD);
        if (tb_round_key == expected) begin
            $display("Round 0x%01x key match.",check_round);
        end
        else begin
            $display("Round 0x%01x key doesn't match.",check_round);
            $display("Generate key is 0x%032x",tb_round_key);
            $display("Expected key is 0x%032x",expected);
        end
    end
endtask

//检查AES-128的10轮密钥
task check_all(
    input [127:0] key,
    input [127:0] expected00,
    input [127:0] expected01,
    input [127:0] expected02,
    input [127:0] expected03,
    input [127:0] expected04,
    input [127:0] expected05,
    input [127:0] expected06,
    input [127:0] expected07,
    input [127:0] expected08,
    input [127:0] expected09,
    input [127:0] expected10
);
    begin
        $display("Testing 128-bit key 0x%032x",key);

        tb_key  = key;
        tb_init = 1;
        #(2 * CLK_PERIOD);  //等待两个时钟周期,使其运行过CTRL_IDLE阶段
        tb_init = 0;
        wait_ready();

        check_key(4'h0,expected00);
        check_key(4'h1,expected01);
        check_key(4'h2,expected02);
        check_key(4'h3,expected03);
        check_key(4'h4,expected04);
        check_key(4'h5,expected05);
        check_key(4'h6,expected06);
        check_key(4'h7,expected07);
        check_key(4'h8,expected08);
        check_key(4'h9,expected09);
        check_key(4'ha,expected10);
    end
endtask

//main
initial begin:main
    reg [127:0] key;
    reg [127:0] expected00;
    reg [127:0] expected01;
    reg [127:0] expected02;
    reg [127:0] expected03;
    reg [127:0] expected04;
    reg [127:0] expected05;
    reg [127:0] expected06;
    reg [127:0] expected07;
    reg [127:0] expected08;
    reg [127:0] expected09;
    reg [127:0] expected10;

    $display("Start test");
    init();
    reset_dut();

    #(100 * CLK_PERIOD);

    key         = 128'h000102030405060708090a0b0c0d0e0f;
    expected00  = 128'h000102030405060708090a0b0c0d0e0f;
    expected01  = 128'hd6aa74fdd2af72fadaa678f1d6ab76fe;
    expected02  = 128'hb692cf0b643dbdf1be9bc5006830b3fe;
    expected03  = 128'hb6ff744ed2c2c9bf6c590cbf0469bf41;
    expected04  = 128'h47f7f7bc95353e03f96c32bcfd058dfd;
    expected05  = 128'h3caaa3e8a99f9deb50f3af57adf622aa;
    expected06  = 128'h5e390f7df7a69296a7553dc10aa31f6b;
    expected07  = 128'h14f9701ae35fe28c440adf4d4ea9c026;
    expected08  = 128'h47438735a41c65b9e016baf4aebf7ad2;
    expected09  = 128'h549932d1f08557681093ed9cbe2c974e;
    expected10  = 128'h13111d7fe3944a17f307a78b4d2b30c5;

    check_all(key,
        expected00,expected01,expected02,expected03,
        expected04,expected05,expected06,expected07,
        expected08,expected09,expected10);
    $finish;
end

endmodule
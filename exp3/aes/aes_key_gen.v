module aes_key_gen (
    input wire clk,
    input wire reset,                   //重置中间状态

    input wire [127:0] key,
    input wire init,                    //初始化的控制位

    input wire [3:0] round,             //输入想要的轮数
    output wire [127:0] round_key,      //得到对应轮数的密钥
    output wire ready,                  //完成标志位

    input wire [31:0] new_sboxw,        //获得对应的S-Box
    output wire [31:0] sboxw           //输入想要获得的S-Box
);

localparam CTRL_IDLE = 2'h0;    //初始化准备状态
localparam CTRL_INIT = 2'h1;    //初始化状态
localparam CTRL_GEN  = 2'h2;    //生成阶段
localparam CTRL_DONE = 2'h3;    //结束

reg [127:0] key_mem [0:10];     //存储10轮密钥,key_mem[0]存储第0轮,便于运行
reg [127:0] key_mem_new;        //临时存储一轮密钥
reg         key_mem_we;         //单轮密钥生成结束

reg [127:0] prev_key_reg;       //存储上一轮密钥
reg [127:0] prev_key_new;       //中间变量
reg         prev_key_we;        //生成结束

reg [3:0]   round_ctr_reg;      //存储轮数
reg [3:0]   round_ctr_new;      //存储变化的轮数
reg         round_ctr_rst;      //存储重置位
reg         round_ctr_inc;      //控制轮数增加
reg         round_ctr_we;       //单轮轮数变化结束

reg         ready_reg;          //完成的标志位
reg         ready_new;
reg         ready_we;

reg [2:0]   key_ctrl_reg;       //用于控制生成key的流程
reg [2:0]   key_ctrl_new;       //存储中间变量
reg         key_ctrl_we;        //控制标志位

reg         round_key_update;   //控制密钥更新

reg [31:0]  tmp_sboxw;          //临时存储S-Box
reg [127:0] tmp_round_key;      //临时存储轮密钥

assign round_key    = tmp_round_key;
assign ready        = ready_reg;
assign sboxw        = tmp_sboxw;



//AES-128对应的Rcon
function [31:0] rcon;
    input [3:0] i;
    case (i)
        4'h1:rcon = 32'h01_00_00_00;
        4'h2:rcon = 32'h02_00_00_00;
        4'h3:rcon = 32'h04_00_00_00;
        4'h4:rcon = 32'h08_00_00_00;
        4'h5:rcon = 32'h10_00_00_00;
        4'h6:rcon = 32'h20_00_00_00;
        4'h7:rcon = 32'h40_00_00_00;
        4'h8:rcon = 32'h80_00_00_00;
        4'h9:rcon = 32'h1b_00_00_00;
        4'ha:rcon = 32'h36_00_00_00;
        default:rcon = 32'h00_00_00_00;
    endcase    
endfunction

//更新参数
always @(posedge clk or negedge reset) begin
    //当reset为0时,重置所有变量,清空中间密钥
    if (!reset) begin
        key_mem[0]      <= 128'h0;
        key_mem[1]      <= 128'h0;
        key_mem[2]      <= 128'h0;
        key_mem[3]      <= 128'h0;
        key_mem[4]      <= 128'h0;
        key_mem[5]      <= 128'h0;
        key_mem[6]      <= 128'h0;
        key_mem[7]      <= 128'h0;
        key_mem[8]      <= 128'h0;
        key_mem[9]      <= 128'h0;
        key_mem[10]     <= 128'h0;
        prev_key_reg    <= 128'h0;
        ready_reg       <= 0;
        round_ctr_reg   <= 4'h0;
        key_ctrl_reg    <= CTRL_INIT;
    end
    
    //更新每轮的参数
    else begin
        if (round_ctr_we) begin
            round_ctr_reg   <= round_ctr_new;
        end

        if (ready_new) begin
            ready_reg       <= ready_new;
        end

        if (key_ctrl_we) begin
            key_ctrl_reg    <= key_ctrl_new;
        end

        if (prev_key_we) begin
            prev_key_reg    <= prev_key_new;
        end

        if (key_mem_we) begin
            key_mem[round_ctr_reg]  <= key_mem_new;
        end

        if (key_ctrl_we) begin
            key_ctrl_reg    <= key_ctrl_new;
        end
    end
end

//将想要的轮密钥传给输出
always @(*) begin
    tmp_round_key   = key_mem[round];
end

//控制轮数增加
always @(*) begin
    round_ctr_new   = 4'h0;
    round_ctr_we    = 1'b0;

    if (round_ctr_rst) begin
        round_ctr_new   = 4'h0;
        round_ctr_we    = 1'b1;
    end
    else if (round_ctr_inc) begin
        round_ctr_new   = round_ctr_reg + 1'b1;
        round_ctr_we    = 1'b1;
    end
end

//密钥生成
always @(*) begin:key_gen
    reg [31:0] w0,w1,w2,w3;
    reg [31:0] k0,k1,k2,k3;
    reg [31:0] trw,rconw,rotw;

    key_mem_new     = 128'h0;
    key_mem_we      = 0;
    prev_key_new    = 128'h0;
    prev_key_we     = 0;

    k0  = 32'h0;
    k1  = 32'h0;
    k2  = 32'h0;
    k3  = 32'h0;

    w0  = prev_key_reg[127:96];
    w1  = prev_key_reg[95:64];
    w2  = prev_key_reg[63:32];
    w3  = prev_key_reg[31:0];

    rconw       = rcon(round_ctr_reg);
    //先过S-Box
    tmp_sboxw   = w3;
    //左移1byte
    rotw        = {new_sboxw[23:0],new_sboxw[31:24]};
    //异或Rcon常量,至此完成g-func
    trw         = rotw ^ rconw;
    if (round_key_update) begin
        key_mem_we  = 1;
        //对于第0轮只初始化
        if (round_ctr_reg == 0) begin
            key_mem_new     = key;
            prev_key_new    = key;
        end
        //第1到10轮正常更新密钥
        else begin
            //这里不能使用刚赋值的k0,有可能有时序问题
            k0  = w0 ^ trw;
            k1  = w1 ^ w0 ^ trw;
            k2  = w2 ^ w1 ^ w0 ^ trw;
            k3  = w3 ^ w2 ^ w1 ^ w0 ^ trw;
            key_mem_new     = {k0,k1,k2,k3};
            prev_key_new    = {k0,k1,k2,k3};
        end
        //该轮密钥完成
        prev_key_we = 1;
    end
end


//该module控制部分
always @(*) begin
    //设置默认参数
    ready_new           = 0;
    ready_we            = 0;
    round_key_update    = 0;
    round_ctr_rst       = 0;
    round_ctr_inc       = 0;
    key_ctrl_new        = CTRL_INIT;
    key_ctrl_we         = 0;

    case(key_ctrl_reg)
        CTRL_IDLE:
            begin
                if (init) begin
                    ready_new       = 0;
                    ready_we        = 1;
                    key_ctrl_new    = CTRL_INIT;
                    key_ctrl_we     = 1;
                end
            end

        //轮数重置,从0开始
        CTRL_INIT:
            begin
                round_ctr_rst   = 1;
                key_ctrl_new    = CTRL_GEN;
                key_ctrl_we     = 1;
            end

        //处于该状态时更新轮密钥,直到完成10轮
        CTRL_GEN:
            begin
                round_ctr_inc       = 1;
                round_key_update    = 1;
                if (round_ctr_reg == 4'b1010) begin
                    key_ctrl_new    = CTRL_DONE;
                    key_ctrl_we     = 1;
                end
            end

        CTRL_DONE:
            begin
                ready_new       = 1;
                ready_we        = 1;
                key_ctrl_new    = CTRL_IDLE;
                key_ctrl_we     = 1;
            end

        default:
            begin
            end
    endcase
end

endmodule
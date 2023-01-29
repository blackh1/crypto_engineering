module aes_encipher(
    input wire          clk,
    input wire          reset,
    input wire          init,

    input wire [127:0]  key,

    input wire [127:0]  plaintext,
    output wire [127:0] ciphertext,

    output wire [31:0]  sboxw,
    input wire [31:0]   new_sboxw,

    output wire         ready
    
);

//控制S-Box更新流程
localparam NO_UPDATE    = 3'h0;
localparam INIT_UPDATE  = 3'h1;
localparam SBOX_UPDATE  = 3'h2;
localparam MAIN_UPDATE  = 3'h3;
localparam FINAL_UPDATE = 3'h4;
localparam KEY_UPDATE   = 3'h5;

//控制整体流程
localparam CTRL_IDLE    = 3'h0;
localparam CTRL_INIT    = 3'h1;
localparam CTRL_SBOX    = 3'h2;
localparam CTRL_MAIN    = 3'h3;
localparam CTRL_DONE    = 3'h4;
localparam CTRL_KEY     = 3'h5;

localparam NUM_ROUND    = 4'b1010;

//GF2^8上的乘00000010
function [7:0] gm2(input [7:0] op);
    begin
        gm2 = {op[6:0] ,1'b0} ^ {8'h1b & {8{op[7]}}};
    end
endfunction

//GF2^8上的乘00000011
function [7:0] gm3(input [7:0] op);
    begin
        gm3 = gm2(op) ^ op;
    end
endfunction

//单列混合
function [31:0] mix_single_col(input [31:0] col);
    reg [7:0] s0,s1,s2,s3;
    reg [7:0] ms0,ms1,ms2,ms3;
    begin
        s0  = col[31:24];
        s1  = col[23:16];
        s2  = col[15:8];
        s3  = col[7:0];

        ms0 = gm2(s0)   ^ gm3(s1)   ^ s2        ^ s3;
        ms1 = s0        ^ gm2(s1)   ^ gm3(s2)   ^ s3;
        ms2 = s0        ^ s1        ^ gm2(s2)   ^ gm3(s3);
        ms3 = gm3(s0)   ^ s1        ^ s2        ^ gm2(s3);

        mix_single_col  = {ms0,ms1,ms2,ms3};
    end
endfunction

//全列混合
function [127:0] mix_all_col(input [127:0] data);
    reg [31:0] w0,w1,w2,w3;
    reg [31:0] mw0,mw1,mw2,mw3;
    begin
        w0  = data[127:96];
        w1  = data[95:64];
        w2  = data[63:32];
        w3  = data[31:0];

        mw0 = mix_single_col(w0);
        mw1 = mix_single_col(w1);
        mw2 = mix_single_col(w2);
        mw3 = mix_single_col(w3);

        mix_all_col = {mw0,mw1,mw2,mw3};
    end
endfunction

//行移位
function [127:0] shiftrows(input [127:0] data);
    reg [31:0] w0,w1,w2,w3;
    reg [31:0] sw0,sw1,sw2,sw3;
    begin
        w0  = data[127:96];
        w1  = data[95:64];
        w2  = data[63:32];
        w3  = data[31:0];

        sw0 = {w0[31:24],w1[23:16],w2[15:8],w3[7:0]};
        sw1 = {w1[31:24],w2[23:16],w3[15:8],w0[7:0]};
        sw2 = {w2[31:24],w3[23:16],w0[15:8],w1[7:0]};
        sw3 = {w3[31:24],w0[23:16],w1[15:8],w2[7:0]};

        shiftrows = {sw0,sw1,sw2,sw3};
    end
endfunction

//轮密钥异或
function [127:0] addroundkey(input [127:0] data,input [127:0] r_key);
    addroundkey = data ^ r_key;
endfunction

reg [127:0] tmp_cipher[0:10];

//S-Box参数
reg [1:0]   sbox_ctr_reg;
reg [1:0]   sbox_ctr_new;
reg         sbox_ctr_we;
reg         sbox_ctr_inc;
reg         sbox_ctr_rst;

//轮数参数
reg [3:0]   round_ctr_reg;
reg [3:0]   round_ctr_new;
reg         round_ctr_we;
reg         round_ctr_inc;
reg         round_ctr_rst;

reg [127:0] block_new;
reg [31:0]  block_w0_reg;
reg [31:0]  block_w1_reg;
reg [31:0]  block_w2_reg;
reg [31:0]  block_w3_reg;

reg         block_w0_we;
reg         block_w1_we;
reg         block_w2_we;
reg         block_w3_we;

wire        key_ready;

reg         ready_reg;
reg         ready_new;
reg         ready_we;

reg [3:0]   enc_ctrl_reg;
reg [3:0]   enc_ctrl_new;
reg         enc_ctrl_we;

reg [3:0]   update_type;
reg [31:0]  tmp_sboxw;

wire [31:0] key_sboxw;
wire [31:0] key_new_sboxw;

wire [127:0] round_key;
wire [3:0]   round;

assign sboxw        = tmp_sboxw;
assign round        = round_ctr_reg;
assign ciphertext   = {block_w0_reg,block_w1_reg,block_w2_reg,block_w3_reg};
assign ready        = ready_reg;

aes_key_gen keygen(
    .clk(clk),
    .reset(reset),
    .key(key),
    .init(init),
    .round(round),
    .round_key(round_key),
    .ready(key_ready),
    .new_sboxw(key_new_sboxw),
    .sboxw(key_sboxw)
);

aes_sbox sbox(
    .sboxw(key_sboxw),.new_sboxw(key_new_sboxw)
);


//类似key里面的reg update
always @(posedge clk or negedge reset)
    begin:reg_update

        //重置变量
        if(!reset)  begin
            block_w0_reg    <= 32'h0;
            block_w1_reg    <= 32'h0;
            block_w2_reg    <= 32'h0;
            block_w3_reg    <= 32'h0;
            sbox_ctr_reg    <= 2'h0;
            round_ctr_reg   <= 4'h0;
            ready_reg       <= 1;
            enc_ctrl_reg    <= CTRL_IDLE;
        end

        else begin
            //更新四个block
            if (block_w0_we) begin
                block_w0_reg    <= block_new[127:96];
            end
            if (block_w1_we) begin
                block_w1_reg    <= block_new[95:64];
            end
            if (block_w2_we) begin
                block_w2_reg    <= block_new[63:32];
            end
            if (block_w3_we) begin
                block_w3_reg    <= block_new[31:0];
            end
            
            if (sbox_ctr_we) begin
                sbox_ctr_reg    <= sbox_ctr_new;
            end

            if (round_ctr_we) begin
                round_ctr_reg   <= round_ctr_new;
            end

            if (ready_we) begin
                ready_reg       <= ready_new; 
            end

            if (enc_ctrl_we) begin
                enc_ctrl_reg    <= enc_ctrl_new;
            end
        end
    end

//控制更新S-Box
always @(*)
    begin:control_S_Box
        sbox_ctr_new    = 2'b0;
        sbox_ctr_we     = 1'b0;

        if (sbox_ctr_rst) begin
            sbox_ctr_new    = 2'b0;
            sbox_ctr_we     = 1'b1;
        end

        else if (sbox_ctr_inc) begin
            sbox_ctr_new    = sbox_ctr_reg + 1'b1;
            sbox_ctr_we     = 1'b1;
        end
    end

//控制更新轮数
always @(*) begin:round_update
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

//加密整体逻辑
always @(*)
    begin:round_logic
        reg [127:0] prev_block,shiftrows_block,mixcolumns_block;
        reg [127:0] addkey_init_block,addkey_main_block,addkey_final_block;

        block_new   = 128'h0;
        tmp_sboxw   = 32'h0;
        block_w0_we = 0;
        block_w1_we = 0;
        block_w2_we = 0;
        block_w3_we = 0;

        
        prev_block          = {block_w0_reg,block_w1_reg,block_w2_reg,block_w3_reg};
        shiftrows_block     = shiftrows(prev_block);
        mixcolumns_block    = mix_all_col(shiftrows_block);
        addkey_init_block   = addroundkey(plaintext,round_key);
        addkey_main_block   = addroundkey(mixcolumns_block,round_key);
        addkey_final_block  = addroundkey(shiftrows_block,round_key);
                    


        case (update_type)
            //最初与轮密钥加
            INIT_UPDATE:
                begin
                    block_new   = addkey_init_block;
                    block_w0_we = 1;
                    block_w1_we = 1;
                    block_w2_we = 1;
                    block_w3_we = 1;
                end

            //更新S-Box,进行字节替换
            SBOX_UPDATE:
                begin
                    //更新一个S-Box后,更新参数,将更新过后的放入reg里面
                    block_new   = {new_sboxw,new_sboxw,new_sboxw,new_sboxw};

                    case (sbox_ctr_reg)
                        2'b00:
                            begin
                                tmp_sboxw   = block_w0_reg;
                                block_w0_we = 1'b1;     
                            end
                        2'b01:
                            begin
                                tmp_sboxw   = block_w1_reg;
                                block_w1_we = 1'b1;     
                            end
                        2'b10:
                            begin
                                tmp_sboxw   = block_w2_reg;
                                block_w2_we = 1'b1;     
                            end
                        2'b11:
                            begin
                                tmp_sboxw   = block_w3_reg;
                                block_w3_we = 1'b1;     
                            end
                    endcase
                end
            //中间9轮替换
            MAIN_UPDATE:
                begin
                    block_new   = addkey_main_block;
                    block_w0_we = 1;
                    block_w1_we = 1;
                    block_w2_we = 1;
                    block_w3_we = 1;
                end

            //最后一轮
            FINAL_UPDATE:
                begin
                    block_new   = addkey_final_block;
                    block_w0_we = 1;
                    block_w1_we = 1;
                    block_w2_we = 1;
                    block_w3_we = 1;
                end
        endcase 
    end

//流程控制
always @(*)
    begin:encipher_control
        
        sbox_ctr_inc    = 0;
        sbox_ctr_rst    = 0;
        round_ctr_inc   = 0;
        round_ctr_rst   = 0;
        ready_new       = 0;
        ready_we        = 0;
        // key_ready       = 0;
        update_type     = NO_UPDATE;
        enc_ctrl_new    = CTRL_IDLE;        //重置所有变量
        enc_ctrl_we     = 0;
        
        
        case (enc_ctrl_reg)
            CTRL_IDLE:
                begin
                    if (init) begin
                        round_ctr_rst   = 1;
                        ready_new       = 0;
                        ready_we        = 1;
                        enc_ctrl_new    = CTRL_INIT;
                        enc_ctrl_we     = 1;
                    end
                end

            CTRL_INIT:
                begin
                    if (key_ready) begin
                        sbox_ctr_rst    = 1;
                        update_type     = INIT_UPDATE;
                        enc_ctrl_new    = CTRL_SBOX;
                        enc_ctrl_we     = 1;
                    end
                    else begin
                        update_type     = NO_UPDATE;
                    end
                end

            CTRL_KEY:
                begin                 
                    if (key_ready) begin
                        enc_ctrl_new    = CTRL_SBOX;
                        enc_ctrl_we     = 1;
                    end
                    else begin
                        round_ctr_inc   = 0;
                        update_type     = NO_UPDATE;
                    end
                end

            CTRL_SBOX:
                begin
                    sbox_ctr_inc    = 1;
                    update_type     = SBOX_UPDATE;
                    //更新完四个block后,该阶段完成
                    if (sbox_ctr_reg == 2'h3) begin
                        round_ctr_inc   = 1;
                        enc_ctrl_new    = CTRL_MAIN;
                        enc_ctrl_we     = 1;
                    end

                end

            CTRL_MAIN:
                begin
                    sbox_ctr_rst    = 1;
                    //前九轮
                    if (round_ctr_reg < NUM_ROUND) begin
                        update_type     = MAIN_UPDATE;
                        enc_ctrl_new    = CTRL_KEY;
                        enc_ctrl_we     = 1;
                    end
                    //最后一轮
                    else begin
                        round_ctr_inc   = 0;
                        if (key_ready) begin
                            update_type     = FINAL_UPDATE;
                            ready_new       = 1;
                            ready_we        = 1;
                            enc_ctrl_new    = CTRL_DONE;
                            enc_ctrl_we     = 1;
                        end
                    end
                end

            CTRL_DONE:
                begin
                    enc_ctrl_new    = CTRL_IDLE;
                    enc_ctrl_we     = 1;
                end

            default:
                begin
                end
        endcase

    end

endmodule
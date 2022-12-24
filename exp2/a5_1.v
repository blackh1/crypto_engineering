`timescale 1ns/1ps

module cipher(
    input clk,
    input [63:0] pubk,
    input [21:0] prik,
    output reg[0:0] out_key=0,
    input flag,
    output reg[0:0] init_flag=1);

// input clk;
// input [63:0] pubk;
// input [21:0] prik;
// output reg[0:0] out_key=0;
// input flag;

integer i=0;

parameter length_lsfr1 = 18,length_lsfr2=21,length_lsfr3=22;    // 长度从0开始
reg [length_lsfr1:0] lsfr1=0;
reg [length_lsfr2:0] lsfr2=0;
reg [length_lsfr3:0] lsfr3=0;
reg [0:0] control1,control2,control3,final_control;
reg [0:0] temp1=0,temp2=0,temp3=0;

always @(posedge clk)
begin
    // for(i=21;i>=0;i=i-1) begin
    //     $display("%b",lsfr2[i]);
    // end
    if(init_flag==1) begin
        for(i=63;i>=0;i=i-1) begin
            temp1=lsfr1[length_lsfr1-18]^lsfr1[length_lsfr1-17]^lsfr1[length_lsfr1-16]^lsfr1[length_lsfr1-13]^pubk[i];
            temp2=lsfr2[length_lsfr2-20]^lsfr2[length_lsfr2-21]^pubk[i];
            temp3=lsfr3[length_lsfr3-22]^lsfr3[length_lsfr3-21]^lsfr3[length_lsfr3-20]^lsfr3[length_lsfr3-7]^pubk[i];
            
            lsfr1=lsfr1>>1;
            lsfr2=lsfr2>>1;
            lsfr3=lsfr3>>1;
            
            lsfr1[length_lsfr1]=temp1;
            lsfr2[length_lsfr2]=temp2;
            lsfr3[length_lsfr3]=temp3;
        
            if(i==0)   begin
                $display("lsfr initial done.");
            end
        end

    // 将帧序号混合其中
        for(i=21;i>=0;i=i-1) begin
            temp1=lsfr1[length_lsfr1-18]^lsfr1[length_lsfr1-17]^lsfr1[length_lsfr1-16]^lsfr1[length_lsfr1-13]^prik[i];
            temp2=lsfr2[length_lsfr2-20]^lsfr2[length_lsfr2-21]^prik[i];
            temp3=lsfr3[length_lsfr3-22]^lsfr3[length_lsfr3-21]^lsfr3[length_lsfr3-20]^lsfr3[length_lsfr3-7]^prik[i];
            
            lsfr1=lsfr1>>1;
            lsfr2=lsfr2>>1;
            lsfr3=lsfr3>>1;
            
            lsfr1[length_lsfr1]=temp1;
            lsfr2[length_lsfr2]=temp2;
            lsfr3[length_lsfr3]=temp3;

            if(i==0)   begin
                $display("private_key initial done.");
            end
        end

        // 混乱输出,+2是时序问题,最开始的密钥是未初始化的,选择性略过
        for(i=99+2;i>=0;i=i-1) begin
            control1=lsfr1[length_lsfr1-8];
            control2=lsfr2[length_lsfr2-10];
            control3=lsfr3[length_lsfr3-10];
            final_control=control1&control2|control2&control3|control3&control1;
            
            if (control1==final_control) begin
                temp1=lsfr1[length_lsfr1-18]^lsfr1[length_lsfr1-17]^lsfr1[length_lsfr1-16]^lsfr1[length_lsfr1-13];
                lsfr1=lsfr1>>1;
                lsfr1[length_lsfr1]=temp1;
            end

            if(control2==final_control)begin
                temp2=lsfr2[length_lsfr2-20]^lsfr2[length_lsfr2-21];
                lsfr2=lsfr2>>1;
                lsfr2[length_lsfr2]=temp2;
            end

            if(control3==final_control) begin
                temp3=lsfr3[length_lsfr3-22]^lsfr3[length_lsfr3-21]^lsfr3[length_lsfr3-20]^lsfr3[length_lsfr3-7];
                lsfr3=lsfr3>>1;
                lsfr3[length_lsfr3]=temp3;
            end
        end
        init_flag=0;
    end
    
    if(flag==1)
    begin
        // 输出密钥
        control1=lsfr1[length_lsfr1-8];
        control2=lsfr2[length_lsfr2-10];
        control3=lsfr3[length_lsfr3-10];
        final_control=control1&control2|control2&control3|control3&control1;
        
        if (control1==final_control) begin
            temp1=lsfr1[length_lsfr1-18]^lsfr1[length_lsfr1-17]^lsfr1[length_lsfr1-16]^lsfr1[length_lsfr1-13];
            lsfr1=lsfr1>>1;
            lsfr1[length_lsfr1]=temp1;
        end

        if(control2==final_control)begin
            temp2=lsfr2[length_lsfr2-20]^lsfr2[length_lsfr2-21];
            lsfr2=lsfr2>>1;
            lsfr2[length_lsfr2]=temp2;
        end

        if(control3==final_control) begin
            temp3=lsfr3[length_lsfr3-22]^lsfr3[length_lsfr3-21]^lsfr3[length_lsfr3-20]^lsfr3[length_lsfr3-7];
            lsfr3=lsfr3>>1;
            lsfr3[length_lsfr3]=temp3;
        end

        out_key=lsfr1[0]^lsfr2[0]^lsfr3[0];
    end
end

endmodule
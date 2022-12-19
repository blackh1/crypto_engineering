`timescale 1ns/1ps

module cipher(clk,msg,pubk,prik,out,ans,flag);

input clk;
input [255:0] msg;
input [63:0] pubk;
input [21:0] prik;
output reg[3:0] out;
output [255:0] ans;
input flag;

integer i=0;

parameter length_lsfr1 = 18,length_lsfr2=21,length_lsfr3=22;    // 长度从0开始
reg [length_lsfr1:0] lsfr1=0;
reg [length_lsfr2:0] lsfr2=0;
reg [length_lsfr3:0] lsfr3=0;
integer temp1,temp2,temp3;

always @(posedge clk)
begin
    if(flag==1)
    begin
        for(i=0;i<64;i=i+1) begin
            temp1=lsfr1[length_lsfr1-18]^lsfr1[length_lsfr1-17]^lsfr1[length_lsfr1-16]^lsfr1[length_lsfr1-13]^pubk[i];
            temp2=lsfr2[length_lsfr2-20]^lsfr2[length_lsfr2-21]^pubk[i];
            temp3=lsfr3[length_lsfr3-22]^lsfr3[length_lsfr3-21]^lsfr3[length_lsfr3-20]^lsfr3[length_lsfr3-7]^pubk[i];
            
            lsfr1=lsfr1>>1;
            lsfr2=lsfr2>>1;
            lsfr3=lsfr3>>1;
            
            lsfr1[length_lsfr1]=temp1;
            lsfr2[length_lsfr2]=temp2;
            lsfr3[length_lsfr3]=temp3;
            if(i==63)   begin
                $display("initial done.\n");
            end
        end

    end
end

endmodule
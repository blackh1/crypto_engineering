`timescale 1ps / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 09.04.2022 16:46:02
// Design Name: 
// Module Name: test
// Project Name: 
// Target Devices: 
// Tool Versions: 
// Description: 
// 
// Dependencies: 
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////////////////


module test();
reg clk;
initial begin
clk=1'b1;
forever
#5 clk=!clk;
end
integer f,id=0,j=65535,t=0,st=256,st2=256,rid=0;
localparam total=65536;
reg [7:0] mem[0:total];
reg [7:0] memo[0:total];
reg [65535:0] ans1;
reg [255:0] p;
reg [0:0] tr;
reg [65535:0] p1=0;
reg [3:0] num=0;
reg [63:0] pubk="hardware";
reg [21:0] priki=22'b1101001110000110010001;
reg [21:0] prik;
wire [3:0] out;
wire [255:0] ans;
cipher uut(p,pubk,prik,clk,out,tr,ans);
initial begin
    $readmemh("testfile.txt",mem); // read file from INFILE
    f = $fopen("output.txt","w");
end
always @(posedge clk)
begin
  if(id<65536)
  begin
   tr=0;
   p1[j]=mem[id][t];
   j=j-1;
   id=id+1;
   if(id==65536)
   begin
    $display("Split done for plane=%d",t+1);
    num=t+1;
   end
  end
  
  else if(num==t+1 && tr==0)
  begin
    prik={priki[21-:18],num};
    tr=1;
    num=t+2;
  end
  
  if(out==t+1 && st2>=0 && num==t+2)
  begin
     p=p1[(st2*256-1)-:256];
     if(st2<=255)
       ans1[(st2+1)*256-1-:256]=ans;
     st2=st2-1;
  end 
   
  if(out==t+1 && st2==-1)
  begin
   st2=256;
   if(num==t+2)
   begin
    $display("plane %d = %b",t+1,ans1);
    for(rid=0;rid<=65535;rid=rid+1)
       memo[rid][t]=ans1[65535-rid];
    t=t+1;
    ans1=0;
    id=0;
    p1=0;
    j=65535;
    if(t==8)
    begin
    $display("Writing");
    for(rid=0;rid<=65535;rid=rid+1)
       $fwrite(f,"%x\n",memo[rid]);
    $fclose(f);
    $display("Total Time=%0t",$time);
    $stop;
    end
   end
  end
 
end
endmodule
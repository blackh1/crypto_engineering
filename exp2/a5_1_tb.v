`timescale 1ps/1ps

module test();

reg clk;
// 设置时钟
initial begin
    clk = 1'b1;
    forever begin
        #5 clk=~clk;
    end
end


reg [7:0] mem[0:65535];
reg [255:0] msg=0;
reg [63:0] pubk="12345678";
reg [21:0] prik=22'b1101001110000110010001;
wire [3:0] out;
wire [255:0] ans;
reg flag=0;
integer f,cnt=0;
cipher uut(
    .clk(clk),
    .msg(msg),
    .pubk(pubk),
    .prik(prik),
    .out(out),
    .ans(ans),
    .flag(flag));

initial begin
    $readmemh("testfile.txt",mem);
    f=$fopen("output.txt","w");
end

always @(posedge clk)
begin

end


endmodule
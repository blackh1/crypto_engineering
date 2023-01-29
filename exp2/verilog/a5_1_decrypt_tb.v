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
reg [7:0] ans[0:65535];
reg [255:0] msg=0;
reg [63:0] pubk="hardware";
reg [21:0] prik=22'b1101001110000110010001;
wire [0:0] out_key;
wire [0:0] init_flag;
reg [0:0] flag=1'b0;
integer f,file,cnt=0,plane=0;
cipher uut(
    .clk(clk),
    .pubk(pubk),
    .prik(prik),
    .out_key(out_key),
    .flag(flag),
    .init_flag(init_flag));

initial begin
    $readmemh("output.txt",mem);
    file=$fopen("decrypt.txt","w");
end

always @(posedge clk)
begin
    if(init_flag==0) begin
        flag=1;
    end
    if(flag==1&&cnt<65536) begin
        ans[cnt][plane]=mem[cnt][plane]^out_key;
<<<<<<< HEAD:exp2/a5_1_decrypt_tb.v
        // if(cnt==0) begin
        //     $display("%b,%b",mem[cnt][plane],out_key);
        // end
=======
>>>>>>> blackhole:exp2/verilog/a5_1_decrypt_tb.v
        plane=plane+1;
        if(plane==8) begin
            cnt=cnt+1;
            plane=0;
        end
    end
    if(cnt==65536) begin
        for(f=0;f<65536;f=f+1) begin
            $fwrite(file,"%02x\n",ans[f]);
        end
        $fclose(file);
        $display("finished.");
        $display("Total time=%0t",$time);
<<<<<<< HEAD:exp2/a5_1_decrypt_tb.v
        // $display("%b",ans[0]);
        // $display("%b",ans[1]);

=======
>>>>>>> blackhole:exp2/verilog/a5_1_decrypt_tb.v
        $stop;
    end
end


endmodule
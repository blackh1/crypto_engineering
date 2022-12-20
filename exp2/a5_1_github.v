`timescale 1ns/1ps

// module cipher (clk,msg,pubk,prik,out,tr,ans);
module cipher(p,pubk,prik,clk,out,tr,ans);
    integer x=0;

input [255:0] p;
output reg[255:0] ans;
input [63:0] pubk;
input [21:0] prik;
input clk;
input tr;
output reg[3:0] out=0;
reg [18:0] r1=0;
reg [21:0] r2=0;
reg [22:0] r3=0;
reg [0:0] a,b,c;
reg [256*256-1:0] key;
integer i=63,j,k=21,m=99,z=256*256-1,st=256;
integer xo1,xo2,xo3,cou=0;
reg [0:0] o;
always @(posedge clk)
begin
	if(tr==1)
 	begin
		if(i>=0)
		begin
			ans=0;
			xo1=r1[5]^r1[2]^r1[1]^r1[0]^pubk[i];
			xo2=r2[1]^r2[0]^pubk[i];
			xo3=r3[15]^r3[2]^r3[1]^r3[0]^pubk[i];
			r1=r1>>1;
			r1[18]=xo1;
			
			r2=r2>>1;
			r2[21]=xo2;
			
			r3=r3>>1;
			r3[22]=xo3;
			i=i-1;
			if(i==-1)
				$display("i done");
		end

		if(k>=0 && i<0)
		begin
			xo1=r1[5]^r1[2]^r1[1]^r1[0]^prik[k];
			xo2=r2[1]^r2[0]^prik[k];
			xo3=r3[15]^r3[2]^r3[1]^r3[0]^prik[k];
			r1=r1>>1;
			r1[18]=xo1;
		
			r2=r2>>1;
			r2[21]=xo2;
		
			r3=r3>>1;
			r3[22]=xo3;
			k=k-1;
			if(k==-1)
			$display("k done");
		end
	
		if(k<0 && m>=0)
		begin
			a=r1[10];
			b=r2[11];
			c=r3[12];
			o=a&b|b&c|c&a;
			// o=maj(a,b,c);

			if(a==o)
			begin
				xo1=r1[5]^r1[2]^r1[1]^r1[0];
				r1=r1>>1;
				r1[18]=xo1;
			end

			if(b==o)
			begin
				xo2=r2[1]^r2[0];
				r2=r2>>1;
				r2[21]=xo2;
			end

			if(c==o)
			begin
				xo3=r3[15]^r3[2]^r3[1]^r3[0];
				r3=r3>>1;
				r3[22]=xo3;
			end
			m=m-1;
			if(m==-1)
				$display("m done");
		end
		
		if(m<0 && z>=0)
		begin
			a=r1[10];
			b=r2[11];
			c=r3[12];
			o=a&b|b&c|c&a;
			// o=maj(a,b,c);

			if(a==o)
			begin
				xo1=r1[5]^r1[2]^r1[1]^r1[0];
				r1=r1>>1;
				r1[18]=xo1;
			end

			if(b==o)
			begin
				xo2=r2[1]^r2[0];
				r2=r2>>1;
				r2[21]=xo2;
			end

			if(c==o)
			begin
				xo3=r3[15]^r3[2]^r3[1]^r3[0];
				r3=r3>>1;
				r3[22]=xo3;
			end

			key[z]=r1[0]^r2[0]^r3[0];
			z=z-1;

			if(z==-1)
			begin
				$display("z done");
				$display("key=%b",key);
				out=out+1;

			end
		end  

		if(z<0 && out!=0)
		begin
			if(^p===1'bx)
				$display("Skipping");
			else
			begin
				ans=p^key[st*256-1-:256];
				st=st-1;
				if(st==0)
				begin
					i=63;
					k=21;
					m=99;
					z=256*256-1;
					r1=0;
					r2=0;
					r3=0;
					key=0;
					st=256;
					$display("Reinit for new plane");
				end
			end
		end
	end
end
endmodule
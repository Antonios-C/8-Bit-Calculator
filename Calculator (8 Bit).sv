module top (
  // I/O ports
  input  logic hz100, reset,
  input  logic [20:0] pb,
  output logic [7:0] left, right,
         ss7, ss6, ss5, ss4, ss3, ss2, ss1, ss0,
  output logic red, green, blue,

  // UART ports
  output logic [7:0] txdata,
  input  logic [7:0] rxdata,
  output logic txclk, rxclk,
  input  logic txready, rxready
);

  // Your code goes here...
  /*
  logic [31:0] p;
          bcdmult8x8 bm1(.clk(pb[16]), .reset(pb[17]), .a(32'd4), .b(32'd5), .p(p));
          ssdec s0(.in(p[3:0]),   .out(ss0[6:0]), .enable(1));
          ssdec s1(.in(p[7:4]),   .out(ss1[6:0]), .enable(1));
          ssdec s2(.in(p[11:8]),  .out(ss2[6:0]), .enable(1));
          ssdec s3(.in(p[15:12]), .out(ss3[6:0]), .enable(1));
          ssdec s4(.in(p[19:16]), .out(ss4[6:0]), .enable(1));
          ssdec s5(.in(p[23:20]), .out(ss5[6:0]), .enable(1));
          ssdec s6(.in(p[27:24]), .out(ss6[6:0]), .enable(1));
          ssdec s7(.in(p[31:28]), .out(ss7[6:0]), .enable(1));
  
  */
  logic ne;
  logic [6:0]inter;
  logic [4:0] keycode;
  logic strobe;
  synckey sk1 (.clk(hz100), .rst(reset), .in(pb[19:0]), .strobe(strobe), .out(keycode));
  logic [31:0] data;
  digits d1 (.in(keycode), .out(data), .clk(strobe), .reset(reset), .neg(ne));
  ssdec s0(.in(data[3:0]),   .out(ss0[6:0]), .enable(1'b1));
  ssdec s1(.in(data[7:4]),   .out(ss1[6:0]), .enable(|data[31:4]));
  ssdec s2(.in(data[11:8]),  .out(ss2[6:0]), .enable(|data[31:8]));
  ssdec s3(.in(data[15:12]), .out(ss3[6:0]), .enable(|data[31:12]));
  ssdec s4(.in(data[19:16]), .out(ss4[6:0]), .enable(|data[31:16]));
  ssdec s5(.in(data[23:20]), .out(ss5[6:0]), .enable(|data[31:20]));
  ssdec s6(.in(data[27:24]), .out(ss6[6:0]), .enable(|data[31:24]));
  ssdec s7(.in(data[31:28]), .out(inter), .enable(|data[31:28]));
  
  always_comb begin 
  if(ne)
    ss7[6:0] = 7'b1000000;
  else 
    ss7[6:0] = inter;
  end
  
  
endmodule

module bcdmult8x8(
input logic clk,
input logic reset,
input logic [31:0] a, b, 
output logic [31:0] p
); 

logic [31:0] accum;
logic [31:0] atmp; // copy of a
logic [31:0] btmp; // copy of b
logic [31:0] num;
logic [31:0] tt;
always_ff @(posedge clk) begin 
if(reset) begin 
  accum <= 0;
  atmp <= a;
  btmp <= b;
  end
else begin 
  accum <= tt;
  atmp <= atmp >> 4;
  btmp <= btmp << 4;
  end
end

bcdmult8x1 bm1(.a(atmp[3:0]), .b(btmp[31:0]), .p(num));
bcdadd8 bm2(.a(accum), .b(num), .ci(1'b0), .s(tt));
assign p = accum;

endmodule

module bcdadd8( ////WORKING
input logic [31:0] a , b,
input logic ci, 
output logic co,
output logic [31:0]s
);

logic c1, c2, c3, c4, c5 ,c6 , c7;

bcdadd1 ba1(.a(a[3:0]), .b(b[3:0]), .ci(ci), .co(c1), .s(s[3:0]));
bcdadd1 ba2(.a(a[7:4]), .b(b[7:4]), .ci(c1), .co(c2), .s(s[7:4]));
bcdadd1 ba3(.a(a[11:8]), .b(b[11:8]), .ci(c2), .co(c3), .s(s[11:8]));
bcdadd1 ba4(.a(a[15:12]), .b(b[15:12]), .ci(c3), .co(c4), .s(s[15:12]));
bcdadd1 ba5(.a(a[19:16]), .b(b[19:16]), .ci(c4), .co(c5), .s(s[19:16]));
bcdadd1 ba6(.a(a[23:20]), .b(b[23:20]), .ci(c5), .co(c6), .s(s[23:20]));
bcdadd1 ba7(.a(a[27:24]), .b(b[27:24]), .ci(c6), .co(c7), .s(s[27:24]));
bcdadd1 ba8(.a(a[31:28]), .b(b[31:28]), .ci(c7), .co(co), .s(s[31:28]));


endmodule


module bcdmult8x1 (
input [3:0]a,
input [31:0]b,
output [31:0]p
);
logic co1, co2, co3, co4, co5, co6;
logic [7:0]store;
logic [7:0]store1, store2, store3, store4, store5, store6, store7;

bcdmult1x1 ba1(.a(a), .b(b[3:0]), .p(store));
bcdmult1x1 ba2(.a(a), .b(b[7:4]), .p(store1));
assign p[3:0] = store[3:0];
bcdadd1 b1(.a(store[7:4]), .b(store1[3:0]), .ci(1'b0), .co(co1), .s(p[7:4]));

bcdmult1x1 ba3(.a(a), .b(b[11:8]), .p(store2));
bcdadd1 b2(.a(store1[7:4]), .b(store2[3:0]), .ci(co1), .co(co2), .s(p[11:8]));

bcdmult1x1 ba4(.a(a), .b(b[15:12]), .p(store3));
bcdadd1 b3(.a(store2[7:4]), .b(store3[3:0]), .ci(co2), .co(co3), .s(p[15:12]));

bcdmult1x1 ba5(.a(a), .b(b[19:16]), .p(store4));
bcdadd1 b4(.a(store3[7:4]), .b(store4[3:0]), .ci(co3), .co(co4), .s(p[19:16]));

bcdmult1x1 ba6(.a(a), .b(b[23:20]), .p(store5));
bcdadd1 b5(.a(store4[7:4]), .b(store5[3:0]), .ci(co4), .co(co5), .s(p[23:20]));

bcdmult1x1 ba7(.a(a), .b(b[27:24]), .p(store6));
bcdadd1 b6(.a(store5[7:4]), .b(store6[3:0]), .ci(co5), .co(co6), .s(p[27:24]));

bcdmult1x1 ba8(.a(a), .b(b[31:28]), .p(store7));
bcdadd1 b7(.a(store6[7:4]), .b(store7[3:0]), .ci(co6), .co(), .s(p[31:28]));

endmodule

module digits (
input logic reset, clk,
input logic [4:0]in,
output logic [31:0] out,
output logic neg
);

logic [31:0] current, save, result;
logic [3:0] op;
logic show;
logic [7:0] full;
logic [31:0]tmp, negtmp;
logic [3:0] stage;

always_comb begin 
if(show)
  tmp = save;
else
  tmp = current;
end

always_comb begin 
if(neg)
  out = negtmp;
else 
  out = tmp;
end

always_comb begin 
if(tmp[31:28] == 9)
  neg = 1'b1;
else
  neg = 1'b0;
end

bcdaddsub8 basneg(.a(0), .b(tmp), .op(1), .s(negtmp));

always_ff @(posedge clk, posedge reset) begin 
  if(reset) begin 
    current <= 32'b0;
    save <= 32'b0;
    op <= 4'b0;
    show <= 1'b0;
    full <= 8'b0;
    stage <= 4'b0;
    end
  else
    casez(in) 
    5'b00??? : begin 
               if(show) begin 
                current <= {28'b0,in[3:0]};
                show <= 0;
                if(in[3]| in[2]| in[1] | in[0])
                  full <= 8'b00000001;
                end
               else begin
                if (~(&full[7:0])) 
                      current <= {current[27:0], in[3:0]};
                      if (full[0] || |in)
                          full <= {full[6:0],1'b1};
                end
               end
    5'b0100? : begin 
               if(show) begin 
                current <= {28'b0,in[3:0]};
                show <= 0;
                if(in[3]| in[2]| in[1] | in[0])
                  full <= 8'b00000001;
                end
               else begin
                if (~(&full[7:0])) 
                      current <= {current[27:0], in[3:0]};
                      if (full[0] || |in)
                          full <= {full[6:0],1'b1};
                end
               end
    5'b10000 : begin
              if(op == 4'd2) begin       
                if(stage < 9)
                  stage <= stage + 1;
                else begin
                  stage <= 0;
                  show <= 1'b1;
                  full <= 8'b0;
                  save <= result;
                end
              end
              else begin 
              save <= result;
              show <= 1'b1;
              full <= 8'b0;
              end
              end
    5'b10001 :begin 
               op <= 4'd2;
               if(~show)
                save <= current;
               current <= 32'b0;
               show <= 1'b1;
               full <= 8'b0;
               end
    5'b10010 : begin 
               op <= 4'b0;
               if(~show)
                save <= current;
               current <= 32'b0;
               show <= 1'b1;
               full <= 8'b0;
               end
    5'b10011 : begin 
               op <= 4'b1;
               if(~show)
                save <= current;
               current <= 32'b0;
               show <= 1'b1;
               full <= 8'b0;
               end
    endcase
end

math m (.clk(clk), .reset(stage == 0), .op(op), .a(save), .b(current), .r(result));

endmodule


module bcdadd1( ///WORKING
input logic [3:0]a, b,
input logic ci, 
output logic co, 
output logic [3:0]s
);

logic cOut, carry;
logic [3:0] sum1;
fa4 f1(.a(a), .b(b), .ci(ci), .s(sum1), .co(cOut));

assign carry = (sum1[3] * sum1[2]) | cOut | (sum1[3]*sum1[1]);

fa4 f2(.a(sum1), .b({1'b0,carry,carry,1'b0}), .ci(1'b0), .s(s), .co());

assign co = carry;

endmodule


module bcdmult1x1(input logic [3:0]a,b, output logic [7:0] p);
          always_comb
            casez({a,b})
              8'b0000????: p = 0;
              8'b????0000: p = 0;
              8'b0001????: p = {4'b0,b};
              8'b????0001: p = {4'b0,a};
              8'h22: p = 8'h04;
              8'h23: p = 8'h06;
              8'h24: p = 8'h08;
              8'h25: p = 8'h10;
              8'h26: p = 8'h12;
              8'h27: p = 8'h14;
              8'h28: p = 8'h16;
              8'h29: p = 8'h18;
              8'h32: p = 8'h06;
              8'h33: p = 8'h09;
              8'h34: p = 8'h12;
              8'h35: p = 8'h15;
              8'h36: p = 8'h18;
              8'h37: p = 8'h21;
              8'h38: p = 8'h24;
              8'h39: p = 8'h27;
              8'h42: p = 8'h08;
              8'h43: p = 8'h12;
              8'h44: p = 8'h16;
              8'h45: p = 8'h20;
              8'h46: p = 8'h24;
              8'h47: p = 8'h28;
              8'h48: p = 8'h32;
              8'h49: p = 8'h36;
              8'h52: p = 8'h10;
              8'h53: p = 8'h15;
              8'h54: p = 8'h20;
              8'h55: p = 8'h25;
              8'h56: p = 8'h30;
              8'h57: p = 8'h35;
              8'h58: p = 8'h40;
              8'h59: p = 8'h45;
              8'h62: p = 8'h12;
              8'h63: p = 8'h18;
              8'h64: p = 8'h24;
              8'h65: p = 8'h30;
              8'h66: p = 8'h36;
              8'h67: p = 8'h42;
              8'h68: p = 8'h48;
              8'h69: p = 8'h54;
              8'h72: p = 8'h14;
              8'h73: p = 8'h21;
              8'h74: p = 8'h28;
              8'h75: p = 8'h35;
              8'h76: p = 8'h42;
              8'h77: p = 8'h49;
              8'h78: p = 8'h56;
              8'h79: p = 8'h63;
              8'h82: p = 8'h16;
              8'h83: p = 8'h24;
              8'h84: p = 8'h32;
              8'h85: p = 8'h40;
              8'h86: p = 8'h48;
              8'h87: p = 8'h56;
              8'h88: p = 8'h64;
              8'h89: p = 8'h72;
              8'h92: p = 8'h18;
              8'h93: p = 8'h27;
              8'h94: p = 8'h36;
              8'h95: p = 8'h45;
              8'h96: p = 8'h54;
              8'h97: p = 8'h63;
              8'h98: p = 8'h72;
              8'h99: p = 8'h81;
              default: p = 0;
            endcase
endmodule


module math(
input logic clk, reset,
input logic [3:0] op,
input logic [31:0] a,b,
output logic [31:0] r);

logic [31:0] prod, addsub;

bcdmult8x8 bm1(.clk(clk), .reset(reset), .a(a), .b(b), .p(prod));
bcdaddsub8 bas1(.a(a), .b(b), .op(op[0]), .s(addsub));

always_comb begin 
case(op)
0 : r = addsub;
1 : r = addsub;
2 : r = prod;
default : r = 0;
endcase
end

endmodule

module ssdec(  
  input logic [3:0] in,
  input logic enable,
  output logic [6:0]out
);
always_comb
  begin 
    case({enable,in})
    5'b10000 : out = 7'b0111111;
    5'b10001 : out = 7'b0000110;
    5'b10010 : out = 7'b1011011;
    5'b10011 : out = 7'b1001111;
    5'b10100 : out = 7'b1100110;
    5'b10101 : out = 7'b1101101;
    5'b10110 : out = 7'b1111101;
    5'b10111 : out = 7'b0000111;
    5'b11000 : out = 7'b1111111;
    5'b11001 : out = 7'b1100111;
    5'b11010 : out = 7'b1110111;
    5'b11011 : out = 7'b1111100;
    5'b11100 : out = 7'b0111001;
    5'b11101 : out = 7'b1011110;
    5'b11110 : out = 7'b1111001;
    5'b11111 : out = 7'b1110001;
    default : out = 7'b0000000;
    endcase
  end
endmodule

module synckey(
input logic clk, rst,
input logic [19:0] in, 
output logic [4:0] out,
output logic strobe
);
  assign out[0] = in[1] | in[3] | in[5] | in[7] | in[9] | in[11] | in[13] | in[15] | in[17] | in[19];
  assign out[1] = in[2] | in[3] | in[6] | in[7] | in[10] | in[11] | in[14] | in[15] | in[18] | in[19];
  assign out[2] = in[4] | in[5] | in[6] | in[7] | in[12] | in[13] | in[14] | in[15];
  assign out[3] = in[8] | in[9] | in[10] | in[11] | in[12] | in[13] | in[14] | in[15];
  assign out[4] = in[16] | in[17] | in[18] | in[19];
  logic keyclk;
  assign keyclk = | in[19:0];
  logic [1:0] delay; 
  always_ff @(posedge clk, posedge rst) begin 
    if(rst)
      delay <= 2'b0;
    else 
      delay <= (delay << 1) | {1'b0, keyclk};
  end
  assign strobe = delay[1];
endmodule


module bcdaddsub8(
input logic [31:0]a, b,
input logic op, 
output logic [31:0]s
);

logic carry;
logic [31:0] ones;
logic [31:0] nine;

bcd9comp1 cmp1(.in(b[3:0]), .out(nine[3:0]));
bcd9comp1 cmp2(.in(b[7:4]), .out(nine[7:4]));
bcd9comp1 cmp3(.in(b[11:8]), .out(nine[11:8]));
bcd9comp1 cmp4(.in(b[15:12]), .out(nine[15:12]));
bcd9comp1 cmp5(.in(b[19:16]), .out(nine[19:16]));
bcd9comp1 cmp6(.in(b[23:20]), .out(nine[23:20]));
bcd9comp1 cmp7(.in(b[27:24]), .out(nine[27:24]));
bcd9comp1 cmp8(.in(b[31:28]), .out(nine[31:28]));



always_comb begin 
  case(op)
  1 : {carry, ones} = {1'b1, nine};
  0 : {carry, ones} = {1'b0, b};
  endcase
end

bcdadd8 ba1(.a(a), .b(ones), .ci(carry), .co(), .s(s));

endmodule

module bcd9comp1( ///WORKING
input logic [3:0] in, 
output logic [3:0] out
);

always_comb begin 
case(in)
0: out = 4'b1001;
1: out = 4'b1000;
2: out = 4'b0111;
3: out = 4'b0110;
4: out = 4'b0101;
5: out = 4'b0100;
6: out = 4'b0011;
7: out = 4'b0010;
8: out = 4'b0001;
9: out = 4'b0000;
default : out = 4'b1001;
endcase

end

endmodule



module fa4( ///WORKING
input logic [3:0]a, b, 
input logic ci, 
output logic co,
output logic [3:0] s
);

logic c1, c2, c3;

fa b0(.a(a[0]), .b(b[0]), .ci(ci), .s(s[0]), .co(c1));
fa b1(.a(a[1]), .b(b[1]), .ci(c1), .s(s[1]), .co(c2));
fa b2(.a(a[2]), .b(b[2]), .ci(c2), .s(s[2]), .co(c3));
fa b3(.a(a[3]), .b(b[3]), .ci(c3), .s(s[3]), .co(co));

endmodule

module fa( ///WORKING
input logic a, b, ci, 
output logic s, co
);

assign s = a ^ b ^ ci;
assign co = (a&b) | (b&ci) | (a&ci); 

endmodule



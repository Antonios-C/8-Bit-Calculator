`default_nettype none
// Empty top module

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
  cla8 cl1(.a(pb[7:0]), .b(pb[15:8]), .ci(pb[19]), .s(right[7:0]), .co(red));
endmodule

// Add more modules down here...
module cla8(
input logic [7:0] a, b,
input logic ci, 
output logic co,
output logic [7:0]s
);

logic p0, p1, p2, p3, p4, p5, p6, p7;
logic g0, g1, g2, g3, g4, g5, g6, g7; 
logic [7:0] c;

ha h1(.a(a[0]), .b(b[0]), .s(p0), .co(g0));
ha h2(.a(a[1]), .b(b[1]), .s(p1), .co(g1));
ha h3(.a(a[2]), .b(b[2]), .s(p2), .co(g2));
ha h4(.a(a[3]), .b(b[3]), .s(p3), .co(g3));
ha h5(.a(a[4]), .b(b[4]), .s(p4), .co(g4));
ha h6(.a(a[5]), .b(b[5]), .s(p5), .co(g5));
ha h7(.a(a[6]), .b(b[6]), .s(p6), .co(g6));
ha h8(.a(a[7]), .b(b[7]), .s(p7), .co(g7));

assign c[0] = g0 | ci & p0;
assign c[1] = g1 | g0 & p1 | ci & p0 & p1;
assign c[2] = g2 | g1 & p2 | g0 & p1 & p2 | ci & p0 & p1 & p2;
assign c[3] = g3 | g2 & p3 | g1 & p2 & p3 | g0 & p1 & p2 & p3 | ci & p0 & p1 & p2 & p3;
assign c[4] = g4 | g3 & p4 | g2 & p3 & p4 | g1 & p2 & p3 & p4 | g0 & p1 & p2 & p3 & p4 | ci & p0 & p1 & p2 & p3 & p4;
assign c[5] = g5 | g4 & p5 | g3 & p4 & p5 | g2 & p3 & p4 & p5 | g1 & p2 & p3 & p4 & p5 | g0 & p1 & p2 & p3 & p4 & p5 | ci & p0 & p1 & p2 & p3 & p4 & p5;
assign c[6] = g6 | g5 & p6 | g4 & p5 & p6 | g3 & p4 & p5 & p6 | g2 & p3 & p4 & p5 & p6 | g1 & p2 & p3 & p4 & p5 & p6 | g0 & p1 & p2 & p3 & p4 & p5 & p6 | ci & p0 & p1 & p2 & p3 & p4 & p5 & p6;
assign c[7] = g7 | g6 & p7 | g5 & p6 & p7 | g4 & p5 & p6 & p7 | g3 & p4 & p5 & p6 & p7 | g2 & p3 & p4 & p5 & p6 & p7 | g1 & p2 & p3 & p4 & p5 & p6 & p7 | g0 & p1 & p2 & p3 & p4 & p5 & p6 & p7 | ci & p0 & p1 & p2 & p3 & p4 & p5 & p6 & p7;

//assign s = {p7, p6, p5, p4 ,p3, p2, p1, p0};
assign s = c;

/*
assign s[0] = p0 ^ ci;
assign s[1] = p1 ^ c[0];
assign s[2] = p2 ^ c[1];
assign s[3] = p3 ^ c[2];
assign s[4] = p4 ^ c[3];
assign s[5] = p5 ^ c[4];
assign s[6] = p6 ^ c[5];
assign s[7] = p7 ^ c[6];
assign co = c[7];
*/

endmodule

module ha( ///WORKING
input logic a, b, 
output logic s, co
);

assign s = a ^ b;
assign co = a & b;

endmodule

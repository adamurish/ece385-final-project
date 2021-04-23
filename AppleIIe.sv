module AppleIIe (
	input MAX10_CLK1_50, 
	input [1:0] KEY,
	output [9:0] LEDR,
	output [6:0] HEX0, HEX1, HEX2, HEX3);
	
	logic [15:0] address;
	logic rw;
	logic [7:0] dram_out, dram_in;
	
	chip_6502 CPU(.clk(MAX10_CLK1_50), .phi(KEY[0]), .nmi(1), .irq(1), .res(KEY[1]), .rdy(1), .so(1), .ab(address), .rw, .dbo(dram_in), .dbi(dram_out));
	dram_bundle dram(.clk(MAX10_CLK1_50), .rw, .A(address), .md_in(dram_in), .md_out(dram_out));
	
	HexDriver h0 (.In0(address[3:0]), .Out0(HEX0));
	HexDriver h1 (.In0(address[7:4]), .Out0(HEX1));
	HexDriver h2 (.In0(address[11:8]), .Out0(HEX2));
	HexDriver h3 (.In0(address[15:12]), .Out0(HEX3));
endmodule
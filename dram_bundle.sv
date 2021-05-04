module dram_bundle(
	input rw, clk, // rw is high for read, low for write
	input [15:0] A, // address (full 16 bits, differs from multiplexed original design)
	input [7:0] md_in,
	output [7:0] md_out);
	
	logic [7:0] mem [65536];
	
	initial
	begin
		$readmemh("rom.hex", mem, 32768, 65535);
	end
	
	always_ff @ (posedge clk)
	begin
		if(~rw) mem[A] <= md_in;
		md_out <= mem[A];
	end
endmodule
	
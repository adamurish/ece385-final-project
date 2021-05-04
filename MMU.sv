module MMU(
	input[15:0] A, // address
	input[7:0] md_in,
	input phi0, //timing signals
	input rw, //read write control (r/w`)
	output kbd, c0xx,
	output[7:0] md_out);
	
	logic PAGE2, HIRES, BANKED_RAM, BANK2; // SOFT SWITCHES
	
	logic [7:0] main_ram [49152]; 		//x0000 - xBFFF
	logic [7:0] banked_ram_4k1 [4096];	//xD000 - xDFFF (BANK 1)
	logic [7:0] banked_ram_4k2 [4096];	//xD000 - xDFFF (BANK 2)
	logic [7:0] banked_ram [12288];		//xE000 - xFFFF
	
	logic [7:0] rom1 [8192];				//xC000 - xDFFF
	logic [7:0] rom2 [8192];				//xE000 - xFFFF
	
	always_ff @ (posedge phi0)
	begin
	end
	
endmodule
module MMU(
	input[15:0] A, // address
	input[7:0] md_in,
	input phi0, //timing signals
	input rw, //read write control (r/w`)
	output kbd, c0xx,
	output[7:0] md_out);
	
	// SOFT SWITCHES
	logic PAGE2 = 0;
	logic HIRES = 0;
	logic BANKED_RAM = 0;
	logic BANK2 = 0;
	
	logic [7:0] main_ram [49152]; 		//x0000 - xBFFF
	logic [7:0] main_ram_out;
	logic [7:0] banked_ram_4k1 [4096];	//xD000 - xDFFF (BANK 1)
	logic [7:0] banked_ram_4k1_out;
	logic [7:0] banked_ram_4k2 [4096];	//xD000 - xDFFF (BANK 2)
	logic [7:0] banked_ram_4k2_out;
	logic [7:0] banked_ram [8192];		//xE000 - xFFFF
	logic [7:0] banked_ram_out;
	
	logic [7:0] rom [16384];					//xC000 - xFFFF
	logic [7:0] rom_out;
	
	initial
	begin
		$readmemh("rom.hex", rom);
	end
	
	logic top;
	logic in_4k;
	
	always_ff @ (posedge phi0)
	begin
		main_ram_out <= main_ram[A];
		banked_ram_4k1_out <= banked_ram_4k1[A - 16'hD000];
		banked_ram_4k2_out <= banked_ram_4k2[A - 16'hD000];
		banked_ram_out <= banked_ram[A - 16'hE000];
		rom_out <= rom[A - 16'hC000];
		
		top <= A > 16'hC000;
		in_4k <= top & A < 16'hE000;
		
		if(A == 16'hC0XX) //SOME SORT OF IO OPERATION
		begin
			c0xx <= 1;	//IO ENABLE SIGNAL FOR IOU
			if(A == 16'hC000) kbd <= 1; //KEYBOARD DATA LOCATION
			else kbd <= 0;
			md_out <= 8'bx;	//MD WILL BE HANDLED BY KB OR BY IOU
		end
		
		if(~top) md_out <= main_ram_out;
		else if(~BANKED_RAM) md_out <= rom_out;	//ADDRESS ABOVE IO, BANKED RAM OFF
		else if(~in_4k) md_out <= banked_ram_out; 	//regular banked ram
		else md_out <= BANK2 ? banked_ram_4k2_out : banked_ram_4k1_out;	//BANKED RAM 4k BLOCKS
		
		if(~rw)
		begin
			if(~top) main_ram[A] <= md_in;
			else if(BANKED_RAM & ~in_4k) banked_ram[A - 16'hE000] <= md_in; 	//regular banked ram
			else if(BANKED_RAM & ~BANK2) banked_ram_4k1[A - 16'hD000] <= md_in;	//BANKED RAM 4k BLOCKS
			else if(BANKED_RAM) banked_ram_4k2[A - 16'hD000] <= md_in;	//BANKED RAM 4k BLOCKS
		end
	end
//		else
//		begin
//			c0xx <= 0;
//			kbd <= 0;
//			if(rw)
//			begin
//				if(A > 16'hC000) //ABOVE THE I/O
//				begin
//					if(BANKED_RAM & A < 16'hE000) //MIRRORED RAM AREA
//						md_out <= BANK2 ? banked_ram_4k2[A - 16'hD000] : banked_ram_4k1[A - 16'hD000];
//					else if(BANKED_RAM) //NORMAL BANKED RAM AREA
//						md_out <= banked_ram[A - 16'hE000];
//					else	//ACCESSING ROM
//						md_out <= rom[A - 16'hC000];
//				end
//				else	//ACCESSING MAIN RAM
//					md_out <= main_ram[A];
//			end
//			else
//			begin
//				md_out <= main_ram[0];
//				if(A > 16'hC000) //ABOVE THE I/O
//				begin
//					if(BANKED_RAM & A < 16'hE000) //MIRRORED RAM AREA
//					begin
//						if(BANK2)
//							banked_ram_4k2[A - 16'hD000] <= md_in;
//						else
//							banked_ram_4k1[A - 16'hD000] <= md_in;
//					end
//					else if(BANKED_RAM) //NORMAL BANKED RAM AREA
//						banked_ram[A - 16'hE000] <= md_in;
//				end
//				else	//ACCESSING MAIN RAM
//					main_ram[A] <= md_in;
//			end
//		end
//	end
	
endmodule
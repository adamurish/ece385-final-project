module IOU(
	input phi0, c0xx, akd, pixel_clk, kstrb,
	input [7:0] vid, 
	input [15:0] address_in,
	input [9:0] DrawX, DrawY,
	output [15:0] vid_address_out,
	output md7,
	output bw_pixel, rw);
	
	logic [6:0] hc;
	logic [8:0] vc;
	logic [3:0] shiftc;
	logic [3:0] sum;
	logic [2:0] counter_counter;
	
	logic [7:0] vid_buffer;
	logic [7:0] vid_shift;
	
	logic [7:0] video_rom [4096]; 
	logic [11:0] vid_rom_address;
	
	logic next_pixel;
	logic kstrb_switch;
	
	assign rw = pixel_clk;
	
	initial
	begin
		$readmemh("video_rom.hex", video_rom);
	end

	always_comb
	begin
		if(address_in == 16'hC010) md7 = akd;
		else if (address_in == 16'hC000) md7 = kstrb_switch;
		else if (address_in == 16'hC01A) md7 = 1;
		else if (address_in == 16'hC015) md7 = 1;
		else md7 = 0;
	end

	always_ff @ (posedge phi0)
	begin
		if(kstrb) kstrb_switch <= 1;
		if(address_in == 16'hC010)
		begin
			kstrb_switch <= 0;
		end
	end
	
	always_comb
	begin
		sum = {~hc[5], vc[6], hc[4], hc[3]} + {vc[7], ~hc[5], vc[7], 1'b1} + vc[6];
		vid_address_out = {5'b0, 1'b1, vc[5], vc[4], vc[3], sum[3], sum[2], sum[1], sum[0], hc[2], hc[1], hc[0]};
		vid_rom_address = {2'b00, vid_buffer[6:0], vc[2:0]};
	end
	
	always_ff @ (posedge pixel_clk)
	begin
		//HORIZANTAL AND VERITALC COUNTERS
		
		if(DrawX >= 100 & DrawX < 380)
		begin
			if(counter_counter == 3'd6)
			begin
				counter_counter <= 0;
				hc <= hc + 1;
			end
			else	counter_counter <= counter_counter + 1;
		end
		else
		begin
			counter_counter <= 0;
			hc <= 7'd24;
		end
		
		if(DrawY >= 100 & DrawY < 292) vc <= DrawY - 100;
		else vc <= 0;
		
		//GENERATING DISPLAY ADDRESS

		vid_buffer <= vid;
		
		next_pixel <= video_rom[vid_rom_address][7-counter_counter];
	
		if(DrawX >= 100 & DrawX < 380 & DrawY >= 100 & DrawY < 292)
		begin
			bw_pixel <= next_pixel;
		end
		else bw_pixel <= 0;
	end
	
endmodule
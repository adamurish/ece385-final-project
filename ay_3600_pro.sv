module ay_3600_pro(
	input phi0,
	input [7:0] keycode, //keycode from nios2
	output [6:0] md_out,	//ASCII keycode output
	output kstrb, akd);	//keyboard strobe and any key down
	
	logic strobed;
	always_ff @ (posedge phi0)
	begin
		if(~strobed & akd) 
		begin
			kstrb <= 1;
			strobed <= 1;
		end
		
		if(strobed) kstrb <= 0;
		if(~akd) strobed <= 0;
	end
	
	always_comb
	begin
		akd = 1;
		case(keycode)
			//ALPHABET
			8'd4: md_out = 7'd65;
			8'd5: md_out = 7'd66;
			8'd6: md_out = 7'd67;
			8'd7: md_out = 7'd68;
			8'd8: md_out = 7'd69;
			8'd9: md_out = 7'd70;
			8'd10: md_out = 7'd71;
			8'd11: md_out = 7'd72;
			8'd12: md_out = 7'd73;
			8'd13: md_out = 7'd74;
			8'd14: md_out = 7'd75;
			8'd15: md_out = 7'd76;
			8'd16: md_out = 7'd77;
			8'd17: md_out = 7'd78;
			8'd18: md_out = 7'd79;
			8'd19: md_out = 7'd80;
			8'd20: md_out = 7'd81;
			8'd21: md_out = 7'd82;
			8'd22: md_out = 7'd83;
			8'd23: md_out = 7'd84;
			8'd24: md_out = 7'd85;
			8'd25: md_out = 7'd86;
			8'd26: md_out = 7'd87;
			8'd27: md_out = 7'd88;
			8'd28: md_out = 7'd89;
			8'd29: md_out = 7'd90;
			// NUMBERS
			8'd30: md_out = 6'd49;
			8'd31: md_out = 6'd50;
			8'd32: md_out = 6'd51;
			8'd33: md_out = 6'd52;
			8'd34: md_out = 6'd53;
			8'd35: md_out = 6'd54;
			8'd36: md_out = 6'd55;
			8'd37: md_out = 6'd56;
			8'd38: md_out = 6'd57;
			8'd39: md_out = 6'd48;
			// SPECIAL KEYS
			8'd40: md_out = 6'd13; //ENTER
			8'd41: md_out = 6'd27;	//ESC
			8'd42: md_out = 6'd127; //DEL (MAPPED TO BACKSPACE CAUSE THATS WHERE IT WAS ON APPLE 2)
			8'd43: md_out = 6'd9;	//TAB
			8'd44: md_out = 6'd32;	//SPACE
			8'd79: md_out = 6'd21;	//ARROW KEYS
			8'd80: md_out = 6'd8;
			8'd81: md_out = 6'd10;
			8'd82: md_out = 6'd11;
			8'd51: md_out = 7'd58;
			8'd45: md_out = 7'd45;
			8'd46: md_out = 7'd43;
			default: 
			begin
				md_out = 6'bx;
				akd = 0;
			end
		endcase
	end
endmodule
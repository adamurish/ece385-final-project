module PAL (input pll_14m, pll_q3
				output clk_M7, clk_M3_5, phase1_clk, phase2_clk);
							

//~7 MHz
 always_ff @ (posedge pll_14m)
    begin 
       clk_M7 <= ~ (clk_M7);
    end
	 
//~3.5 MHz
always_ff @ (posedge clk_M7)
	begin
		clk_M3_5 <= ~ (clk_M3_5);
	end

//1.0227 MHz
always_ff @ (posedge pll_q3)
	begin
		phase1_clk <= ~ (phase1_clk);
		phase2_clk <= phase1_clk;
	end
	
	
endmodule

module PAL (input clk,
				output M14, M7, phase1_clk, phase2_clk);
							

logic divisor = 8'd50;
logic counter = 8'd0;
logic M1_out;		//1 MHz signal to base other signals off of


always @ (posedge(clk))
begin	
	counter <= counter + 8'd1;
	if(counter >= (divisor-1)) counter <= 8'd0;
	
	if(counter < divisor/2)
		M1_out <= 1'b1;
	else
		M1_out <= 1'b0;	
end



endmodule

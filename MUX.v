// http://www.aholme.co.uk/6502/Main.htm

module MUX #(
    parameter N=1
) (
    output wire o,
    input  wire i,
    input  wire [N-1:0] s,
    input  wire [N-1:0] d);

    assign o = (|s) ? &(d|(~s)) : i;
endmodule

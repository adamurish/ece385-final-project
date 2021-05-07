module AppleIIe (
	input MAX10_CLK1_50, 
	input [1:0] KEY,
	output [9:0] LEDR,
	///////// HEX /////////
	output   [ 7: 0]   HEX0,
	output   [ 7: 0]   HEX1,
	output   [ 7: 0]   HEX2,
	output   [ 7: 0]   HEX3,
	output   [ 7: 0]   HEX4,
	output   [ 7: 0]   HEX5,

	///////// SDRAM /////////
	output             DRAM_CLK,
	output             DRAM_CKE,
	output   [12: 0]   DRAM_ADDR,
	output   [ 1: 0]   DRAM_BA,
	inout    [15: 0]   DRAM_DQ,
	output             DRAM_LDQM,
	output             DRAM_UDQM,
	output             DRAM_CS_N,
	output             DRAM_WE_N,
	output             DRAM_CAS_N,
	output             DRAM_RAS_N,

	///////// VGA /////////
	output             VGA_HS,
	output             VGA_VS,
	output   [ 3: 0]   VGA_R,
	output   [ 3: 0]   VGA_G,
	output   [ 3: 0]   VGA_B,


	///////// ARDUINO /////////
	inout    [15: 0]   ARDUINO_IO,
	inout              ARDUINO_RESET_N);
	
	logic SPI0_CS_N, SPI0_SCLK, SPI0_MISO, SPI0_MOSI, USB_GPX, USB_IRQ, USB_RST;
	logic [7:0] keycode;
	assign ARDUINO_IO[10] = SPI0_CS_N;
	assign ARDUINO_IO[13] = SPI0_SCLK;
	assign ARDUINO_IO[11] = SPI0_MOSI;
	assign ARDUINO_IO[12] = 1'bZ;
	assign SPI0_MISO = ARDUINO_IO[12];
	
	assign ARDUINO_IO[9] = 1'bZ; 
	assign USB_IRQ = ARDUINO_IO[9];
		
	//Assignments specific to Circuits At Home UHS_20
	assign ARDUINO_RESET_N = USB_RST;
	assign ARDUINO_IO[7] = USB_RST;//USB reset 
	assign ARDUINO_IO[8] = 1'bZ; //this is GPX (set to input)
	assign USB_GPX = 1'b0;//GPX is not needed for standard USB host - set to 0 to prevent interrupt
	
	//Assign uSD CS to '1' to prevent uSD card from interfering with USB Host (if uSD card is plugged in)
	assign ARDUINO_IO[6] = 1'b1;
	
	logic q3, vid14m;
	apple_kb keyboard(
		.clk_clk                           (MAX10_CLK1_50),  //clk.clk
		.reset_reset_n                     (1'b1),           //reset.reset_n
		//SDRAM
		.sdram_clk_clk(DRAM_CLK),                            //clk_sdram.clk
		.sdram_wire_addr(DRAM_ADDR),                         //sdram_wire.addr
		.sdram_wire_ba(DRAM_BA),                             //.ba
		.sdram_wire_cas_n(DRAM_CAS_N),                       //.cas_n
		.sdram_wire_cke(DRAM_CKE),                           //.cke
		.sdram_wire_cs_n(DRAM_CS_N),                         //.cs_n
		.sdram_wire_dq(DRAM_DQ),                             //.dq
		.sdram_wire_dqm({DRAM_UDQM,DRAM_LDQM}),              //.dqm
		.sdram_wire_ras_n(DRAM_RAS_N),                       //.ras_n
		.sdram_wire_we_n(DRAM_WE_N),                         //.we_n
		
		//USB SPI	
		.spi0_SS_n(SPI0_CS_N),
		.spi0_MOSI(SPI0_MOSI),
		.spi0_MISO(SPI0_MISO),
		.spi0_SCLK(SPI0_SCLK),
		
		//USB GPIO
		.usb_rst_export(USB_RST),
		.usb_irq_export(USB_IRQ),
		.usb_gpx_export(USB_GPX),
		.keycode_export(keycode),
		//PLL CLOCKS
		.pll_14m_clk(vid14m),
		.pll_q3_clk(q3));
	
	logic [15:0] cpu_address;
	logic [15:0] vid_address, mmu_address;
	logic cpu_rw, iou_rw, mmu_rw, kbd, c0xx, akd, iou_md7, kstrb;
	logic [7:0] mmu_in, mmu_out, vid_out, cpu_d_in;
	logic [6:0] encoder_out;
	logic [9:0] DrawX, DrawY;
	
	//CLOCK SIGNALS
	logic phi0, vid7m;
	
	always_ff @ (posedge vid14m) vid7m <= ~vid7m;
	
	always_ff @ (posedge q3) phi0 <= ~phi0;
//	assign phi0 = KEY[0];
	
	
	assign mmu_address = phi0 ? cpu_address : vid_address;
	assign mmu_rw = phi0 ? cpu_rw : iou_rw;
	assign cpu_d_in = c0xx ? {iou_md7, encoder_out} : mmu_out;
	
	chip_6502 CPU(.clk(MAX10_CLK1_50), .phi(phi0), .nmi(1), .irq(1), .res(KEY[1]), .rdy(1), .so(1), .ab(cpu_address), .rw(cpu_rw), .dbo(mmu_in), .dbi(cpu_d_in));
	MMU mmu0 (.A(cpu_address), .md_in(mmu_in), .phi0(MAX10_CLK1_50), .rw(cpu_rw), .md_out(mmu_out), .vid_A(vid_address), .vidr(iou_rw), .vid_out, .kbd, .c0xx);
	
	logic pixel_clk, bw_pixel;
//	assign pixel_clk = vid7m;

	ay_3600_pro kbd_encoder(.phi0, .keycode, .md_out(encoder_out), .akd, .kstrb);
	IOU iou0 (.pixel_clk, .bw_pixel, .vid(vid_out), .vid_address_out(vid_address), .rw(iou_rw), .phi0, .DrawX, .DrawY, .c0xx, .akd, .kstrb, .address_in(cpu_address), .md7(iou_md7));
	vga_controller vga0 (.Clk(MAX10_CLK1_50), .hs(VGA_HS), .vs(VGA_VS), .DrawX, .DrawY, .pixel_clk);
	
	assign VGA_R = bw_pixel ? 4'h2 : 4'h0;
	assign VGA_G = bw_pixel ? 4'hf : 4'h0;
	assign VGA_B = bw_pixel ? 4'h2 : 4'h0;
	
	
	HexDriver h0 (.In0(mmu_address[3:0]), .Out0(HEX0));
	HexDriver h1 (.In0(mmu_address[7:4]), .Out0(HEX1));
	HexDriver h2 (.In0(mmu_address[11:8]), .Out0(HEX2));
	HexDriver h3 (.In0(mmu_address[15:12]), .Out0(HEX3));
	HexDriver h4 (.In0(mmu_out[3:0]), .Out0(HEX4));
	HexDriver h5 (.In0(mmu_out[7:4]), .Out0(HEX5));
endmodule
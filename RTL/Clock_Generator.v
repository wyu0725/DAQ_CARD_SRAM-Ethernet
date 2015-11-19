module Clock_Generator
(
  input GCLK,
  input rst_n,
  input USB_CLKOUT,
  output clk,
  output USB_IFCLK,
  output IFCLK,
  output reset_n
);
//50M clk
clock_buf clk_gen
(
	.inclk(GCLK),
	.outclk(clk)
);
//48M IFCLK
clock_buf IFCLK_gen
(
	.inclk(USB_CLKOUT),
	.outclk(IFCLK)
);
usb_48M usb_ifclk_gen
(
  .inclk0(IFCLK),
  .c0(USB_IFCLK),
  .locked()
);
//Asynchronous reset synchronous release
reg sysrst_nr1,sysrst_nr2;
always @ (posedge clk , negedge rst_n) begin
  if(!rst_n)
    sysrst_nr1 <= 1'b0;
  else
    sysrst_nr1 <= 1'b1;
end
always @ (posedge clk , negedge rst_n) begin
  if(!rst_n)
    sysrst_nr2 <= 1'b0;
  else
    sysrst_nr2 <= sysrst_nr1;
end
assign reset_n = sysrst_nr2; //reset signal generated
endmodule

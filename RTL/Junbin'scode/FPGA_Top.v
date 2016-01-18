//top file of fpga
module FPGA_Top  //
(
  input iClk,               //50MHz
  input iRunStart, 
  inout [15:0]ioDm9000aBusData,  //pin
  input  iDm9000a_Int,     //pin
  output oDm9000a_Cs,     //pin
  output oDm9000a_Cmd, //pin
  output oDm9000a_Ior,    //pin
  output oDm9000a_Iow,  //pin
  output oRunEnd,
  output [6:1] Tp     //output for test       
); 
//clock generator
wire Clk_50M;
//wire Dm9000aClk;
ALTCLKCTRa Clk_sys(
		.inclk(iClk),
		.outclk(Clk_50M) //50M时钟都没问题,有问题不能在一个中断中连续两次工作
		);

reg Dm9000aClk;
always @ (posedge Clk_50M) begin  //Dm9000aClk = 25MHZ
	Dm9000aClk <= ~Dm9000aClk;
end

//异步复位同步释放
reg Dm9000a_RunStart1,Dm9000a_RunStart2;
always @ (posedge Dm9000aClk , negedge iRunStart) begin
	if(!iRunStart) 
		Dm9000a_RunStart1 <= 1'b0;
	else
		Dm9000a_RunStart1 <= 1'b1;
end
always @ (posedge Dm9000aClk , negedge iRunStart) begin
	if(!iRunStart)
		Dm9000a_RunStart2 <= 1'b0;
	else
		Dm9000a_RunStart2 <= Dm9000a_RunStart1;
end
/**********************/
DM9000A_Top Dm9000a_Top
(
	.iDm9000aClk(Dm9000aClk),
	.iRunStart(Dm9000a_RunStart2),
	.ioDm9000aBusData(ioDm9000aBusData),  
	.iDm9000a_Int(iDm9000a_Int),     
	.oDm9000a_Cs(oDm9000a_Cs),     
	.oDm9000a_Cmd(oDm9000a_Cmd), 
	.oDm9000a_Ior(oDm9000a_Ior),    
	.oDm9000a_Iow(oDm9000a_Iow),  
   .oRunEnd(oRunEnd),
	.Tp(Tp)
);
endmodule
/*---------------------------------------------------------------------------*/


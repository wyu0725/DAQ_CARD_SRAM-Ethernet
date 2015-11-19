//////////////////////////////////////////////////////////////////////////////////
// Company:USTC 
// Engineer:Yu Wang
// 
// Create Date:2015/11/19     
// Design Name:DAQ_CARD_2V0_SRAM    
// Module Name:FPGA_TOP     
// Project Name:   
// Target Devices: 
// Tool versions:  
// Description:  
//
// Dependencies: 
//
// Revision: V1.0
// Revision 0.01 - File Created
// Additional Comments: 
//
//////////////////////////////////////////////////////////////////////////////////
module FPGA_TOP
(
	input CLK_OSC,
	input NRESET,
	/*-----IO interface of cy7c68013a---*/
  input USB_CLKOUT,
  output USB_IFCLK,
	//input usb_ifclk,
	input FLAGA,
	input FLAGB,
	input FLAGC,
	output SLCS,
	output SLOE,
	output SLWR,
	output SLRD,
	output PKTEND,
	output [1:0] FIFOADDR,
	inout [15:0] FD,
  /*------IO interface of SRAM------*/
  output [14:0] A_A,
  inout [15:0] IO_A,
  output CE_A,
  output WE_A,
  output OE_A,
  output LB_A,
  output UB_A
);
wire clk;//system clk 50M
wire IFCLK;//USB clock 48M
wire reset_n;//system reset
/*------Clock Generator instantiation------*/
Clock_Generator Clock_Gen
(
  .GCLK(CLK_OSC),
  .rst_n(NRESET),
  .USB_CLKOUT(USB_CLKOUT),
  .clk(clk),
  .USB_IFCLK(USB_IFCLK),
  .IFCLK(IFCLK),
  .reset_n(reset_n)
);
/*------usb_Command_interpreter instantiation-----*/
wire in_from_usb_Ctr_rd_en;
wire [15:0] in_from_usb_ControlWord;
wire [1:0] Channel_Select;
wire out_to_rst_all_fifo;
wire [1:0] set_average_points;
usb_command_interpreter usb_control
(
	.IFCLK(IFCLK),
	.clk(clk),
	.reset_n(reset_n),
	.in_from_usb_Ctr_rd_en(in_from_usb_Ctr_rd_en),  //
	.in_from_usb_ControlWord(in_from_usb_ControlWord),//
	.Channel_Select(Channel_Select),//
	.out_to_rst_all_fifo(out_to_rst_all_fifo),//
  .out_to_set_average_points(set_average_points),
  .LED()
);
/*------usb_synchronous_slavefifo instantiation-----*/
wire [15:0] in_from_ext_fifo_dout;
wire in_from_ext_fifo_empty;
wire [13:0] in_from_ext_fifo_rd_data_count;//FIFO 16384*16
wire out_to_ext_fifo_rd_en;
usb_synchronous_slavefifo usb_cy7c68013A
(
	.IFCLK(IFCLK),
	.FLAGA(FLAGA),
	.FLAGB(FLAGB),
	.FLAGC(FLAGC),
	.nSLCS(SLCS),
	.nSLOE(SLOE),
	.nSLRD(SLRD),
	.nSLWR(SLWR),
	.nPKTEND(PKTEND),
	.FIFOADR(FIFOADDR),
	.FD_BUS(FD),
	.Acq_Start_Stop(Channel_Select[0] | Channel_Select[1]),//
	.Ctr_rd_en(in_from_usb_Ctr_rd_en),//
	.ControlWord(in_from_usb_ControlWord),//
	.in_from_ext_fifo_dout(in_from_ext_fifo_dout),
	.in_from_ext_fifo_empty(in_from_ext_fifo_empty),
	.in_from_ext_fifo_rd_data_count(in_from_ext_fifo_rd_data_count),
	.out_to_ext_fifo_rd_en(out_to_ext_fifo_rd_en)
);
/*------SRAM Data write or read instantiation------*/
wire [15:0] out_to_usb_ext_fifo_din;
wire out_to_usb_ext_fifo_en;
/*SRAM_Control SRAM_data
(
  .clk(clk),
  .reset_n(reset_n),
  .iRunStart(Channel_Select[0]),
  .SRAM_DATA(IO_A),
  .OUT_TO_SRAM_ADDR(A_A),
  .LB_n(LB_A),
  .UB_n(UB_A),
  .CE_n(CE_A),
  .OE_n(OE_A),
  .WE_n(WE_A),
  .Dataout(out_to_usb_ext_fifo_din),
  .Dataout_en(out_to_usb_ext_fifo_en)
);*/
/*------usb data fifo instantiation-------*/
wire usb_fifo_wrfull;//Modified by wyu for test 20151009
usb_data_fifo usb_data
(
	.aclr(out_to_rst_all_fifo | ~reset_n),
	.wrclk(~clk),
	.wrreq(out_to_usb_ext_fifo_en & (!usb_fifo_wrfull)),
	.data(out_to_usb_ext_fifo_din),
	.wrfull(usb_fifo_wrfull),//Modified by wyu for test 20151009
	.rdclk(~IFCLK),
	.rdreq(out_to_ext_fifo_rd_en),
	.q(in_from_ext_fifo_dout),
	.rdempty(in_from_ext_fifo_empty),	
	.wrusedw(in_from_ext_fifo_rd_data_count) //[13:0]
);
/*------Data generator instantiation------*/
wire [15:0] test_Dataout;
wire test_Dataout_en;
test test_data
(
  .clk(clk),
  .reset_n(reset_n),
  .iRunStart(Channel_Select[0] & Data_iRunStart),
  .Dataout_en(test_Dataout_en),
  .Dataout(test_Dataout)
);
/*------SRAM REAR and WRITW Control------*/
wire [10:0] sram_fifo_usedw;
wire WR_RunEnd;
wire RD_RunEnd;
wire WR_iRunStart;
wire [14:0] WR_START_ADDR;
wire [14:0] WR_DATA_NUM;
wire RD_iRunStart;
wire [14:0] RD_START_ADDR;
wire [14:0] RD_DATA_NUM;
wire Data_iRunStart;
SRAM_WR_RD_Control SRAM_read_write
(
  .clk(clk),
  .reset_n(reset_n),
  .iRunStart(Channel_Select[0]),
  //SRAM FIFO used words 
  .SRAM_FIFO_usedw(sram_fifo_usedw),
  //USB FIFO used words
  .USB_FIFO_usedw(in_from_ext_fifo_rd_data_count),
  //Interface with SRAM Control
  .WR_RunEnd(WR_RunEnd),
  .RD_RunEnd(RD_RunEnd),
  .WR_iRunStart(WR_iRunStart),
  .WR_START_ADDR(WR_START_ADDR),
  .WR_DATA_NUM(WR_DATA_NUM),
  .RD_iRunStart(RD_iRunStart),
  .RD_START_ADDR(RD_START_ADDR),
  .RD_DATA_NUM(RD_DATA_NUM),
  //只使用一个SRAM需要在读的时候停止数据产生
  .Data_iRunStart(Data_iRunStart)
);
/*------SRAM Control instantiation------*/
wire [15:0] Data_from_ext_fifo;
wire SRAM_Data_rdreq;
//wire [15:0] SRAM_Dataout;
//wire SRAM_Dataout_en;
SRAM_Control SRAM_IS61W3216
(
  .clk(clk),
  .reset_n(reset_n),
  //SRAM1_pins
  .SRAM_DATA(IO_A),//pin
  .OUT_TO_SRAM_ADDR(A_A),//pin
  .LB_n(LB_A),//pin
  .UB_n(UB_A),//pin
  .CE_n(CE_A),//pin
  .OE_n(OE_A),//pin
  .WE_n(WE_A),//pin
  //Read and Write Control Module
  .WR_iRunStart(WR_iRunStart),
  .WR_START_ADDR(WR_START_ADDR),
  .WR_DATA_NUM(WR_DATA_NUM),
  .RD_iRunStart(RD_iRunStart),
  .RD_START_ADDR(RD_START_ADDR),
  .RD_DATA_NUM(RD_DATA_NUM),
  .WR_RunEnd(WR_RunEnd),
  .RD_RunEnd(RD_RunEnd),
  //Data acquire from external fifo
  .Data_from_ext_fifo(Data_from_ext_fifo),
  .Data_rdreq(SRAM_Data_rdreq),
  //Data send to next module
  .Dataout(out_to_usb_ext_fifo_din),
  .Dataout_en(out_to_usb_ext_fifo_en)
);
/*------SRAM data fifo instantiation------*/
wire sram_fifo_empty;
wire sram_fifo_full;
sram_data_fifo sram_data
(
  .aclr(out_to_rst_all_fifo | ~reset_n),
  .clock(~clk),
  .data(test_Dataout),
  .rdreq(SRAM_Data_rdreq),
  .wrreq(test_Dataout_en),
  .empty(sram_fifo_empty),
  .full(sram_fifo_full),
  .q(Data_from_ext_fifo),
  .usedw(sram_fifo_usedw)
);
endmodule

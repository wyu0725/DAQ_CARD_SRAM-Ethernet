//this module is the top file
//20141820
module DM9000A_Top
(
	input iDm9000aClk,
	input iRunStart,
	inout [15:0]ioDm9000aBusData,  //Databus
	input iDm9000a_Int,     // interrupt pin
	output oDm9000a_Cs,     //pin
	output oDm9000a_Cmd, //pin
	output oDm9000a_Ior,    //pin
	output oDm9000a_Iow,   //pin
   output oRunEnd,
	output  [6:1] Tp
);
//input
wire Dm9000a_Initial_Clk;
wire Dm9000a_Initial_RunStart;
wire Dm9000a_Initial_in_from_Dm9000a_Iow_RunEnd;
wire Dm9000a_Initial_in_from_Dm9000a_Ior_RunEnd;
wire Dm9000a_Initial_in_from_phy_write_RunEnd;
wire Dm9000a_Initial_in_from_Dm9000a_usDelay_RunEnd;
wire [15:0]Dm9000a_Initial_in_from_Dm9000a_Ior_ReturnValue;
//outputs
wire Dm9000a_Initial_RunEnd;
wire Dm9000a_Initial_InitDone;
wire Dm9000a_Initial_out_to_Dm9000a_Iow_RunStart;
wire [15:0]Dm9000a_Initial_out_to_Dm9000a_Iow_Reg;
wire [15:0]Dm9000a_Initial_out_to_Dm9000a_Iow_Data;
wire Dm9000a_Initial_out_to_phy_write_RunStart;
wire [15:0]Dm9000a_Initial_out_to_phy_write_Reg;
wire [15:0]Dm9000a_Initial_out_to_phy_write_Value;
wire Dm9000a_Initial_out_to_Dm9000a_Ior_RunStart;
wire [15:0]Dm9000a_Initial_out_to_Dm9000a_Ior_iReg;
wire Dm9000a_Initial_out_to_Dm9000a_usDelay_RunStart;
wire [10:0]Dm9000a_Initial_out_to_Dm9000a_usDelay_DelayTime;
//assignment
assign Dm9000a_Initial_Clk = iDm9000aClk; //system clock;
assign Dm9000a_Initial_RunStart = iRunStart; //global runstart;
assign Dm9000a_Initial_in_from_Dm9000a_Iow_RunEnd = Dm9000a_Iow_RunEnd;
assign Dm9000a_Initial_in_from_Dm9000a_Ior_RunEnd = Dm9000a_Ior_RunEnd;
assign Dm9000a_Initial_in_from_phy_write_RunEnd = Dm9000a_phy_wr_RunEnd;
assign Dm9000a_Initial_in_from_Dm9000a_usDelay_RunEnd = Dm9000a_usDelay_RunEnd;
assign Dm9000a_Initial_in_from_Dm9000a_Ior_ReturnValue = Dm9000a_Ior_ReturnValue;
//Instantiate this module
 DM9000A_Initial Dm9000a_Initial
 (
   .iDm9000aClk(Dm9000a_Initial_Clk),
   .iRunStart(Dm9000a_Initial_RunStart),
   .in_from_Dm9000a_Iow_RunEnd(Dm9000a_Initial_in_from_Dm9000a_Iow_RunEnd),
   .in_from_Dm9000a_Ior_RunEnd(Dm9000a_Initial_in_from_Dm9000a_Ior_RunEnd),
   .in_from_phy_write_RunEnd(Dm9000a_Initial_in_from_phy_write_RunEnd),
   .in_from_Dm9000a_usDelay_RunEnd(Dm9000a_Initial_in_from_Dm9000a_usDelay_RunEnd),
   .in_from_Dm9000a_Ior_ReturnValue(Dm9000a_Initial_in_from_Dm9000a_Ior_ReturnValue),
   .oRunEnd(Dm9000a_Initial_RunEnd),
   .oInitDone(Dm9000a_Initial_InitDone),
   .out_to_Dm9000a_Iow_RunStart(Dm9000a_Initial_out_to_Dm9000a_Iow_RunStart),
   .out_to_Dm9000a_Iow_Reg(Dm9000a_Initial_out_to_Dm9000a_Iow_Reg),
   .out_to_Dm9000a_Iow_Data(Dm9000a_Initial_out_to_Dm9000a_Iow_Data),
   .out_to_phy_write_RunStart(Dm9000a_Initial_out_to_phy_write_RunStart),
   .out_to_phy_write_Reg(Dm9000a_Initial_out_to_phy_write_Reg),
   .out_to_phy_write_Value(Dm9000a_Initial_out_to_phy_write_Value),   
   .out_to_Dm9000a_Ior_RunStart(Dm9000a_Initial_out_to_Dm9000a_Ior_RunStart),
   .out_to_Dm9000a_Ior_iReg(Dm9000a_Initial_out_to_Dm9000a_Ior_iReg),
   .out_to_Dm9000a_usDelay_RunStart(Dm9000a_Initial_out_to_Dm9000a_usDelay_RunStart),
   .out_to_Dm9000a_usDelay_DelayTime(Dm9000a_Initial_out_to_Dm9000a_usDelay_DelayTime)
  );
  /*----------------------------------------------------------------------------------------*/
  //input
wire Dm9000a_Task_Clk;
wire Dm9000a_Task_RunStart;
wire Dm9000a_Task_in_from_Dm9000a_interrupt_hdl_RunEnd;
wire Dm9000a_Task_rx_enable;
wire [15:0] Dm9000a_Task_in_from_Dm9000a_Rx_IP_totallength;
wire Dm9000a_Task_in_from_etherheader_RunEnd;
wire Dm9000a_Task_in_from_ipheader_RunEnd;
wire Dm9000a_Task_in_from_Arp_Ack_RunEnd;
wire Dm9000a_Task_in_from_Ping_Ack_RunEnd;
wire Dm9000a_Task_in_from_Udp_Ack_RunEnd;
wire Dm9000a_Task_in_from_Write_Fifo_RunEnd;
wire Dm9000a_Task_in_from_Dm9000a_Tx_Done;
wire Dm9000a_Task_in_from_Dm9000a_Rx_Error;
wire Dm9000a_Task_in_from_Dm9000a_Rx_Done;
wire Dm9000a_Task_in_from_Dm9000a_Rx_Arp_Request;
wire Dm9000a_Task_in_from_Dm9000a_Rx_Ping_Request;
wire Dm9000a_Task_in_from_Dm9000a_Rx_Udp_Request;
//output
wire Dm9000a_Task_out_to_Dm9000a_Rx_RunStart;
wire Dm9000a_Task_out_to_etherheader_RunStart;
wire Dm9000a_Task_out_to_ipheader_RunStart;
wire Dm9000a_Task_out_to_Arp_Ack_RunStart;
wire Dm9000a_Task_out_to_Ping_Ack_RunStart;
wire Dm9000a_Task_out_to_Udp_Ack_RunStart;
wire Dm9000a_Task_out_to_Write_Fifo_RunStart;
wire Dm9000a_Task_out_to_Dm9000a_Tx_RunStart;
wire [15:0] Dm9000a_Task_out_to_Dm9000a_ipid;
wire [15:0] Dm9000a_Task_out_to_Write_Fifo_len;
wire Dm9000a_Task_out_to_Tx_Fifo_aclr;
wire Dm9000a_Task_out_to_Dm9000a_interrupt_hdl_RunStart;
wire Event_Success;
//assignment
assign Dm9000a_Task_Clk = iDm9000aClk; //global clock
assign Dm9000a_Task_RunStart = Dm9000a_Initial_RunEnd; //when initial done then start task
assign Dm9000a_Task_rx_enable =  Dm9000a_interrupt_hdl_rx_enable_r;
assign Dm9000a_Task_in_from_Dm9000a_interrupt_hdl_RunEnd = Dm9000a_interrupt_hdl_RunEnd;
assign Dm9000a_Task_in_from_Dm9000a_Rx_IP_totallength = Dm9000a_Rx_IP_totallength;
assign Dm9000a_Task_in_from_etherheader_RunEnd = etherheader_RunEnd;
assign Dm9000a_Task_in_from_ipheader_RunEnd = ipheader_RunEnd;
assign Dm9000a_Task_in_from_Arp_Ack_RunEnd = Arp_Ack_RunEnd;
assign Dm9000a_Task_in_from_Ping_Ack_RunEnd = Ping_Ack_RunEnd;
assign Dm9000a_Task_in_from_Udp_Ack_RunEnd = Udp_Ack_RunEnd;
assign Dm9000a_Task_in_from_Write_Fifo_RunEnd = Write_Fifo_RunEnd;
assign Dm9000a_Task_in_from_Dm9000a_Tx_Done = Dm9000a_Tx_Done;
assign Dm9000a_Task_in_from_Dm9000a_Rx_Error = Dm9000a_Rx_Error;
assign Dm9000a_Task_in_from_Dm9000a_Rx_Done = Dm9000a_Rx_Done;
assign Dm9000a_Task_in_from_Dm9000a_Rx_Arp_Request = Dm9000a_Rx_Arp_Request;
assign Dm9000a_Task_in_from_Dm9000a_Rx_Ping_Request = Dm9000a_Rx_Ping_Request;
assign Dm9000a_Task_in_from_Dm9000a_Rx_Udp_Request = Dm9000a_Rx_Udp_Request;
//Instantiate this module
Task Dm9000a_Task
(
.iDm9000aClk(Dm9000a_Task_Clk),
.iRunStart(Dm9000a_Task_RunStart),
.rx_enable(Dm9000a_Task_rx_enable), //接收使能
.in_from_Dm9000a_interrupt_hdl_RunEnd(Dm9000a_Task_in_from_Dm9000a_interrupt_hdl_RunEnd),
.in_from_Dm9000a_Rx_IP_totallength(Dm9000a_Task_in_from_Dm9000a_Rx_IP_totallength),
.in_from_etherheader_RunEnd(Dm9000a_Task_in_from_etherheader_RunEnd),
.in_from_ipheader_RunEnd(Dm9000a_Task_in_from_ipheader_RunEnd),
.in_from_Arp_Ack_RunEnd(Dm9000a_Task_in_from_Arp_Ack_RunEnd),
.in_from_Ping_Ack_RunEnd(Dm9000a_Task_in_from_Ping_Ack_RunEnd),
.in_from_Udp_Ack_RunEnd(Dm9000a_Task_in_from_Udp_Ack_RunEnd),
.in_from_Write_Fifo_RunEnd(Dm9000a_Task_in_from_Write_Fifo_RunEnd),
.in_from_Dm9000a_Tx_Done(Dm9000a_Task_in_from_Dm9000a_Tx_Done),
.in_from_Dm9000a_Rx_Error(Dm9000a_Task_in_from_Dm9000a_Rx_Error),
.in_from_Dm9000a_Rx_Done(Dm9000a_Task_in_from_Dm9000a_Rx_Done),
.in_from_Dm9000a_Rx_Arp_Request(Dm9000a_Task_in_from_Dm9000a_Rx_Arp_Request),
.in_from_Dm9000a_Rx_Ping_Request(Dm9000a_Task_in_from_Dm9000a_Rx_Ping_Request),
.in_from_Dm9000a_Rx_Udp_Request(Dm9000a_Task_in_from_Dm9000a_Rx_Udp_Request),
.out_to_Dm9000a_Rx_RunStart(Dm9000a_Task_out_to_Dm9000a_Rx_RunStart),
.out_to_etherheader_RunStart(Dm9000a_Task_out_to_etherheader_RunStart),
.out_to_Arp_Ack_RunStart(Dm9000a_Task_out_to_Arp_Ack_RunStart),
.out_to_ipheader_RunStart(Dm9000a_Task_out_to_ipheader_RunStart),
.out_to_Ping_Ack_RunStart(Dm9000a_Task_out_to_Ping_Ack_RunStart),
.out_to_Udp_Ack_RunStart(Dm9000a_Task_out_to_Udp_Ack_RunStart),
.out_to_Write_Fifo_RunStart(Dm9000a_Task_out_to_Write_Fifo_RunStart),
.out_to_Dm9000a_Tx_RunStart(Dm9000a_Task_out_to_Dm9000a_Tx_RunStart),
.out_to_Dm9000a_ipid(Dm9000a_Task_out_to_Dm9000a_ipid),
.out_to_Write_Fifo_len(Dm9000a_Task_out_to_Write_Fifo_len),
.out_to_Tx_Fifo_aclr(Dm9000a_Task_out_to_Tx_Fifo_aclr),
.out_to_Dm9000a_interrupt_hdl_RunStart(Dm9000a_Task_out_to_Dm9000a_interrupt_hdl_RunStart),
.Event_Success(Event_Success)
);
/*-----------------------------------------------------------------------------------------*/
//input
wire Dm9000a_interrupt_hdl_Clk;
wire Dm9000a_interrupt_hdl_RunStart;
wire Dm9000a_interrupt_hdl_interrupt_in;
//wire Dm9000a_interrupt_hdl_int_grant_in;
wire Dm9000a_interrupt_hdl_in_from_Dm9000a_Iow_RunEnd;
wire Dm9000a_interrupt_hdl_in_from_Dm9000a_Ior_RunEnd;
wire [15:0] Dm9000a_interrupt_hdl_in_from_Dm9000a_Ior_ReturnValue;
//output
wire Dm9000a_interrupt_hdl_rx_enable_r;
wire Dm9000a_interrupt_hdl_RunEnd;
wire Dm9000a_interrupt_hdl_out_to_Dm9000a_Ior_RunStart;
wire [15:0] Dm9000a_interrupt_hdl_out_to_Dm9000a_Ior_iReg;
wire Dm9000a_interrupt_hdl_out_to_Dm9000a_Iow_RunStart;
wire [15:0] Dm9000a_interrupt_hdl_out_to_Dm9000a_Iow_Reg;
wire [15:0] Dm9000a_interrupt_hdl_out_to_Dm9000a_Iow_Data;
//assignment
assign Dm9000a_interrupt_hdl_Clk = iDm9000aClk;
assign Dm9000a_interrupt_hdl_RunStart = Dm9000a_Task_out_to_Dm9000a_interrupt_hdl_RunStart;
assign Dm9000a_interrupt_hdl_interrupt_in = oDm9000a_Int; //中断输入
//assign Dm9000a_interrupt_hdl_int_grant_in 
assign Dm9000a_interrupt_hdl_in_from_Dm9000a_Iow_RunEnd = Dm9000a_Iow_RunEnd;
assign Dm9000a_interrupt_hdl_in_from_Dm9000a_Ior_RunEnd = Dm9000a_Ior_RunEnd;
assign Dm9000a_interrupt_hdl_in_from_Dm9000a_Ior_ReturnValue = Dm9000a_Ior_ReturnValue;
//Instantiate this module
DM9000A_interrupt_handle Dm9000a_interrupt
(
.iDm9000aClk(Dm9000a_interrupt_hdl_Clk),
.iRunStart(Dm9000a_interrupt_hdl_RunStart),
.interrupt_in(Dm9000a_interrupt_hdl_interrupt_in),
//.int_grant_in(Dm9000a_interrupt_hdl_int_grant_in),
.in_from_Dm9000a_Iow_RunEnd(Dm9000a_interrupt_hdl_in_from_Dm9000a_Iow_RunEnd),
.in_from_Dm9000a_Ior_RunEnd(Dm9000a_interrupt_hdl_in_from_Dm9000a_Ior_RunEnd),
.in_from_Dm9000a_Ior_ReturnValue(Dm9000a_interrupt_hdl_in_from_Dm9000a_Ior_ReturnValue),
.rx_enable_r(Dm9000a_interrupt_hdl_rx_enable_r),
.oRunEnd(Dm9000a_interrupt_hdl_RunEnd),
.out_to_Dm9000a_Ior_RunStart(Dm9000a_interrupt_hdl_out_to_Dm9000a_Ior_RunStart),
.out_to_Dm9000a_Ior_iReg(Dm9000a_interrupt_hdl_out_to_Dm9000a_Ior_iReg),
.out_to_Dm9000a_Iow_RunStart(Dm9000a_interrupt_hdl_out_to_Dm9000a_Iow_RunStart),
.out_to_Dm9000a_Iow_Reg(Dm9000a_interrupt_hdl_out_to_Dm9000a_Iow_Reg),
.out_to_Dm9000a_Iow_Data(Dm9000a_interrupt_hdl_out_to_Dm9000a_Iow_Data)
);
/*-----------------------------------------------------------------------------------------*/
//input
wire Dm9000a_Rx_Clk;
wire Dm9000a_Rx_RunStart;
//wire Dm9000a_Rx_in_from_Dm9000a_Iow_RunEnd;
wire Dm9000a_Rx_in_from_Dm9000a_Ior_RunEnd;
wire Dm9000a_Rx_in_from_Dm9000a_IOWR_RunEnd;
wire Dm9000a_Rx_in_from_Dm9000a_IORD_RunEnd;
wire Dm9000a_Rx_in_from_Dm9000a_usDelay_RunEnd;
wire [15:0] Dm9000a_Rx_in_from_Dm9000a_Ior_ReturnValue;
wire [15:0] Dm9000a_Rx_in_from_Dm9000a_IORD_ReturnValue;
wire Dm9000a_Rx_in_from_Dm9000a_Rx_Reset_RunEnd; //new add
//output
wire Dm9000a_Rx_Done;
wire Dm9000a_Rx_Error;
//protocol output
wire [47:0] Dm9000a_Rx_MAC_pc;
wire [15:0] Dm9000a_Rx_Ether_Type;

wire Dm9000a_Rx_Arp_Request;
wire [31:0] Dm9000a_Rx_IP_pc;

wire [15:0] Dm9000a_Rx_IP_totallength;
wire [7:0] Dm9000a_Rx_IP_proto;

wire Dm9000a_Rx_Ping_Request;
wire [15:0] Dm9000a_Rx_Ping_id;
wire [15:0] Dm9000a_Rx_Ping_sn;
wire [15:0] Dm9000a_Rx_Ping_len;  

wire Dm9000a_Rx_Udp_Request;
wire [15:0] Dm9000a_Rx_Port_pc;
wire [15:0] Dm9000a_Rx_Control_word;

wire [15:0] Dm9000a_Rx_Tx_len;
wire Dm9000a_Rx_wren_a; //dpram port A
wire [7:0] Dm9000a_Rx_data_a;//dpram port A
wire [9:0] Dm9000a_Rx_address_a;//dpram port A
wire Dm9000a_Rx_out_to_Dm9000a_Rx_Reset_RunStart;//new add
//wire Dm9000a_Rx_out_to_Dm9000a_Iow_RunStart;
//wire [15:0] Dm9000a_Rx_out_to_Dm9000a_Iow_Reg;
//wire [15:0] Dm9000a_Rx_out_to_Dm9000a_Iow_Data;
wire Dm9000a_Rx_out_to_Dm9000a_Ior_RunStart;
wire [15:0] Dm9000a_Rx_out_to_Dm9000a_Ior_iReg;
wire Dm9000a_Rx_out_to_Dm9000a_IOWR_RunStart;
wire Dm9000a_Rx_out_to_Dm9000a_IOWR_IndexOrData;
wire [15:0]Dm9000a_Rx_out_to_Dm9000a_IOWR_OutData;
wire Dm9000a_Rx_out_to_Dm9000a_IORD_RunStart;
wire Dm9000a_Rx_out_to_Dm9000a_IORD_IndexOrData;
wire Dm9000a_Rx_out_to_Dm9000a_usDelay_RunStart;
wire [10:0] Dm9000a_Rx_out_to_Dm9000a_usDelay_DelayTime;
//assignment
assign Dm9000a_Rx_Clk = iDm9000aClk;
assign Dm9000a_Rx_RunStart = Dm9000a_Task_out_to_Dm9000a_Rx_RunStart;
//assign Dm9000a_Rx_in_from_Dm9000a_Iow_RunEnd = Dm9000a_Iow_RunEnd;
assign Dm9000a_Rx_in_from_Dm9000a_Ior_RunEnd = Dm9000a_Ior_RunEnd;
assign Dm9000a_Rx_in_from_Dm9000a_IOWR_RunEnd = Dm9000a_IOWR_RunEnd;
assign Dm9000a_Rx_in_from_Dm9000a_IORD_RunEnd = Dm9000a_IORD_RunEnd;
assign Dm9000a_Rx_in_from_Dm9000a_usDelay_RunEnd = Dm9000a_usDelay_RunEnd;
assign Dm9000a_Rx_in_from_Dm9000a_Ior_ReturnValue = Dm9000a_Ior_ReturnValue;
assign Dm9000a_Rx_in_from_Dm9000a_IORD_ReturnValue = Dm9000a_IORD_ReturnValue;
assign Dm9000a_Rx_in_from_Dm9000a_Rx_Reset_RunEnd = Dm9000a_Rx_Reset_RunEnd;
//Instantiate this module
DM9000A_RX Dm9000a_Rx
(
.iDm9000aClk(Dm9000a_Rx_Clk),
.iRunStart(Dm9000a_Rx_RunStart), 
//.in_from_Dm9000a_Iow_RunEnd(Dm9000a_Rx_in_from_Dm9000a_Iow_RunEnd),
.in_from_Dm9000a_Ior_RunEnd(Dm9000a_Rx_in_from_Dm9000a_Ior_RunEnd),
.in_from_Dm9000a_IOWR_RunEnd(Dm9000a_Rx_in_from_Dm9000a_IOWR_RunEnd),
.in_from_Dm9000a_IORD_RunEnd(Dm9000a_Rx_in_from_Dm9000a_IORD_RunEnd),
.in_from_Dm9000a_usDelay_RunEnd(Dm9000a_Rx_in_from_Dm9000a_usDelay_RunEnd),
.in_from_Dm9000a_Ior_ReturnValue(Dm9000a_Rx_in_from_Dm9000a_Ior_ReturnValue),
.in_from_Dm9000a_IORD_ReturnValue(Dm9000a_Rx_in_from_Dm9000a_IORD_ReturnValue),
.in_from_Dm9000a_Rx_Reset_RunEnd(Dm9000a_Rx_in_from_Dm9000a_Rx_Reset_RunEnd),
.Rx_Done(Dm9000a_Rx_Done),//from upper
.oError(Dm9000a_Rx_Error),//from upper
//protocol output
.MAC_pc(Dm9000a_Rx_MAC_pc), 
.Ether_Type(Dm9000a_Rx_Ether_Type),

.Arp_Request(Dm9000a_Rx_Arp_Request),
.IP_pc(Dm9000a_Rx_IP_pc), 

.IP_totallength(Dm9000a_Rx_IP_totallength),
.IP_proto(Dm9000a_Rx_IP_proto),

.Ping_Request(Dm9000a_Rx_Ping_Request),
.Ping_id(Dm9000a_Rx_Ping_id),
.Ping_sn(Dm9000a_Rx_Ping_sn),
.Ping_len(Dm9000a_Rx_Ping_len), 

.Udp_Request(Dm9000a_Rx_Udp_Request),//from upper
.Port_pc(Dm9000a_Rx_Port_pc),
.Control_word(Dm9000a_Rx_Control_word),
//dpram interface
.wren_a(Dm9000a_Rx_wren_a),
.data_a(Dm9000a_Rx_data_a),
.address_a(Dm9000a_Rx_address_a),
//end
//.out_to_Dm9000a_Iow_RunStart(Dm9000a_Rx_out_to_Dm9000a_Iow_RunStart),
//.out_to_Dm9000a_Iow_Reg(Dm9000a_Rx_out_to_Dm9000a_Iow_Reg),
//.out_to_Dm9000a_Iow_Data(Dm9000a_Rx_out_to_Dm9000a_Iow_Data),
.out_to_Dm9000a_Rx_Reset_RunStart(Dm9000a_Rx_out_to_Dm9000a_Rx_Reset_RunStart),
.out_to_Dm9000a_Ior_RunStart(Dm9000a_Rx_out_to_Dm9000a_Ior_RunStart),
.out_to_Dm9000a_Ior_iReg(Dm9000a_Rx_out_to_Dm9000a_Ior_iReg),
.out_to_Dm9000a_IOWR_RunStart(Dm9000a_Rx_out_to_Dm9000a_IOWR_RunStart),
.out_to_Dm9000a_IOWR_IndexOrData(Dm9000a_Rx_out_to_Dm9000a_IOWR_IndexOrData),
.out_to_Dm9000a_IOWR_OutData(Dm9000a_Rx_out_to_Dm9000a_IOWR_OutData),
.out_to_Dm9000a_IORD_RunStart(Dm9000a_Rx_out_to_Dm9000a_IORD_RunStart),
.out_to_Dm9000a_IORD_IndexOrData(Dm9000a_Rx_out_to_Dm9000a_IORD_IndexOrData),
.out_to_Dm9000a_usDelay_RunStart(Dm9000a_Rx_out_to_Dm9000a_usDelay_RunStart),
.out_to_Dm9000a_usDelay_DelayTime(Dm9000a_Rx_out_to_Dm9000a_usDelay_DelayTime)
);
/*------------------------------------------------------------------------------------------------------*/
//input
wire Dm9000a_Rx_Reset_Clk;
wire Dm9000a_Rx_Reset_RunStart;
wire Dm9000a_Rx_Reset_in_from_Dm9000a_Iow_RunEnd;
wire Dm9000a_Rx_Reset_in_from_Dm9000a_usDelay_RunEnd;
//output
wire Dm9000a_Rx_Reset_out_to_Dm9000a_Iow_RunStart;
wire [15:0] Dm9000a_Rx_Reset_out_to_Dm9000a_Iow_Reg;
wire [15:0] Dm9000a_Rx_Reset_out_to_Dm9000a_Iow_Data;
wire Dm9000a_Rx_Reset_out_to_Dm9000a_usDelay_RunStart;
wire [10:0] Dm9000a_Rx_Reset_out_to_Dm9000a_usDelay_DelayTime;
wire Dm9000a_Rx_Reset_RunEnd;
//assignment
assign Dm9000a_Rx_Reset_Clk = iDm9000aClk;
assign Dm9000a_Rx_Reset_RunStart = Dm9000a_Rx_out_to_Dm9000a_Rx_Reset_RunStart;
assign Dm9000a_Rx_Reset_in_from_Dm9000a_Iow_RunEnd = Dm9000a_Iow_RunEnd;
assign Dm9000a_Rx_Reset_in_from_Dm9000a_usDelay_RunEnd = Dm9000a_usDelay_RunEnd;
//instantiate this module
DM9000A_RX_RESET Dm9000a_Rx_Reset
(
.iDm9000aClk(Dm9000a_Rx_Reset_Clk),
.iRunStart(Dm9000a_Rx_Reset_RunStart),
.in_from_Dm9000a_Iow_RunEnd(Dm9000a_Rx_Reset_in_from_Dm9000a_Iow_RunEnd),
.in_from_Dm9000a_usDelay_RunEnd(Dm9000a_Rx_Reset_in_from_Dm9000a_usDelay_RunEnd),
.out_to_Dm9000a_Iow_RunStart(Dm9000a_Rx_Reset_out_to_Dm9000a_Iow_RunStart),
.out_to_Dm9000a_Iow_Reg(Dm9000a_Rx_Reset_out_to_Dm9000a_Iow_Reg),
.out_to_Dm9000a_Iow_Data(Dm9000a_Rx_Reset_out_to_Dm9000a_Iow_Data),
.out_to_Dm9000a_usDelay_RunStart(Dm9000a_Rx_Reset_out_to_Dm9000a_usDelay_RunStart),
.out_to_Dm9000a_usDelay_DelayTime(Dm9000a_Rx_Reset_out_to_Dm9000a_usDelay_DelayTime),
.oRunEnd(Dm9000a_Rx_Reset_RunEnd)
);
/*------------------------------------------------------------------------------------------------------*/
//input
wire Dm9000a_Tx_Clk;
wire Dm9000a_Tx_RunStart;
wire Dm9000a_Tx_in_from_Dm9000a_Iow_RunEnd;
wire Dm9000a_Tx_in_from_Dm9000a_Ior_RunEnd;
wire Dm9000a_Tx_in_from_Dm9000a_IOWR_RunEnd;
wire Dm9000a_Tx_in_from_Dm9000a_usDelay_RunEnd;
wire [15:0] Dm9000a_Tx_in_from_Dm9000a_Ior_ReturnValue;
wire [15:0] Data_Length;
wire [15:0] dcfifo_data;
wire Dm9000a_Tx_rdempty;
//output
wire Dm9000a_Tx_Done; 
wire Dm9000a_Tx_rdreq;
wire Dm9000a_Tx_out_to_Dm9000a_Iow_RunStart;
wire [15:0] Dm9000a_Tx_out_to_Dm9000a_Iow_Reg;
wire [15:0] Dm9000a_Tx_out_to_Dm9000a_Iow_Data;
wire Dm9000a_Tx_out_to_Dm9000a_IOWR_RunStart;
wire Dm9000a_Tx_out_to_Dm9000a_IOWR_IndexOrData;
wire [15:0] Dm9000a_Tx_out_to_Dm9000a_IOWR_OutData;
wire Dm9000a_Tx_out_to_Dm9000a_Ior_RunStart;
wire [15:0] Dm9000a_Tx_out_to_Dm9000a_Ior_iReg;
wire Dm9000a_Tx_out_to_Dm9000a_usDelay_RunStart;
wire [10:0] Dm9000a_Tx_out_to_Dm9000a_usDelay_DelayTime;
//assignment
assign Dm9000a_Tx_Clk = iDm9000aClk;
assign Dm9000a_Tx_RunStart = Dm9000a_Task_out_to_Dm9000a_Tx_RunStart;
assign Dm9000a_Tx_in_from_Dm9000a_Iow_RunEnd = Dm9000a_Iow_RunEnd;
assign Dm9000a_Tx_in_from_Dm9000a_Ior_RunEnd = Dm9000a_Ior_RunEnd;
assign Dm9000a_Tx_in_from_Dm9000a_IOWR_RunEnd = Dm9000a_IOWR_RunEnd;
assign Dm9000a_Tx_in_from_Dm9000a_usDelay_RunEnd = Dm9000a_usDelay_RunEnd;
assign Dm9000a_Tx_in_from_Dm9000a_Ior_ReturnValue = Dm9000a_Ior_ReturnValue;

assign Data_Length = Dm9000a_Task_out_to_Write_Fifo_len;//Data length
assign dcfifo_data = fifo_data_out;
assign Dm9000a_Tx_rdempty = fifo_empty;

//Instantiate this module
DM9000A_TX Dm9000a_Tx
(
  .iDm9000aClk(Dm9000a_Tx_Clk),
  .iRunStart(Dm9000a_Tx_RunStart),//from upper
  .in_from_Dm9000a_Iow_RunEnd(Dm9000a_Tx_in_from_Dm9000a_Iow_RunEnd),
  .in_from_Dm9000a_Ior_RunEnd(Dm9000a_Tx_in_from_Dm9000a_Ior_RunEnd),
  .in_from_Dm9000a_IOWR_RunEnd(Dm9000a_Tx_in_from_Dm9000a_IOWR_RunEnd),
  .in_from_Dm9000a_usDelay_RunEnd(Dm9000a_Tx_in_from_Dm9000a_usDelay_RunEnd),
  .in_from_Dm9000a_Ior_ReturnValue(Dm9000a_Tx_in_from_Dm9000a_Ior_ReturnValue),
  .Data_Length(Data_Length),
  .dcfifo_data(dcfifo_data),
  .rdempty(Dm9000a_Tx_rdempty),
  .Tx_Done(Dm9000a_Tx_Done),//from upper
  .rdreq(Dm9000a_Tx_rdreq),
  .out_to_Dm9000a_Iow_RunStart(Dm9000a_Tx_out_to_Dm9000a_Iow_RunStart),
  .out_to_Dm9000a_Iow_Reg(Dm9000a_Tx_out_to_Dm9000a_Iow_Reg),
  .out_to_Dm9000a_Iow_Data(Dm9000a_Tx_out_to_Dm9000a_Iow_Data),
  .out_to_Dm9000a_IOWR_RunStart(Dm9000a_Tx_out_to_Dm9000a_IOWR_RunStart),
  .out_to_Dm9000a_IOWR_IndexOrData(Dm9000a_Tx_out_to_Dm9000a_IOWR_IndexOrData),
  .out_to_Dm9000a_IOWR_OutData(Dm9000a_Tx_out_to_Dm9000a_IOWR_OutData),
  .out_to_Dm9000a_Ior_RunStart(Dm9000a_Tx_out_to_Dm9000a_Ior_RunStart),
  .out_to_Dm9000a_Ior_iReg(Dm9000a_Tx_out_to_Dm9000a_Ior_iReg),
  .out_to_Dm9000a_usDelay_RunStart(Dm9000a_Tx_out_to_Dm9000a_usDelay_RunStart),
  .out_to_Dm9000a_usDelay_DelayTime(Dm9000a_Tx_out_to_Dm9000a_usDelay_DelayTime)
);
/*---------------------------------------------------------------------------------------------------------------------*/
//input
wire Arp_Ack_Clk;
wire Arp_Ack_RunStart;
wire [47:0] Arp_Ack_MAC_pc;
wire [31:0] Arp_Ack_IP_pc;
//output
wire Arp_Ack_wren_b;
wire [7:0] Arp_Ack_data_b;
wire [9:0] Arp_Ack_address_b;
wire Arp_Ack_RunEnd;
//assigment
assign Arp_Ack_Clk = iDm9000aClk;
assign Arp_Ack_RunStart = Dm9000a_Task_out_to_Arp_Ack_RunStart; //arp request from Task
assign Arp_Ack_MAC_pc = Dm9000a_Rx_MAC_pc;//MAC pc from Rx module
assign Arp_Ack_IP_pc = Dm9000a_Rx_IP_pc;// IP pc from Rx module
//Instantiate this module
ARP_ACK Arp_Ack
(
  .iDm9000aClk(Arp_Ack_Clk),
  .iRunStart(Arp_Ack_RunStart),//from upper
  .in_from_Dm9000a_Rx_MAC_pc(Arp_Ack_MAC_pc),
  .in_from_Dm9000a_Rx_IP_pc(Arp_Ack_IP_pc),
  .wren_b(Arp_Ack_wren_b), //dpram Port B
  .data_b(Arp_Ack_data_b),//dpram Port B
  .address_b(Arp_Ack_address_b), //dpram Port B
  .oRunEnd(Arp_Ack_RunEnd)
);
/*-------------------------------------------------------------------*/
//input
wire Ping_Ack_Clk;
wire Ping_Ack_RunStart;
wire [15:0] Ping_Ack_Ping_id;
wire [15:0] Ping_Ack_Ping_sn;
wire [15:0] Ping_Ack_Ping_len;
wire Ping_Ack_in_from_chksum_RunEnd;
wire [15:0] Ping_Ack_in_from_chksum_checksum;
//output
wire Ping_Ack_out_to_chksum_RunStart;
wire [15:0] Ping_Ack_out_to_chksum_len;
wire [9:0] Ping_Ack_out_to_chksum_start_addr;
wire Ping_Ack_wren_b;
wire [7:0] Ping_Ack_data_b;
wire [9:0] Ping_Ack_address_b;
wire Ping_Ack_RunEnd;
//assignment
assign Ping_Ack_Clk = iDm9000aClk;
assign Ping_Ack_RunStart = Dm9000a_Task_out_to_Ping_Ack_RunStart; //
assign Ping_Ack_Ping_id = Dm9000a_Rx_Ping_id;
assign Ping_Ack_Ping_sn = Dm9000a_Rx_Ping_sn;
assign Ping_Ack_Ping_len = Dm9000a_Rx_Ping_len;//校验和长度
assign Ping_Ack_in_from_chksum_RunEnd = chksum_RunEnd;
assign Ping_Ack_in_from_chksum_checksum = chksum_checksum;
//Instantiate this module
PING_ACK Ping_Ack
(
  .iDm9000aClk(Ping_Ack_Clk),
  .iRunStart(Ping_Ack_RunStart), //from upper
  .in_from_Dm9000a_Rx_Ping_id(Ping_Ack_Ping_id),
  .in_from_Dm9000a_Rx_Ping_sn(Ping_Ack_Ping_sn),
  .in_from_Dm9000a_Rx_Ping_len(Ping_Ack_Ping_len),
  .in_from_chksum_RunEnd(Ping_Ack_in_from_chksum_RunEnd),
  .in_from_chksum_checksum(Ping_Ack_in_from_chksum_checksum),
  .out_to_chksum_RunStart(Ping_Ack_out_to_chksum_RunStart),
  .out_to_chksum_len(Ping_Ack_out_to_chksum_len),
  .out_to_chksum_start_addr(Ping_Ack_out_to_chksum_start_addr),
  .wren_b(Ping_Ack_wren_b), //dpram Port B
  .data_b(Ping_Ack_data_b), //dpram Port B
  .address_b(Ping_Ack_address_b), //dpram Port B
  .oRunEnd(Ping_Ack_RunEnd)
);
/*----------------------------------------------------------------------------*/
//input 
wire Udp_Ack_Clk;
wire Udp_Ack_RunStart;
wire [15:0] Udp_Ack_Port_pc;
wire [15:0]Udp_Ack_Control_word;
//output
wire Udp_Ack_wren_b;
wire [7:0] Udp_Ack_data_b;
wire [9:0] Udp_Ack_address_b;
wire Udp_Ack_RunEnd;
//assignment
assign Udp_Ack_Clk = iDm9000aClk;
assign Udp_Ack_RunStart = Dm9000a_Task_out_to_Udp_Ack_RunStart;  //here
assign Udp_Ack_Port_pc = Dm9000a_Rx_Port_pc;
assign Udp_Ack_Control_word = Dm9000a_Rx_Control_word;
//Instantiate this module
UDP_ACK Udp_Ack
(
  .iDm9000aClk(Udp_Ack_Clk),
  .iRunStart(Udp_Ack_RunStart), //from upper
  .in_from_Dm9000a_Rx_Port_pc(Udp_Ack_Port_pc),
  .in_from_Dm9000a_Rx_Control_word(Udp_Ack_Control_word),
  .wren_b(Udp_Ack_wren_b),
  .data_b(Udp_Ack_data_b),
  .address_b(Udp_Ack_address_b),
  .oRunEnd(Udp_Ack_RunEnd)
);
/*----------------------------------------------------------------------*/
//input
wire etherheader_Clk;
wire etherheader_RunStart;
wire [47:0] etherheader_in_from_Dm9000a_Rx_MAC_pc;
wire [15:0] etherheader_in_from_Dm9000a_Rx_Ether_type;
//output
wire etherheader_wren_b;
wire [7:0] etherheader_data_b;
wire [9:0] etherheader_address_b;
wire etherheader_RunEnd;
//assignment
assign etherheader_Clk = iDm9000aClk;
assign etherheader_RunStart = Dm9000a_Task_out_to_etherheader_RunStart;
assign etherheader_in_from_Dm9000a_Rx_MAC_pc= Dm9000a_Rx_MAC_pc;
assign etherheader_in_from_Dm9000a_Rx_Ether_type = Dm9000a_Rx_Ether_Type;
//instantiation this module
etherheader Etherheader
(
	.iDm9000aClk(etherheader_Clk),
	.iRunStart(etherheader_RunStart),
	.in_from_Dm9000a_Rx_MAC_pc(etherheader_in_from_Dm9000a_Rx_MAC_pc),
	.in_from_Dm9000a_Rx_Ether_type(etherheader_in_from_Dm9000a_Rx_Ether_type),
	.wren_b(etherheader_wren_b),
	.data_b(etherheader_data_b),
	.address_b(etherheader_address_b),
	.oRunEnd(etherheader_RunEnd)
);
/*----------------------------------------------------------------------*/
//input
wire ipheader_Clk;
wire ipheader_RunStart;
wire [15:0] ipheader_in_from_Dm9000a_Rx_iplength;
wire [15:0] ipheader_ipid;
wire [7:0] ipheader_in_from_Dm9000a_Rx_proto;
wire [31:0] ipheader_IP_pc;
//chksum
wire ipheader_in_from_chksum_RunEnd;
wire [15:0] ipheader_in_from_chksum_checksum;
wire ipheader_out_to_chksum_RunStart;
wire [15:0] ipheader_out_to_chksum_len;
wire [9:0] ipheader_out_to_chksum_start_addr;
//output
wire ipheader_wren_b;
wire [7:0] ipheader_data_b;
wire [9:0] ipheader_address_b;
wire ipheader_RunEnd;
//assignment
assign ipheader_Clk = iDm9000aClk;
assign ipheader_RunStart = Dm9000a_Task_out_to_ipheader_RunStart;
assign ipheader_in_from_Dm9000a_Rx_iplength = Dm9000a_Rx_IP_totallength;
assign ipheader_ipid = Dm9000a_Task_out_to_Dm9000a_ipid;
assign ipheader_in_from_Dm9000a_Rx_proto = Dm9000a_Rx_IP_proto;
assign ipheader_IP_pc = Dm9000a_Rx_IP_pc;

assign ipheader_in_from_chksum_RunEnd = chksum_RunEnd;
assign ipheader_in_from_chksum_checksum = chksum_checksum;
 //Instantiate this module
 ipheader Ipheader
 (
  .iDm9000aClk(ipheader_Clk),
  .iRunStart(ipheader_RunStart),
  .in_from_Dm9000a_Rx_iplength(ipheader_in_from_Dm9000a_Rx_iplength),
  .in_from_Task_ipid(ipheader_ipid),
  .in_from_Dm9000a_Rx_proto_id(ipheader_in_from_Dm9000a_Rx_proto),
  .in_from_Dm9000a_Rx_IP_pc(ipheader_IP_pc),
  
  .in_from_chksum_RunEnd(ipheader_in_from_chksum_RunEnd),
  .in_from_chksum_checksum(ipheader_in_from_chksum_checksum),
  .out_to_chksum_RunStart(ipheader_out_to_chksum_RunStart),
  .out_to_chksum_len(ipheader_out_to_chksum_len),
  .out_to_chksum_start_addr(ipheader_out_to_chksum_start_addr),
  .wren_b(ipheader_wren_b),
  .data_b(ipheader_data_b),
  .address_b(ipheader_address_b),
  .oRunEnd(ipheader_RunEnd)
 );
 /*----------------------------------------------------------------------*/
 //input
 wire chksum_Clk;
 wire chksum_RunStart;
 wire [15:0] chksum_len;
 wire [9:0] chksum_start_addr;
 wire [7:0] chksum_in_from_dpram_q_b;
 //output
 wire chksum_rden_b;
 wire [9:0] chksum_address_b;
 wire [15:0] chksum_checksum;
 wire chksum_RunEnd;
 //assignment
 assign chksum_Clk = iDm9000aClk;
 assign chksum_RunStart = ipheader_out_to_chksum_RunStart | Ping_Ack_out_to_chksum_RunStart;
 assign chksum_len = ipheader_out_to_chksum_len | Ping_Ack_out_to_chksum_len;
 assign chksum_start_addr = ipheader_out_to_chksum_start_addr | Ping_Ack_out_to_chksum_start_addr;
 assign chksum_in_from_dpram_q_b = dpram_q_b;
 //Instantiate this module
 chksum Chksum
 (
  .iDm9000aClk(chksum_Clk),
  .iRunStart(chksum_RunStart),
  .len(chksum_len),
  .start_addr(chksum_start_addr),
  .in_from_dpram_q_b(chksum_in_from_dpram_q_b),
  .rden_b(chksum_rden_b),
  .address_b(chksum_address_b),
  .checksum(chksum_checksum),
  .oRunEnd(chksum_RunEnd)
 );
 /*----------------------------------------------------------------------*/
 wire [7:0] dpram_q_a;
 wire [7:0] dpram_q_b;
 wire fifo_wrfull;
 wire fifo_empty;
 wire [15:0] fifo_data_out;
 dpram_and_dcfifo DPRAM_AND_DCFIFO
 (
  .iDm9000aClk(iDm9000aClk),
  .in_from_Dm9000a_Rx_wren_a(Dm9000a_Rx_wren_a),
  .in_from_Dm9000a_Rx_data_a(Dm9000a_Rx_data_a),
  .in_from_Dm9000a_Rx_address_a(Dm9000a_Rx_address_a),
  .in_from_Arp_Ack_wren_b(Arp_Ack_wren_b),
  .in_from_Arp_Ack_data_b(Arp_Ack_data_b),
  .in_from_Arp_Ack_address_b(Arp_Ack_address_b),
  .in_from_Ping_Ack_wren_b(Ping_Ack_wren_b),
  .in_from_Ping_Ack_data_b(Ping_Ack_data_b),
  .in_from_Ping_Ack_address_b(Ping_Ack_address_b),
  .in_from_Udp_Ack_wren_b(Udp_Ack_wren_b),
  .in_from_Udp_Ack_data_b(Udp_Ack_data_b),
  .in_from_Udp_Ack_address_b(Udp_Ack_address_b),
  .in_from_etherheader_wren_b(etherheader_wren_b),
  .in_from_etherheader_data_b(etherheader_data_b),
  .in_from_etherheader_address_b(etherheader_address_b),
  .in_from_ipheader_wren_b(ipheader_wren_b),
  .in_from_ipheader_data_b(ipheader_data_b),
  .in_from_ipheader_address_b(ipheader_address_b),
  .in_from_chksum_rden_b(chksum_rden_b),
  .in_from_chksum_address_b(chksum_address_b),
  .in_from_Write_Fifo_rden_a(Write_Fifo_rden_a),
  .in_from_Write_Fifo_address_a(Write_Fifo_address_a),
  .dpram_q_a(dpram_q_a),
  .dpram_q_b(dpram_q_b),
  .in_from_Task_Fifo_aclr(Dm9000a_Task_out_to_Tx_Fifo_aclr),
  .in_from_Write_Fifo_wrreq(Write_Fifo_req),
  .in_from_Write_Fifo_data_in(Write_Fifo_data_in),
  .in_from_Dm9000a_Tx_rdreq(Dm9000a_Tx_rdreq),
  .wrfull(fifo_wrfull),
  .rdempty(fifo_empty),
  .Fifo_data_out(fifo_data_out)
 );
 /*----------------------------------------------------------------------*/
 //input
 wire Write_Fifo_Clk;
 wire Write_Fifo_RunStart;
 wire [15:0] Write_Fifo_in_from_Dm9000a_Rx_Tx_Len;
 wire Write_Fifo_wrfull;
 wire [7:0] Write_Fifo_in_from_dpram_q_a;
 //output
 wire Write_Fifo_RunEnd;
 wire Write_Fifo_req;
 wire [7:0] Write_Fifo_data_in;
 wire Write_Fifo_rden_a;
 wire [9:0] Write_Fifo_address_a;
 //assignment
 assign Write_Fifo_Clk = iDm9000aClk;
 assign Write_Fifo_RunStart = Dm9000a_Task_out_to_Write_Fifo_RunStart; //一旦应答包结束就启动写fifo
 assign Write_Fifo_in_from_Dm9000a_Rx_Tx_Len = Dm9000a_Task_out_to_Write_Fifo_len;//向fifo写入的字节长度
 assign Write_Fifo_wrfull = fifo_wrfull;
 assign Write_Fifo_in_from_dpram_q_a = dpram_q_a;
 //Instantiate this module
 Write_Fifo Tx_Fifo
 (
  .iDm9000aClk(Write_Fifo_Clk),
  .iRunStart(Write_Fifo_RunStart),
  .in_from_Dm9000a_Rx_Tx_Len(Write_Fifo_in_from_Dm9000a_Rx_Tx_Len),
  .wrfull(Write_Fifo_wrfull),
  .in_from_dpram_q_a(Write_Fifo_in_from_dpram_q_a),
  .oRunEnd(Write_Fifo_RunEnd),
  .wr_fifo_req(Write_Fifo_req),
  .fifo_data_in(Write_Fifo_data_in),
  .rden_a(Write_Fifo_rden_a),
  .address_a(Write_Fifo_address_a)
 );
/*----------------------------------------------------------------------*/
wire Dm9000a_phy_wr_Clk;
wire Dm9000a_phy_wr_RunStart;
wire [15:0] Dm9000a_phy_wr_Reg;
wire [15:0] Dm9000a_phy_wr_Value;
wire Dm9000a_phy_wr_in_from_Dm9000a_Iow_RunEnd;
wire Dm9000a_phy_wr_in_from_Dm9000a_IOWR_RunEnd;
wire Dm9000a_phy_wr_in_from_Dm9000a_usDelay_RunEnd;
//output
wire Dm9000a_phy_wr_RunEnd;
wire Dm9000a_phy_wr_out_to_Dm9000a_Iow_RunStart;
wire [15:0] Dm9000a_phy_wr_out_to_Dm9000a_Iow_Reg;
wire [15:0] Dm9000a_phy_wr_out_to_Dm9000a_Iow_Data;
wire Dm9000a_phy_wr_out_to_Dm9000a_IOWR_RunStart;
wire Dm9000a_phy_wr_out_to_Dm9000a_IOWR_IndexOrData;
wire [15:0]Dm9000a_phy_wr_out_to_Dm9000a_IOWR_OutData;
wire Dm9000a_phy_wr_out_to_Dm9000a_usDelay_RunStart;
wire [10:0] Dm9000a_phy_wr_out_to_Dm9000a_usDelay_DelayTime;
 //assignment
 assign Dm9000a_phy_wr_Clk = iDm9000aClk; //global clock
 assign Dm9000a_phy_wr_RunStart = Dm9000a_Initial_out_to_phy_write_RunStart;
 assign Dm9000a_phy_wr_Reg = Dm9000a_Initial_out_to_phy_write_Reg;
 assign Dm9000a_phy_wr_Value = Dm9000a_Initial_out_to_phy_write_Value;
 assign Dm9000a_phy_wr_in_from_Dm9000a_Iow_RunEnd = Dm9000a_Iow_RunEnd;
 assign Dm9000a_phy_wr_in_from_Dm9000a_IOWR_RunEnd = Dm9000a_IOWR_RunEnd;
 assign Dm9000a_phy_wr_in_from_Dm9000a_usDelay_RunEnd = Dm9000a_usDelay_RunEnd;
 //Instantiate this module
  DM9000A_PHY_WR Dm9000a_phy_wr(
    .iDm9000aClk(Dm9000a_phy_wr_Clk),
    .iRunStart(Dm9000a_phy_wr_RunStart),//from upper
    .iReg(Dm9000a_phy_wr_Reg),//from upper
    .iValue(Dm9000a_phy_wr_Value),//from upper
    .in_from_Dm9000a_Iow_RunEnd(Dm9000a_phy_wr_in_from_Dm9000a_Iow_RunEnd),
    .in_from_Dm9000a_IOWR_RunEnd(Dm9000a_phy_wr_in_from_Dm9000a_IOWR_RunEnd),
    .in_from_Dm9000a_usDelay_RunEnd(Dm9000a_phy_wr_in_from_Dm9000a_usDelay_RunEnd),
    .oRunEnd(Dm9000a_phy_wr_RunEnd),//from upper
    .out_to_Dm9000a_Iow_RunStart(Dm9000a_phy_wr_out_to_Dm9000a_Iow_RunStart),
    .out_to_Dm9000a_Iow_Reg(Dm9000a_phy_wr_out_to_Dm9000a_Iow_Reg),
    .out_to_Dm9000a_Iow_Data(Dm9000a_phy_wr_out_to_Dm9000a_Iow_Data),
    .out_to_Dm9000a_IOWR_RunStart(Dm9000a_phy_wr_out_to_Dm9000a_IOWR_RunStart),
    .out_to_Dm9000a_IOWR_IndexOrData(Dm9000a_phy_wr_out_to_Dm9000a_IOWR_IndexOrData),
    .out_to_Dm9000a_IOWR_OutData(Dm9000a_phy_wr_out_to_Dm9000a_IOWR_OutData),
    .out_to_Dm9000a_usDelay_RunStart(Dm9000a_phy_wr_out_to_Dm9000a_usDelay_RunStart),
    .out_to_Dm9000a_usDelay_DelayTime(Dm9000a_phy_wr_out_to_Dm9000a_usDelay_DelayTime)
  );
  /*--------------------------------------------------------------------------------------------------------*/
  //input
  wire Dm9000a_Iow_Clk;
  wire Dm9000a_Iow_RunStart;
  wire [15:0] Dm9000a_Iow_Reg;
  wire [15:0] Dm9000a_Iow_Data;
  wire Dm9000a_Iow_in_from_Dm9000a_IOWR_RunEnd;
  wire Dm9000a_Iow_in_from_Dm9000a_usDelay_RunEnd;
  //output
  wire Dm9000a_Iow_RunEnd;
  wire Dm9000a_Iow_out_to_Dm9000a_IOWR_RunStart;
  wire Dm9000a_Iow_out_to_Dm9000a_IOWR_IndexOrData;
  wire [15:0] Dm9000a_Iow_out_to_Dm9000a_IOWR_OutData;
  wire Dm9000a_Iow_out_to_Dm9000a_usDelay_RunStart;
  wire [10:0] Dm9000a_Iow_out_to_Dm9000a_usDelay_DelayTime;
  //assignment
  assign Dm9000a_Iow_Clk = iDm9000aClk; //global clock
  assign Dm9000a_Iow_RunStart =Dm9000a_Initial_out_to_Dm9000a_Iow_RunStart
									 |Dm9000a_interrupt_hdl_out_to_Dm9000a_Iow_RunStart
									 |Dm9000a_phy_wr_out_to_Dm9000a_Iow_RunStart
									// |Dm9000a_Rx_out_to_Dm9000a_Iow_RunStart 
									 |Dm9000a_Rx_Reset_out_to_Dm9000a_Iow_RunStart
									 |Dm9000a_Tx_out_to_Dm9000a_Iow_RunStart;
  assign Dm9000a_Iow_Reg = Dm9000a_Initial_out_to_Dm9000a_Iow_Reg
								  |Dm9000a_interrupt_hdl_out_to_Dm9000a_Iow_Reg
							     |Dm9000a_phy_wr_out_to_Dm9000a_Iow_Reg
							     //|Dm9000a_Rx_out_to_Dm9000a_Iow_Reg 
								  |Dm9000a_Rx_Reset_out_to_Dm9000a_Iow_Reg
							     |Dm9000a_Tx_out_to_Dm9000a_Iow_Reg;
  assign Dm9000a_Iow_Data = Dm9000a_Initial_out_to_Dm9000a_Iow_Data
								 |Dm9000a_interrupt_hdl_out_to_Dm9000a_Iow_Data
								 |Dm9000a_phy_wr_out_to_Dm9000a_Iow_Data
								 //|Dm9000a_Rx_out_to_Dm9000a_Iow_Data
								 |Dm9000a_Rx_Reset_out_to_Dm9000a_Iow_Data
								 |Dm9000a_Tx_out_to_Dm9000a_Iow_Data;
  assign Dm9000a_Iow_in_from_Dm9000a_IOWR_RunEnd = Dm9000a_IOWR_RunEnd;
  assign Dm9000a_Iow_in_from_Dm9000a_usDelay_RunEnd = Dm9000a_usDelay_RunEnd;
  //Instantiate this module
  DM9000A_iow Dm9000a_Iow
  (
    .iDm9000aClk(Dm9000a_Iow_Clk),
    .iRunStart(Dm9000a_Iow_RunStart),//from upper
    .iReg(Dm9000a_Iow_Reg), //from upper
    .iData(Dm9000a_Iow_Data),//from upper
    .in_from_Dm9000a_IOWR_RunEnd(Dm9000a_Iow_in_from_Dm9000a_IOWR_RunEnd),//from lower
    .in_from_Dm9000a_usDelay_RunEnd(Dm9000a_Iow_in_from_Dm9000a_usDelay_RunEnd),//from lower
    .oRunEnd(Dm9000a_Iow_RunEnd),
    .out_to_Dm9000a_IOWR_RunStart(Dm9000a_Iow_out_to_Dm9000a_IOWR_RunStart),//from lower
    .out_to_Dm9000a_IOWR_IndexOrData(Dm9000a_Iow_out_to_Dm9000a_IOWR_IndexOrData),//from lower
    .out_to_Dm9000a_IOWR_OutData(Dm9000a_Iow_out_to_Dm9000a_IOWR_OutData), //from lower
    .out_to_Dm9000a_usDelay_RunStart(Dm9000a_Iow_out_to_Dm9000a_usDelay_RunStart),
    .out_to_Dm9000a_usDelay_DelayTime(Dm9000a_Iow_out_to_Dm9000a_usDelay_DelayTime)
  );
  /*-----------------------------------------------------------------------------------------------------------------------*/
  //input
  wire Dm9000a_Ior_Clk;
  wire Dm9000a_Ior_RunStart;
  wire [15:0] Dm9000a_Ior_Reg;
  wire Dm9000a_Ior_in_from_Dm9000a_IOWR_RunEnd;
  wire Dm9000a_Ior_in_from_Dm9000a_IORD_RunEnd;
  wire Dm9000a_Ior_in_from_Dm9000a_usDelay_RunEnd;
  wire [15:0] Dm9000a_Ior_in_from_Dm9000a_IORD_ReturnValue;
  //output
  wire Dm9000a_Ior_RunEnd;
  wire [15:0] Dm9000a_Ior_ReturnValue;
  wire Dm9000a_Ior_out_to_Dm9000a_IOWR_RunStart;
  wire Dm9000a_Ior_out_to_Dm9000a_IOWR_IndexOrData;
  wire [15:0] Dm9000a_Ior_out_to_Dm9000a_IOWR_OutData;
  wire Dm9000a_Ior_out_to_Dm9000a_IORD_RunStart;
  wire Dm9000a_Ior_out_to_Dm9000a_IORD_IndexOrData;
  wire Dm9000a_Ior_out_to_Dm9000a_usDelay_RunStart;
  wire [10:0] Dm9000a_Ior_out_to_Dm9000a_usDelayTime;
  //assignment
  assign Dm9000a_Ior_Clk = iDm9000aClk; //global clock
  assign Dm9000a_Ior_RunStart = Dm9000a_Initial_out_to_Dm9000a_Ior_RunStart
									 |Dm9000a_interrupt_hdl_out_to_Dm9000a_Ior_RunStart //new add
									 |Dm9000a_Rx_out_to_Dm9000a_Ior_RunStart
									 |Dm9000a_Tx_out_to_Dm9000a_Ior_RunStart;
  assign Dm9000a_Ior_Reg = Dm9000a_Initial_out_to_Dm9000a_Ior_iReg
								 |Dm9000a_interrupt_hdl_out_to_Dm9000a_Ior_iReg
							    |Dm9000a_Rx_out_to_Dm9000a_Ior_iReg 
							    |Dm9000a_Tx_out_to_Dm9000a_Ior_iReg;
  assign Dm9000a_Ior_in_from_Dm9000a_IOWR_RunEnd = Dm9000a_IOWR_RunEnd;
  assign Dm9000a_Ior_in_from_Dm9000a_IORD_RunEnd = Dm9000a_IORD_RunEnd;
  assign Dm9000a_Ior_in_from_Dm9000a_usDelay_RunEnd = Dm9000a_usDelay_RunEnd;
  assign Dm9000a_Ior_in_from_Dm9000a_IORD_ReturnValue = Dm9000a_IORD_ReturnValue;
  //Instantiate this module
    DM9000A_ior Dm9000a_Ior
    (
    .iDm9000aClk(Dm9000a_Ior_Clk),
    .iRunStart(Dm9000a_Ior_RunStart),
    .iReg(Dm9000a_Ior_Reg),
    .in_from_Dm9000a_IOWR_RunEnd(Dm9000a_Ior_in_from_Dm9000a_IOWR_RunEnd),
    .in_from_Dm9000a_IORD_RunEnd(Dm9000a_Ior_in_from_Dm9000a_IORD_RunEnd),
    .in_from_Dm9000a_usDelay_RunEnd(Dm9000a_Ior_in_from_Dm9000a_usDelay_RunEnd),
    .in_from_Dm9000a_IORD_ReturnValue(Dm9000a_Ior_in_from_Dm9000a_IORD_ReturnValue),
    .oRunEnd(Dm9000a_Ior_RunEnd),
    .oReturnValue(Dm9000a_Ior_ReturnValue),
    .out_to_Dm9000a_IOWR_RunStart(Dm9000a_Ior_out_to_Dm9000a_IOWR_RunStart),
    .out_to_Dm9000a_IOWR_IndexOrData(Dm9000a_Ior_out_to_Dm9000a_IOWR_IndexOrData),
    .out_to_Dm9000a_IOWR_OutData(Dm9000a_Ior_out_to_Dm9000a_IOWR_OutData),

    .out_to_Dm9000a_IORD_RunStart(Dm9000a_Ior_out_to_Dm9000a_IORD_RunStart),
    .out_to_Dm9000a_IORD_IndexOrData(Dm9000a_Ior_out_to_Dm9000a_IORD_IndexOrData),

    .out_to_Dm9000a_usDelay_RunStart(Dm9000a_Ior_out_to_Dm9000a_usDelay_RunStart),
    .out_to_Dm9000a_usDelay_DelayTime(Dm9000a_Ior_out_to_Dm9000a_usDelayTime)
  );
  /*----------------------------------------------------------------------------------------------------*/
  //input
  wire Dm9000a_IOWR_Clk;
  wire Dm9000a_IOWR_RunStart;
  wire Dm9000a_IOWR_IndexOrData;
  wire [15:0] Dm9000a_IOWR_OutData;
  //output
  wire Dm9000a_IOWR_RunEnd;
  wire Dm9000a_IOWR_out_to_Dm9000a_Io_Cs;
  wire Dm9000a_IOWR_out_to_Dm9000a_Io_Cmd;
  wire Dm9000a_IOWR_out_to_Dm9000a_Io_Iow;
  wire [15:0] Dm9000a_IOWR_out_to_Dm9000a_Io_Data;
  wire Dm9000a_IOWR_out_to_Dm9000a_Io_DataOutEn;
   //assignment
  assign Dm9000a_IOWR_Clk = iDm9000aClk;   //global clock
  assign Dm9000a_IOWR_RunStart  = Dm9000a_phy_wr_out_to_Dm9000a_IOWR_RunStart 
										| Dm9000a_Rx_out_to_Dm9000a_IOWR_RunStart
										| Dm9000a_Tx_out_to_Dm9000a_IOWR_RunStart
										| Dm9000a_Iow_out_to_Dm9000a_IOWR_RunStart
										| Dm9000a_Ior_out_to_Dm9000a_IOWR_RunStart;
  assign Dm9000a_IOWR_IndexOrData = Dm9000a_phy_wr_out_to_Dm9000a_IOWR_IndexOrData
										| Dm9000a_Rx_out_to_Dm9000a_IOWR_IndexOrData
										| Dm9000a_Tx_out_to_Dm9000a_IOWR_IndexOrData
										| Dm9000a_Iow_out_to_Dm9000a_IOWR_IndexOrData
										| Dm9000a_Ior_out_to_Dm9000a_IOWR_IndexOrData;
  assign Dm9000a_IOWR_OutData =  Dm9000a_phy_wr_out_to_Dm9000a_IOWR_OutData
										| Dm9000a_Rx_out_to_Dm9000a_IOWR_OutData
										| Dm9000a_Tx_out_to_Dm9000a_IOWR_OutData
										| Dm9000a_Iow_out_to_Dm9000a_IOWR_OutData
										| Dm9000a_Ior_out_to_Dm9000a_IOWR_OutData;
  //Instantiate this module
  DM9000A_IOWR Dm9000a_IOWR
  (
    .iDm9000aClk(Dm9000a_IOWR_Clk),
    .iRunStart(Dm9000a_IOWR_RunStart), // form upper
    .iIndexOrData(Dm9000a_IOWR_IndexOrData),//from upper
    .iOutData(Dm9000a_IOWR_OutData),//from upper
    .oRunEnd(Dm9000a_IOWR_RunEnd), //from upper
    .out_to_Dm9000a_Io_Cs(Dm9000a_IOWR_out_to_Dm9000a_Io_Cs),
    .out_to_Dm9000a_Io_Cmd(Dm9000a_IOWR_out_to_Dm9000a_Io_Cmd),
    .out_to_Dm9000a_Io_Iow(Dm9000a_IOWR_out_to_Dm9000a_Io_Iow),
    .out_to_Dm9000a_Io_Data(Dm9000a_IOWR_out_to_Dm9000a_Io_Data),
    .out_to_Dm9000a_Io_DataOutEn(Dm9000a_IOWR_out_to_Dm9000a_Io_DataOutEn)
  );
  /*-----------------------------------------------------------------------------------------*/
  //input
  wire Dm9000a_IORD_Clk;
  wire Dm9000a_IORD_RunStart; 
  wire Dm9000a_IORD_IndexOrData;
  wire [15:0] Dm9000a_IORD_in_from_Dm9000a_Io_ReturnValue;
  //output
  wire Dm9000a_IORD_RunEnd;
  wire Dm9000a_IORD_out_to_Dm9000a_Io_Cs;
  wire Dm9000a_IORD_out_to_Dm9000a_Io_Cmd;
  wire Dm9000a_IORD_out_to_Dm9000a_Io_Ior;
  wire [15:0]Dm9000a_IORD_ReturnValue;
  //assignment
  assign Dm9000a_IORD_Clk = iDm9000aClk; //global clock
  assign Dm9000a_IORD_RunStart = Dm9000a_Rx_out_to_Dm9000a_IORD_RunStart
									     | Dm9000a_Ior_out_to_Dm9000a_IORD_RunStart;
  assign Dm9000a_IORD_IndexOrData =  Dm9000a_Rx_out_to_Dm9000a_IORD_IndexOrData
											| Dm9000a_Ior_out_to_Dm9000a_IORD_IndexOrData;
  assign Dm9000a_IORD_in_from_Dm9000a_Io_ReturnValue = Dm9000a_IO_oData;  // from data bus	
  //Instantiate this module
  DM9000A_IORD Dm9000a_IORD
  (
    .iDm9000aClk(Dm9000a_IORD_Clk),
    .iRunStart(Dm9000a_IORD_RunStart), //from upper
    .iIndexOrData(Dm9000a_IORD_IndexOrData),//from upper
    .in_from_Dm9000a_Io_ReturnValue(Dm9000a_IORD_in_from_Dm9000a_Io_ReturnValue),
    .oRunEnd(Dm9000a_IORD_RunEnd),//from upper
    .out_to_Dm9000a_Io_Cs(Dm9000a_IORD_out_to_Dm9000a_Io_Cs),
    .out_to_Dm9000a_Io_Cmd(Dm9000a_IORD_out_to_Dm9000a_Io_Cmd),
    .out_to_Dm9000a_Io_Ior(Dm9000a_IORD_out_to_Dm9000a_Io_Ior),
    .oReturnValue(Dm9000a_IORD_ReturnValue)//from upper
  );
  /*-------------------------------------------------------------------------------*/
  //input
  wire Dm9000a_usDelay_Clk;
  wire Dm9000a_usDelay_RunStart;
  wire [10:0] Dm9000a_usDelay_DelayTime;
  //output
  wire Dm9000a_usDelay_RunEnd;
  //assignment
  assign Dm9000a_usDelay_Clk = iDm9000aClk;  //global clock
  assign Dm9000a_usDelay_RunStart = Dm9000a_Initial_out_to_Dm9000a_usDelay_RunStart
										| Dm9000a_phy_wr_out_to_Dm9000a_usDelay_RunStart
										| Dm9000a_Rx_out_to_Dm9000a_usDelay_RunStart
										| Dm9000a_Rx_Reset_out_to_Dm9000a_usDelay_RunStart
										| Dm9000a_Tx_out_to_Dm9000a_usDelay_RunStart
										| Dm9000a_Iow_out_to_Dm9000a_usDelay_RunStart
										| Dm9000a_Ior_out_to_Dm9000a_usDelay_RunStart;
  assign Dm9000a_usDelay_DelayTime = Dm9000a_Initial_out_to_Dm9000a_usDelay_DelayTime
										| Dm9000a_phy_wr_out_to_Dm9000a_usDelay_DelayTime
										| Dm9000a_Rx_out_to_Dm9000a_usDelay_DelayTime
										| Dm9000a_Rx_Reset_out_to_Dm9000a_usDelay_DelayTime
										| Dm9000a_Tx_out_to_Dm9000a_usDelay_DelayTime
										| Dm9000a_Iow_out_to_Dm9000a_usDelay_DelayTime
										| Dm9000a_Ior_out_to_Dm9000a_usDelayTime;
 //Instantiate this module
  DM9000A_usDelay Dm9000a_usDelay(
  .iDm9000aClk(Dm9000a_usDelay_Clk),
  .iRunStart(Dm9000a_usDelay_RunStart),
  .iDelayTime(Dm9000a_usDelay_DelayTime),
  .oRunEnd(Dm9000a_usDelay_RunEnd)
  );
  /*----------------------------------------------------------------------------------------*/
  //input
  wire   Dm9000a_IO_Clk; 
  wire   Dm9000a_IO_iReset;
  wire   [15:0] Dm9000a_IO_iDm9000aBusData; // input from data bus
  wire   [15:0] Dm9000a_IO_iData;                       // input from module 
  wire   Dm9000a_IO_iDm9000aBusOutEn;  
  wire   Dm9000a_IO_iCs;
  wire   Dm9000a_IO_iCmd;
  wire   Dm9000a_IO_iIor;
  wire   Dm9000a_IO_iIow;  
  wire   Dm9000a_IO_iInt; 
  //output
  wire   [15:0] Dm9000a_IO_oData; // out to module 
  wire   [15:0] Dm9000a_IO_oDm9000aBusData; // out to data bus 
  wire   Dm9000a_IO_oDm9000aBusOutEn;   //output data bus out enable
  wire   Dm9000a_IO_oCs;
  wire   Dm9000a_IO_oCmd;
  wire   Dm9000a_IO_oIor;
  wire   Dm9000a_IO_oIow; 
  wire   Dm9000a_IO_oInt; 
  //assignment
  assign Dm9000a_IO_Clk = iDm9000aClk;   //global clock
  assign Dm9000a_IO_iReset = iRunStart;    //global reset
  assign Dm9000a_IO_iDm9000aBusData = iDm9000aBusData;     // input from data bus
  assign Dm9000a_IO_iData = Dm9000a_IOWR_out_to_Dm9000a_Io_Data; // input from module 
  assign Dm9000a_IO_iDm9000aBusOutEn = Dm9000a_IOWR_out_to_Dm9000a_Io_DataOutEn;  
  
  assign Dm9000a_IO_iCs  = Dm9000a_IOWR_out_to_Dm9000a_Io_Cs &
								Dm9000a_IORD_out_to_Dm9000a_Io_Cs;                       
  assign Dm9000a_IO_iCmd = Dm9000a_IOWR_out_to_Dm9000a_Io_Cmd &
								  Dm9000a_IORD_out_to_Dm9000a_Io_Cmd;                     
  assign Dm9000a_IO_iIor = Dm9000a_IORD_out_to_Dm9000a_Io_Ior; 
  assign Dm9000a_IO_iIow = Dm9000a_IOWR_out_to_Dm9000a_Io_Iow;  
  assign Dm9000a_IO_iInt = iDm9000a_Int; // interrupt input
  //instantiation
  DM9000A_IO  Dm9000a_IO_1  // Dm9000A 的 IO 引脚
  (  
  .iReset(Dm9000a_IO_iReset),
 
  .iDm9000aClk(Dm9000a_IO_Clk),
  
  .iDm9000aBusData(Dm9000a_IO_iDm9000aBusData),  //input data from data bus
  .oData(Dm9000a_IO_oData), //out to module

  .iData(Dm9000a_IO_iData), //input data from module
  .oDm9000aBusData(Dm9000a_IO_oDm9000aBusData), //out to data bus

  .iDm9000aBusOutEn(Dm9000a_IO_iDm9000aBusOutEn),
  .oDm9000aBusOutEn(Dm9000a_IO_oDm9000aBusOutEn), 

  .iCs(Dm9000a_IO_iCs),
  .oCs(Dm9000a_IO_oCs),

  .iCmd(Dm9000a_IO_iCmd),
  .oCmd(Dm9000a_IO_oCmd),

  .iIor(Dm9000a_IO_iIor),
  .oIor(Dm9000a_IO_oIor),

  .iIow(Dm9000a_IO_iIow),  
  .oIow(Dm9000a_IO_oIow),

  .iInt(Dm9000a_IO_iInt), 
  .oInt(Dm9000a_IO_oInt)
  );
  reg    [15:0] iDm9000aBusData; //data from databus
  always @ (negedge iDm9000aClk)
    begin 
      if(!oDm9000a_Ior) iDm9000aBusData <= ioDm9000aBusData; 
    end 
  wire oDm9000a_Int;//interrupt out to module
  assign ioDm9000aBusData = Dm9000a_IO_oDm9000aBusOutEn ? Dm9000a_IO_oDm9000aBusData : 16'hz; // if bus enable ,output or z
  assign oDm9000a_Cs = Dm9000a_IO_oCs;              //Pin assignment
  assign oDm9000a_Cmd = Dm9000a_IO_oCmd;
  assign oDm9000a_Ior = Dm9000a_IO_oIor;
  assign oDm9000a_Iow = Dm9000a_IO_oIow;
  assign oDm9000a_Int = Dm9000a_IO_oInt;  
  assign oRunEnd = Event_Success;
  /*---------------------------------------------------------------------------*/
  //Test
  assign Tp[1] = Dm9000a_Task_RunStart;                        
  assign Tp[2] = Dm9000a_Rx_Done;
  //assign Tp[2] = Dm9000a_Initial_InitDone;    //if dm9000a is intial         check
  //assign Tp[3] = Dm9000a_Initial_RunEnd;       //if initial done                   check
  assign Tp[3] = Dm9000a_Task_out_to_Dm9000a_Rx_RunStart; //check
  assign Tp[4] = oDm9000a_Int;                        // if the interrupt come?       check
  //assign Tp[5] = oRunEnd;                                  // if a event done?                 Error
  assign Tp[5] = Event_Success;
  assign Tp[6] = Dm9000a_Tx_Done;
  /*---------------------------------------------------------------------------*/

endmodule 

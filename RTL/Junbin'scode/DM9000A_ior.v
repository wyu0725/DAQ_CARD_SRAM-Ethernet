/*DM9000A寄存器写<寄存器读写层>------------------------*/
//Designed by Junbin Zhang
//Updated 20140723
//updated 20140811
/*-----------------------------------------------------*/
//读寄存器iReg中的内容过程如下：
//1.先通过管脚写的操作将寄存的的地址写入
//2.然后通过管脚读回数据
`include "DM9000A.def"
/*---------------------------------------------------------------------------*/
module DM9000A_ior // Dm9000A 端口读模块
(  
  input iDm9000aClk,
  input iRunStart,
  input [15:0]  iReg,                 //寄存器地址
  input in_from_Dm9000a_IOWR_RunEnd,     //IOWR模块的RunEnd信号
  input in_from_Dm9000a_IORD_RunEnd,      //IORD模块的RunEnd信号
  input in_from_Dm9000a_usDelay_RunEnd,  //usDelay 模块的RunEnd信号
  input [15:0] in_from_Dm9000a_IORD_ReturnValue,//IORD模块得到的返回数据
  output reg oRunEnd,
  output reg [15:0]oReturnValue,                                 //模块的输出数据
  output reg out_to_Dm9000a_IOWR_RunStart,        //输出到IOWR模块的RunStart信号
  output reg out_to_Dm9000a_IOWR_IndexOrData,  //输出到IOWR模块的IndexorData信号
  output reg [15:0]out_to_Dm9000a_IOWR_OutData, //输出到IOWR模块的iOutData信号
  output reg out_to_Dm9000a_IORD_RunStart,          //输出到IORD模块的RunStart信号
  output reg out_to_Dm9000a_IORD_IndexOrData,     //输出到IORD模块的IndexOrData信号
  output reg out_to_Dm9000a_usDelay_RunStart,      //启动us延时
  output reg [10:0] out_to_Dm9000a_usDelay_DelayTime //延时的时间
);

/*---------------------------------------------------------------------------*/
reg StateChangeEnable;
wire StateChange;
assign StateChange = (~oRunEnd)
                               & (StateChangeEnable 
                                |(out_to_Dm9000a_IOWR_RunStart & in_from_Dm9000a_IOWR_RunEnd)
                                |(out_to_Dm9000a_IORD_RunStart & in_from_Dm9000a_IORD_RunEnd)
                                |(out_to_Dm9000a_usDelay_RunStart & in_from_Dm9000a_usDelay_RunEnd));
/************************************************/				  
reg [4:0] currentState,nextState;
localparam[4:0] Idle = 5'b00001,
              State1 = 5'b00010,
					    State2 = 5'b00100,
					    State3 = 5'b01000,
					    Rdone  = 5'b10000;
always@(posedge iDm9000aClk,negedge iRunStart)begin
  if(~iRunStart)
    currentState <= Idle;
  else
    currentState <= StateChange ? nextState:currentState;
end
always@(*)begin
	case(currentState)
    Idle:begin
      out_to_Dm9000a_usDelay_RunStart = 1'b0; 
      out_to_Dm9000a_usDelay_DelayTime = 11'd0;
      out_to_Dm9000a_IOWR_RunStart = 1'b0;
      out_to_Dm9000a_IOWR_IndexOrData = 1'b0;
      out_to_Dm9000a_IOWR_OutData = 16'd0;
      out_to_Dm9000a_IORD_RunStart = 1'b0;
      out_to_Dm9000a_IORD_IndexOrData = 1'b0;
      oRunEnd = 1'b0;
      StateChangeEnable = 1'b1;
      nextState = State1;
    end
    State1:begin
      out_to_Dm9000a_usDelay_RunStart = 1'b0;
      out_to_Dm9000a_usDelay_DelayTime = 11'd0;
      out_to_Dm9000a_IOWR_RunStart = 1'b1;  // IOWR(DM9000A_BASE,IO_addr,reg);
      out_to_Dm9000a_IOWR_IndexOrData = `IO_addr;
      out_to_Dm9000a_IOWR_OutData = iReg;
      out_to_Dm9000a_IORD_RunStart = 1'b0;
      out_to_Dm9000a_IORD_IndexOrData = 1'b0;
      oRunEnd = 1'b0;
      StateChangeEnable = 1'b0;
      nextState = State2;
    end
		State2:begin
      out_to_Dm9000a_usDelay_RunStart = 1'b1;
      out_to_Dm9000a_usDelay_DelayTime = `STD_DELAY; //20us
      out_to_Dm9000a_IOWR_RunStart = 1'b0;
      out_to_Dm9000a_IOWR_IndexOrData = 1'b0;
      out_to_Dm9000a_IOWR_OutData = 16'd0;
      out_to_Dm9000a_IORD_RunStart = 1'b0;
      out_to_Dm9000a_IORD_IndexOrData = 1'b0;
      oRunEnd = 1'b0;
      StateChangeEnable = 1'b0;
      nextState = State3;
    end
		State3:begin
      out_to_Dm9000a_usDelay_RunStart = 1'b0;
      out_to_Dm9000a_usDelay_DelayTime = 11'd0;
      out_to_Dm9000a_IOWR_RunStart = 1'b0;
      out_to_Dm9000a_IOWR_IndexOrData = 1'b0;
      out_to_Dm9000a_IOWR_OutData = 16'd0;
      out_to_Dm9000a_IORD_RunStart = 1'b1;
      out_to_Dm9000a_IORD_IndexOrData = `IO_data;  // IORD(DM9000A_BASE,IO_data);
      oRunEnd = 1'b0;
      StateChangeEnable = 1'b0;
      nextState = Rdone;
    end
		Rdone:begin
      out_to_Dm9000a_usDelay_RunStart = 1'b0;
      out_to_Dm9000a_usDelay_DelayTime = 11'd0;
      out_to_Dm9000a_IOWR_RunStart = 1'b0;
      out_to_Dm9000a_IOWR_IndexOrData = 1'b0;
      out_to_Dm9000a_IOWR_OutData = 16'd0;
      out_to_Dm9000a_IORD_RunStart = 1'b0;
      out_to_Dm9000a_IORD_IndexOrData = 1'b0;
      StateChangeEnable = 1'b0;
      oRunEnd = 1'b1;
      nextState = Idle; //modified 20140723
    end
    default:begin
      nextState = Idle;
      out_to_Dm9000a_usDelay_RunStart = 1'b0; 
      out_to_Dm9000a_usDelay_DelayTime = 11'd0;
      out_to_Dm9000a_IOWR_RunStart = 1'b0;
      out_to_Dm9000a_IOWR_IndexOrData = 1'b0;
      out_to_Dm9000a_IOWR_OutData = 16'd0;
      out_to_Dm9000a_IORD_RunStart = 1'b0;
      out_to_Dm9000a_IORD_IndexOrData = 1'b0;
      StateChangeEnable = 1'b1;
      oRunEnd = 1'b0;
    end		
	endcase
end
  /*-----------------------------------------------------*/
always @ (posedge iDm9000aClk)begin 
  if(out_to_Dm9000a_IORD_RunStart & in_from_Dm9000a_IORD_RunEnd) begin
    oReturnValue <= in_from_Dm9000a_IORD_ReturnValue;
  end
end
   /*-----------------------------------------------------*/
endmodule 
/*---------------------------------------------------------------------------*/

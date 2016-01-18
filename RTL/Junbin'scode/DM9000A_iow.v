/*DM9000A寄存器写<寄存器读写层>*/
//Designed by Junbin Zhang
//Update 20140723
//update 20140811
`include "DM9000A.def"
/*---------------------------------------------------------------------------*/
module DM9000A_iow 
(  
  input iDm9000aClk,
  input iRunStart,
  input [15:0]iReg,  //寄存器地址
  input [15:0]iData,//数据
  input in_from_Dm9000a_IOWR_RunEnd,//IOWR模块的RunEnd信号
  input in_from_Dm9000a_usDelay_RunEnd, //延时模块的结束信号
  output reg oRunEnd,
  output reg out_to_Dm9000a_IOWR_RunStart,      //输出到IOWR模块的iRunStart
  output reg out_to_Dm9000a_IOWR_IndexOrData,//输出到IOWR模块的iIndexordata
  output reg [15:0] out_to_Dm9000a_IOWR_OutData,//输出到IOWR模块的iOutData[15:0]
  output reg out_to_Dm9000a_usDelay_RunStart,     //输出启动us延时模块
  output reg [10:0] out_to_Dm9000a_usDelay_DelayTime //延时时间
);
/*---------------------------------------------------------------------------*/
reg    StateChangeEnable;
wire   StateChange;
assign StateChange = (~oRunEnd) 
                     &(StateChangeEnable 
                      |(out_to_Dm9000a_IOWR_RunStart & in_from_Dm9000a_IOWR_RunEnd)
                      |(out_to_Dm9000a_usDelay_RunStart & in_from_Dm9000a_usDelay_RunEnd));
reg [4:0] currentState,nextState;
 localparam[4:0] Idle = 5'b00001,
                 State1 = 5'b00010,
					       State2 = 5'b00100,
					       State3 = 5'b01000,
					       Wdone = 5'b10000;
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
      oRunEnd = 1'b0;
      StateChangeEnable = 1'b1;
      nextState = State1;
    end
    State1:begin
      out_to_Dm9000a_usDelay_RunStart = 1'b0;
      out_to_Dm9000a_usDelay_DelayTime = 11'd0;
      out_to_Dm9000a_IOWR_RunStart = 1'b1;               // IOWR(DM9000A_BASE,IO_addr,reg);
			out_to_Dm9000a_IOWR_IndexOrData = `IO_addr; //Index 模式
      out_to_Dm9000a_IOWR_OutData = iReg;
      oRunEnd = 1'b0;
      StateChangeEnable = 1'b0;
      nextState = State2;
    end
		State2:begin//delay
      out_to_Dm9000a_usDelay_RunStart = 1'b1; 
      out_to_Dm9000a_usDelay_DelayTime = `STD_DELAY; //20us
      out_to_Dm9000a_IOWR_RunStart = 1'b0;
      out_to_Dm9000a_IOWR_IndexOrData = 1'b0;
      out_to_Dm9000a_IOWR_OutData = 16'd0;
      oRunEnd = 1'b0;
      StateChangeEnable = 1'b0;
      nextState = State3;
    end
		State3:begin
      out_to_Dm9000a_usDelay_RunStart = 1'b0; 
      out_to_Dm9000a_usDelay_DelayTime = 11'd0;
      out_to_Dm9000a_IOWR_RunStart = 1'b1; // (DM9000A_BASE,IO_data,data);
      out_to_Dm9000a_IOWR_IndexOrData = `IO_data; //Data模式
      out_to_Dm9000a_IOWR_OutData = iData;
      oRunEnd = 1'b0;
      StateChangeEnable = 1'b0;
      nextState = Wdone;
    end
		Wdone:begin
      out_to_Dm9000a_usDelay_RunStart = 1'b0; 
      out_to_Dm9000a_usDelay_DelayTime = 11'd0;
      out_to_Dm9000a_IOWR_RunStart = 1'b0;
      out_to_Dm9000a_IOWR_IndexOrData = 1'b0;
      out_to_Dm9000a_IOWR_OutData = 16'd0;
      StateChangeEnable = 1'b0;
      oRunEnd = 1'b1;
      nextState = Idle; //modified 20140723
    end
    default:begin
		  out_to_Dm9000a_usDelay_RunStart = 1'b0;
      out_to_Dm9000a_usDelay_DelayTime = 11'd0;
      out_to_Dm9000a_IOWR_RunStart = 1'b0;
      out_to_Dm9000a_IOWR_IndexOrData = 1'b0;
      out_to_Dm9000a_IOWR_OutData = 16'd0;
      oRunEnd = 1'b0;
      StateChangeEnable = 1'b1;
      nextState = Idle;
    end
  endcase
end
endmodule 
/*---------------------------------------------------------------------------*/

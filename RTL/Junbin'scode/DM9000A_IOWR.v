/*此模块为模拟ISA总线写<底层>*/   
//Designed by Junbin Zhang
//updated 20140723
//updated 20140811
/*---------------------------------------------------------------------------*/
module DM9000A_IOWR 
(  
  input iDm9000aClk,                           //25MHz
  input iRunStart,                            //高电平启动
  input iIndexOrData,                        // Index 还是 Data，为0选Index,为1选Data，由上层模块指定
  input [15:0]iOutData,                     //上层模块写入的数据
  output reg oRunEnd,                      //结束标志
  output reg out_to_Dm9000a_Io_Cs,        //与DM9000A_IO模块CS管脚相连
  output reg out_to_Dm9000a_Io_Cmd,      //与DM9000A_IO模块Cmd管脚相连
  output reg out_to_Dm9000a_Io_Iow,     //与DM9000A_IO模块Iow管脚相连
  output [15:0] out_to_Dm9000a_Io_Data,//与DM9000A_IO模块 SD[15:0]相连
  output out_to_Dm9000a_Io_DataOutEn  //与iRunStart相连
);
/*---------------------------------------------------------------------------*/
reg [4:0] currentState,nextState;
reg StateChangeEnable;
wire StateChange;
assign StateChange  = (~oRunEnd) & (StateChangeEnable);
localparam[4:0] Idle = 5'b00001,
              State1 = 5'b00010,
			        State2 = 5'b00100,
			        State3 = 5'b01000,
			         Tend  = 5'b10000;
always@(posedge iDm9000aClk,negedge iRunStart)begin
	if(~iRunStart)
		currentState <= Idle;
	else
    currentState <= StateChange ? nextState:currentState;
end
always@(*)begin
	case(currentState)
    Idle:begin
      out_to_Dm9000a_Io_Cs = 1'b1;
      out_to_Dm9000a_Io_Cmd = 1'b1;
      out_to_Dm9000a_Io_Iow = 1'b1;
      oRunEnd = 1'b0;
      StateChangeEnable = 1'b1;
      nextState = State1;
    end
		State1:begin
      out_to_Dm9000a_Io_Cs = 1'b0;
      out_to_Dm9000a_Io_Cmd = iIndexOrData;
      out_to_Dm9000a_Io_Iow = 1'b1;
      oRunEnd = 1'b0;
      StateChangeEnable = 1'b1;
      nextState = State2;
    end
    State2:begin
      out_to_Dm9000a_Io_Cs = 1'b0;
      out_to_Dm9000a_Io_Cmd = iIndexOrData;
      out_to_Dm9000a_Io_Iow = 1'b0;
      oRunEnd = 1'b0;
      StateChangeEnable = 1'b1;
      nextState = State3;
    end
		State3:begin
      out_to_Dm9000a_Io_Cs = 1'b0;
      out_to_Dm9000a_Io_Cmd = iIndexOrData;
      out_to_Dm9000a_Io_Iow = 1'b1;
      oRunEnd = 1'b0;
      StateChangeEnable = 1'b1;
      nextState = Tend;
    end
		Tend:begin
      out_to_Dm9000a_Io_Cs = 1'b1;
      out_to_Dm9000a_Io_Cmd = 1'b1;
      out_to_Dm9000a_Io_Iow = 1'b1;
      oRunEnd = 1'b1;
      StateChangeEnable = 1'b0;
      nextState = Idle;
    end
    default:begin
      nextState = Idle;
      out_to_Dm9000a_Io_Cs = 1'b1;
      out_to_Dm9000a_Io_Cmd = 1'b1;
      out_to_Dm9000a_Io_Iow = 1'b1;
      oRunEnd = 1'b0;	
      StateChangeEnable = 1'b1;
    end
	endcase
end
assign out_to_Dm9000a_Io_Data = iOutData;
assign out_to_Dm9000a_Io_DataOutEn = iRunStart; 
endmodule 
/*---------------------------------------------------------------------------*/

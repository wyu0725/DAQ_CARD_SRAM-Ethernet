/*��ģ��ģ��ISA���߶�ʱ��<�ײ�>*/
//Designed by Junbin Zhang
//updated 20140723
//updated 20140811
/*************************************************/
module DM9000A_IORD 
(  
  input iDm9000aClk,                           //50MHz
  input iRunStart,
  input iIndexOrData,                          // Index ���� Data��Ϊ0ѡIndex,Ϊ1ѡData�����ϲ�ģ��ָ��
  input [15:0]  in_from_Dm9000a_Io_ReturnValue,//��DM9000A���ص�����,��DM9000A��SD[15:0]����
  output reg oRunEnd,
  output reg out_to_Dm9000a_Io_Cs,             //��DM9000A_IOģ���CS�ܽ�����
  output reg out_to_Dm9000a_Io_Cmd,            //��DM9000A_IOģ���Cmd�ܽ�����
  output reg out_to_Dm9000a_Io_Ior,            //��DM9000A_IOģ���Ior�ܽ�����
  output [15:0] oReturnValue                   //��ȡ��������
);
/*---------------------------------------------------------------------------*/
reg [4:0] currentState,nextState;
reg StateChangeEnable;
wire StateChange;
assign StateChange = (~oRunEnd) & (StateChangeEnable);
localparam[4:0] Idle    = 5'b00001,
                State1 = 5'b00010,
       					State2 = 5'b00100,
					      State3 = 5'b01000,
					        Rend = 5'b10000;
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
      out_to_Dm9000a_Io_Ior = 1'b1;
      oRunEnd = 1'b0;
      StateChangeEnable = 1'b1;
      nextState = State1;
    end
		State1:begin
      out_to_Dm9000a_Io_Cs = 1'b0;
      out_to_Dm9000a_Io_Cmd = iIndexOrData;
      out_to_Dm9000a_Io_Ior = 1'b1;
      oRunEnd = 1'b0;
      StateChangeEnable = 1'b1;
      nextState = State2;
    end
		State2:begin
      out_to_Dm9000a_Io_Cs = 1'b0;
      out_to_Dm9000a_Io_Cmd = iIndexOrData;
      out_to_Dm9000a_Io_Ior = 1'b0;
      oRunEnd = 1'b0;
      StateChangeEnable = 1'b1;
      nextState = State3;
    end
		State3:begin
      out_to_Dm9000a_Io_Cs = 1'b0;
      out_to_Dm9000a_Io_Cmd = iIndexOrData;
      out_to_Dm9000a_Io_Ior = 1'b1;
      oRunEnd = 1'b0;
      StateChangeEnable = 1'b1;
      nextState = Rend;
    end
		Rend:begin
      out_to_Dm9000a_Io_Cs = 1'b1;
      out_to_Dm9000a_Io_Cmd = 1'b1;
      out_to_Dm9000a_Io_Ior = 1'b1;
      oRunEnd = 1'b1;
      StateChangeEnable = 1'b0;
      nextState = Idle; //modified 20140723
    end
	     default:begin
         out_to_Dm9000a_Io_Cs = 1'b1;
         out_to_Dm9000a_Io_Cmd = 1'b1;
         out_to_Dm9000a_Io_Ior = 1'b1;
         oRunEnd = 1'b0;
         StateChangeEnable = 1'b1;
         nextState = Idle;
       end
	endcase
end
assign oReturnValue = in_from_Dm9000a_Io_ReturnValue;
endmodule 

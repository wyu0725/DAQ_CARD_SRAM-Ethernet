/*DM9000A�Ĵ���д<�Ĵ�����д��>------------------------*/
//Designed by Junbin Zhang
//Updated 20140723
//updated 20140811
/*-----------------------------------------------------*/
//���Ĵ���iReg�е����ݹ������£�
//1.��ͨ���ܽ�д�Ĳ������Ĵ�ĵĵ�ַд��
//2.Ȼ��ͨ���ܽŶ�������
`include "DM9000A.def"
/*---------------------------------------------------------------------------*/
module DM9000A_ior // Dm9000A �˿ڶ�ģ��
(  
  input iDm9000aClk,
  input iRunStart,
  input [15:0]  iReg,                 //�Ĵ�����ַ
  input in_from_Dm9000a_IOWR_RunEnd,     //IOWRģ���RunEnd�ź�
  input in_from_Dm9000a_IORD_RunEnd,      //IORDģ���RunEnd�ź�
  input in_from_Dm9000a_usDelay_RunEnd,  //usDelay ģ���RunEnd�ź�
  input [15:0] in_from_Dm9000a_IORD_ReturnValue,//IORDģ��õ��ķ�������
  output reg oRunEnd,
  output reg [15:0]oReturnValue,                                 //ģ����������
  output reg out_to_Dm9000a_IOWR_RunStart,        //�����IOWRģ���RunStart�ź�
  output reg out_to_Dm9000a_IOWR_IndexOrData,  //�����IOWRģ���IndexorData�ź�
  output reg [15:0]out_to_Dm9000a_IOWR_OutData, //�����IOWRģ���iOutData�ź�
  output reg out_to_Dm9000a_IORD_RunStart,          //�����IORDģ���RunStart�ź�
  output reg out_to_Dm9000a_IORD_IndexOrData,     //�����IORDģ���IndexOrData�ź�
  output reg out_to_Dm9000a_usDelay_RunStart,      //����us��ʱ
  output reg [10:0] out_to_Dm9000a_usDelay_DelayTime //��ʱ��ʱ��
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

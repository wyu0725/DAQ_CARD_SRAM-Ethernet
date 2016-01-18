`include "DM9000A.def"
module DM9000A_RX_RESET
(
  input iDm9000aClk,
  input iRunStart,
  input in_from_Dm9000a_Iow_RunEnd,
  input in_from_Dm9000a_usDelay_RunEnd,
  output reg out_to_Dm9000a_Iow_RunStart,
  output reg [15:0] out_to_Dm9000a_Iow_Reg,
  output reg [15:0] out_to_Dm9000a_Iow_Data,
  output reg out_to_Dm9000a_usDelay_RunStart,
  output reg [10:0] out_to_Dm9000a_usDelay_DelayTime,
  output reg oRunEnd
);
reg [5:0] RunCount;
reg RunCountChangeEnable;
wire RunCountChange;
assign RunCountChange = (~oRunEnd)&(RunCountChangeEnable
                       |(out_to_Dm9000a_Iow_RunStart & in_from_Dm9000a_Iow_RunEnd)
                       |(out_to_Dm9000a_usDelay_RunStart & in_from_Dm9000a_usDelay_RunEnd));
always @ (posedge iDm9000aClk , negedge iRunStart) begin
  if(~iRunStart)
    RunCount <= 6'd0;
  else
    RunCount <= RunCount + RunCountChange;
end
always @ (RunCount) begin
	 case(RunCount)
  6'd0:begin
    out_to_Dm9000a_Iow_RunStart = 1'b0;
    out_to_Dm9000a_Iow_Reg = 16'b0;
    out_to_Dm9000a_Iow_Data = 16'b0;
    out_to_Dm9000a_usDelay_RunStart = 1'b0;
    out_to_Dm9000a_usDelay_DelayTime = 11'd0;
    oRunEnd = 1'b0;
    RunCountChangeEnable = 1'b1;
  end
  6'd1:begin //reset
    out_to_Dm9000a_Iow_RunStart = 1'b1;
    out_to_Dm9000a_Iow_Reg = `NCR;
    out_to_Dm9000a_Iow_Data = 16'h03;
    out_to_Dm9000a_usDelay_RunStart = 1'b0;
    out_to_Dm9000a_usDelay_DelayTime = 11'b0;
    oRunEnd = 1'b0;
    RunCountChangeEnable = 1'b0;
  end
  6'd2:begin //wait >10us
    out_to_Dm9000a_Iow_RunStart = 1'b0;
    out_to_Dm9000a_Iow_Reg = 16'b0;
    out_to_Dm9000a_Iow_Data = 16'b0;
    out_to_Dm9000a_usDelay_RunStart = 1'b1;
    out_to_Dm9000a_usDelay_DelayTime = `STD_DELAY;
    oRunEnd = 1'b0;
    RunCountChangeEnable = 1'b0;
  end
  6'd3:begin //normalize
    out_to_Dm9000a_Iow_RunStart = 1'b1;
    out_to_Dm9000a_Iow_Reg = `NCR;
    out_to_Dm9000a_Iow_Data = 16'h0;
    out_to_Dm9000a_usDelay_RunStart = 1'b0;
    out_to_Dm9000a_usDelay_DelayTime = 11'b0;
    oRunEnd = 1'b0;
    RunCountChangeEnable = 1'b0;
  end
  6'd4:begin
    out_to_Dm9000a_Iow_RunStart = 1'b0;
    out_to_Dm9000a_Iow_Reg = 16'b0;
    out_to_Dm9000a_Iow_Data = 16'b0;
    out_to_Dm9000a_usDelay_RunStart = 1'b0;
    out_to_Dm9000a_usDelay_DelayTime = 11'd0;
    oRunEnd = 1'b0;
    RunCountChangeEnable = 1'b1;
  end
  6'd5:begin//reset
    out_to_Dm9000a_Iow_RunStart = 1'b1;
    out_to_Dm9000a_Iow_Reg = `NCR;
    out_to_Dm9000a_Iow_Data = 16'h03;
    out_to_Dm9000a_usDelay_RunStart = 1'b0;
    out_to_Dm9000a_usDelay_DelayTime = 11'b0;
    oRunEnd = 1'b0;
    RunCountChangeEnable = 1'b0;
  end
  6'd6:begin //wait >10us
    out_to_Dm9000a_Iow_RunStart = 1'b0;
    out_to_Dm9000a_Iow_Reg = 16'b0;
    out_to_Dm9000a_Iow_Data = 16'b0;
    out_to_Dm9000a_usDelay_RunStart = 1'b1;
    out_to_Dm9000a_usDelay_DelayTime = `STD_DELAY;
    oRunEnd = 1'b0;
    RunCountChangeEnable = 1'b0;
  end
  6'd7:begin//normalize
    out_to_Dm9000a_Iow_RunStart = 1'b1;
    out_to_Dm9000a_Iow_Reg = `NCR;
    out_to_Dm9000a_Iow_Data = 16'h0;
    out_to_Dm9000a_usDelay_RunStart = 1'b0;
    out_to_Dm9000a_usDelay_DelayTime = 11'b0;
    oRunEnd = 1'b0;
    RunCountChangeEnable = 1'b0;
  end
  6'd8:begin
    out_to_Dm9000a_Iow_RunStart = 1'b0;
    out_to_Dm9000a_Iow_Reg = 16'b0;
    out_to_Dm9000a_Iow_Data = 16'b0;
    out_to_Dm9000a_usDelay_RunStart = 1'b0;
    out_to_Dm9000a_usDelay_DelayTime = 11'd0;
    oRunEnd = 1'b0;
    RunCountChangeEnable = 1'b1;
  end
  6'd9:begin/*if necessary RX back pressure Threshold in Half duplex moe only:High water 3KB,600us*/
    out_to_Dm9000a_Iow_RunStart = 1'b1;
    out_to_Dm9000a_Iow_Reg = `BPTR;
    out_to_Dm9000a_Iow_Data = 16'h3f;
    out_to_Dm9000a_usDelay_RunStart = 1'b0;
    out_to_Dm9000a_usDelay_DelayTime = 11'd0;
    oRunEnd = 1'b0;
    RunCountChangeEnable = 1'b0;
  end
  6'd10:begin
    out_to_Dm9000a_Iow_RunStart = 1'b0;
    out_to_Dm9000a_Iow_Reg = 16'b0;
    out_to_Dm9000a_Iow_Data = 16'b0;
    out_to_Dm9000a_usDelay_RunStart = 1'b0;
    out_to_Dm9000a_usDelay_DelayTime = 11'd0;
    oRunEnd = 1'b0;
    RunCountChangeEnable = 1'b1;
  end
  6'd11:begin /*if necessary Flow Control Threshold setting High/low Water Overflow*/
    out_to_Dm9000a_Iow_RunStart = 1'b1;
    out_to_Dm9000a_Iow_Reg = `FCTR;
    out_to_Dm9000a_Iow_Data = 16'h5a;
    out_to_Dm9000a_usDelay_RunStart = 1'b0;
    out_to_Dm9000a_usDelay_DelayTime = 11'd0;
    oRunEnd = 1'b0;
    RunCountChangeEnable = 1'b0;
  end
  6'd12:begin
    out_to_Dm9000a_Iow_RunStart = 1'b0;
    out_to_Dm9000a_Iow_Reg = 16'b0;
    out_to_Dm9000a_Iow_Data = 16'b0;
    out_to_Dm9000a_usDelay_RunStart = 1'b0;
    out_to_Dm9000a_usDelay_DelayTime = 11'd0;
    oRunEnd = 1'b0;
    RunCountChangeEnable = 1'b1;
  end
  6'd13:begin/*if necessary RX/TX Flow Control Register enable TXPEN,BKPM(TX_Half,),FLCE(RX)*/
    out_to_Dm9000a_Iow_RunStart = 1'b1;
    out_to_Dm9000a_Iow_Reg = `FCR;
    out_to_Dm9000a_Iow_Data = 16'h29;
    out_to_Dm9000a_usDelay_RunStart = 1'b0;
    out_to_Dm9000a_usDelay_DelayTime = 11'd0;
    oRunEnd = 1'b0;
    RunCountChangeEnable = 1'b0;
  end
  6'd14:begin
    out_to_Dm9000a_Iow_RunStart = 1'b0;
    out_to_Dm9000a_Iow_Reg = 16'b0;
    out_to_Dm9000a_Iow_Data = 16'b0;
    out_to_Dm9000a_usDelay_RunStart = 1'b0;
    out_to_Dm9000a_usDelay_DelayTime = 11'd0;
    oRunEnd = 1'b0;
    RunCountChangeEnable = 1'b1;
  end
  6'd15:begin/*clear the all event*/
    out_to_Dm9000a_Iow_RunStart = 1'b1;
    out_to_Dm9000a_Iow_Reg = `WCR;
    out_to_Dm9000a_Iow_Data = 16'b0;
    out_to_Dm9000a_usDelay_RunStart = 1'b0;
    out_to_Dm9000a_usDelay_DelayTime = 11'd0;
    oRunEnd = 1'b0;
    RunCountChangeEnable = 1'b0;
  end
  6'd16:begin
    out_to_Dm9000a_Iow_RunStart = 1'b0;
    out_to_Dm9000a_Iow_Reg = 16'b0;
    out_to_Dm9000a_Iow_Data = 16'b0;
    out_to_Dm9000a_usDelay_RunStart = 1'b0;
    out_to_Dm9000a_usDelay_DelayTime = 11'd0;
    oRunEnd = 1'b0;
    RunCountChangeEnable = 1'b1;
  end
  6'd17:begin/*switch LED to mode 1*/
    out_to_Dm9000a_Iow_RunStart = 1'b1;
    out_to_Dm9000a_Iow_Reg = `TCR2;
    out_to_Dm9000a_Iow_Data = 16'h80;
    out_to_Dm9000a_usDelay_RunStart = 1'b0;
    out_to_Dm9000a_usDelay_DelayTime = 11'd0;
    oRunEnd = 1'b0;
    RunCountChangeEnable = 1'b0;
  end
  6'd18:begin
    out_to_Dm9000a_Iow_RunStart = 1'b0;
    out_to_Dm9000a_Iow_Reg = 16'b0;
    out_to_Dm9000a_Iow_Data = 16'b0;
    out_to_Dm9000a_usDelay_RunStart = 1'b0;
    out_to_Dm9000a_usDelay_DelayTime = 11'd0;
    oRunEnd = 1'b0;
    RunCountChangeEnable = 1'b1;
  end
  6'd19:begin /*Early Transmit 75%*/
    out_to_Dm9000a_Iow_RunStart = 1'b1;
    out_to_Dm9000a_Iow_Reg = `ETXCSR;
    out_to_Dm9000a_Iow_Data = 16'h83;
    out_to_Dm9000a_usDelay_RunStart = 1'b0;
    out_to_Dm9000a_usDelay_DelayTime = 11'd0;
    oRunEnd = 1'b0;
    RunCountChangeEnable = 1'b0;
  end
  6'd20:begin
    out_to_Dm9000a_Iow_RunStart = 1'b0;
    out_to_Dm9000a_Iow_Reg = 16'b0;
    out_to_Dm9000a_Iow_Data = 16'b0;
    out_to_Dm9000a_usDelay_RunStart = 1'b0;
    out_to_Dm9000a_usDelay_DelayTime = 11'd0;
    oRunEnd = 1'b0;
    RunCountChangeEnable = 1'b1;
  end
  6'd21:begin/*enable interrupts to activate Dm9000a on rx interrupt only*/
    out_to_Dm9000a_Iow_RunStart = 1'b1;
    out_to_Dm9000a_Iow_Reg = `IMR;
    out_to_Dm9000a_Iow_Data = 16'h81;
    out_to_Dm9000a_usDelay_RunStart = 1'b0;
    out_to_Dm9000a_usDelay_DelayTime = 11'd0;
    oRunEnd = 1'b0;
    RunCountChangeEnable = 1'b0;
  end
  6'd22:begin
    out_to_Dm9000a_Iow_RunStart = 1'b0;
    out_to_Dm9000a_Iow_Reg = 16'b0;
    out_to_Dm9000a_Iow_Data = 16'b0;
    out_to_Dm9000a_usDelay_RunStart = 1'b0;
    out_to_Dm9000a_usDelay_DelayTime = 11'd0;
    oRunEnd = 1'b0;
    RunCountChangeEnable = 1'b1;
  end
  6'd23:begin/*enable RX (Broadcast / ALL_MUTICAST)*/
    out_to_Dm9000a_Iow_RunStart = 1'b1;
    out_to_Dm9000a_Iow_Reg = `RCR;
    out_to_Dm9000a_Iow_Data = `RCR_set | `RX_ENABLE | `PASS_MULTICAST;
    out_to_Dm9000a_usDelay_RunStart = 1'b0;
    out_to_Dm9000a_usDelay_DelayTime = 11'd0;
    oRunEnd = 1'b0;
    RunCountChangeEnable = 1'b0;
  end
  6'd24:begin
    out_to_Dm9000a_Iow_RunStart = 1'b0;
    out_to_Dm9000a_Iow_Reg = 16'b0;
    out_to_Dm9000a_Iow_Data = 16'b0;
    out_to_Dm9000a_usDelay_RunStart = 1'b0;
    out_to_Dm9000a_usDelay_DelayTime = 11'd0;
    oRunEnd = 1'b1;
    RunCountChangeEnable = 1'b0;
  end
  default:begin
    out_to_Dm9000a_Iow_RunStart = 1'b0;
    out_to_Dm9000a_Iow_Reg = 16'b0;
    out_to_Dm9000a_Iow_Data = 16'b0;
    out_to_Dm9000a_usDelay_RunStart = 1'b0;
    out_to_Dm9000a_usDelay_DelayTime = 11'd0;
    oRunEnd = 1'b0;
    RunCountChangeEnable = 1'b1;
  end
  endcase
end
endmodule

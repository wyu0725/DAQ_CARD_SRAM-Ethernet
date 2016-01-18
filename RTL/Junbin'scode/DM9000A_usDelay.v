//DM9000aµÄÑÓÊ±³ÌÐò
//update 20140811
  /*-----------------------------------------------------*/
  module DM9000A_usDelay
  (
	input iDm9000aClk,   //25M clock
	input iRunStart,         //start
	input [10:0]iDelayTime, //Delay time
	output reg oRunEnd
  );
  reg [10:0] Delay_Count;
  always @ (posedge iDm9000aClk , negedge iRunStart) begin
	if (~iRunStart) begin
		oRunEnd <= 1'b0;
		Delay_Count <= 11'd0;
	end
	else if (Delay_Count < iDelayTime)
		Delay_Count <= Delay_Count + 1'b1;
	else
		oRunEnd <= 1'b1;
  end
  endmodule
  /*-----------------------------------------------------*/
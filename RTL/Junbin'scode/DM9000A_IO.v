/*---------------------------------------------------------------------------*/
module DM9000A_IO                   // Dm9000A 的 IO层 
(  
  input iDm9000aClk,                 
  input iReset,
  input [15:0] iDm9000aBusData,  // input from data bus
  input iDm9000aBusOutEn,        //input from data bus out enble
  input [15:0] iData,            // input from module 
  input iCs,                     //control pin
  input iCmd,                    //control pin
  input iIor,                    //control pin
  input iIow,                    //control pin
  input iInt,                    //control pin
  output [15:0] oDm9000aBusData, // out to data bus 
  output oDm9000aBusOutEn,       //output data bus out enable
  output [15:0]oData,            // out to module 
  output reg oCs,                //control pin
  output reg oCmd,               //control pin
  output reg oIor,               //control pin
  output reg oIow,               //control pin
  output  oInt                   //control pin
);

/*---------------------------------------------------------------------------*/
assign oData = iDm9000aBusData; 
assign oDm9000aBusData = iData;  
assign oDm9000aBusOutEn  = iDm9000aBusOutEn; 
/*-----------------------------------------------------*/
/*always @ (negedge iDm9000aClk or negedge iReset)      //控制端在时钟下降沿三态处理
begin
  if(!iReset)
	  oCs  <= 1'b1; 
	else
		oCs  <= iCs; 
end
always @ (negedge iDm9000aClk or negedge iReset)
begin
  if(!iReset)
	  oCmd <= 1'b1; 
  else
		oCmd <= iCmd; 
end
always @ (negedge iDm9000aClk or negedge iReset)
begin
  if(!iReset)
		oIor <= 1'b1; 
   else
		oIor <= iIor;
end
always @ (negedge iDm9000aClk or negedge iReset)
begin
  if(!iReset)
		oIow <= 1'b1; 
  else
		oIow <= iIow; 
end
*/
always @ (negedge iDm9000aClk , negedge iReset)begin//Modified by wyu 20151211
  if(!iReset)begin
    oCs <= 1'b1;
    oCmd <= 1'b1;
    oIor <= 1'b1;
    oIow <= 1'b1;
  end
  else begin
    oCs <= iCs;
    oCmd <= iCmd;
    oIor <= iIor;
    oIow <= iIow;
  end
end
 /*-----------------------------------------------------*/
 /* always @ (negedge iDm9000aClk or negedge iReset)
 begin
      if(!iReset)  
		oInt <= 1'b0; 
      else 
		oInt <= iInt;  //modified 20140806 对中断信号进行同步 
 end
 */
assign oInt = iInt; //没有对int信号进行同步不必对中断信号进行三态控制
 /*-----------------------------------------------------*/
endmodule 
/*------------------------------------------------------*/

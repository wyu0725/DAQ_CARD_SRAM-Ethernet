/*DM9000A 写PHY--------------------------*/
//Designed by Junbin Zhang
//Updated 20140723
//update 20140811
`include "DM9000A.def"
/*---------------------------------------------------------------------------*/
module DM9000A_PHY_WR                     // Dm9000A PHY register write
(  
  input iDm9000aClk,
  input iRunStart,
  input [15:0]iReg,            //PHY寄存器地址
  input [15:0]iValue,        // 写入的值
  input in_from_Dm9000a_Iow_RunEnd,            //来自iow模块的RunEnd信号
  input in_from_Dm9000a_IOWR_RunEnd,       
  input in_from_Dm9000a_usDelay_RunEnd,    //usDelay结束
  output reg oRunEnd,  //写入结束标志
  output reg out_to_Dm9000a_Iow_RunStart,     //输出到iow模块的runstart信号
  output reg [15:0]out_to_Dm9000a_Iow_Reg,     //输出到iow模块的Reg端
  output reg [15:0]out_to_Dm9000a_Iow_Data,    //输出到iow模块的Data端
  output reg out_to_Dm9000a_IOWR_RunStart,  //输出到IOWR模块的RunStart端
  output reg out_to_Dm9000a_IOWR_IndexOrData,//输出到IOWR模块的IndexOrData端
  output reg [15:0] out_to_Dm9000a_IOWR_OutData,//输出到IOWR模块的outdata端
  output reg out_to_Dm9000a_usDelay_RunStart, //us延时的其实信号
  output reg [10:0] out_to_Dm9000a_usDelay_DelayTime //延时时间
);

/*---------------------------------------------------------------------------*/
  reg    StateChangeEnable;
  wire   StateChange;
  assign StateChange = (~oRunEnd) & ( StateChangeEnable 
                           | (out_to_Dm9000a_Iow_RunStart & in_from_Dm9000a_Iow_RunEnd)
				   |	(out_to_Dm9000a_IOWR_RunStart & in_from_Dm9000a_IOWR_RunEnd)
                           | (out_to_Dm9000a_usDelay_RunStart & in_from_Dm9000a_usDelay_RunEnd)
                          );
/**************************************************************/
 reg [4:0] currentState,nextState;
 localparam[4:0]     Idle   = 5'b00001,
                               State1=5'b00010,
					 State2=5'b00011,
					 State3=5'b00100,
					 State4=5'b00101,
					 State5=5'b00110,
					 State6=5'b00111,
					 State7=5'b01000,
					 State8=5'b01001,
					 State9=5'b01010,
					 State10=5'b01011,
					 State11=5'b01100,
					 State12 = 5'b01101,
					 Done  =5'b01111;
 always@(posedge iDm9000aClk,negedge iRunStart)
  begin
	if(~iRunStart)
		currentState <= Idle;
	else
	      currentState <= StateChange ? nextState:currentState;
  end
always@(*)
  begin
	case(currentState)
		Idle:begin
			     out_to_Dm9000a_usDelay_RunStart = 1'b0; 
			     out_to_Dm9000a_usDelay_DelayTime = 11'd0; 
			     out_to_Dm9000a_Iow_RunStart = 1'b0;
			     out_to_Dm9000a_Iow_Reg = 16'd0; 
			     out_to_Dm9000a_Iow_Data = 16'd0; 		     
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
			      out_to_Dm9000a_Iow_RunStart = 1'b1;  // iow(0x0C, iReg | 0x40);
			      out_to_Dm9000a_Iow_Reg = `EPAR;      
			      out_to_Dm9000a_Iow_Data = (iReg | 16'h40);   //step1 :write offset = iReg into EPAR REG		     			      	
			      out_to_Dm9000a_IOWR_RunStart = 1'b0;
			      out_to_Dm9000a_IOWR_IndexOrData = 1'b0;
			      out_to_Dm9000a_IOWR_OutData = 16'd0;
				oRunEnd = 1'b0;	
				StateChangeEnable = 1'b0;
				nextState = State2;
			      end
		State2:begin
			      out_to_Dm9000a_usDelay_RunStart = 1'b0; 
			      out_to_Dm9000a_usDelay_DelayTime = 11'd0; 
			      out_to_Dm9000a_Iow_RunStart = 1'b0;
			      out_to_Dm9000a_Iow_Reg = 16'd0; 
			      out_to_Dm9000a_Iow_Data = 16'd0; 
			      out_to_Dm9000a_IOWR_RunStart = 1'b0;
			      out_to_Dm9000a_IOWR_IndexOrData = 1'b0;
			      out_to_Dm9000a_IOWR_OutData = 16'd0;				
			      oRunEnd = 1'b0;
				 StateChangeEnable = 1'b1;
				nextState = State3;
				end
		State3:begin
			     out_to_Dm9000a_usDelay_RunStart = 1'b0; 
			     out_to_Dm9000a_usDelay_DelayTime = 11'd0; 
			     out_to_Dm9000a_Iow_RunStart = 1'b1;  // iow(0x0E, ((value >> 8) & 0xFF));
			     out_to_Dm9000a_Iow_Reg = `EPDRH;      
			     out_to_Dm9000a_Iow_Data = {8'h00,iValue[15:8]}; //step2: write the PHY high byte into EPDRH		
			     out_to_Dm9000a_IOWR_RunStart = 1'b0;
			     out_to_Dm9000a_IOWR_IndexOrData = 1'b0;
			     out_to_Dm9000a_IOWR_OutData = 16'd0;     
			     oRunEnd = 1'b0;
			      StateChangeEnable = 1'b0;
			      nextState = State4;
				end
	     State4:begin
			      out_to_Dm9000a_usDelay_RunStart = 1'b0; 
			      out_to_Dm9000a_usDelay_DelayTime = 11'd0; 
			      out_to_Dm9000a_Iow_RunStart = 1'b0;
			      out_to_Dm9000a_Iow_Reg = 16'd0; 
			      out_to_Dm9000a_Iow_Data = 16'd0; 		
			      out_to_Dm9000a_IOWR_RunStart = 1'b0;
			      out_to_Dm9000a_IOWR_IndexOrData = 1'b0;
			      out_to_Dm9000a_IOWR_OutData = 16'd0;				
			      oRunEnd = 1'b0;
				StateChangeEnable = 1'b1;
				nextState = State5;
				end
		State5:begin
			      out_to_Dm9000a_usDelay_RunStart = 1'b0; 
			      out_to_Dm9000a_usDelay_DelayTime = 11'd0; 
			      out_to_Dm9000a_Iow_RunStart = 1'b1;  // iow(0x0D, value & 0xFF);
			      out_to_Dm9000a_Iow_Reg = `EPDRL;      
			      out_to_Dm9000a_Iow_Data = {8'h00,iValue[7:0]}; //step3: write the PHY low byte into EPDRL			  
			      out_to_Dm9000a_IOWR_RunStart = 1'b0;
			      out_to_Dm9000a_IOWR_IndexOrData = 1'b0;
			      out_to_Dm9000a_IOWR_OutData = 16'd0;				
			      oRunEnd = 1'b0;
				StateChangeEnable = 1'b0;
				nextState = State6;
				end
		State6:begin
			     out_to_Dm9000a_usDelay_RunStart = 1'b0; 
			     out_to_Dm9000a_usDelay_DelayTime = 11'd0; 
			     out_to_Dm9000a_Iow_RunStart = 1'b0;
			     out_to_Dm9000a_Iow_Reg = 16'd0; 
			     out_to_Dm9000a_Iow_Data = 16'd0; 		
			     out_to_Dm9000a_IOWR_RunStart = 1'b0;
			     out_to_Dm9000a_IOWR_IndexOrData = 1'b0;
			     out_to_Dm9000a_IOWR_OutData = 16'd0;     
			     oRunEnd = 1'b0;
			     StateChangeEnable = 1'b1;
			     nextState = State7;
				end
		State7:begin
			     out_to_Dm9000a_usDelay_RunStart = 1'b0; 
			     out_to_Dm9000a_usDelay_DelayTime = 11'd0; 
			     out_to_Dm9000a_Iow_RunStart = 1'b1;  // iow(0x0B, 0x08); clear phy command first
			     out_to_Dm9000a_Iow_Reg = `EPCR;                     //step4:write the PHY+WRITE command = 0x0A into EPCR
			     out_to_Dm9000a_Iow_Data = 16'h08;    //08 PHY operation select ;02 EEPROM or PHY write command
			     out_to_Dm9000a_IOWR_RunStart = 1'b0;
			     out_to_Dm9000a_IOWR_IndexOrData = 1'b0;
			     out_to_Dm9000a_IOWR_OutData = 16'd0;			     
			     oRunEnd = 1'b0;
			     StateChangeEnable = 1'b0;
			     nextState = State8;
				end
		State8:begin
			     out_to_Dm9000a_usDelay_RunStart = 1'b0; 
			     out_to_Dm9000a_usDelay_DelayTime = 11'd0; 
			     out_to_Dm9000a_Iow_RunStart = 1'b0;
			     out_to_Dm9000a_Iow_Reg = 16'd0; 
			     out_to_Dm9000a_Iow_Data = 16'd0; 			
			     out_to_Dm9000a_IOWR_RunStart = 1'b0;
			     out_to_Dm9000a_IOWR_IndexOrData = 1'b0;
			     out_to_Dm9000a_IOWR_OutData = 16'd0;     
			     oRunEnd = 1'b0;	
			     StateChangeEnable = 1'b1;
			     nextState = State9;
				end
		State9:begin
			     out_to_Dm9000a_usDelay_RunStart = 1'b0; 
			     out_to_Dm9000a_usDelay_DelayTime = 11'd0; 
			     out_to_Dm9000a_Iow_RunStart = 1'b0;
			     out_to_Dm9000a_Iow_Reg = 16'd0; 
			     out_to_Dm9000a_Iow_Data = 16'd0; 			
			     out_to_Dm9000a_IOWR_RunStart = 1'b1;
			     out_to_Dm9000a_IOWR_IndexOrData = `IO_data;
			     out_to_Dm9000a_IOWR_OutData = 16'h0A;     			      
			      oRunEnd = 1'b0;
				StateChangeEnable = 1'b0;
				nextState = State10;
				end
		State10:begin
			     out_to_Dm9000a_usDelay_RunStart = 1'b1; 
			     out_to_Dm9000a_usDelay_DelayTime = `STD_DELAY; 
			     out_to_Dm9000a_Iow_RunStart = 1'b0;
			     out_to_Dm9000a_Iow_Reg = 16'd0; 
			     out_to_Dm9000a_Iow_Data = 16'd0; 			
			     out_to_Dm9000a_IOWR_RunStart = 1'b0;
			     out_to_Dm9000a_IOWR_IndexOrData = 1'b0;
			     out_to_Dm9000a_IOWR_OutData = 16'd0;     
			     oRunEnd = 1'b0;	
			     StateChangeEnable = 1'b0;
			     nextState = State11;
				end
		State11:begin
				out_to_Dm9000a_usDelay_RunStart = 1'b0;    //clear phy command again
				out_to_Dm9000a_usDelay_DelayTime = 11'd0; 
				out_to_Dm9000a_Iow_RunStart = 1'b0;
				out_to_Dm9000a_Iow_Reg = 16'd0; 
				out_to_Dm9000a_Iow_Data = 16'd0; 			
				out_to_Dm9000a_IOWR_RunStart = 1'b1;
				out_to_Dm9000a_IOWR_IndexOrData = `IO_data;
				out_to_Dm9000a_IOWR_OutData = 16'h08;      			      
			      oRunEnd = 1'b0;
				StateChangeEnable = 1'b0;
				nextState = State12;		
				end
		State12:begin //wait 50us for phy+write completion
			     out_to_Dm9000a_usDelay_RunStart = 1'b1; 
			     out_to_Dm9000a_usDelay_DelayTime = 11'd1250; 
			     out_to_Dm9000a_Iow_RunStart = 1'b0;
			     out_to_Dm9000a_Iow_Reg = 16'd0; 
			     out_to_Dm9000a_Iow_Data = 16'd0; 			
			     out_to_Dm9000a_IOWR_RunStart = 1'b0;
			     out_to_Dm9000a_IOWR_IndexOrData = 1'b0;
			     out_to_Dm9000a_IOWR_OutData = 16'd0;     
			     oRunEnd = 1'b0;	
			     StateChangeEnable = 1'b0;
			     nextState = Done;				
				end
		Done:begin
			     out_to_Dm9000a_usDelay_RunStart = 1'b0; 
			     out_to_Dm9000a_usDelay_DelayTime = 11'd0; 
			     out_to_Dm9000a_Iow_RunStart = 1'b0;
			     out_to_Dm9000a_Iow_Reg = 16'd0; 
			     out_to_Dm9000a_Iow_Data = 16'd0; 		     
			     out_to_Dm9000a_IOWR_RunStart = 1'b0;
			     out_to_Dm9000a_IOWR_IndexOrData = 1'b0;
			     out_to_Dm9000a_IOWR_OutData = 16'd0;
			     oRunEnd = 1'b1;
			     StateChangeEnable = 1'b0;
			     nextState = Idle;
				end
	     default:begin
	                  nextState = Idle;
			      out_to_Dm9000a_usDelay_RunStart = 1'b0; 
			      out_to_Dm9000a_usDelay_DelayTime = 11'd0; 
			      out_to_Dm9000a_Iow_RunStart = 1'b0;
			      out_to_Dm9000a_Iow_Reg = iReg; 
			      out_to_Dm9000a_Iow_Data = iValue; 
				out_to_Dm9000a_IOWR_RunStart = 1'b0;
			      out_to_Dm9000a_IOWR_IndexOrData = 1'b0;
			      out_to_Dm9000a_IOWR_OutData = 16'hffff;			
			      StateChangeEnable = 1'b1;
			      oRunEnd = 1'b0;
		            end		
	endcase
  end
  /*-----------------------------------------------------*/
endmodule 
/*---------------------------------------------------------------------------*/

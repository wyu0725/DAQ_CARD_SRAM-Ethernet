/*DM9000A 写EEPROM--------------------------*/

`include "DM9000A.def"
/*---------------------------------------------------------------------------*/
module DM9000A_EEPROM_WR                                       // Dm9000A PHY register write
(  
  input iDm9000aClk,
  input iRunStart,
  input [15:0]iAddress,            //EEPROM寄存器偏移地址
  input [15:0]iValue,                // 写入的值
  input in_from_Dm9000a_Iow_RunEnd,            //来自iow模块的Runend信号
  output reg oRunEnd,  //写入结束标志
  output reg out_to_Dm9000a_Iow_RunStart,     //输出到iow模块的runstart信号
  output reg [15:0]out_to_Dm9000a_Iow_Reg,     //输出到iow模块的Reg端
  output reg [15:0]out_to_Dm9000a_Iow_Data    //输出到iow模块的Data端
);

/*---------------------------------------------------------------------------*/
  reg    RunCountChangeEnable;
  wire   RunCountChange;
  assign RunCountChange = (~oRunEnd) & ( RunCountChangeEnable 
                           | (out_to_Dm9000a_Iow_RunStart & in_from_Dm9000a_Iow_RunEnd)
                           | (Delay_RunStart & Delay_RunEnd)
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
					 Done  =5'b01100;
 always@(posedge iDm9000aClk,negedge iRunStart)
  begin
	if(~iRunStart)
		currentState <= Idle;
	else
	      currentState <= nextState;
  end
always@(*)
  begin
	case(currentState)
		Idle:begin
			     Delay_RunStart = 1'b0; 
			     Delay_Time = 14'd0; 
			     out_to_Dm9000a_Iow_RunStart = 1'b0;
			     out_to_Dm9000a_Iow_Reg = 16'd0; 
			     out_to_Dm9000a_Iow_Data = 16'd0; 
			     RunCountChangeEnable = 1'b1;
			     oRunEnd = 1'b0;
			     nextState = State1;
			  end
		State1:begin
			      Delay_RunStart = 1'b0; 
			      Delay_Time = 14'd0; 
			      out_to_Dm9000a_Iow_RunStart = 1'b1;  // iow(0x0C, iAddress);
			      out_to_Dm9000a_Iow_Reg = `EPAR;      
			      out_to_Dm9000a_Iow_Data = iAddress;   //step1 :write word address = iAddress into EPAR REG                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                
			      RunCountChangeEnable = 1'b0;
			      oRunEnd = 1'b0;		
				nextState = (RunCountChange)? State2:State1;
			      end
		State2:begin
		            Delay_RunStart = 1'b0; 
			      Delay_Time = 14'd0; 
			      out_to_Dm9000a_Iow_RunStart = 1'b0;
			      out_to_Dm9000a_Iow_Reg = 16'd0; 
			      out_to_Dm9000a_Iow_Data = 16'd0; 
			      RunCountChangeEnable = 1'b1;
			      oRunEnd = 1'b0;
				nextState = State3;
				end
		State3:begin
		           Delay_RunStart = 1'b0; 
			     Delay_Time = 14'd0; 
			     out_to_Dm9000a_Iow_RunStart = 1'b1;  // iow(0x0E, ((value >> 8) & 0xFF));
			     out_to_Dm9000a_Iow_Reg = `EPDRH;      
			     out_to_Dm9000a_Iow_Data = {8'h00,iValue[15:8]}; //step2: write the SROM high byte into EPDRH
			     RunCountChangeEnable = 1'b0;
			     oRunEnd = 1'b0;
			      nextState = (RunCountChange)? State4:State3;
				end
	     State4:begin
	                  Delay_RunStart = 1'b0; 
			      Delay_Time = 14'd0; 
			      out_to_Dm9000a_Iow_RunStart = 1'b0;
			      out_to_Dm9000a_Iow_Reg = 16'd0; 
			      out_to_Dm9000a_Iow_Data = 16'd0; 
			      RunCountChangeEnable = 1'b1;
			      oRunEnd = 1'b0;
				nextState = State5;
				end
		State5:begin
		            Delay_RunStart = 1'b0; 
			      Delay_Time = 14'd0; 
			      out_to_Dm9000a_Iow_RunStart = 1'b1;  // iow(0x0D, value & 0xFF);
			      out_to_Dm9000a_Iow_Reg = `EPDRL;      
			      out_to_Dm9000a_Iow_Data = {8'h00,iValue[7:0]}; //step3: write the SROM low byte into EPDRL
			      RunCountChangeEnable = 1'b0;
			      oRunEnd = 1'b0;
				nextState = (RunCountChange)? State6:State5;
				end
		State6:begin
			     Delay_RunStart = 1'b0; 
			     Delay_Time = 14'd0; 
			     out_to_Dm9000a_Iow_RunStart = 1'b0;
			     out_to_Dm9000a_Iow_Reg = 16'd0; 
			     out_to_Dm9000a_Iow_Data = 16'd0; 
			     RunCountChangeEnable = 1'b1;
			     oRunEnd = 1'b0;
			     nextState = State7;
				end
		State7:begin
		           Delay_RunStart = 1'b0; 
			     Delay_Time = 14'd0; 
			     out_to_Dm9000a_Iow_RunStart = 1'b1;  // iow(0x0B, 0x08);
			     out_to_Dm9000a_Iow_Reg = `EPCR;                     //step4:write the SROM+WRITE command = 0x12 into EPCR
			     out_to_Dm9000a_Iow_Data = (16'h02 | 16'h10);  //10 SROM operation select ;02 EEPROM or PHY write command
			     RunCountChangeEnable = 1'b0;
			     oRunEnd = 1'b0;
			     nextState = (RunCountChange)? State8:State7;
				end
		State8:begin
	                 Delay_RunStart = 1'b0; 
			     Delay_Time = 14'd0; 
			     out_to_Dm9000a_Iow_RunStart = 1'b0;
			     out_to_Dm9000a_Iow_Reg = 16'd0; 
			     out_to_Dm9000a_Iow_Data = 16'd0; 
			     RunCountChangeEnable = 1'b1;
			     oRunEnd = 1'b0;	
			     nextState = State9;
				end
		State9:begin
		            Delay_RunStart = 1'b1; 
			      Delay_Time = 14'd15000;                                       //step5: wait 500us at least for the SROM+WRITE command completion
			      out_to_Dm9000a_Iow_RunStart = 1'b0;  
			      out_to_Dm9000a_Iow_Reg = 16'd0;      
			      out_to_Dm9000a_Iow_Data = 16'd0; 
			      RunCountChangeEnable = 1'b0;
			      oRunEnd = 1'b0;
				nextState = (RunCountChange)? State10:State9;
				end
		State10:begin
		           Delay_RunStart = 1'b0; 
			     Delay_Time = 14'd0; 
			     out_to_Dm9000a_Iow_RunStart = 1'b1;  
			     out_to_Dm9000a_Iow_Reg = `EPCR;                //stepe6: write''0''into EPCR to clear it  
			     out_to_Dm9000a_Iow_Data = 16'h00; 
			     RunCountChangeEnable = 1'b0;
			     oRunEnd = 1'b0;
			     nextState = (RunCountChange)? Done:State10;
				end
		Done:begin
		           Delay_RunStart = 1'b0;  
			     Delay_Time = 14'd0; 
			     out_to_Dm9000a_Iow_RunStart = 1'b0;
			     out_to_Dm9000a_Iow_Reg = 16'd0; 
			     out_to_Dm9000a_Iow_Data = 16'd0; 
			     RunCountChangeEnable = 1'b0;
			     oRunEnd = 1'b1;
			     nextState = Idle;
				end
	     default:begin
	                  nextState = Idle;
				Delay_RunStart = 1'b0; 
			      Delay_Time = 14'd0; 
			      out_to_Dm9000a_Iow_RunStart = 1'b0;
			      out_to_Dm9000a_Iow_Reg = iAddress; 
			      out_to_Dm9000a_Iow_Data = iValue; 
			      RunCountChangeEnable = 1'b1;
			      oRunEnd = 1'b0;
		            end		
	endcase
  end
  /*-----------------------------------------------------*/
  // delay 

  reg    Delay_RunStart;
  reg    Delay_RunEnd;
  reg    [13:0] Delay_Time;
  reg    [13:0] Delay_Count;  
  always @ (posedge iDm9000aClk or negedge Delay_RunStart) // 用于延时    iDm9000aClk为25Mhz
    begin 
      if(!Delay_RunStart) begin 
        Delay_Count <= 14'd0;
        Delay_RunEnd <= 1'b0;
      end else if(Delay_Count < Delay_Time) begin 
        Delay_Count <= Delay_Count + 1'b1;
      end else begin 
        Delay_RunEnd <= 1'b1;
      end

    end
  
  /*-----------------------------------------------------*/
 
endmodule 
/*---------------------------------------------------------------------------*/

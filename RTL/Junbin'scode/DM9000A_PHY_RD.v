/*DM9000A 读PHY--------------------------*/

`include "DM9000A.def"
/*---------------------------------------------------------------------------*/
module DM9000A_PHY_RD                     // Dm9000A PHY register read
(  
  input iDm9000aClk,
  input iRunStart,
  input [15:0]iReg,            //PHY寄存器地址
  input [15:0]iValue,        // 写入的值
  input in_from_Dm9000a_Iow_RunEnd,            //来自iow模块的RunEnd信号
  input in_from_Dm9000a_Ior_RunEnd,             //来自ior模块的RunEnd信号
  input [15:0]in_from_Dm9000a_Ior_ReturnValue,//来自ior模块返回的数据
  output reg oRunEnd,  //结束标志
  output reg [15:0] oPHY_Reg_Value,       //输出读到的PHY寄存器的数据
  output reg out_to_Dm9000a_Iow_RunStart,     //输出到iow模块的runstart信号
  output reg [15:0]out_to_Dm9000a_Iow_Reg,     //输出到iow模块的Reg端
  output reg [15:0]out_to_Dm9000a_Iow_Data,    //输出到iow模块的Data端
  output reg out_to_Dm9000a_Ior_RunStart,      //输出到ior模块的runstart信号
  output reg [15:0]out_to_Dm9000a_Ior_iReg     //输出到ior模块的Reg端
);

/*---------------------------------------------------------------------------*/
  reg    [15:0] Temp_Value;
  reg    RunCountChangeEnable;
  wire   RunCountChange;
  assign RunCountChange = (~oRunEnd) & ( RunCountChangeEnable 
                           | (out_to_Dm9000a_Iow_RunStart & in_from_Dm9000a_Iow_RunEnd)
				   |(out_to_Dm9000a_Ior_RunStart & in_from_Dm9000a_Ior_RunEnd)
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
			     Delay_Time = 12'd0; 
			     out_to_Dm9000a_Iow_RunStart = 1'b0;
			     out_to_Dm9000a_Iow_Reg = 16'd0; 
			     out_to_Dm9000a_Iow_Data = 16'd0; 
			     out_to_Dm9000a_Ior_RunStart = 1'b0;
			     out_to_Dm9000a_Ior_iReg = 16'd0;
			     Temp_Value = 16'd0;        //Temp_Value清0
			     RunCountChangeEnable = 1'b1;
			     oRunEnd = 1'b0;
			     nextState = State1;
			  end
		State1:begin
			      Delay_RunStart = 1'b0; 
			      Delay_Time = 12'd0; 
			      out_to_Dm9000a_Iow_RunStart = 1'b1;  // iow(0x0C, iReg | 0x40);
			      out_to_Dm9000a_Iow_Reg = `EPAR;      
			      out_to_Dm9000a_Iow_Data = (iReg | 16'h40);   //step1 :write offset = iReg into EPAR REG
			      out_to_Dm9000a_Ior_RunStart = 1'b0;
			      out_to_Dm9000a_Ior_iReg = 16'd0;	
			      RunCountChangeEnable = 1'b0;
			      oRunEnd = 1'b0;		
				nextState = (RunCountChange)? State2:State1;
			      end
		State2:begin
		            Delay_RunStart = 1'b0; 
			      Delay_Time = 12'd0; 
			      out_to_Dm9000a_Iow_RunStart = 1'b0;
			      out_to_Dm9000a_Iow_Reg = 16'd0; 
			      out_to_Dm9000a_Iow_Data = 16'd0; 
			      out_to_Dm9000a_Ior_RunStart = 1'b0;
			      out_to_Dm9000a_Ior_iReg = 16'd0;					
			      RunCountChangeEnable = 1'b1;
			      oRunEnd = 1'b0;
				nextState = State3;
				end
		State3:begin//
		           Delay_RunStart = 1'b0; 
			     Delay_Time = 12'd0; 
			     out_to_Dm9000a_Iow_RunStart = 1'b1;  // iow(0x0B, 0x0C)
			     out_to_Dm9000a_Iow_Reg = `EPCR;                     //step2:write the PHY+Read command = 0x0C into EPCR
			     out_to_Dm9000a_Iow_Data = (16'h04 | 16'h08);  //08 PHY operation select ;04 EEPROM or PHY read command
			      out_to_Dm9000a_Ior_RunStart = 1'b0;
			      out_to_Dm9000a_Ior_iReg = 16'd0;				     
			     RunCountChangeEnable = 1'b0;
			     oRunEnd = 1'b0;
	                 nextState = (RunCountChange)? State4:State3;
				end
	     State4:begin
	                  Delay_RunStart = 1'b0; 
			      Delay_Time = 12'd0; 
			      out_to_Dm9000a_Iow_RunStart = 1'b0;
			      out_to_Dm9000a_Iow_Reg = 16'd0; 
			      out_to_Dm9000a_Iow_Data = 16'd0; 
			      out_to_Dm9000a_Ior_RunStart = 1'b0;
			      out_to_Dm9000a_Ior_iReg = 16'd0;						
			      RunCountChangeEnable = 1'b1;
			      oRunEnd = 1'b0;
				nextState = State5;
				end
		State5:begin
				Delay_RunStart = 1'b1; 
			      Delay_Time = 12'd125;                                       //step3: wait 5us maximun for the PHY+READ command completion
			      out_to_Dm9000a_Iow_RunStart = 1'b0;  
			      out_to_Dm9000a_Iow_Reg = 16'd0;      
			      out_to_Dm9000a_Iow_Data = 16'd0; 
			      out_to_Dm9000a_Ior_RunStart = 1'b0;
			      out_to_Dm9000a_Ior_iReg = 16'd0;					
			      RunCountChangeEnable = 1'b0;
			      oRunEnd = 1'b0;
				nextState = (RunCountChange)? State6:State5;
				end
		State6:begin
			     Delay_RunStart = 1'b0; 
			     Delay_Time = 12'd0; 
			     out_to_Dm9000a_Iow_RunStart = 1'b0;
			     out_to_Dm9000a_Iow_Reg = 16'd0; 
			     out_to_Dm9000a_Iow_Data = 16'd0; 
			     out_to_Dm9000a_Ior_RunStart = 1'b1;
			     out_to_Dm9000a_Ior_iReg = `EPDRH;	    //step4: read the high byte from EPDRH
			     RunCountChangeEnable = 1'b0;
			     oRunEnd = 1'b0;
			     nextState = (RunCountChange)?State7:State6;
				end
		State7:begin
		           Temp_Value = (Temp_Value |in_from_Dm9000a_Ior_ReturnValue)<<8;	//read the high byte value	
		           Delay_RunStart = 1'b0; 
			     Delay_Time = 12'd0; 
			     out_to_Dm9000a_Iow_RunStart = 1'b0;  
			     out_to_Dm9000a_Iow_Reg = 16'd0;      
			     out_to_Dm9000a_Iow_Data = 16'd0;
			     out_to_Dm9000a_Ior_RunStart = 1'b0;
			     out_to_Dm9000a_Ior_iReg = 16'd0;	
			     RunCountChangeEnable = 1'b1;
			     oRunEnd = 1'b0;
			      nextState = State8;
				end
		State8:begin	           
	                 Delay_RunStart = 1'b0; 
			     Delay_Time = 12'd0; 
			     out_to_Dm9000a_Iow_RunStart = 1'b0;
			     out_to_Dm9000a_Iow_Reg = 16'd0; 
			     out_to_Dm9000a_Iow_Data = 16'd0; 
			     out_to_Dm9000a_Ior_RunStart = 1'b1;
			     out_to_Dm9000a_Ior_iReg = `EPDRL;       //step5:read low byte from EPDRL
			     RunCountChangeEnable = 1'b0;
			     oRunEnd = 1'b0;	
			     nextState =  (RunCountChange)?State9:State8;
				end
		State9:begin
		            Temp_Value = Temp_Value |in_from_Dm9000a_Ior_ReturnValue;//read the low byte
		            Delay_RunStart = 1'b0; 
			      Delay_Time = 12'd0;                                    
			      out_to_Dm9000a_Iow_RunStart = 1'b0;  
			      out_to_Dm9000a_Iow_Reg = 16'd0;      
			      out_to_Dm9000a_Iow_Data = 16'd0; 
			      out_to_Dm9000a_Ior_RunStart = 1'b0;
			      out_to_Dm9000a_Ior_iReg = 16'd0;					
			      RunCountChangeEnable = 1'b1;
			      oRunEnd = 1'b0;
				nextState = Done;
				end
		Done:begin
		           Delay_RunStart = 1'b0;  
			     Delay_Time = 12'd0; 
			     out_to_Dm9000a_Iow_RunStart = 1'b0;
			     out_to_Dm9000a_Iow_Reg = 16'd0; 
			     out_to_Dm9000a_Iow_Data = 16'd0; 
			     out_to_Dm9000a_Ior_RunStart = 1'b0;
			     out_to_Dm9000a_Ior_iReg = 16'd0;	
			     RunCountChangeEnable = 1'b0;
			     oRunEnd = 1'b1;
			     nextState = Idle;
				end
	     default:begin
	                  nextState = Idle;
				Delay_RunStart = 1'b0; 
			      Delay_Time = 12'd0; 
			      out_to_Dm9000a_Iow_RunStart = 1'b0;
			      out_to_Dm9000a_Iow_Reg = iReg; 
			      out_to_Dm9000a_Iow_Data = iValue; 
			      out_to_Dm9000a_Ior_RunStart = 1'b0;
			      out_to_Dm9000a_Ior_iReg = 16'd0;
			      RunCountChangeEnable = 1'b1;
			      oRunEnd = 1'b0;
		            end		
	endcase
  end
  /*-----------------------------------------------------*/
  // delay 

  reg    Delay_RunStart;
  reg    Delay_RunEnd;
  reg    [11:0] Delay_Time;
  reg    [11:0] Delay_Count;  
  always @ (posedge iDm9000aClk or negedge Delay_RunStart) // 用于延时    iDm9000aClk为25Mhz
    begin 
      if(!Delay_RunStart) begin 
        Delay_Count <= 12'd0;
        Delay_RunEnd <= 1'b0;
      end else if(Delay_Count < Delay_Time) begin 
        Delay_Count <= Delay_Count + 1'b1;
      end else begin 
        Delay_RunEnd <= 1'b1;
      end
    end

  /*-----------------------------------------------------*/
   always @ (posedge iDm9000aClk)
    begin 
      if(out_to_Dm9000a_Ior_RunStart & in_from_Dm9000a_Ior_RunEnd & oRunEnd ) begin         
        oPHY_Reg_Value <= Temp_Value;
      end
    end
endmodule 
/*---------------------------------------------------------------------------*/

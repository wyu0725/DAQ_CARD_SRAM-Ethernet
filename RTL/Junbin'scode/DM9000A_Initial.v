/***************DM9000A初始化***********************/
//Designed by Junbin Zhang
//Updated 20140723
//Updated 20140725
//update 20140811
`include "DM9000A.def"
module DM9000A_Initial         // Dm9000A Initial
(  
  input iDm9000aClk,
  input iRunStart,
  input in_from_Dm9000a_Iow_RunEnd,
  input in_from_phy_write_RunEnd,
  input in_from_Dm9000a_Ior_RunEnd,
  input in_from_Dm9000a_usDelay_RunEnd, //new add
  input [15:0]in_from_Dm9000a_Ior_ReturnValue,
  // input [47:0]iMacAddr, // 6 byte Ethernet node address 不再提供这个输入端
  output reg oRunEnd,
  output oInitDone,       // Init Success
  output reg out_to_Dm9000a_Iow_RunStart,
  output reg [15:0]out_to_Dm9000a_Iow_Reg,
  output reg [15:0]out_to_Dm9000a_Iow_Data,
  
  output reg out_to_phy_write_RunStart,
  output reg [15:0]out_to_phy_write_Reg,
  output reg [15:0]out_to_phy_write_Value,
  
  output reg out_to_Dm9000a_Ior_RunStart,
  output reg [15:0]out_to_Dm9000a_Ior_iReg,
  output reg out_to_Dm9000a_usDelay_RunStart, //new adda
  output reg [10:0] out_to_Dm9000a_usDelay_DelayTime //new add
);
  reg    StateChangeEnable;
  wire   StateChange;
  assign StateChange = (~oRunEnd) & ( StateChangeEnable 
                           | (out_to_Dm9000a_Iow_RunStart & in_from_Dm9000a_Iow_RunEnd)
                           | (out_to_phy_write_RunStart & in_from_phy_write_RunEnd)
                           | (out_to_Dm9000a_Ior_RunStart & in_from_Dm9000a_Ior_RunEnd)
                           | (out_to_Dm9000a_usDelay_RunStart & in_from_Dm9000a_usDelay_RunEnd) //us级延时
				   | (msDelay_RunStart & msDelay_RunEnd) //ms 级延时
                          );
 reg [5:0] currentState,nextState;
 localparam[5:0]     Idle   = 6'd0,State1=6'd1,State2=6'd2,State3=6'd3,State4=6'd4,State5=6'd5,State6=6'd6,
           State7=6'd7,State8=6'd8,State9=6'd9,State10=6'd10,State11=6'd11,State12=6'd12,State13=6'd13,
					 State14=6'd14,State15=6'd15,State16=6'd16,State17=6'd17,State18=6'd18,State19=6'd19,State20=6'd20,
					 State21=6'd21,State22=6'd22,State23=6'd23,State24=6'd24,State25=6'd25,State26=6'd26,State27=6'd27,
					 State28=6'd28,State29=6'd29,State30=6'd30,State31=6'd31,State32=6'd32,State33=6'd33,State34=6'd34,
					 State35=6'd35,State36=6'd36,State37=6'd37,State38=6'd38,State39=6'd39,State40=6'd40,State41=6'd41,
					 State42=6'd42,State43=6'd43,State44=6'd44,State45=6'd45,State46=6'd46,State47=6'd47,State48=6'd48,
					 State49=6'd49,State50=6'd50,State51=6'd51,State52=6'd52,State53=6'd53,State54=6'd54,State55=6'd55,
					 State56=6'd56,State57=6'd57,State58=6'd58,State59=6'd59,Done=6'd60;					 
 always@(posedge iDm9000aClk,negedge iRunStart)
  begin
	if(~iRunStart)
		currentState <= Idle;
	else
	      currentState <= StateChange ? nextState : currentState;
  end

  always @ (*)
    begin
      case(currentState)
        Idle: begin
		    out_to_Dm9000a_usDelay_RunStart = 1'b0; //us
		    out_to_Dm9000a_usDelay_DelayTime = 11'd0;
		    msDelay_RunStart = 1'b0; //ms
		    msDelay_Time = 20'd0;
		    out_to_Dm9000a_Iow_RunStart = 1'b0;
		    out_to_Dm9000a_Iow_Reg = 16'd0;
		    out_to_Dm9000a_Iow_Data = 16'd0;
		    out_to_phy_write_RunStart = 1'b0;
		    out_to_phy_write_Reg = 16'd0;
		    out_to_phy_write_Value = 16'd0;
		    out_to_Dm9000a_Ior_RunStart = 1'b0; 
		    out_to_Dm9000a_Ior_iReg = 16'd0; 		
		    oRunEnd = 1'b0;    
		    StateChangeEnable = 1'b1; 
		    nextState = State1;
		    end
   State1: begin
		    out_to_Dm9000a_usDelay_RunStart = 1'b0; //us
		    out_to_Dm9000a_usDelay_DelayTime = 11'd0;
		    msDelay_RunStart = 1'b0; //ms
		    msDelay_Time = 20'd0;
		    out_to_Dm9000a_Iow_RunStart = 1'b1;    /*GPCR REG.1EH =1 selected GPIO0 ''output'' port for internal PHY*/
		    out_to_Dm9000a_Iow_Reg = `GPCR;
		    out_to_Dm9000a_Iow_Data = 16'h01;
		    out_to_phy_write_RunStart = 1'b0;
		    out_to_phy_write_Reg = 16'd0;
		    out_to_phy_write_Value = 16'd0;
		    out_to_Dm9000a_Ior_RunStart = 1'b0; 
		    out_to_Dm9000a_Ior_iReg = 16'd0; 		
		    oRunEnd = 1'b0;    
		    StateChangeEnable = 1'b0; 
		    nextState = State2;
		    end
   State2: begin
		    out_to_Dm9000a_usDelay_RunStart = 1'b0; //us
		    out_to_Dm9000a_usDelay_DelayTime = 11'd0;
		    msDelay_RunStart = 1'b0; //ms
		    msDelay_Time = 20'd0;
		    out_to_Dm9000a_Iow_RunStart = 1'b0;
		    out_to_Dm9000a_Iow_Reg = 16'd0;
		    out_to_Dm9000a_Iow_Data = 16'd0;
		    out_to_phy_write_RunStart = 1'b0;
		    out_to_phy_write_Reg = 16'd0;
		    out_to_phy_write_Value = 16'd0;
		    out_to_Dm9000a_Ior_RunStart = 1'b0; 
		    out_to_Dm9000a_Ior_iReg = 16'd0; 		
		    oRunEnd = 1'b0;    
		    StateChangeEnable = 1'b1; 
		    nextState = State3;
               end
  State3: begin
		    out_to_Dm9000a_usDelay_RunStart = 1'b0; //us
		    out_to_Dm9000a_usDelay_DelayTime = 11'd0;
		    msDelay_RunStart = 1'b0; //ms
		    msDelay_Time = 20'd0;
		    out_to_Dm9000a_Iow_RunStart = 1'b1;    /*GPR REG.1FH =GEPIO0 Bit [0] = 0 to activate internal PHY */
		    out_to_Dm9000a_Iow_Reg = `GPR;
		    out_to_Dm9000a_Iow_Data = 16'h00;
		    out_to_phy_write_RunStart = 1'b0;
		    out_to_phy_write_Reg = 16'd0;
		    out_to_phy_write_Value = 16'd0;
		    out_to_Dm9000a_Ior_RunStart = 1'b0; 
		    out_to_Dm9000a_Ior_iReg = 16'd0; 		
		    oRunEnd = 1'b0;    
		    StateChangeEnable = 1'b0; 
		    nextState = State4;
		    end
   State4: begin
		    out_to_Dm9000a_usDelay_RunStart = 1'b0; //us
		    out_to_Dm9000a_usDelay_DelayTime = 11'd0;
		    msDelay_RunStart = 1'b1; //ms                  /*wait >2ms for PHY power-up ready*/
		    msDelay_Time = 20'd125000;
		    out_to_Dm9000a_Iow_RunStart = 1'b0;
		    out_to_Dm9000a_Iow_Reg = 16'd0;
		    out_to_Dm9000a_Iow_Data = 16'd0;
		    out_to_phy_write_RunStart = 1'b0;
		    out_to_phy_write_Reg = 16'd0;
		    out_to_phy_write_Value = 16'd0;
		    out_to_Dm9000a_Ior_RunStart = 1'b0; 
		    out_to_Dm9000a_Ior_iReg = 16'd0; 		
		    oRunEnd = 1'b0;    
		    StateChangeEnable = 1'b0; 
		    nextState = State5;
		    end    
   State5: begin
		    out_to_Dm9000a_usDelay_RunStart = 1'b0; //us
		    out_to_Dm9000a_usDelay_DelayTime = 11'd0;
		    msDelay_RunStart = 1'b0; //ms
		    msDelay_Time = 20'd0;
		    out_to_Dm9000a_Iow_RunStart = 1'b1;           /*reset on*/
		    out_to_Dm9000a_Iow_Reg = `NCR;
		    out_to_Dm9000a_Iow_Data = 16'h03;
		    out_to_phy_write_RunStart = 1'b0;
		    out_to_phy_write_Reg = 16'd0;
		    out_to_phy_write_Value = 16'd0;
		    out_to_Dm9000a_Ior_RunStart = 1'b0; 
		    out_to_Dm9000a_Ior_iReg = 16'd0; 		
		    oRunEnd = 1'b0;    
		    StateChangeEnable = 1'b0; 
		    nextState = State6;
		    end
   State6: begin
		    out_to_Dm9000a_usDelay_RunStart = 1'b1; //us
		    out_to_Dm9000a_usDelay_DelayTime = `STD_DELAY;  /*wait >10us for a software-RESET ok*/
		    msDelay_RunStart = 1'b0; //ms
		    msDelay_Time = 20'd0;
		    out_to_Dm9000a_Iow_RunStart = 1'b0;
		    out_to_Dm9000a_Iow_Reg = 16'd0;
		    out_to_Dm9000a_Iow_Data = 16'd0;
		    out_to_phy_write_RunStart = 1'b0;
		    out_to_phy_write_Reg = 16'd0;
		    out_to_phy_write_Value = 16'd0;
		    out_to_Dm9000a_Ior_RunStart = 1'b0; 
		    out_to_Dm9000a_Ior_iReg = 16'd0; 		
		    oRunEnd = 1'b0;    
		    StateChangeEnable = 1'b0; 
		    nextState = State7;
		    end
//add  20140725
  State7: begin
		    out_to_Dm9000a_usDelay_RunStart = 1'b0; //us
		    out_to_Dm9000a_usDelay_DelayTime = 11'd0;
		    msDelay_RunStart = 1'b0; //ms
		    msDelay_Time = 20'd0;
		    out_to_Dm9000a_Iow_RunStart = 1'b1;             /*normalize*/
		    out_to_Dm9000a_Iow_Reg = `NCR;
		    out_to_Dm9000a_Iow_Data = 16'h00;
		    out_to_phy_write_RunStart = 1'b0;
		    out_to_phy_write_Reg = 16'd0;
		    out_to_phy_write_Value = 16'd0;
		    out_to_Dm9000a_Ior_RunStart = 1'b0; 
		    out_to_Dm9000a_Ior_iReg = 16'd0; 		
		    oRunEnd = 1'b0;    
		    StateChangeEnable = 1'b0; 
		    nextState = State8;
		    end
   State8: begin 
		    out_to_Dm9000a_usDelay_RunStart = 1'b0; //us
		    out_to_Dm9000a_usDelay_DelayTime = 11'd0;
		    msDelay_RunStart = 1'b0; //ms
		    msDelay_Time = 20'd0;
		    out_to_Dm9000a_Iow_RunStart = 1'b0;
		    out_to_Dm9000a_Iow_Reg = 16'd0;
		    out_to_Dm9000a_Iow_Data = 16'd0;
		    out_to_phy_write_RunStart = 1'b0;
		    out_to_phy_write_Reg = 16'd0;
		    out_to_phy_write_Value = 16'd0;
		    out_to_Dm9000a_Ior_RunStart = 1'b0; 
		    out_to_Dm9000a_Ior_iReg = 16'd0; 		
		    oRunEnd = 1'b0;    
		    StateChangeEnable = 1'b1; 
		    nextState = State9;
		    end		        
 State9:   begin
		    out_to_Dm9000a_usDelay_RunStart = 1'b0; //us
		    out_to_Dm9000a_usDelay_DelayTime = 11'd0;
		    msDelay_RunStart = 1'b0; //ms
		    msDelay_Time = 20'd0;
		    out_to_Dm9000a_Iow_RunStart = 1'b1;           /*reset on*/
		    out_to_Dm9000a_Iow_Reg = `NCR;
		    out_to_Dm9000a_Iow_Data = 16'h03;
		    out_to_phy_write_RunStart = 1'b0;
		    out_to_phy_write_Reg = 16'd0;
		    out_to_phy_write_Value = 16'd0;
		    out_to_Dm9000a_Ior_RunStart = 1'b0; 
		    out_to_Dm9000a_Ior_iReg = 16'd0; 		
		    oRunEnd = 1'b0;    
		    StateChangeEnable = 1'b0; 
		    nextState = State10;
		    end	    
   State10: begin 
		    out_to_Dm9000a_usDelay_RunStart = 1'b1; //us
		    out_to_Dm9000a_usDelay_DelayTime = `STD_DELAY;  /*wait >10us for a software-RESET ok*/
		    msDelay_RunStart = 1'b0; //ms
		    msDelay_Time = 20'd0;
		    out_to_Dm9000a_Iow_RunStart = 1'b0;
		    out_to_Dm9000a_Iow_Reg = 16'd0;
		    out_to_Dm9000a_Iow_Data = 16'd0;
		    out_to_phy_write_RunStart = 1'b0;
		    out_to_phy_write_Reg = 16'd0;
		    out_to_phy_write_Value = 16'd0;
		    out_to_Dm9000a_Ior_RunStart = 1'b0; 
		    out_to_Dm9000a_Ior_iReg = 16'd0; 		
		    oRunEnd = 1'b0;    
		    StateChangeEnable = 1'b0; 
		    nextState = State11;
		    end
 State11: begin
		    out_to_Dm9000a_usDelay_RunStart = 1'b0; //us
		    out_to_Dm9000a_usDelay_DelayTime = 11'd0;
		    msDelay_RunStart = 1'b0; //ms
		    msDelay_Time = 20'd0;
		    out_to_Dm9000a_Iow_RunStart = 1'b1;             /*normalize*/
		    out_to_Dm9000a_Iow_Reg = `NCR;
		    out_to_Dm9000a_Iow_Data = 16'h00;
		    out_to_phy_write_RunStart = 1'b0;
		    out_to_phy_write_Reg = 16'd0;
		    out_to_phy_write_Value = 16'd0;
		    out_to_Dm9000a_Ior_RunStart = 1'b0; 
		    out_to_Dm9000a_Ior_iReg = 16'd0; 		
		    oRunEnd = 1'b0;    
		    StateChangeEnable = 1'b0; 
		    nextState = State12;	    
                end 
 State12: begin
		    out_to_Dm9000a_usDelay_RunStart = 1'b0; //us
		    out_to_Dm9000a_usDelay_DelayTime = 11'd0;
		    msDelay_RunStart = 1'b0; //ms
		    msDelay_Time = 20'd0;
		    out_to_Dm9000a_Iow_RunStart = 1'b0;
		    out_to_Dm9000a_Iow_Reg = 16'd0;
		    out_to_Dm9000a_Iow_Data = 16'd0;
		    out_to_phy_write_RunStart = 1'b0;
		    out_to_phy_write_Reg = 16'd0;
		    out_to_phy_write_Value = 16'd0;
		    out_to_Dm9000a_Ior_RunStart = 1'b0; 
		    out_to_Dm9000a_Ior_iReg = 16'd0; 		
		    oRunEnd = 1'b0;    
		    StateChangeEnable = 1'b1; 
		    nextState = State13;
		    end
		    //here 明天从这里开始
 State13: begin
		    out_to_Dm9000a_usDelay_RunStart = 1'b0; //us
		    out_to_Dm9000a_usDelay_DelayTime = 11'd0;
		    msDelay_RunStart = 1'b0; //ms
		    msDelay_Time = 20'd0;
		    out_to_Dm9000a_Iow_RunStart = 1'b1;      /*turn-off PHY*/
		    out_to_Dm9000a_Iow_Reg = `GPR;
		    out_to_Dm9000a_Iow_Data = 16'h01;
		    out_to_phy_write_RunStart = 1'b0;
		    out_to_phy_write_Reg = 16'd0;
		    out_to_phy_write_Value = 16'd0;
		    out_to_Dm9000a_Ior_RunStart = 1'b0; 
		    out_to_Dm9000a_Ior_iReg = 16'd0; 		
		    oRunEnd = 1'b0;    
		    StateChangeEnable = 1'b0; 
		    nextState = State14;
	          end
 State14: begin
		    out_to_Dm9000a_usDelay_RunStart = 1'b0; //us
		    out_to_Dm9000a_usDelay_DelayTime = 11'd0;
		    msDelay_RunStart = 1'b0; //ms
		    msDelay_Time = 20'd0;
		    out_to_Dm9000a_Iow_RunStart = 1'b0;
		    out_to_Dm9000a_Iow_Reg = 16'd0;
		    out_to_Dm9000a_Iow_Data = 16'd0;
		    out_to_phy_write_RunStart = 1'b0;
		    out_to_phy_write_Reg = 16'd0;
		    out_to_phy_write_Value = 16'd0;
		    out_to_Dm9000a_Ior_RunStart = 1'b0; 
		    out_to_Dm9000a_Ior_iReg = 16'd0; 		
		    oRunEnd = 1'b0;    
		    StateChangeEnable = 1'b1; 
		    nextState = State15;
		    end
 State15: begin
		    out_to_Dm9000a_usDelay_RunStart = 1'b0; //us
		    out_to_Dm9000a_usDelay_DelayTime = 11'd0;
		    msDelay_RunStart = 1'b0; //ms
		    msDelay_Time = 20'd0;
		    out_to_Dm9000a_Iow_RunStart = 1'b1;   /*activate phy*/
		    out_to_Dm9000a_Iow_Reg = `GPR;
		    out_to_Dm9000a_Iow_Data = 16'h0;
		    out_to_phy_write_RunStart = 1'b0;
		    out_to_phy_write_Reg = 16'd0;
		    out_to_phy_write_Value = 16'd0;
		    out_to_Dm9000a_Ior_RunStart = 1'b0; 
		    out_to_Dm9000a_Ior_iReg = 16'd0; 		
		    oRunEnd = 1'b0;    
		    StateChangeEnable = 1'b0; 
		    nextState = State16;
		    end
 State16: begin
		    out_to_Dm9000a_usDelay_RunStart = 1'b0; //us
		    out_to_Dm9000a_usDelay_DelayTime = 11'd0;
		    msDelay_RunStart = 1'b1; //ms
		    msDelay_Time = 20'd125000;                 /*wait >4ms for PHY power-up*/
		    out_to_Dm9000a_Iow_RunStart = 1'b0;
		    out_to_Dm9000a_Iow_Reg = 16'd0;
		    out_to_Dm9000a_Iow_Data = 16'd0;
		    out_to_phy_write_RunStart = 1'b0;
		    out_to_phy_write_Reg = 16'd0;
		    out_to_phy_write_Value = 16'd0;
		    out_to_Dm9000a_Ior_RunStart = 1'b0; 
		    out_to_Dm9000a_Ior_iReg = 16'd0; 		
		    oRunEnd = 1'b0;    
		    StateChangeEnable = 1'b0; 
		    nextState = State17;
		    end
//set PHY operation mode		    
 State17: begin
		    out_to_Dm9000a_usDelay_RunStart = 1'b0; //us
		    out_to_Dm9000a_usDelay_DelayTime = 11'd0;
		    msDelay_RunStart = 1'b0; //ms
		    msDelay_Time = 20'd0;
		    out_to_Dm9000a_Iow_RunStart = 1'b0;
		    out_to_Dm9000a_Iow_Reg = 16'd0;
		    out_to_Dm9000a_Iow_Data = 16'd0;
		    out_to_phy_write_RunStart = 1'b1;  /*reset PHY:registers back to the default states*/
		    out_to_phy_write_Reg = `BMCR;
		    out_to_phy_write_Value = `PHY_reset;
		    out_to_Dm9000a_Ior_RunStart = 1'b0; 
		    out_to_Dm9000a_Ior_iReg = 16'd0; 		
		    oRunEnd = 1'b0;    
		    StateChangeEnable = 1'b0; 
		    nextState = State18;
		    end
 State18: begin
		    out_to_Dm9000a_usDelay_RunStart = 1'b1; //us
		    out_to_Dm9000a_usDelay_DelayTime = 11'd1250;
		    msDelay_RunStart = 1'b0; //ms
		    msDelay_Time = 20'd0;
		    out_to_Dm9000a_Iow_RunStart = 1'b0;   /*wait >30us for PHY software-Reset ok*/
		    out_to_Dm9000a_Iow_Reg = 16'd0;
		    out_to_Dm9000a_Iow_Data = 16'd0;
		    out_to_phy_write_RunStart = 1'b0;
		    out_to_phy_write_Reg = 16'd0;
		    out_to_phy_write_Value = 16'd0;
		    out_to_Dm9000a_Ior_RunStart = 1'b0; 
		    out_to_Dm9000a_Ior_iReg = 16'd0; 		
		    oRunEnd = 1'b0;    
		    StateChangeEnable = 1'b0; 
		    nextState = State19;
		    end
State19: begin
		    out_to_Dm9000a_usDelay_RunStart = 1'b0; //us
		    out_to_Dm9000a_usDelay_DelayTime = 11'd0;
		    msDelay_RunStart = 1'b0; //ms
		    msDelay_Time = 20'd0;
		    out_to_Dm9000a_Iow_RunStart = 1'b0;
		    out_to_Dm9000a_Iow_Reg = 16'd0;
		    out_to_Dm9000a_Iow_Data = 16'd0;
		    out_to_phy_write_RunStart = 1'b1;
		    out_to_phy_write_Reg = `DSCR;             /*turn-off PHY reduce-power-done mode only*/
		    out_to_phy_write_Value = 16'h0404;
		    out_to_Dm9000a_Ior_RunStart = 1'b0; 
		    out_to_Dm9000a_Ior_iReg = 16'd0; 		
		    oRunEnd = 1'b0;    
		    StateChangeEnable = 1'b0; 
		    nextState = State20;
		    end
 State20: begin
		    out_to_Dm9000a_usDelay_RunStart = 1'b0; //us
		    out_to_Dm9000a_usDelay_DelayTime = 11'd0;
		    msDelay_RunStart = 1'b0; //ms
		    msDelay_Time = 20'd0;
		    out_to_Dm9000a_Iow_RunStart = 1'b0;
		    out_to_Dm9000a_Iow_Reg = 16'd0;
		    out_to_Dm9000a_Iow_Data = 16'd0;
		    out_to_phy_write_RunStart = 1'b0;
		    out_to_phy_write_Reg = 16'd0;
		    out_to_phy_write_Value = 16'd0;
		    out_to_Dm9000a_Ior_RunStart = 1'b0; 
		    out_to_Dm9000a_Ior_iReg = 16'd0; 		
		    oRunEnd = 1'b0;    
		    StateChangeEnable = 1'b1; 
		    nextState = State21;
		    end
 State21: begin
		    out_to_Dm9000a_usDelay_RunStart = 1'b0; //us
		    out_to_Dm9000a_usDelay_DelayTime = 11'd0;
		    msDelay_RunStart = 1'b0; //ms
		    msDelay_Time = 20'd0;
		    out_to_Dm9000a_Iow_RunStart = 1'b0;
		    out_to_Dm9000a_Iow_Reg = 16'd0;
		    out_to_Dm9000a_Iow_Data = 16'd0;
		    out_to_phy_write_RunStart = 1'b1;            /*set PHY TX advertised ability: ALL+ Flow_control*/
		    out_to_phy_write_Reg = `ANAR;
		    out_to_phy_write_Value = `PHY_txab;
		    out_to_Dm9000a_Ior_RunStart = 1'b0; 
		    out_to_Dm9000a_Ior_iReg = 16'd0; 		
		    oRunEnd = 1'b0;    
		    StateChangeEnable = 1'b0; 
		    nextState = State22;  
		    end
 State22: begin
		    out_to_Dm9000a_usDelay_RunStart = 1'b0; //us
		    out_to_Dm9000a_usDelay_DelayTime = 11'd0;
		    msDelay_RunStart = 1'b0; //ms
		    msDelay_Time = 20'd0;
		    out_to_Dm9000a_Iow_RunStart = 1'b0;
		    out_to_Dm9000a_Iow_Reg = 16'd0;
		    out_to_Dm9000a_Iow_Data = 16'd0;
		    out_to_phy_write_RunStart = 1'b0;
		    out_to_phy_write_Reg = 16'd0;
		    out_to_phy_write_Value = 16'd0;
		    out_to_Dm9000a_Ior_RunStart = 1'b0; 
		    out_to_Dm9000a_Ior_iReg = 16'd0; 		
		    oRunEnd = 1'b0;    
		    StateChangeEnable = 1'b1; 
		    nextState = State23;
		    end		    
 State23: begin
		    out_to_Dm9000a_usDelay_RunStart = 1'b0; //us
		    out_to_Dm9000a_usDelay_DelayTime = 11'd0;
		    msDelay_RunStart = 1'b0; //ms
		    msDelay_Time = 20'd0;
		    out_to_Dm9000a_Iow_RunStart = 1'b0;
		    out_to_Dm9000a_Iow_Reg = 16'd0;
		    out_to_Dm9000a_Iow_Data = 16'd0;
		    out_to_phy_write_RunStart = 1'b1;              /*PHY auto-NEGO re-start enable*/
		    out_to_phy_write_Reg = `BMCR;
		    out_to_phy_write_Value = 16'h1200;
		    out_to_Dm9000a_Ior_RunStart = 1'b0; 
		    out_to_Dm9000a_Ior_iReg = 16'd0; 		
		    oRunEnd = 1'b0;    
		    StateChangeEnable = 1'b0; 
		    nextState = State24;
		    end
 State24: begin
		    out_to_Dm9000a_usDelay_RunStart = 1'b0; //us
		    out_to_Dm9000a_usDelay_DelayTime = 11'd0;
		    msDelay_RunStart = 1'b1; //ms
		    msDelay_Time = 20'd125000;              /*wait > 2ms for PHY auto-sense linking to partner*/
		    out_to_Dm9000a_Iow_RunStart = 1'b0;
		    out_to_Dm9000a_Iow_Reg = 16'd0;
		    out_to_Dm9000a_Iow_Data = 16'd0;
		    out_to_phy_write_RunStart = 1'b0;
		    out_to_phy_write_Reg = 16'd0;
		    out_to_phy_write_Value = 16'd0;
		    out_to_Dm9000a_Ior_RunStart = 1'b0; 
		    out_to_Dm9000a_Ior_iReg = 16'd0; 		
		    oRunEnd = 1'b0;    
		    StateChangeEnable = 1'b0; 
		    nextState = State25;
		    end
 State25: begin
		    out_to_Dm9000a_usDelay_RunStart = 1'b0; //us
		    out_to_Dm9000a_usDelay_DelayTime = 11'd0;
		    msDelay_RunStart = 1'b0; //ms
		    msDelay_Time = 20'd0;
		    out_to_Dm9000a_Iow_RunStart = 1'b1;
		    out_to_Dm9000a_Iow_Reg = `PAB_0;
		    out_to_Dm9000a_Iow_Data = {8'h00,`MAC_Addr0};/*store MAC address into NIC*/
		    out_to_phy_write_RunStart = 1'b0;
		    out_to_phy_write_Reg = 16'd0;
		    out_to_phy_write_Value = 16'd0;
		    out_to_Dm9000a_Ior_RunStart = 1'b0; 
		    out_to_Dm9000a_Ior_iReg = 16'd0; 		
		    oRunEnd = 1'b0;    
		    StateChangeEnable = 1'b0; 
		    nextState = State26;
		    end
 State26: begin//写完一个模块下一状态必须复位一下模块,才能继续写,否则状态卡在那里
		    out_to_Dm9000a_usDelay_RunStart = 1'b0; //us
		    out_to_Dm9000a_usDelay_DelayTime = 11'd0;
		    msDelay_RunStart = 1'b0; //ms
		    msDelay_Time = 20'd0;
		    out_to_Dm9000a_Iow_RunStart = 1'b0;
		    out_to_Dm9000a_Iow_Reg = 16'd0;
		    out_to_Dm9000a_Iow_Data = 16'd0;
		    out_to_phy_write_RunStart = 1'b0;
		    out_to_phy_write_Reg = 16'd0;
		    out_to_phy_write_Value = 16'd0;
		    out_to_Dm9000a_Ior_RunStart = 1'b0; 
		    out_to_Dm9000a_Ior_iReg = 16'd0; 		
		    oRunEnd = 1'b0;    
		    StateChangeEnable = 1'b1; 
		    nextState = State27;
		    end
 State27: begin
		    out_to_Dm9000a_usDelay_RunStart = 1'b0; //us
		    out_to_Dm9000a_usDelay_DelayTime = 11'd0;
		    msDelay_RunStart = 1'b0; //ms
		    msDelay_Time = 20'd0;
		    out_to_Dm9000a_Iow_RunStart = 1'b1;
		    out_to_Dm9000a_Iow_Reg = `PAB_1;
		    out_to_Dm9000a_Iow_Data = {8'h00,`MAC_Addr1};/*store MAC address into NIC*/
		    out_to_phy_write_RunStart = 1'b0;
		    out_to_phy_write_Reg = 16'd0;
		    out_to_phy_write_Value = 16'd0;
		    out_to_Dm9000a_Ior_RunStart = 1'b0; 
		    out_to_Dm9000a_Ior_iReg = 16'd0; 		
		    oRunEnd = 1'b0;    
		    StateChangeEnable = 1'b0; 
		    nextState = State28;
		    end
 State28: begin
		    out_to_Dm9000a_usDelay_RunStart = 1'b0; //us
		    out_to_Dm9000a_usDelay_DelayTime = 11'd0;
		    msDelay_RunStart = 1'b0; //ms
		    msDelay_Time = 20'd0;
		    out_to_Dm9000a_Iow_RunStart = 1'b0;
		    out_to_Dm9000a_Iow_Reg = 16'd0;
		    out_to_Dm9000a_Iow_Data = 16'd0;
		    out_to_phy_write_RunStart = 1'b0;
		    out_to_phy_write_Reg = 16'd0;
		    out_to_phy_write_Value = 16'd0;
		    out_to_Dm9000a_Ior_RunStart = 1'b0; 
		    out_to_Dm9000a_Ior_iReg = 16'd0; 		
		    oRunEnd = 1'b0;    
		    StateChangeEnable = 1'b1; 
		    nextState = State29;   
	          end
 State29: begin
		    out_to_Dm9000a_usDelay_RunStart = 1'b0; //us
		    out_to_Dm9000a_usDelay_DelayTime = 11'd0;
		    msDelay_RunStart = 1'b0; //ms
		    msDelay_Time = 20'd0;
		    out_to_Dm9000a_Iow_RunStart = 1'b1;
		    out_to_Dm9000a_Iow_Reg = `PAB_2;
		    out_to_Dm9000a_Iow_Data = {8'h00,`MAC_Addr2};/*store MAC address into NIC*/
		    out_to_phy_write_RunStart = 1'b0;
		    out_to_phy_write_Reg = 16'd0;
		    out_to_phy_write_Value = 16'd0;
		    out_to_Dm9000a_Ior_RunStart = 1'b0; 
		    out_to_Dm9000a_Ior_iReg = 16'd0; 		
		    oRunEnd = 1'b0;    
		    StateChangeEnable = 1'b0; 
		    nextState = State30;
                end
 State30: begin
		    out_to_Dm9000a_usDelay_RunStart = 1'b0; //us
		    out_to_Dm9000a_usDelay_DelayTime = 11'd0;
		    msDelay_RunStart = 1'b0; //ms
		    msDelay_Time = 20'd0;
		    out_to_Dm9000a_Iow_RunStart = 1'b0;
		    out_to_Dm9000a_Iow_Reg = 16'd0;
		    out_to_Dm9000a_Iow_Data = 16'd0;
		    out_to_phy_write_RunStart = 1'b0;
		    out_to_phy_write_Reg = 16'd0;
		    out_to_phy_write_Value = 16'd0;
		    out_to_Dm9000a_Ior_RunStart = 1'b0; 
		    out_to_Dm9000a_Ior_iReg = 16'd0; 		
		    oRunEnd = 1'b0;    
		    StateChangeEnable = 1'b1; 
		    nextState = State31;   
		    end
 State31: begin
		    out_to_Dm9000a_usDelay_RunStart = 1'b0; //us
		    out_to_Dm9000a_usDelay_DelayTime = 11'd0;
		    msDelay_RunStart = 1'b0; //ms
		    msDelay_Time = 20'd0;
		    out_to_Dm9000a_Iow_RunStart = 1'b1;
		    out_to_Dm9000a_Iow_Reg = `PAB_3;
		    out_to_Dm9000a_Iow_Data = {8'h00,`MAC_Addr3};/*store MAC address into NIC*/
		    out_to_phy_write_RunStart = 1'b0;
		    out_to_phy_write_Reg = 16'd0;
		    out_to_phy_write_Value = 16'd0;
		    out_to_Dm9000a_Ior_RunStart = 1'b0; 
		    out_to_Dm9000a_Ior_iReg = 16'd0; 		
		    oRunEnd = 1'b0;    
		    StateChangeEnable = 1'b0; 
		    nextState = State32;
		    end
 State32: begin
		    out_to_Dm9000a_usDelay_RunStart = 1'b0; //us
		    out_to_Dm9000a_usDelay_DelayTime = 11'd0;
		    msDelay_RunStart = 1'b0; //ms
		    msDelay_Time = 20'd0;
		    out_to_Dm9000a_Iow_RunStart = 1'b0;
		    out_to_Dm9000a_Iow_Reg = 16'd0;
		    out_to_Dm9000a_Iow_Data = 16'd0;
		    out_to_phy_write_RunStart = 1'b0;
		    out_to_phy_write_Reg = 16'd0;
		    out_to_phy_write_Value = 16'd0;
		    out_to_Dm9000a_Ior_RunStart = 1'b0; 
		    out_to_Dm9000a_Ior_iReg = 16'd0; 		
		    oRunEnd = 1'b0;    
		    StateChangeEnable = 1'b1; 
		    nextState = State33;   
		    end
 State33: begin
		    out_to_Dm9000a_usDelay_RunStart = 1'b0; //us
		    out_to_Dm9000a_usDelay_DelayTime = 11'd0;
		    msDelay_RunStart = 1'b0; //ms
		    msDelay_Time = 20'd0;
		    out_to_Dm9000a_Iow_RunStart = 1'b1;
		    out_to_Dm9000a_Iow_Reg = `PAB_4;
		    out_to_Dm9000a_Iow_Data = {8'h00,`MAC_Addr4};/*store MAC address into NIC*/
		    out_to_phy_write_RunStart = 1'b0;
		    out_to_phy_write_Reg = 16'd0;
		    out_to_phy_write_Value = 16'd0;
		    out_to_Dm9000a_Ior_RunStart = 1'b0; 
		    out_to_Dm9000a_Ior_iReg = 16'd0; 		
		    oRunEnd = 1'b0;    
		    StateChangeEnable = 1'b0; 
		    nextState = State34;
		    end
 State34: begin
		    out_to_Dm9000a_usDelay_RunStart = 1'b0; //us
		    out_to_Dm9000a_usDelay_DelayTime = 11'd0;
		    msDelay_RunStart = 1'b0; //ms
		    msDelay_Time = 20'd0;
		    out_to_Dm9000a_Iow_RunStart = 1'b0;
		    out_to_Dm9000a_Iow_Reg = 16'd0;
		    out_to_Dm9000a_Iow_Data = 16'd0;
		    out_to_phy_write_RunStart = 1'b0;
		    out_to_phy_write_Reg = 16'd0;
		    out_to_phy_write_Value = 16'd0;
		    out_to_Dm9000a_Ior_RunStart = 1'b0; 
		    out_to_Dm9000a_Ior_iReg = 16'd0; 		
		    oRunEnd = 1'b0;    
		    StateChangeEnable = 1'b1; 
		    nextState = State35;   
		    end
 State35: begin
		    out_to_Dm9000a_usDelay_RunStart = 1'b0; //us
		    out_to_Dm9000a_usDelay_DelayTime = 11'd0;
		    msDelay_RunStart = 1'b0; //ms
		    msDelay_Time = 20'd0;
		    out_to_Dm9000a_Iow_RunStart = 1'b1;
		    out_to_Dm9000a_Iow_Reg = `PAB_5;
		    out_to_Dm9000a_Iow_Data = {8'h00,`MAC_Addr5};/*store MAC address into NIC*/
		    out_to_phy_write_RunStart = 1'b0;
		    out_to_phy_write_Reg = 16'd0;
		    out_to_phy_write_Value = 16'd0;
		    out_to_Dm9000a_Ior_RunStart = 1'b0; 
		    out_to_Dm9000a_Ior_iReg = 16'd0; 		
		    oRunEnd = 1'b0;    
		    StateChangeEnable = 1'b0; 
		    nextState = State36;
		    end
 State36: begin
		    out_to_Dm9000a_usDelay_RunStart = 1'b0; //us
		    out_to_Dm9000a_usDelay_DelayTime = 11'd0;
		    msDelay_RunStart = 1'b0; //ms
		    msDelay_Time = 20'd0;
		    out_to_Dm9000a_Iow_RunStart = 1'b0;
		    out_to_Dm9000a_Iow_Reg = 16'd0;
		    out_to_Dm9000a_Iow_Data = 16'd0;
		    out_to_phy_write_RunStart = 1'b0;
		    out_to_phy_write_Reg = 16'd0;
		    out_to_phy_write_Value = 16'd0;
		    out_to_Dm9000a_Ior_RunStart = 1'b0; 
		    out_to_Dm9000a_Ior_iReg = 16'd0; 		
		    oRunEnd = 1'b0;    
		    StateChangeEnable = 1'b1; 
		    nextState = State37;   
		    end
 State37: begin
		    out_to_Dm9000a_usDelay_RunStart = 1'b0; //us
		    out_to_Dm9000a_usDelay_DelayTime = 11'd0;
		    msDelay_RunStart = 1'b0; //ms
		    msDelay_Time = 20'd0;
		    out_to_Dm9000a_Iow_RunStart = 1'b1;     /*clear the ISR status:PRS,PTS,ROS,ROOS 4 bits by RW/C1*/
		    out_to_Dm9000a_Iow_Reg = `ISR;
		    out_to_Dm9000a_Iow_Data = 16'h3F;
		    out_to_phy_write_RunStart = 1'b0;
		    out_to_phy_write_Reg = 16'd0;
		    out_to_phy_write_Value = 16'd0;
		    out_to_Dm9000a_Ior_RunStart = 1'b0; 
		    out_to_Dm9000a_Ior_iReg = 16'd0; 		
		    oRunEnd = 1'b0;    
		    StateChangeEnable = 1'b0; 
		    nextState = State38;   
		    end
 State38: begin
		    out_to_Dm9000a_usDelay_RunStart = 1'b0; //us
		    out_to_Dm9000a_usDelay_DelayTime = 11'd0;
		    msDelay_RunStart = 1'b0; //ms
		    msDelay_Time = 20'd0;
		    out_to_Dm9000a_Iow_RunStart = 1'b0;
		    out_to_Dm9000a_Iow_Reg = 16'd0;
		    out_to_Dm9000a_Iow_Data = 16'd0;
		    out_to_phy_write_RunStart = 1'b0;
		    out_to_phy_write_Reg = 16'd0;
		    out_to_phy_write_Value = 16'd0;
		    out_to_Dm9000a_Ior_RunStart = 1'b0; 
		    out_to_Dm9000a_Ior_iReg = 16'd0; 		
		    oRunEnd = 1'b0;    
		    StateChangeEnable = 1'b1; 
		    nextState = State39;   
                end 
 State39: begin
		    out_to_Dm9000a_usDelay_RunStart = 1'b0; //us
		    out_to_Dm9000a_usDelay_DelayTime = 11'd0;
		    msDelay_RunStart = 1'b0; //ms
		    msDelay_Time = 20'd0;
		    out_to_Dm9000a_Iow_RunStart = 1'b1;                      /*clear the TX status: TX1END,TX2END,WAKEUP 3bits,by RW/C1*/
		    out_to_Dm9000a_Iow_Reg = `NSR;
		    out_to_Dm9000a_Iow_Data = 16'h2C;
		    out_to_phy_write_RunStart = 1'b0;
		    out_to_phy_write_Reg = 16'd0;
		    out_to_phy_write_Value = 16'd0;
		    out_to_Dm9000a_Ior_RunStart = 1'b0; 
		    out_to_Dm9000a_Ior_iReg = 16'd0; 		
		    oRunEnd = 1'b0;    
		    StateChangeEnable = 1'b0; 
		    nextState = State40;   
		    end 
State40:  begin
		    out_to_Dm9000a_usDelay_RunStart = 1'b0; //us
		    out_to_Dm9000a_usDelay_DelayTime = 11'd0;
		    msDelay_RunStart = 1'b0; //ms
		    msDelay_Time = 20'd0;
		    out_to_Dm9000a_Iow_RunStart = 1'b0;
		    out_to_Dm9000a_Iow_Reg = 16'd0;
		    out_to_Dm9000a_Iow_Data = 16'd0;
		    out_to_phy_write_RunStart = 1'b0;
		    out_to_phy_write_Reg = 16'd0;
		    out_to_phy_write_Value = 16'd0;
		    out_to_Dm9000a_Ior_RunStart = 1'b0; 
		    out_to_Dm9000a_Ior_iReg = 16'd0; 		
		    oRunEnd = 1'b0;    
		    StateChangeEnable = 1'b1; 
		    nextState = State41;   
		    end
		    //program operation registers
State41:  begin
		    out_to_Dm9000a_usDelay_RunStart = 1'b0; //us
		    out_to_Dm9000a_usDelay_DelayTime = 11'd0;
		    msDelay_RunStart = 1'b0; //ms
		    msDelay_Time = 20'd0;
		    out_to_Dm9000a_Iow_RunStart = 1'b1; /*enable the chip functions and disable MAC loopback mode back to normal*/
		    out_to_Dm9000a_Iow_Reg = `NCR;
		    out_to_Dm9000a_Iow_Data = 16'd0;
		    out_to_phy_write_RunStart = 1'b0;
		    out_to_phy_write_Reg = 16'd0;
		    out_to_phy_write_Value = 16'd0;
		    out_to_Dm9000a_Ior_RunStart = 1'b0; 
		    out_to_Dm9000a_Ior_iReg = 16'd0; 		
		    oRunEnd = 1'b0;    
		    StateChangeEnable = 1'b0; 
		    nextState = State42;   
		    end		    
State42:  begin
		    out_to_Dm9000a_usDelay_RunStart = 1'b0; //us
		    out_to_Dm9000a_usDelay_DelayTime = 11'd0;
		    msDelay_RunStart = 1'b0; //ms
		    msDelay_Time = 20'd0;
		    out_to_Dm9000a_Iow_RunStart = 1'b0;
		    out_to_Dm9000a_Iow_Reg = 16'd0;
		    out_to_Dm9000a_Iow_Data = 16'd0;
		    out_to_phy_write_RunStart = 1'b0;
		    out_to_phy_write_Reg = 16'd0;
		    out_to_phy_write_Value = 16'd0;
		    out_to_Dm9000a_Ior_RunStart = 1'b0; 
		    out_to_Dm9000a_Ior_iReg = 16'd0; 		
		    oRunEnd = 1'b0;    
		    StateChangeEnable = 1'b1; 
		    nextState = State43;   
		    end
State43:  begin
		    out_to_Dm9000a_usDelay_RunStart = 1'b0; //us
		    out_to_Dm9000a_usDelay_DelayTime = 11'd0;
		    msDelay_RunStart = 1'b0; //ms
		    msDelay_Time = 20'd0;
		    out_to_Dm9000a_Iow_RunStart = 1'b1;  /*Rx Back pressure Threshold in Half duplex moe only:high water 3KB*/
		    out_to_Dm9000a_Iow_Reg = `BPTR;
		    out_to_Dm9000a_Iow_Data = 16'h3F;
		    out_to_phy_write_RunStart = 1'b0;
		    out_to_phy_write_Reg = 16'd0;
		    out_to_phy_write_Value = 16'd0;
		    out_to_Dm9000a_Ior_RunStart = 1'b0; 
		    out_to_Dm9000a_Ior_iReg = 16'd0; 		
		    oRunEnd = 1'b0;    
		    StateChangeEnable = 1'b0; 
		    nextState = State44;   
		    end		    
State44:  begin
		    out_to_Dm9000a_usDelay_RunStart = 1'b0; //us
		    out_to_Dm9000a_usDelay_DelayTime = 11'd0;
		    msDelay_RunStart = 1'b0; //ms
		    msDelay_Time = 20'd0;
		    out_to_Dm9000a_Iow_RunStart = 1'b0;
		    out_to_Dm9000a_Iow_Reg = 16'd0;
		    out_to_Dm9000a_Iow_Data = 16'd0;
		    out_to_phy_write_RunStart = 1'b0;
		    out_to_phy_write_Reg = 16'd0;
		    out_to_phy_write_Value = 16'd0;
		    out_to_Dm9000a_Ior_RunStart = 1'b0; 
		    out_to_Dm9000a_Ior_iReg = 16'd0; 		
		    oRunEnd = 1'b0;    
		    StateChangeEnable = 1'b1; 
		    nextState = State45;   
		    end
State45:  begin
		    out_to_Dm9000a_usDelay_RunStart = 1'b0; //us
		    out_to_Dm9000a_usDelay_DelayTime = 11'd0;
		    msDelay_RunStart = 1'b0; //ms
		    msDelay_Time = 20'd0;
		    out_to_Dm9000a_Iow_RunStart = 1'b1;
		    out_to_Dm9000a_Iow_Reg = `FCTR;      /*Flow Control Threshold setting high/low water overflow 5KB/10KB*/
		    out_to_Dm9000a_Iow_Data = 16'h5A;
		    out_to_phy_write_RunStart = 1'b0;
		    out_to_phy_write_Reg = 16'd0;
		    out_to_phy_write_Value = 16'd0;
		    out_to_Dm9000a_Ior_RunStart = 1'b0; 
		    out_to_Dm9000a_Ior_iReg = 16'd0; 		
		    oRunEnd = 1'b0;    
		    StateChangeEnable = 1'b0; 
		    nextState = State46;   
		    end			    
State46:  begin
		    out_to_Dm9000a_usDelay_RunStart = 1'b0; //us
		    out_to_Dm9000a_usDelay_DelayTime = 11'd0;
		    msDelay_RunStart = 1'b0; //ms
		    msDelay_Time = 20'd0;
		    out_to_Dm9000a_Iow_RunStart = 1'b0;
		    out_to_Dm9000a_Iow_Reg = 16'd0;
		    out_to_Dm9000a_Iow_Data = 16'd0;
		    out_to_phy_write_RunStart = 1'b0;
		    out_to_phy_write_Reg = 16'd0;
		    out_to_phy_write_Value = 16'd0;
		    out_to_Dm9000a_Ior_RunStart = 1'b0; 
		    out_to_Dm9000a_Ior_iReg = 16'd0; 		
		    oRunEnd = 1'b0;    
		    StateChangeEnable = 1'b1; 
		    nextState = State47;   
		    end		    
State47:  begin
		    out_to_Dm9000a_usDelay_RunStart = 1'b0; //us
		    out_to_Dm9000a_usDelay_DelayTime = 11'd0;
		    msDelay_RunStart = 1'b0; //ms
		    msDelay_Time = 20'd0;
		    out_to_Dm9000a_Iow_RunStart = 1'b1;  /*RX/TX Flow control register enable TXPEN,BKPM(TX_Half),FLCE(RX)*/
		    out_to_Dm9000a_Iow_Reg = `FCR;
		    out_to_Dm9000a_Iow_Data = 16'h29;
		    out_to_phy_write_RunStart = 1'b0;
		    out_to_phy_write_Reg = 16'd0;
		    out_to_phy_write_Value = 16'd0;
		    out_to_Dm9000a_Ior_RunStart = 1'b0; 
		    out_to_Dm9000a_Ior_iReg = 16'd0; 		
		    oRunEnd = 1'b0;    
		    StateChangeEnable = 1'b0; 
		    nextState = State48;   
		    end		
State48:  begin	
		    out_to_Dm9000a_usDelay_RunStart = 1'b0; //us
		    out_to_Dm9000a_usDelay_DelayTime = 11'd0;
		    msDelay_RunStart = 1'b0; //ms
		    msDelay_Time = 20'd0;
		    out_to_Dm9000a_Iow_RunStart = 1'b0;
		    out_to_Dm9000a_Iow_Reg = 16'd0;
		    out_to_Dm9000a_Iow_Data = 16'd0;
		    out_to_phy_write_RunStart = 1'b0;
		    out_to_phy_write_Reg = 16'd0;
		    out_to_phy_write_Value = 16'd0;
		    out_to_Dm9000a_Ior_RunStart = 1'b0; 
		    out_to_Dm9000a_Ior_iReg = 16'd0; 		
		    oRunEnd = 1'b0;    
		    StateChangeEnable = 1'b1; 
		    nextState = State49;   
		    end	
State49:  begin	
		    out_to_Dm9000a_usDelay_RunStart = 1'b0; //us
		    out_to_Dm9000a_usDelay_DelayTime = 11'd0;
		    msDelay_RunStart = 1'b0; //ms
		    msDelay_Time = 20'd0;
		    out_to_Dm9000a_Iow_RunStart = 1'b1;   /*clear the all event*/
		    out_to_Dm9000a_Iow_Reg = `WCR;
		    out_to_Dm9000a_Iow_Data = 16'd0;
		    out_to_phy_write_RunStart = 1'b0;
		    out_to_phy_write_Reg = 16'd0;
		    out_to_phy_write_Value = 16'd0;
		    out_to_Dm9000a_Ior_RunStart = 1'b0; 
		    out_to_Dm9000a_Ior_iReg = 16'd0; 		
		    oRunEnd = 1'b0;    
		    StateChangeEnable = 1'b0; 
		    nextState = State50;   
		    end	
State50:  begin
		    out_to_Dm9000a_usDelay_RunStart = 1'b0; //us
		    out_to_Dm9000a_usDelay_DelayTime = 11'd0;
		    msDelay_RunStart = 1'b0; //ms
		    msDelay_Time = 20'd0;
		    out_to_Dm9000a_Iow_RunStart = 1'b0;
		    out_to_Dm9000a_Iow_Reg = 16'd0;
		    out_to_Dm9000a_Iow_Data = 16'd0;
		    out_to_phy_write_RunStart = 1'b0;
		    out_to_phy_write_Reg = 16'd0;
		    out_to_phy_write_Value = 16'd0;
		    out_to_Dm9000a_Ior_RunStart = 1'b0; 
		    out_to_Dm9000a_Ior_iReg = 16'd0; 		
		    oRunEnd = 1'b0;    
		    StateChangeEnable = 1'b1; 
		    nextState = State51;   
		    end	
State51:  begin
		    out_to_Dm9000a_usDelay_RunStart = 1'b0; //us
		    out_to_Dm9000a_usDelay_DelayTime = 11'd0;
		    msDelay_RunStart = 1'b0; //ms
		    msDelay_Time = 20'd0;
		    out_to_Dm9000a_Iow_RunStart = 1'b1; /*switch LED to mode 1*/
		    out_to_Dm9000a_Iow_Reg = `TCR2;
		    out_to_Dm9000a_Iow_Data = 16'h80;
		    out_to_phy_write_RunStart = 1'b0;
		    out_to_phy_write_Reg = 16'd0;
		    out_to_phy_write_Value = 16'd0;
		    out_to_Dm9000a_Ior_RunStart = 1'b0; 
		    out_to_Dm9000a_Ior_iReg = 16'd0; 		
		    oRunEnd = 1'b0;    
		    StateChangeEnable = 1'b0; 
		    nextState = State52;      
		    end	
State52:  begin
		    out_to_Dm9000a_usDelay_RunStart = 1'b0; //us
		    out_to_Dm9000a_usDelay_DelayTime = 11'd0;
		    msDelay_RunStart = 1'b0; //ms
		    msDelay_Time = 20'd0;
		    out_to_Dm9000a_Iow_RunStart = 1'b0;
		    out_to_Dm9000a_Iow_Reg = 16'd0;
		    out_to_Dm9000a_Iow_Data = 16'd0;
		    out_to_phy_write_RunStart = 1'b0;
		    out_to_phy_write_Reg = 16'd0;
		    out_to_phy_write_Value = 16'd0;
		    out_to_Dm9000a_Ior_RunStart = 1'b0; 
		    out_to_Dm9000a_Ior_iReg = 16'd0; 		
		    oRunEnd = 1'b0;    
		    StateChangeEnable = 1'b1; 
		    nextState = State53;   
		    end	
//set other registers depending on applications
State53:  begin
		    out_to_Dm9000a_usDelay_RunStart = 1'b0; //us
		    out_to_Dm9000a_usDelay_DelayTime = 11'd0;
		    msDelay_RunStart = 1'b0; //ms
		    msDelay_Time = 20'd0;
		    out_to_Dm9000a_Iow_RunStart = 1'b1;
		    out_to_Dm9000a_Iow_Reg = `ETXCSR; /*Early Transmit 75%*/
		    out_to_Dm9000a_Iow_Data = 16'h83;
		    out_to_phy_write_RunStart = 1'b0;
		    out_to_phy_write_Reg = 16'd0;
		    out_to_phy_write_Value = 16'd0;
		    out_to_Dm9000a_Ior_RunStart = 1'b0; 
		    out_to_Dm9000a_Ior_iReg = 16'd0; 		
		    oRunEnd = 1'b0;    
		    StateChangeEnable = 1'b0; 
		    nextState = State54;   	    
		    end	
State54:  begin
		    out_to_Dm9000a_usDelay_RunStart = 1'b0; //us
		    out_to_Dm9000a_usDelay_DelayTime = 11'd0;
		    msDelay_RunStart = 1'b0; //ms
		    msDelay_Time = 20'd0;
		    out_to_Dm9000a_Iow_RunStart = 1'b0;
		    out_to_Dm9000a_Iow_Reg = 16'd0;
		    out_to_Dm9000a_Iow_Data = 16'd0;
		    out_to_phy_write_RunStart = 1'b0;
		    out_to_phy_write_Reg = 16'd0;
		    out_to_phy_write_Value = 16'd0;
		    out_to_Dm9000a_Ior_RunStart = 1'b0; 
		    out_to_Dm9000a_Ior_iReg = 16'd0; 		
		    oRunEnd = 1'b0;    
		    StateChangeEnable = 1'b1; 
		    nextState = State55;   
		    end	    
State55:  begin
		    out_to_Dm9000a_usDelay_RunStart = 1'b0; //us
		    out_to_Dm9000a_usDelay_DelayTime = 11'd0;
		    msDelay_RunStart = 1'b0; //ms
		    msDelay_Time = 20'd0;
		    out_to_Dm9000a_Iow_RunStart = 1'b1;  /*PAR=1 only*/
		    out_to_Dm9000a_Iow_Reg = `IMR;
		    out_to_Dm9000a_Iow_Data = 16'h81;
		    out_to_phy_write_RunStart = 1'b0;
		    out_to_phy_write_Reg = 16'd0;
		    out_to_phy_write_Value = 16'd0;
		    out_to_Dm9000a_Ior_RunStart = 1'b0; 
		    out_to_Dm9000a_Ior_iReg = 16'd0; 		
		    oRunEnd = 1'b0;    
		    StateChangeEnable = 1'b0; 
		    nextState = State56;   
		    end
State56:  begin
		    out_to_Dm9000a_usDelay_RunStart = 1'b0; //us
		    out_to_Dm9000a_usDelay_DelayTime = 11'd0;
		    msDelay_RunStart = 1'b0; //ms
		    msDelay_Time = 20'd0;
		    out_to_Dm9000a_Iow_RunStart = 1'b0;
		    out_to_Dm9000a_Iow_Reg = 16'd0;
		    out_to_Dm9000a_Iow_Data = 16'd0;
		    out_to_phy_write_RunStart = 1'b0;
		    out_to_phy_write_Reg = 16'd0;
		    out_to_phy_write_Value = 16'd0;
		    out_to_Dm9000a_Ior_RunStart = 1'b0; 
		    out_to_Dm9000a_Ior_iReg = 16'd0; 		
		    oRunEnd = 1'b0;    
		    StateChangeEnable = 1'b1; 
		    nextState = State57;   
		    end
State57:  begin
		    out_to_Dm9000a_usDelay_RunStart = 1'b0; //us
		    out_to_Dm9000a_usDelay_DelayTime = 11'd0;
		    msDelay_RunStart = 1'b0; //ms
		    msDelay_Time = 20'd0;
		    out_to_Dm9000a_Iow_RunStart = 1'b1;  /*enable rx(broadcast/all_multicast)*/
		    out_to_Dm9000a_Iow_Reg = `RCR;
		    out_to_Dm9000a_Iow_Data = `RCR_set | `RX_ENABLE | `PASS_MULTICAST;
		    out_to_phy_write_RunStart = 1'b0;
		    out_to_phy_write_Reg = 16'd0;
		    out_to_phy_write_Value = 16'd0;
		    out_to_Dm9000a_Ior_RunStart = 1'b0; 
		    out_to_Dm9000a_Ior_iReg = 16'd0; 		
		    oRunEnd = 1'b0;    
		    StateChangeEnable = 1'b0; 
		    nextState = State58;   
		    end
State58:  begin
		    out_to_Dm9000a_usDelay_RunStart = 1'b0; //us
		    out_to_Dm9000a_usDelay_DelayTime = 11'd0;
		    msDelay_RunStart = 1'b0; //ms
		    msDelay_Time = 20'd0;
		    out_to_Dm9000a_Iow_RunStart = 1'b0;
		    out_to_Dm9000a_Iow_Reg = 16'd0;
		    out_to_Dm9000a_Iow_Data = 16'd0;
		    out_to_phy_write_RunStart = 1'b0;
		    out_to_phy_write_Reg = 16'd0;
		    out_to_phy_write_Value = 16'd0;
		    out_to_Dm9000a_Ior_RunStart = 1'b1; 
		    out_to_Dm9000a_Ior_iReg = `TCR2; 		
		    oRunEnd = 1'b0;    
		    StateChangeEnable = 1'b0; 
		    nextState = State59;   
		    end
State59:  begin
		    out_to_Dm9000a_usDelay_RunStart = 1'b0; //us
		    out_to_Dm9000a_usDelay_DelayTime = 11'd0;
		    msDelay_RunStart = 1'b0; //ms
		    msDelay_Time = 20'd0;
		    out_to_Dm9000a_Iow_RunStart = 1'b0;
		    out_to_Dm9000a_Iow_Reg = 16'd0;
		    out_to_Dm9000a_Iow_Data = 16'd0;
		    out_to_phy_write_RunStart = 1'b0;
		    out_to_phy_write_Reg = 16'd0;
		    out_to_phy_write_Value = 16'd0;
		    out_to_Dm9000a_Ior_RunStart = 1'b0; 
		    out_to_Dm9000a_Ior_iReg = 16'd0; 		
		    oRunEnd = 1'b0;    
		    StateChangeEnable = 1'b1; 
		    nextState = Done;   
		    end
Done:      begin
		    out_to_Dm9000a_usDelay_RunStart = 1'b0; //us
		    out_to_Dm9000a_usDelay_DelayTime = 11'd0;
		    msDelay_RunStart = 1'b0; //ms
		    msDelay_Time = 20'd0;
		    out_to_Dm9000a_Iow_RunStart = 1'b0;
		    out_to_Dm9000a_Iow_Reg = 16'd0;
		    out_to_Dm9000a_Iow_Data = 16'd0;
		    out_to_phy_write_RunStart = 1'b0;
		    out_to_phy_write_Reg = 16'd0;
		    out_to_phy_write_Value = 16'd0;
		    out_to_Dm9000a_Ior_RunStart = 1'b0; 
		    out_to_Dm9000a_Ior_iReg = 16'd0; 		
		    oRunEnd = 1'b1;    //结束
		    StateChangeEnable = 1'b0; 
		    nextState = Idle;   
		    end		    
default:   begin
		    out_to_Dm9000a_usDelay_RunStart = 1'b0; //us
		    out_to_Dm9000a_usDelay_DelayTime = 11'd0;
		    msDelay_RunStart = 1'b0; //ms
		    msDelay_Time = 20'd0;
		    out_to_Dm9000a_Iow_RunStart = 1'b0;
		    out_to_Dm9000a_Iow_Reg = 16'hffff;
		    out_to_Dm9000a_Iow_Data = 16'hffff;
		    out_to_phy_write_RunStart = 1'b0;
		    out_to_phy_write_Reg = 16'hffff;
		    out_to_phy_write_Value = 16'hffff;
		    out_to_Dm9000a_Ior_RunStart = 1'b0; 
		    out_to_Dm9000a_Ior_iReg = 16'hffff; 		
		    oRunEnd = 1'b0;    
		    StateChangeEnable = 1'b1; 
		    nextState = Idle;   
		    end		    
	endcase		    
end		   
/****************ms级的延时*****************/
  reg    msDelay_RunStart;
  reg    msDelay_RunEnd;
  reg    [19:0] msDelay_Time;
  reg    [19:0] Delay_Count;  
  always @ (posedge iDm9000aClk or negedge msDelay_RunStart) 
  begin 
      if(!msDelay_RunStart) 
		begin 
		  Delay_Count <= 20'd0;
		  msDelay_RunEnd <= 1'b0;
		end 
	else if(Delay_Count < msDelay_Time) 
		  Delay_Count <= Delay_Count + 1'b1;
	else 
		  msDelay_RunEnd <= 1'b1;
  end
/***************************************************/
 reg    [15:0] oReturnValue;
 always @ (posedge iDm9000aClk or negedge iRunStart)
 begin 
      if(~iRunStart) 
		oReturnValue <= 16'd0;
		else if(out_to_Dm9000a_Ior_RunStart & in_from_Dm9000a_Ior_RunEnd)  
		oReturnValue <= in_from_Dm9000a_Ior_ReturnValue;
	else
		oReturnValue <= oReturnValue;
 end
 
assign oInitDone = (oReturnValue == 16'h80) ? `INIT_SUCCESS :`INIT_FAIL; 
endmodule 

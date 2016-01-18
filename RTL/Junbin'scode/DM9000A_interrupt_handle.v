`include "DM9000A.def"
module DM9000A_interrupt_handle
(
    input iDm9000aClk,
    input iRunStart,
    input interrupt_in,//中断输入
    input in_from_Dm9000a_Iow_RunEnd,
    input in_from_Dm9000a_Ior_RunEnd,
    input [15:0] in_from_Dm9000a_Ior_ReturnValue,
    output reg rx_enable_r,//允许接收
    output reg oRunEnd,
    output reg out_to_Dm9000a_Ior_RunStart,
    output reg [15:0] out_to_Dm9000a_Ior_iReg,
    output reg out_to_Dm9000a_Iow_RunStart,
    output reg [15:0] out_to_Dm9000a_Iow_Reg,
    output reg [15:0] out_to_Dm9000a_Iow_Data
);
reg [3:0]State;
localparam [3:0] Idle = 4'd0 ,
                 ENA_INT = 4'd1,
                 CHECK_INT = 4'd2,
                 GET_STATUS = 4'd3, 
								 CHECK_ISR = 4'd4,
                 CLR_ISR = 4'd5,
                 DELAY = 4'd6,
                 MASK_INT = 4'd7,
                 END = 4'd8;
reg [15:0] ISR_status;
always @ (posedge iDm9000aClk , negedge iRunStart) begin
    if(!iRunStart) begin
      rx_enable_r <= 1'b0;
      ISR_status <= 16'b0;
      State <= Idle;
    end
    else begin
      case(State)
        Idle:begin
          rx_enable_r <= 1'b0;
          State <= ENA_INT;
          /*
          * 仅仅是方便阅读，注释中的代码不可以在这里使用
				  out_to_Dm9000a_Ior_RunStart = 1'b0;
				  out_to_Dm9000a_Ior_iReg = 16'b0;
				  out_to_Dm9000a_Iow_RunStart = 1'b0;
				  out_to_Dm9000a_Iow_Reg = 16'b0;
				  out_to_Dm9000a_Iow_Data = 16'b0;
				  oRunEnd = 1'b0;
          */
        end
        ENA_INT:begin //使能中断
          if(out_to_Dm9000a_Iow_RunStart & in_from_Dm9000a_Iow_RunEnd)
            State <= CHECK_INT;
          else
            State <= ENA_INT;
          /*
				  out_to_Dm9000a_Ior_RunStart = 1'b0;
				  out_to_Dm9000a_Ior_iReg = 16'b0;
				  out_to_Dm9000a_Iow_RunStart = 1'b1;
				  out_to_Dm9000a_Iow_Reg = `IMR;
				  out_to_Dm9000a_Iow_Data = 16'h81;
				  oRunEnd = 1'b0;	        
          */
        end
        CHECK_INT:begin
          if(interrupt_in) begin//有中断输入,从管脚查询有没有中断输入
            State <= GET_STATUS;
          end
          else begin
            State <= CHECK_INT;
          end
         /*仅仅是方便阅读，注释中的代码不可以在这里使用
		  	  out_to_Dm9000a_Ior_RunStart = 1'b0;
				  out_to_Dm9000a_Ior_iReg = 16'b0;
				  out_to_Dm9000a_Iow_RunStart = 1'b0;
				  out_to_Dm9000a_Iow_Reg = 16'b0;
				  out_to_Dm9000a_Iow_Data = 16'b0;
				  oRunEnd = 1'b0;	         
         */
        end
        GET_STATUS:begin // 读ISR寄存器
          if(out_to_Dm9000a_Ior_RunStart & in_from_Dm9000a_Ior_RunEnd) begin
            ISR_status <= in_from_Dm9000a_Ior_ReturnValue;
            State <= CHECK_ISR;
          end
          else
            State <= GET_STATUS;
          /*
		  		out_to_Dm9000a_Ior_RunStart = 1'b1;
				  out_to_Dm9000a_Ior_iReg = `ISR;
				  out_to_Dm9000a_Iow_RunStart = 1'b0;
				  out_to_Dm9000a_Iow_Reg = 16'b0;
				  out_to_Dm9000a_Iow_Data = 16'b0;
				  oRunEnd = 1'b0;          
          */
        end
        CHECK_ISR:begin
          if(ISR_status[0] == 1'b1) begin//Packet Received
            rx_enable_r <= 1'b1;//接收使能输出
            State <= CLR_ISR;
          end
          else begin
            rx_enable_r <= 1'b0;
            State <= CLR_ISR;
          end
          /*仅仅是方便阅读，注释中的代码不可以在这里使用
				  out_to_Dm9000a_Ior_RunStart = 1'b0;
				  out_to_Dm9000a_Ior_iReg = 16'b0;
				  out_to_Dm9000a_Iow_RunStart = 1'b0;
				  out_to_Dm9000a_Iow_Reg = 16'b0;
				  out_to_Dm9000a_Iow_Data = 16'b0;
				  oRunEnd = 1'b0;	
          */
        end
        CLR_ISR:begin
          if(out_to_Dm9000a_Iow_RunStart & in_from_Dm9000a_Iow_RunEnd)
            State <= DELAY;
          else
            State <= CLR_ISR;
          /*
				  out_to_Dm9000a_Ior_RunStart = 1'b0;
				  out_to_Dm9000a_Ior_iReg = 16'b0;
				  out_to_Dm9000a_Iow_RunStart = 1'b1;
				  out_to_Dm9000a_Iow_Reg = `ISR;
				  out_to_Dm9000a_Iow_Data = 16'h3f;
				  oRunEnd = 1'b0;           
          */
        end
        DELAY:begin
          State <= MASK_INT;
          /*
				  out_to_Dm9000a_Ior_RunStart = 1'b0;
				  out_to_Dm9000a_Ior_iReg = 16'b0;
				  out_to_Dm9000a_Iow_RunStart = 1'b0;
				  out_to_Dm9000a_Iow_Reg = 16'b0;
				  out_to_Dm9000a_Iow_Data = 16'b0;
				  oRunEnd = 1'b0;
          * 
          */
        end
        MASK_INT:begin
          if(out_to_Dm9000a_Iow_RunStart & in_from_Dm9000a_Iow_RunEnd)
            State <= END;
          else
            State <= MASK_INT;
          /*
				  out_to_Dm9000a_Ior_RunStart = 1'b0;
				  out_to_Dm9000a_Ior_iReg = 16'b0;
				  out_to_Dm9000a_Iow_RunStart = 1'b1;
				  out_to_Dm9000a_Iow_Reg = `IMR;
				  out_to_Dm9000a_Iow_Data = 16'h80;
				  oRunEnd = 1'b0;
          * 
          */
        end
        END:begin
          State <= END;
		  	  /*
          out_to_Dm9000a_Ior_RunStart = 1'b0;
				  out_to_Dm9000a_Ior_iReg = 16'b0;
				  out_to_Dm9000a_Iow_RunStart = 1'b0;
				  out_to_Dm9000a_Iow_Reg = 16'b0;
				  out_to_Dm9000a_Iow_Data = 16'b0;
				  oRunEnd = 1'b1;	
          */
        end
				default:State <= Idle;	
        endcase
    end
end
always @ (State) begin
  case(State)
    Idle:begin
      out_to_Dm9000a_Ior_RunStart = 1'b0;
      out_to_Dm9000a_Ior_iReg = 16'b0;
      out_to_Dm9000a_Iow_RunStart = 1'b0;
      out_to_Dm9000a_Iow_Reg = 16'b0;
      out_to_Dm9000a_Iow_Data = 16'b0;
      oRunEnd = 1'b0;
    end
    ENA_INT:begin
      out_to_Dm9000a_Ior_RunStart = 1'b0;
      out_to_Dm9000a_Ior_iReg = 16'b0;
      out_to_Dm9000a_Iow_RunStart = 1'b1;
      out_to_Dm9000a_Iow_Reg = `IMR;
      out_to_Dm9000a_Iow_Data = 16'h81;
      oRunEnd = 1'b0;	
    end
    CHECK_INT:begin//added by wyu
      out_to_Dm9000a_Ior_RunStart = 1'b0;
			out_to_Dm9000a_Ior_iReg = 16'b0;
			out_to_Dm9000a_Iow_RunStart = 1'b0;
			out_to_Dm9000a_Iow_Reg = 16'b0;
			out_to_Dm9000a_Iow_Data = 16'b0;
			oRunEnd = 1'b0;
    end
    GET_STATUS:begin
      out_to_Dm9000a_Ior_RunStart = 1'b1;
      out_to_Dm9000a_Ior_iReg = `ISR;
      out_to_Dm9000a_Iow_RunStart = 1'b0;
      out_to_Dm9000a_Iow_Reg = 16'b0;
      out_to_Dm9000a_Iow_Data = 16'b0;
      oRunEnd = 1'b0;
    end
    CHECK_ISR:begin
      out_to_Dm9000a_Ior_RunStart = 1'b0;
      out_to_Dm9000a_Ior_iReg = 16'b0;
      out_to_Dm9000a_Iow_RunStart = 1'b0;
      out_to_Dm9000a_Iow_Reg = 16'b0;
      out_to_Dm9000a_Iow_Data = 16'b0;
      oRunEnd = 1'b0;
    end
    CLR_ISR:begin
      out_to_Dm9000a_Ior_RunStart = 1'b0;
      out_to_Dm9000a_Ior_iReg = 16'b0;
      out_to_Dm9000a_Iow_RunStart = 1'b1;
      out_to_Dm9000a_Iow_Reg = `ISR;
      out_to_Dm9000a_Iow_Data = 16'h3f;
      oRunEnd = 1'b0;
    end
    DELAY:begin
      out_to_Dm9000a_Ior_RunStart = 1'b0;
      out_to_Dm9000a_Ior_iReg = 16'b0;
      out_to_Dm9000a_Iow_RunStart = 1'b0;
      out_to_Dm9000a_Iow_Reg = 16'b0;
      out_to_Dm9000a_Iow_Data = 16'b0;
      oRunEnd = 1'b0;
    end
    MASK_INT:begin
      out_to_Dm9000a_Ior_RunStart = 1'b0;
      out_to_Dm9000a_Ior_iReg = 16'b0;
      out_to_Dm9000a_Iow_RunStart = 1'b1;
      out_to_Dm9000a_Iow_Reg = `IMR;
      out_to_Dm9000a_Iow_Data = 16'h80;
      oRunEnd = 1'b0;
    end
    END:begin
      out_to_Dm9000a_Ior_RunStart = 1'b0;
      out_to_Dm9000a_Ior_iReg = 16'b0;
      out_to_Dm9000a_Iow_RunStart = 1'b0;
      out_to_Dm9000a_Iow_Reg = 16'b0;
      out_to_Dm9000a_Iow_Data = 16'b0;
      oRunEnd = 1'b1;	
    end
    default:begin
      out_to_Dm9000a_Ior_RunStart = 1'b0;
      out_to_Dm9000a_Ior_iReg = 16'b0;
      out_to_Dm9000a_Iow_RunStart = 1'b0;
      out_to_Dm9000a_Iow_Reg = 16'b0;
      out_to_Dm9000a_Iow_Data = 16'b0;
      oRunEnd = 1'b0;	
    end
  endcase
end
endmodule

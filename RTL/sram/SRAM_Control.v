//////////////////////////////////////////////////////////////////////////////////
// Company:USTC 
// Engineer:Yu Wang
// 
// Create Date:2015/11/18     
// Design Name:DAQ_CARD_2V0_SRAM    
// Module Name:SRAM_Control     
// Project Name:   
// Target Devices:EP4CE10U14 
// Tool versions:Quartus II 15.0  
// Description:
//External module set the start address and the number to write or read and
//give a start signal.When reading this module give a read request to get data for SRAM.
//When write it gives a Dataout_en signal for data out from SRAM
//
// SRAM read and write control module
// READ CYCLE:
//   1.Address Controled:CE = OE = UB = LB = LOW,WE = HIGH.Data write to SRAM
//   with the address settled.
//   2.OE,CE Controled:WE = HIGH
// WRITE CYCLE:
//   1.CE Controled:No matter what the status OE is,CE,WE and the address
//   control the writing
//   2.WE Controled:OE is high during write cycle,CE = LOW
//   3.WE Controled:OE,CE is low during write cycle,data is write to SRAM by
//   the control if WE
//   4.LB,UB Controled:...
//
//Chose Address Control for READ CYCLE,WE Control for WRITE CYCLE
//
// Dependencies: 
//
// Revision: V1.0
// Revision 0.01 - File Created
// Additional Comments: 
//////////////////////////////////////////////////////////////////////////////////
module SRAM_Control
(
		input clk,
    input reset_n,
    //interface with SRAM
    inout  [15:0] SRAM_DATA,//pin
    output reg [14:0] OUT_TO_SRAM_ADDR,//pin
    output reg LB_n,//pin
    output reg UB_n,//pin
    output reg CE_n,//pin
    output reg OE_n,//pin
    output reg WE_n,//pin
    //Interface with control module
    input WR_iRunStart,
    input [14:0] WR_START_ADDR,
    input [14:0] WR_DATA_NUM,
    input RD_iRunStart,
    input [14:0] RD_START_ADDR,
    input [14:0] RD_DATA_NUM,
    output reg WR_RunEnd,
    output reg RD_RunEnd,
    //Interface with external fifo
    input [15:0] Data_from_ext_fifo,
    output reg Data_rdreq,
    //Interface with output module
    output reg [15:0] Dataout,
    output reg Dataout_en
);
reg [3:0] State;
reg [14:0] cnt;
//reg [4:0] word_cnt;
reg [15:0] SRAM_DATA_r;
reg SRAM_DATA_link;
//parameter SRAM_DATA_NUM = 15'd2047;
parameter [3:0] Idle = 4'd0,
                WR_IDLE = 4'd1,
            WR_DATA_GET = 4'd2,
            WR_ADDR_SET = 4'd3,
            //WR_ADDR_SET = 4'd2,
            //WR_DATA_OUT = 4'd3,
              WRITE_END = 4'd4,
                RD_IDLE = 4'd5,
            RD_ADDR_SET = 4'd6,
             RD_DATA_IN = 4'd7,
               READ_END = 4'd8;
                //RD_WAIT = 4'd9;
always @ (posedge clk , negedge reset_n)begin
  if(!reset_n) begin
    cnt <= 15'b0;
    //Data in module
    Data_rdreq <= 1'b0;
    //word_cnt <= 5'b0;
    //Data out to next module
    Dataout <= 16'b0;
    Dataout_en <= 1'b0;
    //Feedback to read and write module
    WR_RunEnd <= 1'b0;
    RD_RunEnd <= 1'b0;
    //SRAM Control 
    OUT_TO_SRAM_ADDR <= 15'bz;
    SRAM_DATA_r <= 15'b0;
    SRAM_DATA_link <= 1'b0;//Default input
    LB_n <= 1'b1;
    UB_n <= 1'b1;
    CE_n <= 1'b1;
    OE_n <= 1'b1;
    WE_n <= 1'b1;
    State <= Idle;
  end
  else begin
    case(State)
      Idle:begin//0
        WR_RunEnd <= 1'b0;
        RD_RunEnd <= 1'b0;
        LB_n <= 1'b1;
        UB_n <= 1'b1;
        CE_n <= 1'b1;
        OE_n <= 1'b1;
        WE_n <= 1'b1;
        SRAM_DATA_link <= 1'b0;
        if(WR_iRunStart)
          State <= WR_IDLE;
        else if(RD_iRunStart)
          State <= RD_IDLE;
        else
          State <= Idle;
      end
      WR_IDLE:begin//1
        cnt <= 15'b0;
        LB_n <= 1'b0;
        UB_n <= 1'b0;
        CE_n <= 1'b0;
        OE_n <= 1'b0;
        SRAM_DATA_link <= 1'b1;
        Data_rdreq <= 1'b1;
        State <= WR_DATA_GET;
      end
      WR_DATA_GET:begin//2
        Data_rdreq <= 1'b0;
        WE_n <= 1'b1;
        SRAM_DATA_r <= Data_from_ext_fifo;
        State <= WR_ADDR_SET;
      end
      WR_ADDR_SET:begin//3
        if(cnt == WR_DATA_NUM)begin
          cnt <= 15'b0;
          State <= WRITE_END;
        end
        else if(cnt == WR_DATA_NUM - 1)begin
          WE_n <= 1'b0;
          OUT_TO_SRAM_ADDR <= WR_START_ADDR + cnt;
          cnt <= cnt + 1'b1;
          State <= WR_DATA_GET;
        end
        else begin
          Data_rdreq <= 1'b1;
          WE_n <= 1'b0;
          OUT_TO_SRAM_ADDR <= WR_START_ADDR + cnt;
          cnt <= cnt + 1'b1;
          State <= WR_DATA_GET;
        end
      end
      /*WR_ADDR_SET:begin        
        if(cnt == WR_DATA_NUM)begin
          cnt <= 15'b0;
          State <= WRITE_END;
        end
        else begin
          //OUT_TO_SRAM_ADDR <= OUT_TO_SRAM_ADDR + 1'b1;
          OUT_TO_SRAM_ADDR <= WR_START_ADDR + cnt;
          Data_rdreq <= 1'b1;
          cnt <= cnt + 1'b1;
          State <= WR_DATA_OUT;
        end
      end
      WR_DATA_OUT:begin
        Data_rdreq <= 1'b0;
        SRAM_DATA_r <= Data_from_ext_fifo;
        State <= WR_ADDR_SET;
      end*/
      WRITE_END:begin//4
        WR_RunEnd <= 1'b1;
        SRAM_DATA_link <= 1'b0;
        LB_n <= 1'b1;
        UB_n <= 1'b1;
        CE_n <= 1'b1;
        WE_n <= 1'b1;
        OUT_TO_SRAM_ADDR <= 15'bz;
        State <= Idle;
      end
      RD_IDLE:begin
        LB_n <= 1'b0;
        UB_n <= 1'b0;
        CE_n <= 1'b0;
        OE_n <= 1'b0;
        //OUT_TO_SRAM_ADDR <= RD_START_ADDR;
        State <= RD_ADDR_SET;
      end
      RD_ADDR_SET:begin
        Dataout_en <= 1'b0;
        if(cnt == RD_DATA_NUM)begin
          cnt <= 15'b0;
          State <= READ_END;
        end
        else begin
          //OUT_TO_SRAM_ADDR <= OUT_TO_SRAM_ADDR + 1'b1;
          OUT_TO_SRAM_ADDR <= RD_START_ADDR + cnt;
          cnt <= cnt + 1'b1;
          State <= RD_DATA_IN;
        end
      end
      RD_DATA_IN:begin
        Dataout <= SRAM_DATA;
        Dataout_en <= 1'b1;
        //State <= RD_WAIT;
        State <= RD_ADDR_SET;
      end
      /*RD_WAIT:begin
        Dataout_en <= 1'b0;
        if(word_cnt == WAIT_PERIOD)begin
          word_cnt <= 5'b0;
          State <= RD_ADDR_SET;
        end
        else begin
          word_cnt <= word_cnt + 1'b1;
          State <= RD_WAIT;
        end
      end*/
      READ_END:begin
        RD_RunEnd <= 1'b1;
        LB_n <= 1'b1;
        UB_n <= 1'b1;
        CE_n <= 1'b1;
        OE_n <= 1'b1;
        OUT_TO_SRAM_ADDR <= 15'bz;
        State <= Idle;
      end
      default:State <= Idle;
    endcase
  end
end
assign SRAM_DATA = SRAM_DATA_link ? SRAM_DATA_r : 16'bz;
endmodule

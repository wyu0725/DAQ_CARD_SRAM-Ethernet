module SRAM_WR_RD_Control
(
  input clk,
  input reset_n,
  input iRunStart,
  //Data in FIFO used word
  input [10:0] SRAM_FIFO_usedw,
  //Data out FIFO used word
  input [13:0] USB_FIFO_usedw,
  //Interface with SRAM Control module
  input WR_RunEnd,
  input RD_RunEnd,
  output reg WR_iRunStart,
  output reg [14:0] WR_START_ADDR,
  output reg [14:0] WR_DATA_NUM,
  output reg RD_iRunStart,
  output reg [14:0] RD_START_ADDR,
  output reg [14:0] RD_DATA_NUM,
  //Test module Start Control
  output reg Data_iRunStart
  /*//test bench port
  input WR_State,
  input RD_State,
  input [5:0] WR_wait_cnt,
  input [5:0] RD_wait_cnt*/
);
parameter DATA_NUM_TO_SRAM = 11'd1024;
parameter USB_FIFO_MAX_USED = 14'h3000;//16384 - 4096
parameter SRAM_MAX_WORD = 16'd16383;//16k-1,
reg [15:0] SRAM_USED_WORD;
//reg [14:0] SRAM_RD_WORD;
reg [2:0] State;
parameter [2:0] Idle = 3'd0,
        SRAM_WR_IDLE = 3'd1,
       //SRAM_WR_START = 4'd2,
        SRAM_WR_WAIT = 3'd2,
         SRAM_WR_END = 3'd3,
        SRAM_RD_IDLE = 3'd4,
       //SRAM_RD_START = 4'd6,
        SRAM_RD_WAIT = 3'd5,
         SRAM_RD_END = 3'd6;
             //ALL_END = 4'd9;
always @ (posedge clk , negedge reset_n)begin
  if(!reset_n)begin
    WR_iRunStart <= 1'b0;
    WR_START_ADDR <= 15'b0;
    WR_DATA_NUM <= 15'b0;
    SRAM_USED_WORD <= 16'b0;
    RD_iRunStart <= 1'b0;
    RD_START_ADDR <= 15'b0;
    RD_DATA_NUM <= 15'b0;
    //SRAM_RD_WORD <= 15'b0;
    Data_iRunStart <= 1'b0;
    State <= Idle;
  end
  else begin
    case(State)
      Idle:begin
        WR_iRunStart <= 1'b0;
        RD_iRunStart <= 1'b0;
        WR_START_ADDR <= 15'b0;
        RD_START_ADDR <= 15'b0;
        SRAM_USED_WORD <= 16'b0;
        //SRAM_RD_WORD <= 15'b0;
        if(iRunStart)begin
          Data_iRunStart <= 1'b1;
          State <= SRAM_WR_IDLE;
        end
        else
          State <= Idle;
      end
      SRAM_WR_IDLE:begin
        if(SRAM_FIFO_usedw >= DATA_NUM_TO_SRAM) begin
          WR_iRunStart <= 1'b1;
          WR_DATA_NUM <= 15'd1024;
          State <= SRAM_WR_WAIT;
          //State <= SRAM_WR_START;
        end
        else
          State <= SRAM_WR_IDLE;
      end
      /*SRAM_WR_START:begin
        WR_iRunStart <= 1'b1;
        WR_DATA_NUM <= 15'd1024;
        State <= SRAM_WR_WAIT;
      end*/
      SRAM_WR_WAIT:begin
        WR_iRunStart <= 1'b0;
        if(WR_RunEnd)begin
          WR_START_ADDR <= WR_START_ADDR + WR_DATA_NUM;
          SRAM_USED_WORD <= SRAM_USED_WORD + WR_DATA_NUM;
          State <= SRAM_WR_END;
        end
        else 
          State <= SRAM_WR_WAIT;
      end
      SRAM_WR_END:begin
        if(SRAM_USED_WORD >= SRAM_MAX_WORD)begin//写了超过设定的容量限制就将其读出
          State <= SRAM_RD_IDLE;
          Data_iRunStart <= 1'b0;
        end
        else 
          State <= SRAM_WR_IDLE;
      end
      SRAM_RD_IDLE:begin
        if(USB_FIFO_usedw <= USB_FIFO_MAX_USED) begin
          RD_iRunStart <= 1'b1;
          RD_DATA_NUM <= 15'd4096;
          State <= SRAM_RD_WAIT;
          //State <= SRAM_RD_START;
        end
        else
          State <= SRAM_RD_IDLE;
      end
      /*SRAM_RD_START:begin
        RD_iRunStart <= 1'b1;
        RD_DATA_NUM <= 15'd4096;
        State <= SRAM_RD_WAIT;
      end*/
      SRAM_RD_WAIT:begin
        RD_iRunStart <= 1'b0;
        if(RD_RunEnd)begin
          RD_START_ADDR <= RD_START_ADDR + RD_DATA_NUM;
          SRAM_USED_WORD <= SRAM_USED_WORD - RD_DATA_NUM;
          State <= SRAM_RD_END;
        end
        else
          State <= SRAM_RD_WAIT;
      end
      SRAM_RD_END:begin
        if(SRAM_USED_WORD == 16'b0)begin//读空了
          State <= Idle;
        end
        else
          State <= SRAM_RD_IDLE;
      end
      default:State <= Idle;
    endcase
  end
end
endmodule

//DM9000A transfer data
//Designed by Junbin 20140630
//update 20140721
//update 20140723
//update 20140817
//update 20140818
`include  "DM9000A.def"
module DM9000A_TX(
	input iDm9000aClk,
	input iRunStart, //写完fifo结束还是同时开始？答：同时开始
	input in_from_Dm9000a_Iow_RunEnd,
	input in_from_Dm9000a_Ior_RunEnd,
	input in_from_Dm9000a_IOWR_RunEnd,
	input in_from_Dm9000a_usDelay_RunEnd,
	input [15:0] in_from_Dm9000a_Ior_ReturnValue,	

	input [15:0] Data_Length,  //要传送数据长度
	output reg Tx_Done,  //transfer completed
	//dc fifo control
	input [15:0] dcfifo_data,
	input rdempty,
	output reg rdreq,
	//dc fifo control
	output reg out_to_Dm9000a_Iow_RunStart,
	output reg [15:0] out_to_Dm9000a_Iow_Reg,
	output reg [15:0] out_to_Dm9000a_Iow_Data,
	
	output reg out_to_Dm9000a_IOWR_RunStart,
	output reg out_to_Dm9000a_IOWR_IndexOrData,
	output reg [15:0] out_to_Dm9000a_IOWR_OutData,
	
	output reg out_to_Dm9000a_Ior_RunStart,
	output reg [15:0] out_to_Dm9000a_Ior_iReg,
	
	output reg out_to_Dm9000a_usDelay_RunStart,
	output reg [10:0] out_to_Dm9000a_usDelay_DelayTime
);
wire [15:0] Data_Send;
assign Data_Send = dcfifo_data; //fifo的输出数据
reg [15:0] Tx_cnt;
reg [15:0] NSR_Value;
reg [3:0] State;
localparam [3:0] Idle = 4'd0 , W_TXPLH = 4'd1 , WAIT1 = 4'd2 , W_TXPLL = 4'd3,
                SET_MWCMD = 4'd4 , FILL_DATA = 4'd5 , FIFO_EPT = 4'd6 , FIFO_READ = 4'd7,
                WAIT2 = 4'd8 , FILL_IN = 4'd9 , TRANSMIT = 4'd10 , READ_NSR = 4'd11,
                CHECK_NSR = 4'd12 , DELAY = 4'd13 , CLR_NSR = 4'd14 , DONE = 4'd15;
always @ (posedge iDm9000aClk , negedge iRunStart)begin
  if(~iRunStart)begin
    State <= Idle;
    Tx_cnt <= 16'b0;
    NSR_Value <= 16'b0;
    rdreq <= 1'b0;
  end
  else begin
    case(State)
      Idle:begin
        Tx_cnt <= 16'b0;
        NSR_Value <= 16'b0;
        rdreq <= 1'b0;
        State <= W_TXPLH;
      end
      W_TXPLH:begin //issue Tx Packet's length into TXPLH
        if(out_to_Dm9000a_Iow_RunStart & in_from_Dm9000a_Iow_RunEnd)
          State <= WAIT1;
        else
          State <= W_TXPLH;
      end
      WAIT1:begin //release bus
        State <= W_TXPLL;
      end
      W_TXPLL:begin//issue Tx Packet's length into TXPLL
        if(out_to_Dm9000a_Iow_RunStart & in_from_Dm9000a_Iow_RunEnd)
          State <= SET_MWCMD;
        else
          State <= W_TXPLL;
      end
      SET_MWCMD:begin //set MWCMD Tx I/O port ready
        if(out_to_Dm9000a_IOWR_RunStart & in_from_Dm9000a_IOWR_RunEnd)
          State <= FILL_DATA;
        else
          State <= SET_MWCMD;
      end
      FILL_DATA:begin
        if(Tx_cnt < Data_Length)begin
          State <= FIFO_EPT;
          rdreq <= 1'b0;
        end
        else begin
          Tx_cnt <= 16'b0;//clear cnt
          State <= TRANSMIT;
        end
      end
      FIFO_EPT:begin
        if(!rdempty)begin
          rdreq <= 1'b1; //read fifo
          State <= FIFO_READ;
        end
        else begin
          State <= FIFO_EPT;//State here
          rdreq <= 1'b0; //fifo is empty can't read any more
        end
      end
      FIFO_READ:begin
          rdreq <= 1'b0;
          State <= WAIT2;
      end
      WAIT2:begin //wait the fifo output data stable
        State <= FILL_IN;
      end
      FILL_IN:begin
        if(out_to_Dm9000a_IOWR_RunStart & in_from_Dm9000a_IOWR_RunEnd)begin
          Tx_cnt <= Tx_cnt + 2'd2;
          State <= FILL_DATA;
        end
        else
          State <= FILL_IN;
      end
      TRANSMIT:begin //issue TX polling command activated
        if(out_to_Dm9000a_Iow_RunStart & in_from_Dm9000a_Iow_RunEnd)
          State <= READ_NSR;
        else
          State <= TRANSMIT;
      end
      READ_NSR:begin
        if(out_to_Dm9000a_Ior_RunStart & in_from_Dm9000a_Ior_RunEnd)begin
          NSR_Value <= in_from_Dm9000a_Ior_ReturnValue;
          State <= CHECK_NSR;
        end
        else
          State <= READ_NSR;
      end
      CHECK_NSR:begin
        if(!(NSR_Value & 16'h000c))begin //not done
          State <= DELAY;
        end
        else //transmit done
          State <= CLR_NSR;
      end
      DELAY:begin //delay 20us
        if(out_to_Dm9000a_usDelay_RunStart & in_from_Dm9000a_usDelay_RunEnd)
          State <= READ_NSR;
        else
          State <= DELAY;
      end
      CLR_NSR:begin //clear NSR transmit done
        if(out_to_Dm9000a_Iow_RunStart & in_from_Dm9000a_Iow_RunEnd)
          State <= DONE;
        else
          State <= CLR_NSR;
      end
      DONE:begin
        State <= DONE;
      end
      default:begin
        State <= Idle;
      end
    endcase
  end
end
always @ (State , Data_Send , Data_Length) begin
  case(State)
    Idle:begin
      Tx_Done = 1'b0;
      out_to_Dm9000a_Iow_RunStart = 1'b0;
      out_to_Dm9000a_Iow_Reg = 16'b0;
      out_to_Dm9000a_Iow_Data = 16'b0;
      out_to_Dm9000a_IOWR_RunStart = 1'b0;
      out_to_Dm9000a_IOWR_IndexOrData = 1'b0;
      out_to_Dm9000a_IOWR_OutData = 16'b0;
      out_to_Dm9000a_Ior_RunStart = 1'b0;
      out_to_Dm9000a_Ior_iReg = 16'b0;
      out_to_Dm9000a_usDelay_RunStart = 1'b0;
      out_to_Dm9000a_usDelay_DelayTime = 11'b0;
    end
    W_TXPLH:begin
      Tx_Done = 1'b0;
      out_to_Dm9000a_Iow_RunStart = 1'b1;
      out_to_Dm9000a_Iow_Reg = `TXPLH;
      out_to_Dm9000a_Iow_Data = {8'h00,Data_Length[15:8]};
      out_to_Dm9000a_IOWR_RunStart = 1'b0;
      out_to_Dm9000a_IOWR_IndexOrData = 1'b0;
      out_to_Dm9000a_IOWR_OutData = 16'b0;
      out_to_Dm9000a_Ior_RunStart = 1'b0;
      out_to_Dm9000a_Ior_iReg = 16'b0;
      out_to_Dm9000a_usDelay_RunStart = 1'b0;
      out_to_Dm9000a_usDelay_DelayTime = 11'b0;
    end
    WAIT1:begin
      Tx_Done = 1'b0;
      out_to_Dm9000a_Iow_RunStart = 1'b0;
      out_to_Dm9000a_Iow_Reg = 16'b0;
      out_to_Dm9000a_Iow_Data = 16'b0;
      out_to_Dm9000a_IOWR_RunStart = 1'b0;
      out_to_Dm9000a_IOWR_IndexOrData = 1'b0;
      out_to_Dm9000a_IOWR_OutData = 16'b0;
      out_to_Dm9000a_Ior_RunStart = 1'b0;
      out_to_Dm9000a_Ior_iReg = 16'b0;
      out_to_Dm9000a_usDelay_RunStart = 1'b0;
      out_to_Dm9000a_usDelay_DelayTime = 11'b0;
    end
    W_TXPLL:begin
      Tx_Done = 1'b0;
      out_to_Dm9000a_Iow_RunStart = 1'b1;
      out_to_Dm9000a_Iow_Reg = `TXPLL;
      out_to_Dm9000a_Iow_Data = {8'h00,Data_Length[7:0]};
      out_to_Dm9000a_IOWR_RunStart = 1'b0;
      out_to_Dm9000a_IOWR_IndexOrData = 1'b0;
      out_to_Dm9000a_IOWR_OutData = 16'b0;
      out_to_Dm9000a_Ior_RunStart = 1'b0;
      out_to_Dm9000a_Ior_iReg = 16'b0;
      out_to_Dm9000a_usDelay_RunStart = 1'b0;
      out_to_Dm9000a_usDelay_DelayTime = 11'b0;
    end
    SET_MWCMD:begin
      Tx_Done = 1'b0;
      out_to_Dm9000a_Iow_RunStart = 1'b0;
      out_to_Dm9000a_Iow_Reg = 16'b0;
      out_to_Dm9000a_Iow_Data = 16'b0;
      out_to_Dm9000a_IOWR_RunStart = 1'b1;
      out_to_Dm9000a_IOWR_IndexOrData = `IO_addr;
      out_to_Dm9000a_IOWR_OutData = `MWCMD;
      out_to_Dm9000a_Ior_RunStart = 1'b0;
      out_to_Dm9000a_Ior_iReg = 16'b0;
      out_to_Dm9000a_usDelay_RunStart = 1'b0;
      out_to_Dm9000a_usDelay_DelayTime = 11'b0;
    end
    FILL_DATA:begin
      Tx_Done = 1'b0;
      out_to_Dm9000a_Iow_RunStart = 1'b0;
      out_to_Dm9000a_Iow_Reg = 16'b0;
      out_to_Dm9000a_Iow_Data = 16'b0;
      out_to_Dm9000a_IOWR_RunStart = 1'b0;
      out_to_Dm9000a_IOWR_IndexOrData = 1'b0;
      out_to_Dm9000a_IOWR_OutData = 16'b0;
      out_to_Dm9000a_Ior_RunStart = 1'b0;
      out_to_Dm9000a_Ior_iReg = 16'b0;
      out_to_Dm9000a_usDelay_RunStart = 1'b0;
      out_to_Dm9000a_usDelay_DelayTime = 11'b0;
    end
    FIFO_EPT:begin
      Tx_Done = 1'b0;
      out_to_Dm9000a_Iow_RunStart = 1'b0;
      out_to_Dm9000a_Iow_Reg = 16'b0;
      out_to_Dm9000a_Iow_Data = 16'b0;
      out_to_Dm9000a_IOWR_RunStart = 1'b0;
      out_to_Dm9000a_IOWR_IndexOrData = 1'b0;
      out_to_Dm9000a_IOWR_OutData = 16'b0;
      out_to_Dm9000a_Ior_RunStart = 1'b0;
      out_to_Dm9000a_Ior_iReg = 16'b0;
      out_to_Dm9000a_usDelay_RunStart = 1'b0;
      out_to_Dm9000a_usDelay_DelayTime = 11'b0;
    end
    FIFO_READ:begin
      Tx_Done = 1'b0;
      out_to_Dm9000a_Iow_RunStart = 1'b0;
      out_to_Dm9000a_Iow_Reg = 16'b0;
      out_to_Dm9000a_Iow_Data = 16'b0;
      out_to_Dm9000a_IOWR_RunStart = 1'b0;
      out_to_Dm9000a_IOWR_IndexOrData = 1'b0;
      out_to_Dm9000a_IOWR_OutData = 16'b0;
      out_to_Dm9000a_Ior_RunStart = 1'b0;
      out_to_Dm9000a_Ior_iReg = 16'b0;
      out_to_Dm9000a_usDelay_RunStart = 1'b0;
      out_to_Dm9000a_usDelay_DelayTime = 11'b0;
    end
    WAIT2:begin
      Tx_Done = 1'b0;
      out_to_Dm9000a_Iow_RunStart = 1'b0;
      out_to_Dm9000a_Iow_Reg = 16'b0;
      out_to_Dm9000a_Iow_Data = 16'b0;
      out_to_Dm9000a_IOWR_RunStart = 1'b0;
      out_to_Dm9000a_IOWR_IndexOrData = 1'b0;
      out_to_Dm9000a_IOWR_OutData = 16'b0;
      out_to_Dm9000a_Ior_RunStart = 1'b0;
      out_to_Dm9000a_Ior_iReg = 16'b0;
      out_to_Dm9000a_usDelay_RunStart = 1'b0;
      out_to_Dm9000a_usDelay_DelayTime = 11'b0;
    end
    FILL_IN:begin
      Tx_Done = 1'b0;
      out_to_Dm9000a_Iow_RunStart = 1'b0;
      out_to_Dm9000a_Iow_Reg = 16'b0;
      out_to_Dm9000a_Iow_Data = 16'b0;
      out_to_Dm9000a_IOWR_RunStart = 1'b1;
      out_to_Dm9000a_IOWR_IndexOrData = `IO_data;
      out_to_Dm9000a_IOWR_OutData = Data_Send;
      out_to_Dm9000a_Ior_RunStart = 1'b0;
      out_to_Dm9000a_Ior_iReg = 16'b0;
      out_to_Dm9000a_usDelay_RunStart = 1'b0;
      out_to_Dm9000a_usDelay_DelayTime = 11'b0;
    end
    TRANSMIT:begin
      Tx_Done = 1'b0;
      out_to_Dm9000a_Iow_RunStart = 1'b1;
      out_to_Dm9000a_Iow_Reg = `TCR;
      out_to_Dm9000a_Iow_Data = `TCR_set | `TX_REQUEST;
      out_to_Dm9000a_IOWR_RunStart = 1'b0;
      out_to_Dm9000a_IOWR_IndexOrData = 1'b0;
      out_to_Dm9000a_IOWR_OutData = 16'b0;
      out_to_Dm9000a_Ior_RunStart = 1'b0;
      out_to_Dm9000a_Ior_iReg = 16'b0;
      out_to_Dm9000a_usDelay_RunStart = 1'b0;
      out_to_Dm9000a_usDelay_DelayTime = 11'b0;
    end
    READ_NSR:begin
      Tx_Done = 1'b0;
      out_to_Dm9000a_Iow_RunStart = 1'b0;
      out_to_Dm9000a_Iow_Reg = 16'b0;
      out_to_Dm9000a_Iow_Data = 16'b0;
      out_to_Dm9000a_IOWR_RunStart = 1'b0;
      out_to_Dm9000a_IOWR_IndexOrData = 1'b0;
      out_to_Dm9000a_IOWR_OutData = 16'b0;
      out_to_Dm9000a_Ior_RunStart = 1'b1;
      out_to_Dm9000a_Ior_iReg = `NSR;
      out_to_Dm9000a_usDelay_RunStart = 1'b0;
      out_to_Dm9000a_usDelay_DelayTime = 11'b0;
    end
    CHECK_NSR:begin
      Tx_Done = 1'b0;
      out_to_Dm9000a_Iow_RunStart = 1'b0;
      out_to_Dm9000a_Iow_Reg = 16'b0;
      out_to_Dm9000a_Iow_Data = 16'b0;
      out_to_Dm9000a_IOWR_RunStart = 1'b0;
      out_to_Dm9000a_IOWR_IndexOrData = 1'b0;
      out_to_Dm9000a_IOWR_OutData = 16'b0;
      out_to_Dm9000a_Ior_RunStart = 1'b0;
      out_to_Dm9000a_Ior_iReg = 16'b0;
      out_to_Dm9000a_usDelay_RunStart = 1'b0;
      out_to_Dm9000a_usDelay_DelayTime = 11'b0;
    end
    DELAY:begin
      Tx_Done = 1'b0;
      out_to_Dm9000a_Iow_RunStart = 1'b0;
      out_to_Dm9000a_Iow_Reg = 16'b0;
      out_to_Dm9000a_Iow_Data = 16'b0;
      out_to_Dm9000a_IOWR_RunStart = 1'b0;
      out_to_Dm9000a_IOWR_IndexOrData = 1'b0;
      out_to_Dm9000a_IOWR_OutData = 16'b0;
      out_to_Dm9000a_Ior_RunStart = 1'b0;
      out_to_Dm9000a_Ior_iReg = 16'b0;
      out_to_Dm9000a_usDelay_RunStart = 1'b1;
      out_to_Dm9000a_usDelay_DelayTime = `STD_DELAY;
    end
    CLR_NSR:begin
      Tx_Done = 1'b0;
      out_to_Dm9000a_Iow_RunStart = 1'b1;
      out_to_Dm9000a_Iow_Reg = `NSR;
      out_to_Dm9000a_Iow_Data = 16'b0;
      out_to_Dm9000a_IOWR_RunStart = 1'b0;
      out_to_Dm9000a_IOWR_IndexOrData = 1'b0;
      out_to_Dm9000a_IOWR_OutData = 16'b0;
      out_to_Dm9000a_Ior_RunStart = 1'b0;
      out_to_Dm9000a_Ior_iReg = 16'b0;
      out_to_Dm9000a_usDelay_RunStart = 1'b0;
      out_to_Dm9000a_usDelay_DelayTime = 11'b0;
    end
    DONE:begin
      Tx_Done = 1'b1;
      out_to_Dm9000a_Iow_RunStart = 1'b0;
      out_to_Dm9000a_Iow_Reg = 16'b0;
      out_to_Dm9000a_Iow_Data = 16'b0;
      out_to_Dm9000a_IOWR_RunStart = 1'b0;
      out_to_Dm9000a_IOWR_IndexOrData = 1'b0;
      out_to_Dm9000a_IOWR_OutData = 16'b0;
      out_to_Dm9000a_Ior_RunStart = 1'b0;
      out_to_Dm9000a_Ior_iReg = 16'b0;
      out_to_Dm9000a_usDelay_RunStart = 1'b0;
      out_to_Dm9000a_usDelay_DelayTime = 11'b0;
    end
    default:begin
      Tx_Done = 1'b0;
      out_to_Dm9000a_Iow_RunStart = 1'b0;
      out_to_Dm9000a_Iow_Reg = 16'b0;
      out_to_Dm9000a_Iow_Data = 16'b0;
      out_to_Dm9000a_IOWR_RunStart = 1'b0;
      out_to_Dm9000a_IOWR_IndexOrData = 1'b0;
      out_to_Dm9000a_IOWR_OutData = 16'b0;
      out_to_Dm9000a_Ior_RunStart = 1'b0;
      out_to_Dm9000a_Ior_iReg = 16'b0;
      out_to_Dm9000a_usDelay_RunStart = 1'b0;
      out_to_Dm9000a_usDelay_DelayTime = 11'b0;
    end
  endcase
end
endmodule 

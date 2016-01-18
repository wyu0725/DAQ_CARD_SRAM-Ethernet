module Write_Fifo
(
	input iDm9000aClk,
	input iRunStart,    //rx_done & request_done is the fifo reset port
	input [15:0] in_from_Dm9000a_Rx_Tx_Len,  //写入fifo数据长度	
	output reg oRunEnd, //when write done 
	
	input wrfull,//fifo is full?
	output reg wr_fifo_req,  //to fifo
	output [7:0] fifo_data_in, //to fifo
	//output fifo_aclr,//fifo复位端高电平复位
	input [7:0] in_from_dpram_q_a, //interface of dpram
	output reg rden_a, //interface of dpram
	output reg [9:0]address_a //interface of dpram
);
assign  fifo_data_in = in_from_dpram_q_a;//ram data to fifo directly
//assign fifo_aclr = ~iRunStart;
wire [9:0] len;
assign len = in_from_Dm9000a_Rx_Tx_Len[9:0];
reg [2:0] State;
localparam Idle = 3'b001,READ = 3'b010,READ_1 = 3'b011, WRITE = 3'b100 , WRITE_1 = 3'b101 , DONE = 3'b110;
always @ (posedge iDm9000aClk , negedge iRunStart) begin //fifo高电平复位
	if(~iRunStart) begin
		State <= Idle;
		address_a <= 10'd0;
	end
	else
		case (State)
		Idle:begin
			if(!wrfull)
				State <= READ;
			else 
				State <= Idle;
		end
		READ:begin  //read dpram
			if(address_a != len) 
				State <= READ_1;		
			else
				State <= DONE;
		end
		READ_1:begin
			State <= WRITE;
		end
		WRITE:begin
			State <= WRITE_1;
			address_a <= address_a + 1'b1;
		end
		WRITE_1:begin
			State <= READ;
		end
		DONE:begin
			State <= DONE;
		end
		default:begin
			State <= Idle;
			address_a <= 10'd0;
		end
		endcase
end
always @ (State) begin
	case(State)
	Idle:begin
		wr_fifo_req = 1'b0;
		rden_a = 1'b0;
		oRunEnd = 1'b0;
	end
	READ:begin
		wr_fifo_req = 1'b0;
		rden_a = 1'b1;	
		oRunEnd = 1'b0;
	end
	READ_1:begin
		wr_fifo_req = 1'b0;
		rden_a = 1'b0;
		oRunEnd = 1'b0;	
	end
	WRITE:begin
		wr_fifo_req = 1'b1;
		rden_a = 1'b0;	
		oRunEnd = 1'b0;
	end
	WRITE_1:begin
		wr_fifo_req = 1'b0;
		rden_a = 1'b0;		
		oRunEnd = 1'b0;
	end
	DONE:begin
		wr_fifo_req = 1'b0;
		rden_a = 1'b0;		
		oRunEnd = 1'b1;	//结束信号
	end
	default:begin
		wr_fifo_req = 1'b0;
		rden_a = 1'b0;			
	end
	endcase
end
endmodule 
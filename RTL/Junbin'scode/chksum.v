//create 20140918
module chksum
(
	input iDm9000aClk,
	input iRunStart,
	input [15:0] len,                //校验数据长度
	input [9:0] start_addr,      //入口地址
	input [7:0] in_from_dpram_q_b,
	output reg rden_b,
	output reg [9:0]address_b,
	output reg [15:0] checksum,    //输出校验值
	output reg oRunEnd
);
localparam [3:0] Idle = 4'd0,
									READ_HB = 4'd1,
									STORE_HB = 4'd2,
									READ_LB = 4'd3,
									STORE_LB = 4'd4,
									SUM = 4'd5,
									JUDGE = 4'd6,
									ODD_OR_EVEN = 4'd7,
									CARRY = 4'd8,
									CHECKSUM = 4'd9,
									END = 4'd10;
reg [3:0] State;
reg [15:0] temp,cnt;
reg [31:0] sum;
always @ (posedge iDm9000aClk , negedge iRunStart)begin
	if(~iRunStart)begin 
		State <= Idle;
		address_b <= 10'b0;
		temp <= 16'b0;
		sum <= 32'b0;
		cnt <= 16'b0;
		end
	else begin
		case(State)
			Idle:begin
				State <= READ_HB;
				address_b <= start_addr;
				temp <= 16'b0;
				sum <= 32'b0;
				cnt <= 16'b0;
			end
			READ_HB:begin
				State <= STORE_HB;	
			end
			STORE_HB:begin
				temp [15:8] <= in_from_dpram_q_b;
				address_b <= address_b + 1'b1;
				State <= READ_LB;
			end
			READ_LB:begin
				State <= STORE_LB;
			end
			STORE_LB:begin
				temp [7:0] <= in_from_dpram_q_b;
				State <= SUM;
			end
			SUM:begin
				sum <= sum + temp;
				cnt <= cnt +2'd2;
				State <= JUDGE;
			end
			JUDGE:begin
				if(cnt < len)begin
					State <= READ_HB;
					address_b <= address_b + 1'b1;
				end
				else begin
					State <= ODD_OR_EVEN;
					address_b <= 10'd0; //一旦不使用address_b就立刻释放
				end
			end
			ODD_OR_EVEN:begin
				if(len & 16'h01)begin//长度为单数
					sum <= sum + (temp & 16'hff00);
					State <= CARRY;
				end
				else begin//长度为偶数 
					sum <= {16'b0,sum[15:0]}+{16'b0,sum[31:16]};
					State <= CARRY;
				end
			end
			CARRY:begin
				if(sum & 32'hffff0000) begin//有进位
					sum <= sum + 1'b1;
					State <= CHECKSUM;
				end
				else begin
					sum <= sum;
					State <= CHECKSUM;
				end
			end
			CHECKSUM:begin
				checksum <= sum[15:0];
				State <= END;
			end
			END:begin
				State <= END;
			end
			default:begin
				State <= Idle;
			end
		endcase
	end
end
always @ (State)begin
	case(State)
		Idle:begin
			rden_b = 1'b0;
			oRunEnd = 1'b0;
		end
		READ_HB:begin
			rden_b = 1'b1;
			oRunEnd = 1'b0;
		end
		STORE_HB:begin
			rden_b = 1'b0;
			oRunEnd = 1'b0;
		end
		READ_LB:begin
			rden_b = 1'b1;
			oRunEnd = 1'b0;
		end
		STORE_LB:begin
			rden_b = 1'b0;
			oRunEnd = 1'b0;
		end
		SUM:begin
			rden_b = 1'b0;
			oRunEnd = 1'b0;
		end
		JUDGE:begin
			rden_b = 1'b0;
			oRunEnd = 1'b0;
		end
		ODD_OR_EVEN:begin
			rden_b = 1'b0;
			oRunEnd = 1'b0;
		end
		CARRY:begin
			rden_b = 1'b0;
			oRunEnd = 1'b0;
		end
		CHECKSUM:begin
			rden_b = 1'b0;
			oRunEnd = 1'b0;
		end
		END:begin
			rden_b = 1'b0;
			oRunEnd = 1'b1;
		end
		default:begin
			rden_b = 1'b0;
			oRunEnd = 1'b0;
		end
	endcase
end
endmodule

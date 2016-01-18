//以太网帧头
`include "DM9000A.def"
module etherheader
(
	input iDm9000aClk,
	input iRunStart,
	input [47:0]in_from_Dm9000a_Rx_MAC_pc,
	input [15:0]in_from_Dm9000a_Rx_Ether_type,
	output reg wren_b,
	output reg [7:0]data_b,
	output reg [9:0]address_b,
	output reg oRunEnd
);
localparam ETHER_OFFSET = 10'd0; //帧头从0开始
localparam TOTAL_LEN = 14;
reg [3:0]State;
localparam [3:0] Idle = 4'b0001,
							WRITE= 4'b0010,
							JUDGE = 4'b0100,
							END = 4'b1000;
reg [3:0] cnt;
always @ (posedge iDm9000aClk , negedge iRunStart)begin
	if(~iRunStart)begin
		State <= Idle;
		cnt <= 4'he; //释放数据
		address_b <= 10'd0;//释放地址
	end
	else begin
		case(State)
			Idle:begin
				State <= WRITE;
				address_b <= ETHER_OFFSET;
				cnt <= 4'b0;
			end
			WRITE:begin
				State <= JUDGE;				
			end
			JUDGE:begin
				if(cnt < TOTAL_LEN-1)begin
					address_b <= address_b + 1'b1;
					cnt <= cnt + 1'b1;
					State <= WRITE;
				end
				else begin
					State <= END;
					address_b <= 10'd0;//释放地址线
					cnt <= cnt + 1'b1;//释放数据
				end
			end
			END:begin
					State <= END;
			end
		endcase
	end
end
always @ (State)begin
	case (State)
		Idle:begin
			wren_b = 1'b0;
			oRunEnd = 1'b0;
		end
		WRITE:begin
			wren_b = 1'b1;
			oRunEnd = 1'b0;
		end
		JUDGE:begin
			wren_b = 1'b0;
			oRunEnd = 1'b0;
		end
		END:begin
			wren_b = 1'b0;
			oRunEnd = 1'b1;
		end
		default:begin
			wren_b = 1'b0;
			oRunEnd = 1'b0;
		end
	endcase
end
always @ (cnt , MAC_dest , Ether_Type) begin
	case(cnt)
	4'h0:data_b = MAC_dest[47:40];//目的MAC
	4'h1:data_b = MAC_dest[39:32];//目的MAC
	4'h2:data_b = MAC_dest[31:24];//目的MAC
	4'h3:data_b = MAC_dest[23:16];//目的MAC
	4'h4:data_b = MAC_dest[15:8];//目的MAC
	4'h5:data_b = MAC_dest[7:0];//目的MAC
	4'h6:data_b = `MAC_Addr0;//源MAC
	4'h7:data_b = `MAC_Addr1;//源MAC
	4'h8:data_b = `MAC_Addr2;//源MAC
	4'h9:data_b = `MAC_Addr3;//源MAC
	4'ha:data_b = `MAC_Addr4;//源MAC
	4'hb:data_b = `MAC_Addr5;//源MAC
	4'hc:data_b = Ether_Type[15:8];//帧类型
	4'hd:data_b = Ether_Type[7:0];//帧类型
	default:data_b = 8'h00;
	endcase
end
wire [47:0] MAC_dest;
assign MAC_dest = in_from_Dm9000a_Rx_MAC_pc;
wire [15:0] Ether_Type;
assign Ether_Type = in_from_Dm9000a_Rx_Ether_type;
endmodule 
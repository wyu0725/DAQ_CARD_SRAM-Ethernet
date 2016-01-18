//ping 应答模块
//update 20140727
//update 20140818
`include "DM9000A.def"
module UDP_ACK
(
	input iDm9000aClk,
	input iRunStart,                                            //来自Rx模块的Udp 请求信号
	input [15:0] in_from_Dm9000a_Rx_Port_pc,       //pc端的端口地址发送端和接收端端口不能一样
	input [15:0] in_from_Dm9000a_Rx_Control_word,//来自Rx模块的Udp payload
	output reg wren_b,
	output reg [7:0]data_b,
	output reg [9:0]address_b,
	output reg oRunEnd
);
reg [4:0]cnt;
reg [3:0]State;
localparam UDP_OFFSET = 10'd34;
localparam TOTAL_LEN = 26;
localparam [3:0] Idle = 4'b0001,
							WRITE= 4'b0010,
							JUDGE = 4'b0100,
							END = 4'b1000;
always @ (posedge iDm9000aClk , negedge iRunStart) begin
	if(~iRunStart) begin
		State <= Idle;
		address_b <= 10'd0;
		cnt <=5'd26;
	end 
	else begin
		case(State)
			Idle:begin
				State <= WRITE;
				address_b <= UDP_OFFSET;
				cnt <= 5'd0;
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
always @ (cnt , Port_dest , payload) begin
	case(cnt)
	5'd0:data_b = Port_src[15:8];//源端口
	5'd1:data_b = Port_src[7:0];  //源端口
	5'd2:data_b = Port_dest[15:8];//目的端口
	5'd3:data_b = Port_dest[7:0]; //目的端口 
	5'd4:data_b = 8'h00;//UDP报文长度
	5'd5:data_b = 8'd26;//UDP报文长度
	5'd6:data_b = 8'h00;//UDP校验和00,不必进行校验
	5'd7:data_b = 8'h00;//UDP校验和00,不必进行校验
	5'd8:data_b = 8'h55;//UDP payload 18 bytes 1
	5'd9:data_b = 8'haa;//2
	5'd10:data_b = 8'heb;//3
	5'd11:data_b = 8'h90;//4
	5'd12:data_b = payload[15:8];//5
	5'd13:data_b = payload[7:0];//6
	5'd14:data_b = payload[15:8];//7
	5'd15:data_b = payload[7:0];//8
	5'd16:data_b = payload[15:8];//9
	5'd17:data_b = payload[7:0];//10
	5'd18:data_b = payload[15:8];//11
	5'd19:data_b = payload[7:0];//12
	5'd20:data_b = payload[15:8];//13
	5'd21:data_b = payload[7:0];//14
	5'd22:data_b = payload[15:8];//15
	5'd23:data_b = payload[7:0];//16
	5'd24:data_b = 8'haa;
	5'd25:data_b = 8'h55;
	default:data_b = 8'h00;
	endcase
end
//wire [15:0] Port_dest;  // modified 20140917
//assign Port_dest = in_from_Dm9000a_Rx_Port_pc;//modified 20140917
localparam [15:0] Port_dest = `PC_Port;
localparam [15:0] Port_src  =  `DM9000A_Port;

wire [15:0] payload;
assign payload = in_from_Dm9000a_Rx_Control_word;
endmodule 
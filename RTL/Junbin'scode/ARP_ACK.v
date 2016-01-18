//ARP应答发送模块
//update 20140722
//update 20140817
//修改RAM里面的数据成为应答报文
`include "DM9000A.def"
module ARP_ACK
(
	input iDm9000aClk,
	input iRunStart,	 //arp request from rx module
	input [47:0] in_from_Dm9000a_Rx_MAC_pc, //从Rx中获得上位机的MAC地址
	input [31:0] in_from_Dm9000a_Rx_IP_pc,     //从Rx中获得上位机的Ip地址
	/*modified the content of dpram*/
	output reg wren_b,
	output reg [7:0]data_b,
	output reg [9:0]address_b,
	output reg oRunEnd
);
localparam ARP_OFFSET = 10'd14;
localparam TOTAL_LEN = 5'd28;
reg [4:0] cnt;
reg [3:0]State;
localparam [3:0] Idle = 4'b0001,
							WRITE= 4'b0010,
							JUDGE = 4'b0100,
							END = 4'b1000;
always @ (posedge iDm9000aClk , negedge iRunStart)begin
	if(~iRunStart)begin
		State <= Idle;
		address_b <= 10'd0;
		cnt <= 5'd28;
	end
	else begin
		case(State)
			Idle:begin
				State <= WRITE;
				address_b <= ARP_OFFSET;
				cnt <= 5'd0; //计数器请0
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
always @ (cnt , MAC_dest , IP_dest)begin
	case(cnt)
		5'd0:data_b = 8'h00;//硬件类型
		5'd1:data_b = 8'h01;//硬件类型表示以太网地址
		5'd2:data_b = 8'h08;//协议类型
		5'd3:data_b = 8'h00;//通过IP地址查询MAC
		5'd4:data_b = 8'h06;//硬件地址长度
		5'd5:data_b = 8'h04;//协议地址长度
		5'd6:data_b = 8'h00;//操作类型
		5'd7:data_b = 8'h02;//ARP应答
		5'd8:data_b = `MAC_Addr0;//发送端MAC
		5'd9:data_b = `MAC_Addr1;//发送端MAC
		5'd10:data_b = `MAC_Addr2;//发送端MAC
		5'd11:data_b = `MAC_Addr3;//发送端MAC
		5'd12:data_b = `MAC_Addr4;//发送端MAC
		5'd13:data_b = `MAC_Addr5;//发送端MAC
		5'd14:data_b = IP_src[31:24];//发送端IP
		5'd15:data_b = IP_src[23:16];//发送端IP
		5'd16:data_b = IP_src[15:8]; //发送端IP
		5'd17:data_b = IP_src[7:0];   //发送端IP
		5'd18:data_b = MAC_dest[47:40];//目的MAC
		5'd19:data_b = MAC_dest[39:32];//目的MAC
		5'd20:data_b = MAC_dest[31:24];//目的MAC
		5'd21:data_b = MAC_dest[23:16];//目的MAC
		5'd22:data_b = MAC_dest[15:8]; //目的MAC
		5'd23:data_b = MAC_dest[7:0];   //目的MAC
		5'd24:data_b = IP_dest[31:24];//目的IP
		5'd25:data_b = IP_dest[23:16];//目的IP
		5'd26:data_b = IP_dest[15:8];  //目的IP
		5'd27:data_b = IP_dest[7:0];   //目的IP
		default:data_b = 8'h00;
	endcase
end
wire [47:0] MAC_dest;
assign MAC_dest = in_from_Dm9000a_Rx_MAC_pc;
wire [31:0] IP_dest;
assign IP_dest = in_from_Dm9000a_Rx_IP_pc;
localparam [31:0] IP_src = `IP_addr;                            //源ip地址为Dm9000a ip                          4byte
endmodule

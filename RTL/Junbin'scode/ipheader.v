`include "DM9000A.def"
module ipheader
(
	input iDm9000aClk,
	input iRunStart,	 //arp request from rx module
	
	input [15:0] in_from_Dm9000a_Rx_iplength, //ip报文的总长度
	input [15:0] in_from_Task_ipid, //ip的标识号
	input [7:0] in_from_Dm9000a_Rx_proto_id,  //ip协议icmp or udp
	input [31:0] in_from_Dm9000a_Rx_IP_pc,     //从Rx中获得上位机的Ip地址
	
	input in_from_chksum_RunEnd,
	input [15:0] in_from_chksum_checksum,	
	/*modified the content of dpram*/
	output reg wren_b,
	output reg [7:0]data_b,
	output reg [9:0]address_b,
	//checksum port
	output reg out_to_chksum_RunStart,
	output reg [15:0] out_to_chksum_len,
	output reg [9:0] out_to_chksum_start_addr,

	output reg oRunEnd
);
reg[4:0]cnt;
parameter IPHEAD_OFFSET = 10'd14;  //ip头部的偏移地址
parameter IPHEAD_LENGTH = 16'd20;  //ip头长度20字节
reg [3:0]State;
localparam [3:0] Idle = 4'd0,WRITE = 4'd1,JUDGE = 4'd2,CHKSUM = 4'd3,FILLCHKSUM = 4'd4,
								FILL_HB = 4'd5,FILL_LB = 4'd6, END = 4'd7;
always @ (posedge iDm9000aClk , negedge iRunStart)begin
	if(~iRunStart) begin
		State <= Idle;
		address_b <= 10'd0; //释放地址
		cnt <= 5'd22;//释放数据
	end
	else begin
		case(State)
			Idle:begin
				State <= WRITE;
				address_b <= IPHEAD_OFFSET;
				cnt <= 5'd0;  //计数器清0
			end
			WRITE:begin
				State <= JUDGE;
			end
			JUDGE:begin
				if(cnt < IPHEAD_LENGTH -1)begin
					address_b <= address_b + 1'b1;
					cnt <= cnt + 1'b1;
					State <= WRITE;
				end
				else begin
					State <= CHKSUM;
					address_b <= 10'd0; //地址清0很重要，因为chksum也用到address_b
				end
			end
			CHKSUM:begin
				if(out_to_chksum_RunStart & in_from_chksum_RunEnd)
					State <= FILLCHKSUM;
				else
					State <= CHKSUM;
			end
			FILLCHKSUM:begin
				address_b <= 10'd24; //校验和所在地址
				cnt <= 5'd20;            //给一个可以赋值
				State <= FILL_HB;
			end
			FILL_HB:begin
				address_b <= address_b + 1'b1;
				cnt <= cnt + 1'b1;
				State <= FILL_LB;
			end
			FILL_LB:begin
				address_b <= 10'd0;  //释放address_b;
				cnt <= cnt +1'b1;      //释放data_b;
				State <= END;
			end
			END:begin
				State <= END;
			end
		endcase
	end
end
always @ (State) begin
	case(State)
		Idle:begin
			wren_b = 1'b0;
			oRunEnd = 1'b0;
			out_to_chksum_RunStart = 1'b0;
			out_to_chksum_len = 16'd0;
			out_to_chksum_start_addr = 10'd0;				
		end
		WRITE:begin
			wren_b = 1'b1;
			oRunEnd = 1'b0;
			out_to_chksum_RunStart = 1'b0;
			out_to_chksum_len = 16'd0;
			out_to_chksum_start_addr = 10'd0;					
		end
		JUDGE:begin
			wren_b = 1'b0;
			oRunEnd = 1'b0;
			out_to_chksum_RunStart = 1'b0;
			out_to_chksum_len = 16'd0;
			out_to_chksum_start_addr = 10'd0;		
		end
		CHKSUM:begin
			wren_b = 1'b0;
			oRunEnd = 1'b0;
			out_to_chksum_RunStart = 1'b1;
			out_to_chksum_len = IPHEAD_LENGTH;
			out_to_chksum_start_addr = IPHEAD_OFFSET;		
		end
		FILLCHKSUM:begin
			wren_b = 1'b0;
			oRunEnd = 1'b0;
			out_to_chksum_RunStart = 1'b0;
			out_to_chksum_len = 16'd0;
			out_to_chksum_start_addr = 10'd0;				
		end
		FILL_HB:begin
			wren_b = 1'b1; //写
			oRunEnd = 1'b0;			
			out_to_chksum_RunStart = 1'b0;
			out_to_chksum_len = 16'd0;
			out_to_chksum_start_addr = 10'd0;							
		end
		FILL_LB:begin
			wren_b = 1'b1; //写
			oRunEnd = 1'b0;	
			out_to_chksum_RunStart = 1'b0;
			out_to_chksum_len = 16'd0;
			out_to_chksum_start_addr = 10'd0;							
		end
		END:begin
			wren_b = 1'b0; //写
			oRunEnd = 1'b1;	
			out_to_chksum_RunStart = 1'b0;
			out_to_chksum_len = 16'd0;
			out_to_chksum_start_addr = 10'd0;			
		end
	endcase
end
always @ (cnt , total_length , identifier , protocal , IP_dest , checksum) begin
	case(cnt)
	5'd0:data_b = 8'h45; //ip版本号和首部长度
	5'd1:data_b = 8'h00; //服务类型为普通服务
	5'd2:data_b = total_length[15:8];//ip报文长度------------
	5'd3:data_b = total_length[7:0]; //ip报文长度-------------
	5'd4:data_b = identifier[15:8];//ip标识---------------------
	5'd5:data_b = identifier[7:0];//ip标识-----------------------
	5'd6:data_b = 8'h00; //标志片偏移，不分片
	5'd7:data_b = 8'h00; //标志片偏移，不分片
	5'd8:data_b = 8'h40; //TTL = 64
	5'd9:data_b = protocal; //协议----------------------------
	5'd10:data_b = 8'h00; //校验和
	5'd11:data_b = 8'h00; //校验和
	5'd12:data_b = IP_src[31:24]; //源IP-----------------------
	5'd13:data_b = IP_src[23:16];//源IP------------------------
	5'd14:data_b = IP_src[15:8]; //源IP-------------------------
	5'd15:data_b = IP_src[7:0];   //源IP------------------------
	5'd16:data_b = IP_dest[31:24];//目的IP
	5'd17:data_b = IP_dest[23:16];//目的IP
	5'd18:data_b = IP_dest[15:8];//目的IP
	5'd19:data_b = IP_dest[7:0];//目的IP
	5'd20:data_b = checksum[15:8];//校验和高字节
	5'd21:data_b = checksum[7:0];//校验和低字节
	default:data_b = 8'h00;
	endcase
end
wire [15:0] total_length;
assign total_length = in_from_Dm9000a_Rx_iplength;      //ip报文长度
wire [15:0] identifier;
assign identifier = in_from_Task_ipid;                           //ip标识
wire [7:0] protocal;
assign protocal = in_from_Dm9000a_Rx_proto_id;          //ip协议;
wire [31:0] IP_dest;
assign IP_dest = in_from_Dm9000a_Rx_IP_pc;               //目的ip
localparam [31:0] IP_src = `IP_addr;                            //源ip地址为Dm9000a ip                          4byte

reg [15:0] checksum;
always @ (posedge iDm9000aClk , negedge iRunStart) begin
	if(~iRunStart) 
		checksum <= 16'd0;
	else if(out_to_chksum_RunStart & in_from_chksum_RunEnd)
		checksum <= ~in_from_chksum_checksum;
	else
		checksum <= checksum;
end
endmodule 
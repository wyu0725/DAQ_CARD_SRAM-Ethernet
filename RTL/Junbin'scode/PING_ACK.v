//ping 应答模块
//update 20140727更新了校验和部分
//updata 20140814
//改造ping应答包
`include "DM9000A.def"
module PING_ACK
(
	input iDm9000aClk,
	input iRunStart,                                       
	input [15:0] in_from_Dm9000a_Rx_Ping_id,   //从Rx中获得Ping包标示符
	input [15:0] in_from_Dm9000a_Rx_Ping_sn,  //从Rx中获得Ping包的序列号
	input [15:0] in_from_Dm9000a_Rx_Ping_len, //从Rx中获得Ping报文长度
	//modified the content of dpram
	output reg wren_b,
	output reg [7:0]data_b,
	output reg [9:0]address_b,
	//chksum port
	input in_from_chksum_RunEnd,
	input [15:0] in_from_chksum_checksum,		
	output reg out_to_chksum_RunStart,
	output reg [15:0] out_to_chksum_len,
	output reg [9:0] out_to_chksum_start_addr,
	output reg oRunEnd
);
localparam ICMP_OFFSET = 10'd34;   //Icmp 偏移地址
localparam ICMP_HEAD_LEN = 8;      //Icmp头部8字节
reg [3:0]cnt;
reg [3:0]State;
localparam [3:0] Idle = 4'd0,WRITE = 4'd1,JUDGE = 4'd2,CHKSUM = 4'd3,FILLCHKSUM = 4'd4,
								FILL_HB = 4'd5,FILL_LB = 4'd6, END = 4'd7;
always @ (posedge iDm9000aClk , negedge iRunStart)begin
	if(~iRunStart)begin
		State <= Idle;
		address_b <= 10'd0; //释放地址
		cnt <= 4'd10; //释放数据
	end
	else begin
		case(State)
			Idle:begin
				address_b <= ICMP_OFFSET;
				cnt <= 4'd0;//计数器清0的
				State <= WRITE;
			end
			WRITE:begin
				State <= JUDGE;
			end
			JUDGE:begin
				if(cnt < ICMP_HEAD_LEN -1)begin
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
				address_b <= 10'd36; //校验和所在地址
				cnt <= 4'd8;            //给一个可以赋值
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
always @ (State , Icmp_len , Ping_id , Ping_sn , checksum) begin
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
			out_to_chksum_len = Icmp_len;//ping报文长度
			out_to_chksum_start_addr = ICMP_OFFSET;	//便宜地址	
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
always @ (cnt , Ping_id , Ping_sn , checksum)begin
	case(cnt)
		4'h0:data_b = 8'h00;//类型
		4'h1:data_b = 8'h00;//代码ping应答
		4'h2:data_b = 8'h00;//校验和00
		4'h3:data_b = 8'h00;//检验和00
		4'h4:data_b = Ping_id[15:8];//标识符
		4'h5:data_b = Ping_id[7:0];//标识符
		4'h6:data_b = Ping_sn[15:8];//序列号
		4'h7:data_b = Ping_sn[7:0];  //序列号
		4'h8:data_b = checksum[15:8];//检验和高8位
		4'h9:data_b = checksum[7:0];//检验和低8位
		default:data_b = 8'h00;
	endcase
end
wire [15:0] Ping_id;
wire [15:0] Ping_sn;
wire [15:0] Icmp_len;
assign	Ping_id = in_from_Dm9000a_Rx_Ping_id; 
assign	Ping_sn = in_from_Dm9000a_Rx_Ping_sn;
assign	Icmp_len = in_from_Dm9000a_Rx_Ping_len;
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

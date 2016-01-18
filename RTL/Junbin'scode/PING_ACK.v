//ping Ӧ��ģ��
//update 20140727������У��Ͳ���
//updata 20140814
//����pingӦ���
`include "DM9000A.def"
module PING_ACK
(
	input iDm9000aClk,
	input iRunStart,                                       
	input [15:0] in_from_Dm9000a_Rx_Ping_id,   //��Rx�л��Ping����ʾ��
	input [15:0] in_from_Dm9000a_Rx_Ping_sn,  //��Rx�л��Ping�������к�
	input [15:0] in_from_Dm9000a_Rx_Ping_len, //��Rx�л��Ping���ĳ���
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
localparam ICMP_OFFSET = 10'd34;   //Icmp ƫ�Ƶ�ַ
localparam ICMP_HEAD_LEN = 8;      //Icmpͷ��8�ֽ�
reg [3:0]cnt;
reg [3:0]State;
localparam [3:0] Idle = 4'd0,WRITE = 4'd1,JUDGE = 4'd2,CHKSUM = 4'd3,FILLCHKSUM = 4'd4,
								FILL_HB = 4'd5,FILL_LB = 4'd6, END = 4'd7;
always @ (posedge iDm9000aClk , negedge iRunStart)begin
	if(~iRunStart)begin
		State <= Idle;
		address_b <= 10'd0; //�ͷŵ�ַ
		cnt <= 4'd10; //�ͷ�����
	end
	else begin
		case(State)
			Idle:begin
				address_b <= ICMP_OFFSET;
				cnt <= 4'd0;//��������0��
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
					address_b <= 10'd0; //��ַ��0����Ҫ����ΪchksumҲ�õ�address_b
				end
			end
			CHKSUM:begin
				if(out_to_chksum_RunStart & in_from_chksum_RunEnd)
					State <= FILLCHKSUM;
				else
					State <= CHKSUM;
			end
			FILLCHKSUM:begin
				address_b <= 10'd36; //У������ڵ�ַ
				cnt <= 4'd8;            //��һ�����Ը�ֵ
				State <= FILL_HB;
			end
			FILL_HB:begin
				address_b <= address_b + 1'b1;
				cnt <= cnt + 1'b1;
				State <= FILL_LB;
			end
			FILL_LB:begin
				address_b <= 10'd0;  //�ͷ�address_b;
				cnt <= cnt +1'b1;      //�ͷ�data_b;
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
			out_to_chksum_len = Icmp_len;//ping���ĳ���
			out_to_chksum_start_addr = ICMP_OFFSET;	//���˵�ַ	
		end
		FILLCHKSUM:begin
			wren_b = 1'b0;
			oRunEnd = 1'b0;
			out_to_chksum_RunStart = 1'b0;
			out_to_chksum_len = 16'd0;
			out_to_chksum_start_addr = 10'd0;				
		end
		FILL_HB:begin
			wren_b = 1'b1; //д
			oRunEnd = 1'b0;			
			out_to_chksum_RunStart = 1'b0;
			out_to_chksum_len = 16'd0;
			out_to_chksum_start_addr = 10'd0;							
		end
		FILL_LB:begin
			wren_b = 1'b1; //д
			oRunEnd = 1'b0;	
			out_to_chksum_RunStart = 1'b0;
			out_to_chksum_len = 16'd0;
			out_to_chksum_start_addr = 10'd0;							
		end
		END:begin
			wren_b = 1'b0; //д
			oRunEnd = 1'b1;	
			out_to_chksum_RunStart = 1'b0;
			out_to_chksum_len = 16'd0;
			out_to_chksum_start_addr = 10'd0;			
		end
	endcase
end
always @ (cnt , Ping_id , Ping_sn , checksum)begin
	case(cnt)
		4'h0:data_b = 8'h00;//����
		4'h1:data_b = 8'h00;//����pingӦ��
		4'h2:data_b = 8'h00;//У���00
		4'h3:data_b = 8'h00;//�����00
		4'h4:data_b = Ping_id[15:8];//��ʶ��
		4'h5:data_b = Ping_id[7:0];//��ʶ��
		4'h6:data_b = Ping_sn[15:8];//���к�
		4'h7:data_b = Ping_sn[7:0];  //���к�
		4'h8:data_b = checksum[15:8];//����͸�8λ
		4'h9:data_b = checksum[7:0];//����͵�8λ
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

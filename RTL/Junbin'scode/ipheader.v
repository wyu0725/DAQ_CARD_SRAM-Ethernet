`include "DM9000A.def"
module ipheader
(
	input iDm9000aClk,
	input iRunStart,	 //arp request from rx module
	
	input [15:0] in_from_Dm9000a_Rx_iplength, //ip���ĵ��ܳ���
	input [15:0] in_from_Task_ipid, //ip�ı�ʶ��
	input [7:0] in_from_Dm9000a_Rx_proto_id,  //ipЭ��icmp or udp
	input [31:0] in_from_Dm9000a_Rx_IP_pc,     //��Rx�л����λ����Ip��ַ
	
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
parameter IPHEAD_OFFSET = 10'd14;  //ipͷ����ƫ�Ƶ�ַ
parameter IPHEAD_LENGTH = 16'd20;  //ipͷ����20�ֽ�
reg [3:0]State;
localparam [3:0] Idle = 4'd0,WRITE = 4'd1,JUDGE = 4'd2,CHKSUM = 4'd3,FILLCHKSUM = 4'd4,
								FILL_HB = 4'd5,FILL_LB = 4'd6, END = 4'd7;
always @ (posedge iDm9000aClk , negedge iRunStart)begin
	if(~iRunStart) begin
		State <= Idle;
		address_b <= 10'd0; //�ͷŵ�ַ
		cnt <= 5'd22;//�ͷ�����
	end
	else begin
		case(State)
			Idle:begin
				State <= WRITE;
				address_b <= IPHEAD_OFFSET;
				cnt <= 5'd0;  //��������0
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
				address_b <= 10'd24; //У������ڵ�ַ
				cnt <= 5'd20;            //��һ�����Ը�ֵ
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
always @ (cnt , total_length , identifier , protocal , IP_dest , checksum) begin
	case(cnt)
	5'd0:data_b = 8'h45; //ip�汾�ź��ײ�����
	5'd1:data_b = 8'h00; //��������Ϊ��ͨ����
	5'd2:data_b = total_length[15:8];//ip���ĳ���------------
	5'd3:data_b = total_length[7:0]; //ip���ĳ���-------------
	5'd4:data_b = identifier[15:8];//ip��ʶ---------------------
	5'd5:data_b = identifier[7:0];//ip��ʶ-----------------------
	5'd6:data_b = 8'h00; //��־Ƭƫ�ƣ�����Ƭ
	5'd7:data_b = 8'h00; //��־Ƭƫ�ƣ�����Ƭ
	5'd8:data_b = 8'h40; //TTL = 64
	5'd9:data_b = protocal; //Э��----------------------------
	5'd10:data_b = 8'h00; //У���
	5'd11:data_b = 8'h00; //У���
	5'd12:data_b = IP_src[31:24]; //ԴIP-----------------------
	5'd13:data_b = IP_src[23:16];//ԴIP------------------------
	5'd14:data_b = IP_src[15:8]; //ԴIP-------------------------
	5'd15:data_b = IP_src[7:0];   //ԴIP------------------------
	5'd16:data_b = IP_dest[31:24];//Ŀ��IP
	5'd17:data_b = IP_dest[23:16];//Ŀ��IP
	5'd18:data_b = IP_dest[15:8];//Ŀ��IP
	5'd19:data_b = IP_dest[7:0];//Ŀ��IP
	5'd20:data_b = checksum[15:8];//У��͸��ֽ�
	5'd21:data_b = checksum[7:0];//У��͵��ֽ�
	default:data_b = 8'h00;
	endcase
end
wire [15:0] total_length;
assign total_length = in_from_Dm9000a_Rx_iplength;      //ip���ĳ���
wire [15:0] identifier;
assign identifier = in_from_Task_ipid;                           //ip��ʶ
wire [7:0] protocal;
assign protocal = in_from_Dm9000a_Rx_proto_id;          //ipЭ��;
wire [31:0] IP_dest;
assign IP_dest = in_from_Dm9000a_Rx_IP_pc;               //Ŀ��ip
localparam [31:0] IP_src = `IP_addr;                            //Դip��ַΪDm9000a ip                          4byte

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
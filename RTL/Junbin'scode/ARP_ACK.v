//ARPӦ����ģ��
//update 20140722
//update 20140817
//�޸�RAM��������ݳ�ΪӦ����
`include "DM9000A.def"
module ARP_ACK
(
	input iDm9000aClk,
	input iRunStart,	 //arp request from rx module
	input [47:0] in_from_Dm9000a_Rx_MAC_pc, //��Rx�л����λ����MAC��ַ
	input [31:0] in_from_Dm9000a_Rx_IP_pc,     //��Rx�л����λ����Ip��ַ
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
				cnt <= 5'd0; //��������0
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
					address_b <= 10'd0;//�ͷŵ�ַ��
					cnt <= cnt + 1'b1;//�ͷ�����
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
		5'd0:data_b = 8'h00;//Ӳ������
		5'd1:data_b = 8'h01;//Ӳ�����ͱ�ʾ��̫����ַ
		5'd2:data_b = 8'h08;//Э������
		5'd3:data_b = 8'h00;//ͨ��IP��ַ��ѯMAC
		5'd4:data_b = 8'h06;//Ӳ����ַ����
		5'd5:data_b = 8'h04;//Э���ַ����
		5'd6:data_b = 8'h00;//��������
		5'd7:data_b = 8'h02;//ARPӦ��
		5'd8:data_b = `MAC_Addr0;//���Ͷ�MAC
		5'd9:data_b = `MAC_Addr1;//���Ͷ�MAC
		5'd10:data_b = `MAC_Addr2;//���Ͷ�MAC
		5'd11:data_b = `MAC_Addr3;//���Ͷ�MAC
		5'd12:data_b = `MAC_Addr4;//���Ͷ�MAC
		5'd13:data_b = `MAC_Addr5;//���Ͷ�MAC
		5'd14:data_b = IP_src[31:24];//���Ͷ�IP
		5'd15:data_b = IP_src[23:16];//���Ͷ�IP
		5'd16:data_b = IP_src[15:8]; //���Ͷ�IP
		5'd17:data_b = IP_src[7:0];   //���Ͷ�IP
		5'd18:data_b = MAC_dest[47:40];//Ŀ��MAC
		5'd19:data_b = MAC_dest[39:32];//Ŀ��MAC
		5'd20:data_b = MAC_dest[31:24];//Ŀ��MAC
		5'd21:data_b = MAC_dest[23:16];//Ŀ��MAC
		5'd22:data_b = MAC_dest[15:8]; //Ŀ��MAC
		5'd23:data_b = MAC_dest[7:0];   //Ŀ��MAC
		5'd24:data_b = IP_dest[31:24];//Ŀ��IP
		5'd25:data_b = IP_dest[23:16];//Ŀ��IP
		5'd26:data_b = IP_dest[15:8];  //Ŀ��IP
		5'd27:data_b = IP_dest[7:0];   //Ŀ��IP
		default:data_b = 8'h00;
	endcase
end
wire [47:0] MAC_dest;
assign MAC_dest = in_from_Dm9000a_Rx_MAC_pc;
wire [31:0] IP_dest;
assign IP_dest = in_from_Dm9000a_Rx_IP_pc;
localparam [31:0] IP_src = `IP_addr;                            //Դip��ַΪDm9000a ip                          4byte
endmodule

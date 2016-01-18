//modified 2014 0921
module Task
(
	input iDm9000aClk,
	input iRunStart,
	input rx_enable,//����ʹ��
	input in_from_Dm9000a_interrupt_hdl_RunEnd, //new add
	input [15:0] in_from_Dm9000a_Rx_IP_totallength,  //
  input in_from_etherheader_RunEnd,//MAC֡ͷ���������
  input in_from_ipheader_RunEnd,//IPͷ���������
  input in_from_Arp_Ack_RunEnd,//ArpӦ�����
  input in_from_Ping_Ack_RunEnd,//PingӦ�����
  input in_from_Udp_Ack_RunEnd, //Udp Ӧ�����
  input in_from_Write_Fifo_RunEnd,//дFIFO����
  input in_from_Dm9000a_Tx_Done,  //Tx���ͽ���
	input in_from_Dm9000a_Rx_Error,//Rx���մ���
	input in_from_Dm9000a_Rx_Done, //Rx������ȷ
  input in_from_Dm9000a_Rx_Arp_Request,
  input in_from_Dm9000a_Rx_Ping_Request,
  input in_from_Dm9000a_Rx_Udp_Request,
  output reg out_to_Dm9000a_Rx_RunStart,
  output reg out_to_etherheader_RunStart,
  output reg out_to_Arp_Ack_RunStart,
  output reg out_to_ipheader_RunStart,
  output reg out_to_Ping_Ack_RunStart,
  output reg out_to_Udp_Ack_RunStart,
  output reg out_to_Write_Fifo_RunStart,
  output reg out_to_Dm9000a_Tx_RunStart,
  output reg [15:0] out_to_Dm9000a_ipid,//ip��ͷ�ı�ʶ��
  output reg [15:0] out_to_Write_Fifo_len,//�����дfifo��
  output reg out_to_Tx_Fifo_aclr,//fifo�ߵ�ƽ��λ
  output reg out_to_Dm9000a_interrupt_hdl_RunStart, //new add
  output reg Event_Success
);
reg [15:0] Tx_len;
always @ (posedge iDm9000aClk ,negedge iRunStart)begin
	if(~iRunStart)
		Tx_len <= 16'b0;
	else if(in_from_Dm9000a_Rx_Ping_Request)
		Tx_len <= in_from_Dm9000a_Rx_IP_totallength;
	else
		Tx_len <= Tx_len;
end
	
reg [3:0] State;
localparam [3:0] Idle = 4'd0,RX_START = 4'd1,
                 RX_ERROR = 4'd2,
                 RX_DONE = 4'd3 , 
                 ETHER_HEAD = 4'd4 , 
                 IP_HEAD = 4'd5,
								 ARP_RESPONSE = 4'd6 , 
                 PING_RESPONSE = 4'd7 , 
                 UDP_RESPONSE = 4'd8 , 
                 WRITE_FIFO = 4'd9,
								 TX_START = 4'd10 , 
                 TX_DONE = 4'd11 , 
                 INT_GEN = 4'd12 , 
                 RX_ENABLE = 4'd13;
wire Any_Request;//arp,ping,udp����
assign Any_Request = in_from_Dm9000a_Rx_Arp_Request | in_from_Dm9000a_Rx_Ping_Request | in_from_Dm9000a_Rx_Udp_Request;
always @ (posedge iDm9000aClk , negedge iRunStart) begin
	if(~iRunStart) begin
		State <= Idle;
    out_to_Dm9000a_ipid <= 16'b0;
		out_to_Write_Fifo_len <= 16'b0;
		out_to_Tx_Fifo_aclr <= 1'b1; //fifo��0
	end
	else begin
		case(State)
			Idle:begin
				out_to_Write_Fifo_len <= 16'b0;
				out_to_Tx_Fifo_aclr <= 1'b1;//FIFO �ߵ�ƽ��λ
				State <= INT_GEN;
        /*
        * ����������ʹ�ã��������Ķ�����
        out_to_Dm9000a_interrupt_hdl_RunStart = 1'b0;
        out_to_Dm9000a_Rx_RunStart = 1'b0;
        out_to_etherheader_RunStart = 1'b0;
        out_to_ipheader_RunStart = 1'b0;
        out_to_Arp_Ack_RunStart = 1'b0;
        out_to_Ping_Ack_RunStart = 1'b0;
        out_to_Udp_Ack_RunStart = 1'b0;
        out_to_Write_Fifo_RunStart = 1'b0;
        out_to_Dm9000a_Tx_RunStart = 1'b0;
        Event_Success = 1'b0;        
        */
			end
		INT_GEN:begin
				if(in_from_Dm9000a_interrupt_hdl_RunEnd)
					State <= RX_ENABLE;
				else
					State <= INT_GEN;
      /*
			  out_to_Dm9000a_interrupt_hdl_RunStart = 1'b1; //�ж϶�ȡ�ж�
		    out_to_Dm9000a_Rx_RunStart = 1'b0;
		    out_to_etherheader_RunStart = 1'b0;
		    out_to_ipheader_RunStart = 1'b0;
		    out_to_Arp_Ack_RunStart = 1'b0;
		    out_to_Ping_Ack_RunStart = 1'b0;
		    out_to_Udp_Ack_RunStart = 1'b0;
		    out_to_Write_Fifo_RunStart = 1'b0;
		    out_to_Dm9000a_Tx_RunStart = 1'b0;
		    Event_Success = 1'b0;	 
      * 
      */
		end
		RX_ENABLE:begin
				if(rx_enable)
					State <= RX_START;
				else
					State <= Idle;
        /*
	      out_to_Dm9000a_interrupt_hdl_RunStart = 1'b1; //����
        out_to_Dm9000a_Rx_RunStart = 1'b0;
        out_to_etherheader_RunStart = 1'b0;
        out_to_ipheader_RunStart = 1'b0;
        out_to_Arp_Ack_RunStart = 1'b0;
        out_to_Ping_Ack_RunStart = 1'b0;
        out_to_Udp_Ack_RunStart = 1'b0;
        out_to_Write_Fifo_RunStart = 1'b0;
        out_to_Dm9000a_Tx_RunStart = 1'b0;
        Event_Success = 1'b0;	
        *
        */
		end
      RX_START:begin
        if(in_from_Dm9000a_Rx_Error)
            State <= RX_ERROR;
        else if(in_from_Dm9000a_Rx_Done)
            State <= RX_DONE;
		  else
				State <= RX_START;
      /*
		    out_to_Dm9000a_interrupt_hdl_RunStart = 1'b0;
        out_to_Dm9000a_Rx_RunStart = 1'b1; //��������
        out_to_etherheader_RunStart = 1'b0;
        out_to_ipheader_RunStart = 1'b0;
        out_to_Arp_Ack_RunStart = 1'b0;
        out_to_Ping_Ack_RunStart = 1'b0;
        out_to_Udp_Ack_RunStart = 1'b0;
        out_to_Write_Fifo_RunStart = 1'b0;
        out_to_Dm9000a_Tx_RunStart = 1'b0;
        Event_Success = 1'b0;
      * 
      */
      end
      RX_ERROR:begin
        State <= Idle;
        /*
	      out_to_Dm9000a_interrupt_hdl_RunStart = 1'b0;
        out_to_Dm9000a_Rx_RunStart = 1'b0;
        out_to_etherheader_RunStart = 1'b0;
        out_to_ipheader_RunStart = 1'b0;
        out_to_Arp_Ack_RunStart = 1'b0;
        out_to_Ping_Ack_RunStart = 1'b0;
        out_to_Udp_Ack_RunStart = 1'b0;
        out_to_Write_Fifo_RunStart = 1'b0;
        out_to_Dm9000a_Tx_RunStart = 1'b0;
        Event_Success = 1'b0;
        * 
        */
      end
      RX_DONE:begin
        if(Any_Request) begin//Arp,Ping,udp����
          State <= ETHER_HEAD;
			 out_to_Tx_Fifo_aclr <= 1'b0;//�ָ�fifo,���ݿ���д��
		    end
        else
          State <= Idle;//û�����󣬰�������ȷ������������Ҫ�İ�

        /*
	      out_to_Dm9000a_interrupt_hdl_RunStart = 1'b0;
        out_to_Dm9000a_Rx_RunStart = 1'b1; //����ס
        out_to_etherheader_RunStart = 1'b0;
        out_to_ipheader_RunStart = 1'b0;
        out_to_Arp_Ack_RunStart = 1'b0;
        out_to_Ping_Ack_RunStart = 1'b0;
        out_to_Udp_Ack_RunStart = 1'b0;
        out_to_Write_Fifo_RunStart = 1'b0;
        out_to_Dm9000a_Tx_RunStart = 1'b0;
        Event_Success = 1'b0;
        * 
        */
      end
      ETHER_HEAD:begin
        if(in_from_etherheader_RunEnd & in_from_Dm9000a_Rx_Arp_Request)//arp MAC֡ͷ�������
          State <= ARP_RESPONSE;
        else if(in_from_etherheader_RunEnd & in_from_Dm9000a_Rx_Ping_Request)//ping MAC֡ͷ�������
          State <= IP_HEAD;
        else if(in_from_etherheader_RunEnd & in_from_Dm9000a_Rx_Udp_Request)//Udp MAC֡ͷ�������
          State <= IP_HEAD;
        else 
          State <= ETHER_HEAD;//�ȴ��������
        /*
	      out_to_Dm9000a_interrupt_hdl_RunStart = 1'b0;
	      out_to_Dm9000a_Rx_RunStart = 1'b1; //����ס
        out_to_etherheader_RunStart = 1'b1;   //MAC֡ͷ
        out_to_ipheader_RunStart = 1'b0;
        out_to_Arp_Ack_RunStart = 1'b0;
        out_to_Ping_Ack_RunStart = 1'b0;
        out_to_Udp_Ack_RunStart = 1'b0;
        out_to_Write_Fifo_RunStart = 1'b0;
        out_to_Dm9000a_Tx_RunStart = 1'b0;
        Event_Success = 1'b0;
        * 
        */
      end
      ARP_RESPONSE:begin
        if(in_from_Arp_Ack_RunEnd)begin
          State <= WRITE_FIFO; //�ȴ�������д��FIFO
			 out_to_Write_Fifo_len <= 16'd64;
		  end
        else
          State <= ARP_RESPONSE;//�ȴ��������
        /*
	      out_to_Dm9000a_interrupt_hdl_RunStart = 1'b0;
	      out_to_Dm9000a_Rx_RunStart = 1'b1; //����ס
        out_to_etherheader_RunStart = 1'b0;
        out_to_ipheader_RunStart = 1'b0;
        out_to_Arp_Ack_RunStart = 1'b1;         //ArpӦ��
        out_to_Ping_Ack_RunStart = 1'b0;
        out_to_Udp_Ack_RunStart = 1'b0;
        out_to_Write_Fifo_RunStart = 1'b0;
        out_to_Dm9000a_Tx_RunStart = 1'b0;
        Event_Success = 1'b0;
        * 
        */
      end
      IP_HEAD:begin
        if(in_from_ipheader_RunEnd & in_from_Dm9000a_Rx_Ping_Request)begin//Ping�� ipͷ���������
          State <= PING_RESPONSE;
          out_to_Dm9000a_ipid <= out_to_Dm9000a_ipid + 1'b1;//ip��ʶ��1
        end
        else if(in_from_ipheader_RunEnd & in_from_Dm9000a_Rx_Udp_Request)begin//Udp�� ipͷ���������
          State <= UDP_RESPONSE;
          out_to_Dm9000a_ipid <= out_to_Dm9000a_ipid + 1'b1;//ip��ʶ��1
        end
        else
          State <= IP_HEAD;//�ȴ��������
        /*
	      out_to_Dm9000a_interrupt_hdl_RunStart = 1'b0;
	      out_to_Dm9000a_Rx_RunStart = 1'b1; //����ס
        out_to_etherheader_RunStart = 1'b0;
        out_to_ipheader_RunStart = 1'b1;        //IPͷ
        out_to_Arp_Ack_RunStart = 1'b0;
        out_to_Ping_Ack_RunStart = 1'b0;
        out_to_Udp_Ack_RunStart = 1'b0;
        out_to_Write_Fifo_RunStart = 1'b0;
        out_to_Dm9000a_Tx_RunStart = 1'b0;
        Event_Success = 1'b0;
        * 
        */
      end
      PING_RESPONSE:begin
        if(in_from_Ping_Ack_RunEnd) begin//Ping���������
          State <= WRITE_FIFO;
			 out_to_Write_Fifo_len <= Tx_len + 16'd18;
			end
        else 
          State <= PING_RESPONSE;//�ȴ��������
        /*
	      out_to_Dm9000a_interrupt_hdl_RunStart = 1'b0;
	      out_to_Dm9000a_Rx_RunStart = 1'b1; //����ס
        out_to_etherheader_RunStart = 1'b0;
        out_to_ipheader_RunStart = 1'b0;
        out_to_Arp_Ack_RunStart = 1'b0;
        out_to_Ping_Ack_RunStart = 1'b1;      //PingӦ��
        out_to_Udp_Ack_RunStart = 1'b0;
        out_to_Write_Fifo_RunStart = 1'b0;
        out_to_Dm9000a_Tx_RunStart = 1'b0;
        Event_Success = 1'b0;
        * 
        */
      end
      UDP_RESPONSE:begin
        if(in_from_Udp_Ack_RunEnd)begin//Udp���������
          State <= WRITE_FIFO;
			 out_to_Write_Fifo_len <= 16'd64; //Ҫд�����ݳ���
		 end
       else
          State <= UDP_RESPONSE;//�ȴ��������
        /*
	      out_to_Dm9000a_interrupt_hdl_RunStart = 1'b0;
	      out_to_Dm9000a_Rx_RunStart = 1'b1; //����ס
        out_to_etherheader_RunStart = 1'b0;
        out_to_ipheader_RunStart = 1'b0;
        out_to_Arp_Ack_RunStart = 1'b0;
        out_to_Ping_Ack_RunStart = 1'b0;
        out_to_Udp_Ack_RunStart = 1'b1;      //UdpӦ��
        out_to_Write_Fifo_RunStart = 1'b0;
        out_to_Dm9000a_Tx_RunStart = 1'b0;
        Event_Success = 1'b0;
        * 
        */
      end
		  WRITE_FIFO:begin
			  if(in_from_Dm9000a_Tx_Done)
				  State <= TX_DONE;
			  else
				  State <= WRITE_FIFO;
        /*
	      out_to_Dm9000a_interrupt_hdl_RunStart = 1'b0;
	      out_to_Dm9000a_Rx_RunStart = 1'b0; //����ס��
        out_to_etherheader_RunStart = 1'b0;
        out_to_ipheader_RunStart = 1'b0;
        out_to_Arp_Ack_RunStart = 1'b0;
        out_to_Ping_Ack_RunStart = 1'b0;
        out_to_Udp_Ack_RunStart = 1'b0;
        out_to_Write_Fifo_RunStart = 1'b1;
        out_to_Dm9000a_Tx_RunStart = 1'b1;
        Event_Success = 1'b0;
        * 
        */
		  end
		/*
      WRITE_FIFO:begin
        if(in_from_Write_Fifo_RunEnd)//fifoд�����
          State <= TX_START;
        else
          State <= WRITE_FIFO;
      end
      TX_START:begin
        if(in_from_Dm9000a_Tx_Done)//�������
          State <= TX_DONE;
        else
          State <= TX_START; //�ȴ��������
      end*/
      TX_DONE:begin
        State <= Idle;//�ȴ���һ���¼�
        /*
	      out_to_Dm9000a_interrupt_hdl_RunStart = 1'b0;
	      out_to_Dm9000a_Rx_RunStart = 1'b0; 
        out_to_etherheader_RunStart = 1'b0;
        out_to_ipheader_RunStart = 1'b0;
        out_to_Arp_Ack_RunStart = 1'b0;
        out_to_Ping_Ack_RunStart = 1'b0;
        out_to_Udp_Ack_RunStart = 1'b0;
        out_to_Write_Fifo_RunStart = 1'b0;
        out_to_Dm9000a_Tx_RunStart = 1'b0;
        Event_Success = 1'b1;
        * 
        */
      end
      default:State <= Idle;
		endcase
	end
end
always @ (State) begin
  case(State)
    Idle:begin
	    out_to_Dm9000a_interrupt_hdl_RunStart = 1'b0;
      out_to_Dm9000a_Rx_RunStart = 1'b0;
      out_to_etherheader_RunStart = 1'b0;
      out_to_ipheader_RunStart = 1'b0;
      out_to_Arp_Ack_RunStart = 1'b0;
      out_to_Ping_Ack_RunStart = 1'b0;
      out_to_Udp_Ack_RunStart = 1'b0;
      out_to_Write_Fifo_RunStart = 1'b0;
      out_to_Dm9000a_Tx_RunStart = 1'b0;
      Event_Success = 1'b0;
    end
	 INT_GEN:begin
	    out_to_Dm9000a_interrupt_hdl_RunStart = 1'b1; //�ж϶�ȡ�ж�
      out_to_Dm9000a_Rx_RunStart = 1'b0;
      out_to_etherheader_RunStart = 1'b0;
      out_to_ipheader_RunStart = 1'b0;
      out_to_Arp_Ack_RunStart = 1'b0;
      out_to_Ping_Ack_RunStart = 1'b0;
      out_to_Udp_Ack_RunStart = 1'b0;
      out_to_Write_Fifo_RunStart = 1'b0;
      out_to_Dm9000a_Tx_RunStart = 1'b0;
      Event_Success = 1'b0;	 
	 end
	 RX_ENABLE:begin
	    out_to_Dm9000a_interrupt_hdl_RunStart = 1'b1; //����
      out_to_Dm9000a_Rx_RunStart = 1'b0;
      out_to_etherheader_RunStart = 1'b0;
      out_to_ipheader_RunStart = 1'b0;
      out_to_Arp_Ack_RunStart = 1'b0;
      out_to_Ping_Ack_RunStart = 1'b0;
      out_to_Udp_Ack_RunStart = 1'b0;
      out_to_Write_Fifo_RunStart = 1'b0;
      out_to_Dm9000a_Tx_RunStart = 1'b0;
      Event_Success = 1'b0;		 
	 end
    RX_START:begin
		  out_to_Dm9000a_interrupt_hdl_RunStart = 1'b0;
      out_to_Dm9000a_Rx_RunStart = 1'b1; //��������
      out_to_etherheader_RunStart = 1'b0;
      out_to_ipheader_RunStart = 1'b0;
      out_to_Arp_Ack_RunStart = 1'b0;
      out_to_Ping_Ack_RunStart = 1'b0;
      out_to_Udp_Ack_RunStart = 1'b0;
      out_to_Write_Fifo_RunStart = 1'b0;
      out_to_Dm9000a_Tx_RunStart = 1'b0;
      Event_Success = 1'b0;
    end
    RX_ERROR:begin
	    out_to_Dm9000a_interrupt_hdl_RunStart = 1'b0;
      out_to_Dm9000a_Rx_RunStart = 1'b0;
      out_to_etherheader_RunStart = 1'b0;
      out_to_ipheader_RunStart = 1'b0;
      out_to_Arp_Ack_RunStart = 1'b0;
      out_to_Ping_Ack_RunStart = 1'b0;
      out_to_Udp_Ack_RunStart = 1'b0;
      out_to_Write_Fifo_RunStart = 1'b0;
      out_to_Dm9000a_Tx_RunStart = 1'b0;
      Event_Success = 1'b0;
    end
    RX_DONE:begin
	    out_to_Dm9000a_interrupt_hdl_RunStart = 1'b0;
      out_to_Dm9000a_Rx_RunStart = 1'b1; //����ס
      out_to_etherheader_RunStart = 1'b0;
      out_to_ipheader_RunStart = 1'b0;
      out_to_Arp_Ack_RunStart = 1'b0;
      out_to_Ping_Ack_RunStart = 1'b0;
      out_to_Udp_Ack_RunStart = 1'b0;
      out_to_Write_Fifo_RunStart = 1'b0;
      out_to_Dm9000a_Tx_RunStart = 1'b0;
      Event_Success = 1'b0;
    end
    ETHER_HEAD:begin
	    out_to_Dm9000a_interrupt_hdl_RunStart = 1'b0;
	    out_to_Dm9000a_Rx_RunStart = 1'b1; //����ס
      out_to_etherheader_RunStart = 1'b1;   //MAC֡ͷ
      out_to_ipheader_RunStart = 1'b0;
      out_to_Arp_Ack_RunStart = 1'b0;
      out_to_Ping_Ack_RunStart = 1'b0;
      out_to_Udp_Ack_RunStart = 1'b0;
      out_to_Write_Fifo_RunStart = 1'b0;
      out_to_Dm9000a_Tx_RunStart = 1'b0;
      Event_Success = 1'b0;
    end
    IP_HEAD:begin
	    out_to_Dm9000a_interrupt_hdl_RunStart = 1'b0;
	    out_to_Dm9000a_Rx_RunStart = 1'b1; //����ס
      out_to_etherheader_RunStart = 1'b0;
      out_to_ipheader_RunStart = 1'b1;        //IPͷ
      out_to_Arp_Ack_RunStart = 1'b0;
      out_to_Ping_Ack_RunStart = 1'b0;
      out_to_Udp_Ack_RunStart = 1'b0;
      out_to_Write_Fifo_RunStart = 1'b0;
      out_to_Dm9000a_Tx_RunStart = 1'b0;
      Event_Success = 1'b0;
    end
    ARP_RESPONSE:begin
	    out_to_Dm9000a_interrupt_hdl_RunStart = 1'b0;
	    out_to_Dm9000a_Rx_RunStart = 1'b1; //����ס
      out_to_etherheader_RunStart = 1'b0;
      out_to_ipheader_RunStart = 1'b0;
      out_to_Arp_Ack_RunStart = 1'b1;         //ArpӦ��
      out_to_Ping_Ack_RunStart = 1'b0;
      out_to_Udp_Ack_RunStart = 1'b0;
      out_to_Write_Fifo_RunStart = 1'b0;
      out_to_Dm9000a_Tx_RunStart = 1'b0;
      Event_Success = 1'b0;
    end
    PING_RESPONSE:begin
	    out_to_Dm9000a_interrupt_hdl_RunStart = 1'b0;
	    out_to_Dm9000a_Rx_RunStart = 1'b1; //����ס
      out_to_etherheader_RunStart = 1'b0;
      out_to_ipheader_RunStart = 1'b0;
      out_to_Arp_Ack_RunStart = 1'b0;
      out_to_Ping_Ack_RunStart = 1'b1;      //PingӦ��
      out_to_Udp_Ack_RunStart = 1'b0;
      out_to_Write_Fifo_RunStart = 1'b0;
      out_to_Dm9000a_Tx_RunStart = 1'b0;
      Event_Success = 1'b0;
    end
    UDP_RESPONSE:begin
	    out_to_Dm9000a_interrupt_hdl_RunStart = 1'b0;
	    out_to_Dm9000a_Rx_RunStart = 1'b1; //����ס
      out_to_etherheader_RunStart = 1'b0;
      out_to_ipheader_RunStart = 1'b0;
      out_to_Arp_Ack_RunStart = 1'b0;
      out_to_Ping_Ack_RunStart = 1'b0;
      out_to_Udp_Ack_RunStart = 1'b1;      //UdpӦ��
      out_to_Write_Fifo_RunStart = 1'b0;
      out_to_Dm9000a_Tx_RunStart = 1'b0;
      Event_Success = 1'b0;
    end
    WRITE_FIFO:begin
	    out_to_Dm9000a_interrupt_hdl_RunStart = 1'b0;
	    out_to_Dm9000a_Rx_RunStart = 1'b0; //����ס��
      out_to_etherheader_RunStart = 1'b0;
      out_to_ipheader_RunStart = 1'b0;
      out_to_Arp_Ack_RunStart = 1'b0;
      out_to_Ping_Ack_RunStart = 1'b0;
      out_to_Udp_Ack_RunStart = 1'b0;
      out_to_Write_Fifo_RunStart = 1'b1;
      out_to_Dm9000a_Tx_RunStart = 1'b1;
      Event_Success = 1'b0;
    end
	 /*
    TX_START:begin
	    out_to_Dm9000a_Rx_RunStart = 1'b1; //����ס
      out_to_etherheader_RunStart = 1'b0;
      out_to_ipheader_RunStart = 1'b0;
      out_to_Arp_Ack_RunStart = 1'b0;
      out_to_Ping_Ack_RunStart = 1'b0;
      out_to_Udp_Ack_RunStart = 1'b0;
      out_to_Write_Fifo_RunStart = 1'b1;
      out_to_Dm9000a_Tx_RunStart = 1'b1;
      Event_Success = 1'b0;
    end
	 */
    TX_DONE:begin
	    out_to_Dm9000a_interrupt_hdl_RunStart = 1'b0;
	    out_to_Dm9000a_Rx_RunStart = 1'b0; 
      out_to_etherheader_RunStart = 1'b0;
      out_to_ipheader_RunStart = 1'b0;
      out_to_Arp_Ack_RunStart = 1'b0;
      out_to_Ping_Ack_RunStart = 1'b0;
      out_to_Udp_Ack_RunStart = 1'b0;
      out_to_Write_Fifo_RunStart = 1'b0;
      out_to_Dm9000a_Tx_RunStart = 1'b0;
      Event_Success = 1'b1;
    end
    default:begin
	    out_to_Dm9000a_Rx_RunStart = 1'b0; 
      out_to_etherheader_RunStart = 1'b0;
      out_to_ipheader_RunStart = 1'b0;
      out_to_Arp_Ack_RunStart = 1'b0;
      out_to_Ping_Ack_RunStart = 1'b0;
      out_to_Udp_Ack_RunStart = 1'b0;
      out_to_Write_Fifo_RunStart = 1'b0;
      out_to_Dm9000a_Tx_RunStart = 1'b0;
      Event_Success = 1'b0;
    end
  endcase
end
endmodule 

//DM9000A recieve data
//Design by Junbin 20140701
//modified in 20140720
//update 20140722
//update 20140816
//update 20140818
//update 20140819
//update 20140911
`include "DM9000A.def"
module DM9000A_RX(
	input iDm9000aClk,
	input iRunStart,
	//input in_from_Dm9000a_Iow_RunEnd,no used
	input in_from_Dm9000a_Ior_RunEnd,
	input in_from_Dm9000a_IOWR_RunEnd, 
	input in_from_Dm9000a_IORD_RunEnd,  
	input in_from_Dm9000a_usDelay_RunEnd,
	input [15:0] in_from_Dm9000a_Ior_ReturnValue,
	input [15:0] in_from_Dm9000a_IORD_ReturnValue,
	input in_from_Dm9000a_Rx_Reset_RunEnd,//new add
	output reg Rx_Done,//��ȷ���
	output reg oError,  //������
	//protocol output
	output reg [47:0] MAC_pc,//pc����MAC��ַ
	output reg [15:0] Ether_Type,//֡����
	
	output reg Arp_Request, //����arpӦ��
	output reg [31:0] IP_pc,    //pc����IP��ַ
	
	output reg [15:0]IP_totallength,//ip���ĳ���
	output reg [7:0] IP_proto,    //ipЭ��
	
	output reg Ping_Request,//����pingӦ��
	output reg [15:0] Ping_id, //Ping���ı�ʾ��
	output reg [15:0] Ping_sn,//Ping�������к�	
	output reg [15:0] Ping_len,//Ping���ĳ���
	
	output reg Udp_Request,//����udpӦ��
	output reg [15:0] Port_pc,  //Udp pc�˿�
	output reg [15:0] Control_word, //Udp�û�����

	//write to dpram
	output reg wren_a,
	output reg [7:0]data_a,
	output reg [9:0]address_a,
	//
  output reg out_to_Dm9000a_Rx_Reset_RunStart,//new add
//	output reg out_to_Dm9000a_Iow_RunStart,
//	output reg [15:0] out_to_Dm9000a_Iow_Reg,
//	output reg [15:0] out_to_Dm9000a_Iow_Data,
	output reg out_to_Dm9000a_Ior_RunStart,
	output reg [15:0] out_to_Dm9000a_Ior_iReg ,
	output reg out_to_Dm9000a_IOWR_RunStart, //new add
	output reg out_to_Dm9000a_IOWR_IndexOrData, //new add
	output reg [15:0] out_to_Dm9000a_IOWR_OutData, //new add
	output reg out_to_Dm9000a_IORD_RunStart, //new add
	output reg out_to_Dm9000a_IORD_IndexOrData,//new add
	output reg out_to_Dm9000a_usDelay_RunStart, //new add
	output reg [10:0] out_to_Dm9000a_usDelay_DelayTime //new add
);
reg [7:0] rx_READY;
reg [15:0] RxStatus;
reg [15:0] RxLength;
reg [15:0] Buffer;
reg [10:0] cnt;
reg [10:0] fcnt;
wire Packet_good; //��õİ�
assign Packet_good = !(RxStatus & 16'hbf00) && (RxLength < `PACKET_MAX_SIZE);//16h'bf00 = 16'h1011_1111_0000_0000
reg [4:0] State;
localparam [4:0] Idle = 5'd0 , 
                 DUMMY_READ = 5'd1 , 
                 READ_MRCMDX = 5'd2 , 
                 CHECK_READY = 5'd3,
                 SET_MRCMD = 5'd4 , 
                 DELAY1 = 5'd5 , 
                 GET_STATUS = 5'd6 , 
                 DELAY2 = 5'd7,
                 GET_LENGTH = 5'd8 , 
                 CHECK_PKT = 5'd9 , 
                 RCV_AND_STORE = 5'd10 , 
                 DELAY3 = 5'd11,
                 RCV_ONE = 5'd12 , 
                 LOW_BYTE = 5'd13 , 
                 HIGH_BYTE = 5'd14 , 
                 DONE = 5'd15,
                 RCV_NOT_STORE = 5'd16 , 
                 DELAY4 = 5'd17 , 
                 RCV_DUMMY = 5'd18 , 
                 ERROR = 5'd19,
                 RESET = 5'd20;
always @ (posedge iDm9000aClk , negedge iRunStart) begin
  if(~iRunStart) begin
    State <= Idle;
    rx_READY <= 8'b0;
    RxStatus <= 16'b0;
    RxLength <= 16'b0;
    Buffer <= 16'b0;
    address_a <= 10'b0;
    data_a <= 8'b0;
    cnt <= 11'b0;
    fcnt <= 11'b0;
    oError <= 1'b0;
    Rx_Done <= 1'b0;
  end
  else begin
    case(State)
      Idle:begin
        State <= DUMMY_READ;
        address_a <= 10'b0;//write ram from address 0
        data_a <= 8'b0;
        cnt <= 11'b0;
        fcnt <= 11'b0;
        oError <= 1'b0;
        Rx_Done <= 1'b0;
        /*
        * �����Ƿ����Ķ�������ȡ��ע���ڴ�ʹ��
	      wren_a = 1'b0;
        out_to_Dm9000a_Rx_Reset_RunStart = 1'b0;
	      out_to_Dm9000a_Ior_RunStart = 1'b0;
	      out_to_Dm9000a_Ior_iReg = 16'b0;
	      out_to_Dm9000a_IOWR_RunStart = 1'b0;
	      out_to_Dm9000a_IOWR_IndexOrData = 1'b0;
	      out_to_Dm9000a_IOWR_OutData = 16'b0;
	      out_to_Dm9000a_IORD_RunStart = 1'b0;
	      out_to_Dm9000a_IORD_IndexOrData = 1'b0;
	      out_to_Dm9000a_usDelay_RunStart = 1'b0;
        out_to_Dm9000a_usDelay_DelayTime = 11'b0;
        * 
        */
      end
      DUMMY_READ:begin //dummy read a byte from MRCMDX
        if(out_to_Dm9000a_Ior_RunStart & in_from_Dm9000a_Ior_RunEnd)begin
          rx_READY <= in_from_Dm9000a_Ior_ReturnValue[7:0];//������ݶ�������ʲô��;��
          State <= READ_MRCMDX;
        end
        else
          State <= DUMMY_READ;
        /*
	      wren_a = 1'b0;
        out_to_Dm9000a_Rx_Reset_RunStart = 1'b0;
	      out_to_Dm9000a_Ior_RunStart = 1'b1;
	      out_to_Dm9000a_Ior_iReg = `MRCMDX;
	      -out_to_Dm9000a_IOWR_RunStart = 1'b0;
	      out_to_Dm9000a_IOWR_IndexOrData = 1'b0;
	      out_to_Dm9000a_IOWR_OutData = 16'b0;
	      out_to_Dm9000a_IORD_RunStart = 1'b0;
	      out_to_Dm9000a_IORD_IndexOrData = 1'b0;
	      out_to_Dm9000a_usDelay_RunStart = 1'b0;
        out_to_Dm9000a_usDelay_DelayTime = 11'b0;
        * 
        */
      end
      READ_MRCMDX:begin //get most updated byte :rx_READY
        if(out_to_Dm9000a_IORD_RunStart & in_from_Dm9000a_IORD_RunEnd)begin
          rx_READY <= in_from_Dm9000a_IORD_ReturnValue[7:0] & 8'h03;//8'h03 = 8'b0000_0011,ֻҪ�����λ
          State <= CHECK_READY;
        end
        else
          State <= READ_MRCMDX;
        /*
	      wren_a = 1'b0;
        out_to_Dm9000a_Rx_Reset_RunStart = 1'b0;
	      out_to_Dm9000a_Ior_RunStart = 1'b0;
	      out_to_Dm9000a_Ior_iReg = 16'b0;
	      out_to_Dm9000a_IOWR_RunStart = 1'b0;
	      out_to_Dm9000a_IOWR_IndexOrData = 1'b0;
	      out_to_Dm9000a_IOWR_OutData = 16'b0;
	      out_to_Dm9000a_IORD_RunStart = 1'b1;
	      out_to_Dm9000a_IORD_IndexOrData = `IO_data;
	      out_to_Dm9000a_usDelay_RunStart = 1'b0;
        out_to_Dm9000a_usDelay_DelayTime = 11'b0;
        * 
        */
      end
      CHECK_READY:begin
        if(rx_READY == `DM9000_PKT_READY)//received Packet ready
          State <= SET_MRCMD;
        else if(rx_READY == `DM9000_PKT_UNREADY)//no Packet
          State <= ERROR;
        else
          State <= RESET;//need to be reset
        /*
        CHECK_READY:begin
	      wren_a = 1'b0;
        out_to_Dm9000a_Rx_Reset_RunStart = 1'b0;
	      out_to_Dm9000a_Ior_RunStart = 1'b0;
	      out_to_Dm9000a_Ior_iReg = 16'b0;
	      out_to_Dm9000a_IOWR_RunStart = 1'b0;
	      out_to_Dm9000a_IOWR_IndexOrData = 1'b0;
	      out_to_Dm9000a_IOWR_OutData = 16'b0;
	      out_to_Dm9000a_IORD_RunStart = 1'b0;
	      out_to_Dm9000a_IORD_IndexOrData = 1'b0;
	      out_to_Dm9000a_usDelay_RunStart = 1'b0;
        out_to_Dm9000a_usDelay_DelayTime = 11'b0;
        * 
        */
      end
      SET_MRCMD:begin //set MRCMD port ready
        if(out_to_Dm9000a_IOWR_RunStart & in_from_Dm9000a_IOWR_RunEnd)
          State <= DELAY1;
        else
          State <= SET_MRCMD;
        /*
	      wren_a = 1'b0;
        out_to_Dm9000a_Rx_Reset_RunStart = 1'b0;
	      out_to_Dm9000a_Ior_RunStart = 1'b0;
	      out_to_Dm9000a_Ior_iReg = 16'b0;
	      out_to_Dm9000a_IOWR_RunStart = 1'b1;
	      out_to_Dm9000a_IOWR_IndexOrData = `IO_addr;
	      out_to_Dm9000a_IOWR_OutData = `MRCMD;
	      out_to_Dm9000a_IORD_RunStart = 1'b0;
	      out_to_Dm9000a_IORD_IndexOrData = 1'b0;
	      out_to_Dm9000a_usDelay_RunStart = 1'b0;
        out_to_Dm9000a_usDelay_DelayTime = 11'b0;
        * 
        */
      end
      DELAY1:begin
        if(out_to_Dm9000a_usDelay_RunStart & in_from_Dm9000a_usDelay_RunEnd)
          State <= GET_STATUS;
        else
          State <= DELAY1;
        /*
	      wren_a = 1'b0;
        out_to_Dm9000a_Rx_Reset_RunStart = 1'b0;
	      out_to_Dm9000a_Ior_RunStart = 1'b0;
	      out_to_Dm9000a_Ior_iReg = 16'b0;
	      out_to_Dm9000a_IOWR_RunStart = 1'b0;
	      out_to_Dm9000a_IOWR_IndexOrData = 1'b0;
	      out_to_Dm9000a_IOWR_OutData = 16'b0;
	      out_to_Dm9000a_IORD_RunStart = 1'b0;
	      out_to_Dm9000a_IORD_IndexOrData = 1'b0;
	      out_to_Dm9000a_usDelay_RunStart = 1'b1;
        out_to_Dm9000a_usDelay_DelayTime = `STD_DELAY;
        * 
        */
      end
      GET_STATUS:begin //got RxStatus
        if(out_to_Dm9000a_IORD_RunStart & in_from_Dm9000a_IORD_RunEnd)begin
          State <= DELAY2;
          RxStatus <= in_from_Dm9000a_IORD_ReturnValue;
        end
        else
          State <= GET_STATUS;
        /*
	      wren_a = 1'b0;
        out_to_Dm9000a_Rx_Reset_RunStart = 1'b0;
	      out_to_Dm9000a_Ior_RunStart = 1'b0;
	      out_to_Dm9000a_Ior_iReg = 16'b0;
	      out_to_Dm9000a_IOWR_RunStart = 1'b0;
	      out_to_Dm9000a_IOWR_IndexOrData = 1'b0;
	      out_to_Dm9000a_IOWR_OutData = 16'b0;
	      out_to_Dm9000a_IORD_RunStart = 1'b1;
	      out_to_Dm9000a_IORD_IndexOrData = `IO_data;
	      out_to_Dm9000a_usDelay_RunStart = 1'b0;
        out_to_Dm9000a_usDelay_DelayTime = 11'b0;
        * 
        */
      end
      DELAY2:begin
        if(out_to_Dm9000a_usDelay_RunStart & in_from_Dm9000a_usDelay_RunEnd)
          State <= GET_LENGTH;
        else
          State <= DELAY2;
      end
      GET_LENGTH:begin //got RxLength
        if(out_to_Dm9000a_IORD_RunStart & in_from_Dm9000a_IORD_RunEnd)begin
          State <= CHECK_PKT;
          RxLength <= in_from_Dm9000a_IORD_ReturnValue;
        end
        else
          State <= GET_LENGTH;
        /*
	      wren_a = 1'b0;
        out_to_Dm9000a_Rx_Reset_RunStart = 1'b0;
	      out_to_Dm9000a_Ior_RunStart = 1'b0;
	      out_to_Dm9000a_Ior_iReg = 16'b0;
	      out_to_Dm9000a_IOWR_RunStart = 1'b0;
	      out_to_Dm9000a_IOWR_IndexOrData = 1'b0;
	      out_to_Dm9000a_IOWR_OutData = 16'b0;
	      out_to_Dm9000a_IORD_RunStart = 1'b1;
	      out_to_Dm9000a_IORD_IndexOrData = `IO_data;
	      out_to_Dm9000a_usDelay_RunStart = 1'b0;
        out_to_Dm9000a_usDelay_DelayTime = 11'b0;
        * 
        */
      end
      CHECK_PKT:begin//check this packet_status good or bad
        if(Packet_good)
          State <= RCV_AND_STORE; //read and write in dpram
        else
          State <= RCV_NOT_STORE; //dummy ready
      end
      RCV_AND_STORE:begin
        if(cnt < RxLength)
          State <= DELAY3;
        else
          State <= DONE;
      end
      DELAY3:begin
        if(out_to_Dm9000a_usDelay_RunStart & in_from_Dm9000a_usDelay_RunEnd)
          State <= RCV_ONE;
        else
          State <= DELAY3;
      end
      RCV_ONE:begin //read one word
        if(out_to_Dm9000a_IORD_RunStart & in_from_Dm9000a_IORD_RunEnd)begin
          State <= LOW_BYTE;
          Buffer <= Swap(in_from_Dm9000a_IORD_ReturnValue);//swap
          data_a <= in_from_Dm9000a_IORD_ReturnValue[7:0];
          cnt <= cnt + 2'd2;
        end
        else
          State <= RCV_ONE;
        /*
	      wren_a = 1'b0;
        out_to_Dm9000a_Rx_Reset_RunStart = 1'b0;
	      out_to_Dm9000a_Ior_RunStart = 1'b0;
	      out_to_Dm9000a_Ior_iReg = 16'b0;
	      out_to_Dm9000a_IOWR_RunStart = 1'b0;
	      out_to_Dm9000a_IOWR_IndexOrData = 1'b0;
	      out_to_Dm9000a_IOWR_OutData = 16'b0;
	      out_to_Dm9000a_IORD_RunStart = 1'b1;
	      out_to_Dm9000a_IORD_IndexOrData = `IO_data;
	      out_to_Dm9000a_usDelay_RunStart = 1'b0;
        out_to_Dm9000a_usDelay_DelayTime = 11'b0;
        * 
        */
      end
      LOW_BYTE:begin //write in dpram low byte first
        address_a <= address_a + 1'b1;
        data_a <= Buffer[7:0];
        State <= HIGH_BYTE;
        /*
	      wren_a = 1'b1;
        out_to_Dm9000a_Rx_Reset_RunStart = 1'b0;
	      out_to_Dm9000a_Ior_RunStart = 1'b0;
	      out_to_Dm9000a_Ior_iReg = 16'b0;
	      out_to_Dm9000a_IOWR_RunStart = 1'b0;
	      out_to_Dm9000a_IOWR_IndexOrData = 1'b0;
	      out_to_Dm9000a_IOWR_OutData = 16'b0;
	      out_to_Dm9000a_IORD_RunStart = 1'b0;
	      out_to_Dm9000a_IORD_IndexOrData = 1'b0;
	      out_to_Dm9000a_usDelay_RunStart = 1'b0;
        out_to_Dm9000a_usDelay_DelayTime = 11'b0;
        *
        */
      end
      HIGH_BYTE:begin //write in dpram high byte
        address_a <= address_a + 1'b1;
       // cnt <= cnt + 2'd2;
        State <= RCV_AND_STORE;
        /*
	      wren_a = 1'b1;
        out_to_Dm9000a_Rx_Reset_RunStart = 1'b0;
	      out_to_Dm9000a_Ior_RunStart = 1'b0;
	      out_to_Dm9000a_Ior_iReg = 16'b0;
	      out_to_Dm9000a_IOWR_RunStart = 1'b0;
	      out_to_Dm9000a_IOWR_IndexOrData = 1'b0;
	      out_to_Dm9000a_IOWR_OutData = 16'b0;
	      out_to_Dm9000a_IORD_RunStart = 1'b0;
	      out_to_Dm9000a_IORD_IndexOrData = 1'b0;
	      out_to_Dm9000a_usDelay_RunStart = 1'b0;
        out_to_Dm9000a_usDelay_DelayTime = 11'b0;
        * 
        */
      end
      DONE:begin  //release bus Stay  here
        address_a <= 10'b0;
        data_a <= 8'b0;
        Buffer <= 16'b0;
        State <= DONE;
        Rx_Done <= 1'b1;
      end
      RCV_NOT_STORE:begin//this packect is bad,dump it from Rx SRAM,this is important
        if(fcnt < RxLength)
          State <= DELAY4;
        else
          State <= ERROR;
      end
      DELAY4:begin
        if(out_to_Dm9000a_usDelay_RunStart & in_from_Dm9000a_usDelay_RunEnd)
          State <= RCV_DUMMY;
        else
          State <= DELAY4;
      end
      RCV_DUMMY:begin
        if(out_to_Dm9000a_IORD_RunStart & in_from_Dm9000a_IORD_RunEnd)begin
          Buffer <= in_from_Dm9000a_IORD_ReturnValue;
          fcnt <= fcnt + 2'd2;
          State <= RCV_NOT_STORE;
        end
        else
          State <= RCV_DUMMY;
      end
      ERROR:begin  //stay here
         fcnt <= 11'b0;
         Buffer <= 16'b0;
         State <= ERROR;
         oError <= 1'b1;
      end
      RESET:begin
         if(in_from_Dm9000a_Rx_Reset_RunEnd)
           State <= ERROR;
         else
           State <= RESET;
      end
      default:begin
        State <= Idle;
      end
    endcase
  end
end
always @ (State) begin
  case(State)
    Idle:begin
	    wren_a = 1'b0;
      out_to_Dm9000a_Rx_Reset_RunStart = 1'b0;
	    out_to_Dm9000a_Ior_RunStart = 1'b0;
	    out_to_Dm9000a_Ior_iReg = 16'b0;
	    out_to_Dm9000a_IOWR_RunStart = 1'b0;
	    out_to_Dm9000a_IOWR_IndexOrData = 1'b0;
	    out_to_Dm9000a_IOWR_OutData = 16'b0;
	    out_to_Dm9000a_IORD_RunStart = 1'b0;
	    out_to_Dm9000a_IORD_IndexOrData = 1'b0;
	    out_to_Dm9000a_usDelay_RunStart = 1'b0;
      out_to_Dm9000a_usDelay_DelayTime = 11'b0;
    end
    DUMMY_READ:begin
	    wren_a = 1'b0;
      out_to_Dm9000a_Rx_Reset_RunStart = 1'b0;
	    out_to_Dm9000a_Ior_RunStart = 1'b1;
	    out_to_Dm9000a_Ior_iReg = `MRCMDX;
	    out_to_Dm9000a_IOWR_RunStart = 1'b0;
	    out_to_Dm9000a_IOWR_IndexOrData = 1'b0;
	    out_to_Dm9000a_IOWR_OutData = 16'b0;
	    out_to_Dm9000a_IORD_RunStart = 1'b0;
	    out_to_Dm9000a_IORD_IndexOrData = 1'b0;
	    out_to_Dm9000a_usDelay_RunStart = 1'b0;
      out_to_Dm9000a_usDelay_DelayTime = 11'b0;
    end
    READ_MRCMDX:begin
	    wren_a = 1'b0;
      out_to_Dm9000a_Rx_Reset_RunStart = 1'b0;
	    out_to_Dm9000a_Ior_RunStart = 1'b0;
	    out_to_Dm9000a_Ior_iReg = 16'b0;
	    out_to_Dm9000a_IOWR_RunStart = 1'b0;
	    out_to_Dm9000a_IOWR_IndexOrData = 1'b0;
	    out_to_Dm9000a_IOWR_OutData = 16'b0;
	    out_to_Dm9000a_IORD_RunStart = 1'b1;
	    out_to_Dm9000a_IORD_IndexOrData = `IO_data;
	    out_to_Dm9000a_usDelay_RunStart = 1'b0;
      out_to_Dm9000a_usDelay_DelayTime = 11'b0;
    end
    CHECK_READY:begin
	    wren_a = 1'b0;
      out_to_Dm9000a_Rx_Reset_RunStart = 1'b0;
	    out_to_Dm9000a_Ior_RunStart = 1'b0;
	    out_to_Dm9000a_Ior_iReg = 16'b0;
	    out_to_Dm9000a_IOWR_RunStart = 1'b0;
	    out_to_Dm9000a_IOWR_IndexOrData = 1'b0;
	    out_to_Dm9000a_IOWR_OutData = 16'b0;
	    out_to_Dm9000a_IORD_RunStart = 1'b0;
	    out_to_Dm9000a_IORD_IndexOrData = 1'b0;
	    out_to_Dm9000a_usDelay_RunStart = 1'b0;
      out_to_Dm9000a_usDelay_DelayTime = 11'b0;
    end
    SET_MRCMD:begin
	    wren_a = 1'b0;
      out_to_Dm9000a_Rx_Reset_RunStart = 1'b0;
	    out_to_Dm9000a_Ior_RunStart = 1'b0;
	    out_to_Dm9000a_Ior_iReg = 16'b0;
	    out_to_Dm9000a_IOWR_RunStart = 1'b1;
	    out_to_Dm9000a_IOWR_IndexOrData = `IO_addr;
	    out_to_Dm9000a_IOWR_OutData = `MRCMD;
	    out_to_Dm9000a_IORD_RunStart = 1'b0;
	    out_to_Dm9000a_IORD_IndexOrData = 1'b0;
	    out_to_Dm9000a_usDelay_RunStart = 1'b0;
      out_to_Dm9000a_usDelay_DelayTime = 11'b0;
    end
    DELAY1:begin
	    wren_a = 1'b0;
      out_to_Dm9000a_Rx_Reset_RunStart = 1'b0;
	    out_to_Dm9000a_Ior_RunStart = 1'b0;
	    out_to_Dm9000a_Ior_iReg = 16'b0;
	    out_to_Dm9000a_IOWR_RunStart = 1'b0;
	    out_to_Dm9000a_IOWR_IndexOrData = 1'b0;
	    out_to_Dm9000a_IOWR_OutData = 16'b0;
	    out_to_Dm9000a_IORD_RunStart = 1'b0;
	    out_to_Dm9000a_IORD_IndexOrData = 1'b0;
	    out_to_Dm9000a_usDelay_RunStart = 1'b1;
      out_to_Dm9000a_usDelay_DelayTime = `STD_DELAY;
    end
    GET_STATUS:begin
	    wren_a = 1'b0;
      out_to_Dm9000a_Rx_Reset_RunStart = 1'b0;
	    out_to_Dm9000a_Ior_RunStart = 1'b0;
	    out_to_Dm9000a_Ior_iReg = 16'b0;
	    out_to_Dm9000a_IOWR_RunStart = 1'b0;
	    out_to_Dm9000a_IOWR_IndexOrData = 1'b0;
	    out_to_Dm9000a_IOWR_OutData = 16'b0;
	    out_to_Dm9000a_IORD_RunStart = 1'b1;
	    out_to_Dm9000a_IORD_IndexOrData = `IO_data;
	    out_to_Dm9000a_usDelay_RunStart = 1'b0;
      out_to_Dm9000a_usDelay_DelayTime = 11'b0;
    end
    DELAY2:begin
	    wren_a = 1'b0;
      out_to_Dm9000a_Rx_Reset_RunStart = 1'b0;
	    out_to_Dm9000a_Ior_RunStart = 1'b0;
	    out_to_Dm9000a_Ior_iReg = 16'b0;
	    out_to_Dm9000a_IOWR_RunStart = 1'b0;
	    out_to_Dm9000a_IOWR_IndexOrData = 1'b0;
	    out_to_Dm9000a_IOWR_OutData = 16'b0;
	    out_to_Dm9000a_IORD_RunStart = 1'b0;
	    out_to_Dm9000a_IORD_IndexOrData = 1'b0;
	    out_to_Dm9000a_usDelay_RunStart = 1'b1;
      out_to_Dm9000a_usDelay_DelayTime = `STD_DELAY;
    end
    GET_LENGTH:begin
	    wren_a = 1'b0;
      out_to_Dm9000a_Rx_Reset_RunStart = 1'b0;
	    out_to_Dm9000a_Ior_RunStart = 1'b0;
	    out_to_Dm9000a_Ior_iReg = 16'b0;
	    out_to_Dm9000a_IOWR_RunStart = 1'b0;
	    out_to_Dm9000a_IOWR_IndexOrData = 1'b0;
	    out_to_Dm9000a_IOWR_OutData = 16'b0;
	    out_to_Dm9000a_IORD_RunStart = 1'b1;
	    out_to_Dm9000a_IORD_IndexOrData = `IO_data;
	    out_to_Dm9000a_usDelay_RunStart = 1'b0;
      out_to_Dm9000a_usDelay_DelayTime = 11'b0;
    end
    CHECK_PKT:begin
	    wren_a = 1'b0;
      out_to_Dm9000a_Rx_Reset_RunStart = 1'b0;
	    out_to_Dm9000a_Ior_RunStart = 1'b0;
	    out_to_Dm9000a_Ior_iReg = 16'b0;
	    out_to_Dm9000a_IOWR_RunStart = 1'b0;
	    out_to_Dm9000a_IOWR_IndexOrData = 1'b0;
	    out_to_Dm9000a_IOWR_OutData = 16'b0;
	    out_to_Dm9000a_IORD_RunStart = 1'b0;
	    out_to_Dm9000a_IORD_IndexOrData = 1'b0;
	    out_to_Dm9000a_usDelay_RunStart = 1'b0;
      out_to_Dm9000a_usDelay_DelayTime = 11'b0;
    end
    RCV_AND_STORE:begin
	    wren_a = 1'b0;
      out_to_Dm9000a_Rx_Reset_RunStart = 1'b0;
	    out_to_Dm9000a_Ior_RunStart = 1'b0;
	    out_to_Dm9000a_Ior_iReg = 16'b0;
	    out_to_Dm9000a_IOWR_RunStart = 1'b0;
	    out_to_Dm9000a_IOWR_IndexOrData = 1'b0;
	    out_to_Dm9000a_IOWR_OutData = 16'b0;
	    out_to_Dm9000a_IORD_RunStart = 1'b0;
	    out_to_Dm9000a_IORD_IndexOrData = 1'b0;
	    out_to_Dm9000a_usDelay_RunStart = 1'b0;
      out_to_Dm9000a_usDelay_DelayTime = 11'b0;
    end
    DELAY3:begin
	    wren_a = 1'b0;
      out_to_Dm9000a_Rx_Reset_RunStart = 1'b0;
	    out_to_Dm9000a_Ior_RunStart = 1'b0;
	    out_to_Dm9000a_Ior_iReg = 16'b0;
	    out_to_Dm9000a_IOWR_RunStart = 1'b0;
	    out_to_Dm9000a_IOWR_IndexOrData = 1'b0;
	    out_to_Dm9000a_IOWR_OutData = 16'b0;
	    out_to_Dm9000a_IORD_RunStart = 1'b0;
	    out_to_Dm9000a_IORD_IndexOrData = 1'b0;
	    out_to_Dm9000a_usDelay_RunStart = 1'b1;
      out_to_Dm9000a_usDelay_DelayTime = `STD_DELAY;
    end
    RCV_ONE:begin
	    wren_a = 1'b0;
      out_to_Dm9000a_Rx_Reset_RunStart = 1'b0;
	    out_to_Dm9000a_Ior_RunStart = 1'b0;
	    out_to_Dm9000a_Ior_iReg = 16'b0;
	    out_to_Dm9000a_IOWR_RunStart = 1'b0;
	    out_to_Dm9000a_IOWR_IndexOrData = 1'b0;
	    out_to_Dm9000a_IOWR_OutData = 16'b0;
	    out_to_Dm9000a_IORD_RunStart = 1'b1;
	    out_to_Dm9000a_IORD_IndexOrData = `IO_data;
	    out_to_Dm9000a_usDelay_RunStart = 1'b0;
      out_to_Dm9000a_usDelay_DelayTime = 11'b0;
    end
    LOW_BYTE:begin
	    wren_a = 1'b1;
      out_to_Dm9000a_Rx_Reset_RunStart = 1'b0;
	    out_to_Dm9000a_Ior_RunStart = 1'b0;
	    out_to_Dm9000a_Ior_iReg = 16'b0;
	    out_to_Dm9000a_IOWR_RunStart = 1'b0;
	    out_to_Dm9000a_IOWR_IndexOrData = 1'b0;
	    out_to_Dm9000a_IOWR_OutData = 16'b0;
	    out_to_Dm9000a_IORD_RunStart = 1'b0;
	    out_to_Dm9000a_IORD_IndexOrData = 1'b0;
	    out_to_Dm9000a_usDelay_RunStart = 1'b0;
      out_to_Dm9000a_usDelay_DelayTime = 11'b0;
    end
    HIGH_BYTE:begin
	    wren_a = 1'b1;
      out_to_Dm9000a_Rx_Reset_RunStart = 1'b0;
	    out_to_Dm9000a_Ior_RunStart = 1'b0;
	    out_to_Dm9000a_Ior_iReg = 16'b0;
	    out_to_Dm9000a_IOWR_RunStart = 1'b0;
	    out_to_Dm9000a_IOWR_IndexOrData = 1'b0;
	    out_to_Dm9000a_IOWR_OutData = 16'b0;
	    out_to_Dm9000a_IORD_RunStart = 1'b0;
	    out_to_Dm9000a_IORD_IndexOrData = 1'b0;
	    out_to_Dm9000a_usDelay_RunStart = 1'b0;
      out_to_Dm9000a_usDelay_DelayTime = 11'b0;
    end
    DONE:begin
	    wren_a = 1'b0;
      out_to_Dm9000a_Rx_Reset_RunStart = 1'b0;
	    out_to_Dm9000a_Ior_RunStart = 1'b0;
	    out_to_Dm9000a_Ior_iReg = 16'b0;
	    out_to_Dm9000a_IOWR_RunStart = 1'b0;
	    out_to_Dm9000a_IOWR_IndexOrData = 1'b0;
	    out_to_Dm9000a_IOWR_OutData = 16'b0;
	    out_to_Dm9000a_IORD_RunStart = 1'b0;
	    out_to_Dm9000a_IORD_IndexOrData = 1'b0;
	    out_to_Dm9000a_usDelay_RunStart = 1'b0;
      out_to_Dm9000a_usDelay_DelayTime = 11'b0;
    end
    RCV_NOT_STORE:begin
	    wren_a = 1'b0;
      out_to_Dm9000a_Rx_Reset_RunStart = 1'b0;
	    out_to_Dm9000a_Ior_RunStart = 1'b0;
	    out_to_Dm9000a_Ior_iReg = 16'b0;
	    out_to_Dm9000a_IOWR_RunStart = 1'b0;
	    out_to_Dm9000a_IOWR_IndexOrData = 1'b0;
	    out_to_Dm9000a_IOWR_OutData = 16'b0;
	    out_to_Dm9000a_IORD_RunStart = 1'b0;
	    out_to_Dm9000a_IORD_IndexOrData = 1'b0;
	    out_to_Dm9000a_usDelay_RunStart = 1'b0;
      out_to_Dm9000a_usDelay_DelayTime = 11'b0;
    end
    DELAY4:begin
	    wren_a = 1'b0;
      out_to_Dm9000a_Rx_Reset_RunStart = 1'b0;
	    out_to_Dm9000a_Ior_RunStart = 1'b0;
	    out_to_Dm9000a_Ior_iReg = 16'b0;
	    out_to_Dm9000a_IOWR_RunStart = 1'b0;
	    out_to_Dm9000a_IOWR_IndexOrData = 1'b0;
	    out_to_Dm9000a_IOWR_OutData = 16'b0;
	    out_to_Dm9000a_IORD_RunStart = 1'b0;
	    out_to_Dm9000a_IORD_IndexOrData = 1'b0;
	    out_to_Dm9000a_usDelay_RunStart = 1'b1;
      out_to_Dm9000a_usDelay_DelayTime = `STD_DELAY;
    end
    RCV_DUMMY:begin
	    wren_a = 1'b0;
      out_to_Dm9000a_Rx_Reset_RunStart = 1'b0;
	    out_to_Dm9000a_Ior_RunStart = 1'b0;
	    out_to_Dm9000a_Ior_iReg = 16'b0;
	    out_to_Dm9000a_IOWR_RunStart = 1'b0;
	    out_to_Dm9000a_IOWR_IndexOrData = 1'b0;
	    out_to_Dm9000a_IOWR_OutData = 16'b0;
	    out_to_Dm9000a_IORD_RunStart = 1'b1;
	    out_to_Dm9000a_IORD_IndexOrData = `IO_data;
	    out_to_Dm9000a_usDelay_RunStart = 1'b0;
      out_to_Dm9000a_usDelay_DelayTime = 11'b0;
    end
    ERROR:begin
	    wren_a = 1'b0;
      out_to_Dm9000a_Rx_Reset_RunStart = 1'b0;
	    out_to_Dm9000a_Ior_RunStart = 1'b0;
	    out_to_Dm9000a_Ior_iReg = 16'b0;
	    out_to_Dm9000a_IOWR_RunStart = 1'b0;
	    out_to_Dm9000a_IOWR_IndexOrData = 1'b0;
	    out_to_Dm9000a_IOWR_OutData = 16'b0;
	    out_to_Dm9000a_IORD_RunStart = 1'b0;
	    out_to_Dm9000a_IORD_IndexOrData = 1'b0;
	    out_to_Dm9000a_usDelay_RunStart = 1'b0;
      out_to_Dm9000a_usDelay_DelayTime = 11'b0;
    end
    RESET:begin
	    wren_a = 1'b0;
      out_to_Dm9000a_Rx_Reset_RunStart = 1'b1;
	    out_to_Dm9000a_Ior_RunStart = 1'b0;
	    out_to_Dm9000a_Ior_iReg = 16'b0;
	    out_to_Dm9000a_IOWR_RunStart = 1'b0;
	    out_to_Dm9000a_IOWR_IndexOrData = 1'b0;
	    out_to_Dm9000a_IOWR_OutData = 16'b0;
	    out_to_Dm9000a_IORD_RunStart = 1'b0;
	    out_to_Dm9000a_IORD_IndexOrData = 1'b0;
	    out_to_Dm9000a_usDelay_RunStart = 1'b0;
      out_to_Dm9000a_usDelay_DelayTime = 11'b0;
    end
    default:begin
	    wren_a = 1'b0;
      out_to_Dm9000a_Rx_Reset_RunStart = 1'b0;
	    out_to_Dm9000a_Ior_RunStart = 1'b0;
	    out_to_Dm9000a_Ior_iReg = 16'b0;
	    out_to_Dm9000a_IOWR_RunStart = 1'b0;
	    out_to_Dm9000a_IOWR_IndexOrData = 1'b0;
	    out_to_Dm9000a_IOWR_OutData = 16'b0;
	    out_to_Dm9000a_IORD_RunStart = 1'b0;
	    out_to_Dm9000a_IORD_IndexOrData = 1'b0;
	    out_to_Dm9000a_usDelay_RunStart = 1'b0;
      out_to_Dm9000a_usDelay_DelayTime = 11'b0;
    end
  endcase
end
//�ؼ��ֵĶ�ȡ��Ϊ�ж�����
reg [15:0] ver_len;             //ip���İ汾���ײ����Ⱥͷ�������   
reg [15:0] Ip_length;           //ip�����ܳ���
reg [7:0] Ip_protocol;          //�ж�ipЭ���Ƿ�Ϊicmp��udp�������Ĳ�Ҫ
reg [15:0] Ping_protocol;       //��icmpЭ��Ļ������ж��Ƿ�ΪPingЭ��
reg [15:0] Port_dest;           //UDPĿ�Ķ˿�
reg [15:0] Udp_payload;         //udp�����û����ݣ�ֻ�е�һ��
reg [15:0] Tmp1,Tmp2,Tmp3,Tmp4,Tmp5,Tmp6;
reg [15:0] Arp_OP;              //arp��������1:����2Ӧ��
always @ (posedge iDm9000aClk , negedge iRunStart) begin
	if(~iRunStart) begin
		MAC_pc <= 48'b0;
		Ether_Type <= 16'b0;
		ver_len <= 16'd0;
		Ip_length <= 16'd0;
		Ip_protocol <= 8'b0;
		Ping_protocol <= 16'b0;
		Port_dest <= 16'b0;
		Udp_payload <= 16'b0;	
		Tmp1 <= 16'b0;
		Tmp2 <= 16'b0;
		Tmp3 <= 16'b0;
		Tmp4 <= 16'b0;
		Tmp5 <= 16'b0;
		Tmp6 <= 16'b0;
		Arp_OP <= 16'b0;
	end
	else begin
		case(cnt)
		11'h008:MAC_pc[47:32] <= Buffer;    //�������MAC
		11'h00a:MAC_pc[31:16] <= Buffer;    //�������MAC
		11'h00c:MAC_pc[15:0] <= Buffer;     //�������MAC
		11'h00e:Ether_Type <= Buffer;       //������0806��0800Ӧ��ȥ
		11'h010:ver_len <= Buffer;          //ip�汾���ײ����ȷ�������
		11'h012:Ip_length <= Buffer;        //ip�����ܳ���
		11'h018:Ip_protocol <= Buffer[7:0]; //������01 ICMP�� 17 UDPӦ��ȥ��������4�ֽ�ѡ��		
		11'h016:Arp_OP <= Buffer;           //arp��������0������1Ӧ��
		11'h01c:Tmp1 <= Buffer;
		11'h01e:Tmp2 <= Buffer; 
		11'h020:Tmp3 <= Buffer;  
	  11'h022:Tmp4 <= Buffer; 
		11'h024:Ping_protocol <= Buffer;    //����⵽��Ping����0800�������PingӦ������0000
		11'h026:Port_dest <= Buffer;        //Ŀ�Ķ˿ڸ�ֵ
		11'h028:Tmp5 <= Buffer;             //ping����ʾ��,��Ŀ��ip��ַ
		11'h02a:Tmp6 <= Buffer;             //Ping�����к�,��Ŀ��ip��ַ
		11'h02c:Udp_payload <= Buffer;      //UDPֻ��һ���֣���λ�������������� 
		default:begin//����סֵ
				MAC_pc <= MAC_pc;
				Ether_Type <= Ether_Type;
				ver_len <= ver_len; //ip�汾���ײ����ȷ�������
				Ip_length <= Ip_length; //ip�����ܳ���				
				Ip_protocol <= Ip_protocol;
				Ping_protocol <= Ping_protocol;
				Port_dest <= Port_dest;
				Udp_payload <= Udp_payload;							
				Tmp1 <= Tmp1;
				Tmp2 <= Tmp2;
				Tmp3 <= Tmp3;
				Tmp4 <= Tmp4;
				Tmp5 <= Tmp5;
				Tmp6 <= Tmp6;
				Arp_OP <= Arp_OP;
				end
		endcase
	end
end
wire [15:0] fragment_info;
assign fragment_info = Arp_OP;
wire [15:0] Port_src;
assign Port_src = Ping_protocol;
/*******************Ӧ���ж�*****************************/
always @ (posedge iDm9000aClk , negedge iRunStart) begin
	if(~iRunStart) begin
		IP_totallength <= 16'b0;
		IP_proto <= 8'b0;
		IP_pc <= 32'b0;
		Arp_Request <= 1'b0;
		Ping_Request <= 1'b0;
		Ping_id <= 16'd0;
		Ping_sn <= 16'd0;
		Ping_len <= 16'd0;		
		Udp_Request <= 1'b0;
		Port_pc <= 16'd0;
		Control_word <= 16'd0;
	end
  else begin
    case(Ether_Type)
      `ARP_PKT:begin        //����ARP������Ҫ�ж��Ƿ���arp�����ź���Ҫ�Ա�Ŀ��IP�Ƿ�ΪDm9000a��ip
        if(({Tmp5,Tmp6} == `IP_addr) && (Arp_OP == `ARP_REQ_SIG)) begin//���arpӦ�������źţ�������MAC��ip
          Arp_Request <= 1'b1; //���Arp����
          IP_pc <= {Tmp2,Tmp3};//�����λ��ip
        end
        else begin     //���ǶԱ���arpѯ��
          Arp_Request <= 1'b0;
        end
      end
      `IP_PKT:begin //����IP������Ҫ�ж���ICMP����UDP��
        if((ver_len[15:8] == 8'h45) && (!((fragment_info[15:8] & 8'h3f) || (fragment_info[7:0] & 8'hff))))begin//������ipv4��ipͷ���Ȳ���20�ֽ��� ����
          case(Ip_protocol)
						`ICMP_PKT:begin //����ICMP����Ҫ�ж��Ƿ�ΪPing��,�ұȶ��Ƿ��Dm9000a ip����ping
              if((Ping_protocol == `Ping_PKT_Request) &&({Tmp3,Tmp4} == `IP_addr)) begin //��Ϊ�������������PingӦ������,IpheadeӦ��
                IP_totallength <= Ip_length;//IP���ĳ���
                IP_proto <= `ICMP_PKT;//ICMPЭ��
                IP_pc <= {Tmp1,Tmp2};//��λ��IP
                //Ping��Ӧ��	
                Ping_Request <= 1'b1;
                Ping_id <= Tmp5;
                Ping_sn <= Tmp6;
                Ping_len <= Ip_length-5'd20; //ping�������ݶγ���
              end
              else  begin //���ǻ������������Ա���
                Ping_Request <= 1'b0;
              end
            end
            `UDP_PKT:begin//����UDP������Ҫ�ж����ݰ��еĶ˿��ֶ��Ƿ����Ѷ�������ݽ��ն˿�
              if(Port_dest == `DM9000A_Port) begin //���˿ڷ������ȡ��Ч����
                IP_totallength <= 16'd46;  //IP���ĳ���Ϊ46�ֽ�
                IP_proto <= `UDP_PKT;    //UDPЭ��
                IP_pc <= {Tmp1,Tmp2};//���IP��ַ
                //Udp��Ӧ��
                Udp_Request <= 1'b1;
                Port_pc <= Port_src;              //���Դ�˿�
                Control_word <= Udp_payload;//����û�����
              end
              else begin
                Udp_Request <= 1'b0;
              end
            end 
						default:begin //��IP��������ICMP����UDP��������ΪTCP����
            Ping_Request <= 1'b0;
            Udp_Request <= 1'b0;
          end
        endcase
      end
      else begin
        Ping_Request <= 1'b0;
        Udp_Request <= 1'b0;
      end
    end
    default:begin //����arp������ip��Ӧ�������
    Arp_Request <= 1'b0;
    Ping_Request <= 1'b0;
    Udp_Request <= 1'b0;
    end
  endcase
end
end
/*******************************************************/
function [15:0] Swap(input [15:0] num);  //swap high byte and low byte
	begin: swap
	Swap = ( (num & 16'h00ff) << 8 ) | ((num & 16'hff00) >> 8 );
	end
endfunction
/*************************************************************************/
 endmodule 

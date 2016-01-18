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
	output reg Rx_Done,//正确封包
	output reg oError,  //错误封包
	//protocol output
	output reg [47:0] MAC_pc,//pc机的MAC地址
	output reg [15:0] Ether_Type,//帧类型
	
	output reg Arp_Request, //启动arp应答
	output reg [31:0] IP_pc,    //pc机的IP地址
	
	output reg [15:0]IP_totallength,//ip报文长度
	output reg [7:0] IP_proto,    //ip协议
	
	output reg Ping_Request,//启动ping应答
	output reg [15:0] Ping_id, //Ping包的标示符
	output reg [15:0] Ping_sn,//Ping包的序列号	
	output reg [15:0] Ping_len,//Ping报文长度
	
	output reg Udp_Request,//启动udp应答
	output reg [15:0] Port_pc,  //Udp pc端口
	output reg [15:0] Control_word, //Udp用户数据

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
wire Packet_good; //完好的包
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
        * 仅仅是方便阅读，不可取消注释在此使用
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
          rx_READY <= in_from_Dm9000a_Ior_ReturnValue[7:0];//这个数据读进来有什么用途？
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
          rx_READY <= in_from_Dm9000a_IORD_ReturnValue[7:0] & 8'h03;//8'h03 = 8'b0000_0011,只要最后两位
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
//关键字的读取作为判定依据
reg [15:0] ver_len;             //ip报文版本号首部长度和服务类型   
reg [15:0] Ip_length;           //ip报文总长度
reg [7:0] Ip_protocol;          //判断ip协议是否为icmp或udp，其他的不要
reg [15:0] Ping_protocol;       //在icmp协议的基础上判断是否为Ping协议
reg [15:0] Port_dest;           //UDP目的端口
reg [15:0] Udp_payload;         //udp包的用户数据，只有第一个
reg [15:0] Tmp1,Tmp2,Tmp3,Tmp4,Tmp5,Tmp6;
reg [15:0] Arp_OP;              //arp操作类型1:请求，2应答
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
		11'h008:MAC_pc[47:32] <= Buffer;    //获得主机MAC
		11'h00a:MAC_pc[31:16] <= Buffer;    //获得主机MAC
		11'h00c:MAC_pc[15:0] <= Buffer;     //获得主机MAC
		11'h00e:Ether_Type <= Buffer;       //若不是0806和0800应舍去
		11'h010:ver_len <= Buffer;          //ip版本号首部长度服务类型
		11'h012:Ip_length <= Buffer;        //ip报文总长度
		11'h018:Ip_protocol <= Buffer[7:0]; //若不是01 ICMP和 17 UDP应舍去，不包含4字节选项		
		11'h016:Arp_OP <= Buffer;           //arp操作类型0：请求，1应答
		11'h01c:Tmp1 <= Buffer;
		11'h01e:Tmp2 <= Buffer; 
		11'h020:Tmp3 <= Buffer;  
	  11'h022:Tmp4 <= Buffer; 
		11'h024:Ping_protocol <= Buffer;    //若检测到是Ping请求0800，则输出Ping应答请求0000
		11'h026:Port_dest <= Buffer;        //目的端口赋值
		11'h028:Tmp5 <= Buffer;             //ping包标示符,或目的ip地址
		11'h02a:Tmp6 <= Buffer;             //Ping包序列号,或目的ip地址
		11'h02c:Udp_payload <= Buffer;      //UDP只有一个字，上位机发过来的命令 
		default:begin//保存住值
				MAC_pc <= MAC_pc;
				Ether_Type <= Ether_Type;
				ver_len <= ver_len; //ip版本号首部长度服务类型
				Ip_length <= Ip_length; //ip报文总长度				
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
/*******************应答判定*****************************/
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
      `ARP_PKT:begin        //若是ARP包，则要判断是否是arp请求信号且要对比目的IP是否为Dm9000a的ip
        if(({Tmp5,Tmp6} == `IP_addr) && (Arp_OP == `ARP_REQ_SIG)) begin//输出arp应答请求信号，请求者MAC与ip
          Arp_Request <= 1'b1; //输出Arp请求
          IP_pc <= {Tmp2,Tmp3};//输出上位机ip
        end
        else begin     //不是对本机arp询问
          Arp_Request <= 1'b0;
        end
      end
      `IP_PKT:begin //若是IP包，则要判断是ICMP或是UDP包
        if((ver_len[15:8] == 8'h45) && (!((fragment_info[15:8] & 8'h3f) || (fragment_info[7:0] & 8'hff))))begin//若不是ipv4且ip头长度不是20字节则 错误
          case(Ip_protocol)
						`ICMP_PKT:begin //若是ICMP包则要判断是否为Ping包,且比对是否对Dm9000a ip进行ping
              if((Ping_protocol == `Ping_PKT_Request) &&({Tmp3,Tmp4} == `IP_addr)) begin //若为回显请求则输出Ping应答请求,Ipheade应答
                IP_totallength <= Ip_length;//IP报文长度
                IP_proto <= `ICMP_PKT;//ICMP协议
                IP_pc <= {Tmp1,Tmp2};//上位机IP
                //Ping包应答	
                Ping_Request <= 1'b1;
                Ping_id <= Tmp5;
                Ping_sn <= Tmp6;
                Ping_len <= Ip_length-5'd20; //ping报文数据段长度
              end
              else  begin //不是回显请求或不是针对本机
                Ping_Request <= 1'b0;
              end
            end
            `UDP_PKT:begin//若是UDP包则需要判断数据包中的端口字段是否是已定义的数据接收端口
              if(Port_dest == `DM9000A_Port) begin //若端口符合则读取有效数据
                IP_totallength <= 16'd46;  //IP报文长度为46字节
                IP_proto <= `UDP_PKT;    //UDP协议
                IP_pc <= {Tmp1,Tmp2};//输出IP地址
                //Udp包应答
                Udp_Request <= 1'b1;
                Port_pc <= Port_src;              //输出源端口
                Control_word <= Udp_payload;//输出用户数据
              end
              else begin
                Udp_Request <= 1'b0;
              end
            end 
						default:begin //是IP包但不是ICMP或者UDP包，可能为TCP包等
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
    default:begin //不是arp包或者ip包应给予过滤
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

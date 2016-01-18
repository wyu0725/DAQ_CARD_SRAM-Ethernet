module dpram_and_dcfifo
(
	input iDm9000aClk,
	input in_from_Dm9000a_Rx_wren_a,
	input [7:0] in_from_Dm9000a_Rx_data_a,
	input [9:0] in_from_Dm9000a_Rx_address_a,
	
	input in_from_Arp_Ack_wren_b,
	input [7:0] in_from_Arp_Ack_data_b,
	input [9:0] in_from_Arp_Ack_address_b,
	
	input in_from_Ping_Ack_wren_b,
	input [7:0] in_from_Ping_Ack_data_b,
	input [9:0] in_from_Ping_Ack_address_b,
	
	input in_from_Udp_Ack_wren_b,
	input [7:0] in_from_Udp_Ack_data_b,
	input [9:0] in_from_Udp_Ack_address_b,
	
	input in_from_etherheader_wren_b,
	input [7:0] in_from_etherheader_data_b,
	input [9:0] in_from_etherheader_address_b,
	
	input in_from_ipheader_wren_b,
	input [7:0] in_from_ipheader_data_b,
	input [9:0] in_from_ipheader_address_b,
	
	input in_from_chksum_rden_b,
	input [9:0] in_from_chksum_address_b,
	
	input in_from_Write_Fifo_rden_a,
	input [9:0] in_from_Write_Fifo_address_a,
	
	output [7:0] dpram_q_a,
	output [7:0] dpram_q_b,
	
	input in_from_Task_Fifo_aclr,//”…TaskÃ·π©
	input in_from_Write_Fifo_wrreq,
	input [7:0] in_from_Write_Fifo_data_in,
	input in_from_Dm9000a_Tx_rdreq,
	output wrfull,
	output rdempty,
	output [15:0] Fifo_data_out
	
);
wire wren_a;
wire [7:0] data_a;
wire [9:0] address_a;
wire wren_b;
wire [7:0] data_b;
wire [9:0] address_b;
wire rden_a;
wire rden_b;
//assignment
assign wren_a = in_from_Dm9000a_Rx_wren_a;
assign data_a = in_from_Dm9000a_Rx_data_a;
assign address_a = in_from_Dm9000a_Rx_address_a | in_from_Write_Fifo_address_a;
assign wren_b = in_from_Arp_Ack_wren_b | in_from_Ping_Ack_wren_b | in_from_Udp_Ack_wren_b | in_from_etherheader_wren_b | in_from_ipheader_wren_b;
assign data_b = in_from_Arp_Ack_data_b | in_from_Ping_Ack_data_b | in_from_Udp_Ack_data_b | in_from_etherheader_data_b| in_from_ipheader_data_b;
assign address_b = in_from_Arp_Ack_address_b | in_from_Ping_Ack_address_b | in_from_Udp_Ack_address_b 
					| in_from_etherheader_address_b | in_from_ipheader_address_b | in_from_chksum_address_b;
assign rden_a = in_from_Write_Fifo_rden_a;
assign rden_b = in_from_chksum_rden_b;
dpram DPRAM
(
	.inclock(~iDm9000aClk),
	.wren_a(wren_a),
	.address_a(address_a),	
	.data_a(data_a),
	
	.wren_b(wren_b),
	.address_b(address_b),
	.data_b(data_b),
	
	.outclock(~iDm9000aClk),
	.rden_a(rden_a),
	.q_a(dpram_q_a),
	.rden_b(rden_b),
	.q_b(dpram_q_b)		
);
wire aclr;
wire wrreq;
wire [7:0] data;
wire rdreq;
//assignment
assign aclr = in_from_Task_Fifo_aclr;
assign wrreq  = in_from_Write_Fifo_wrreq;
assign data = in_from_Write_Fifo_data_in;
assign rdreq = in_from_Dm9000a_Tx_rdreq;
dcmixfifo DCMIXFIFO
(
	.aclr(aclr),
	.wrclk(iDm9000aClk),
	.wrreq(wrreq),
	.data(data),
	
	.rdclk(iDm9000aClk),
	.rdreq(rdreq),
	.q(Fifo_data_out),
	
	.rdempty(rdempty),
	.wrfull(wrfull)
);
endmodule 
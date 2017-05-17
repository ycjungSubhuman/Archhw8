`timescale 1ns/1ns
`define WORD_SIZE 16    // data and address word size
`include "Datapath.v"
`include "Cache.v"

module cpu(Clk, Reset_N, i_readM, i_address, i_data, d_readM, d_writeM, d_address, d_data, num_inst, output_port, is_halted, complete1, complete2);
	input Clk;
	wire Clk;
	input Reset_N;
	wire Reset_N;
	input complete1;
	input complete2;

	// Instruction memory interface
	output i_readM;
	wire i_readM;
	wire i_writeM;
	assign i_writeM = 0;
	output [`WORD_SIZE-1:0] i_address;
	wire [`WORD_SIZE-1:0] i_address;

	inout [`WORD_SIZE-1:0] i_data;
	wire [`WORD_SIZE-1:0] i_data;

	//assign i_data = 16'bz;

	// Data memory interface
	output d_readM;
	wire d_readM;
	output d_writeM;
	wire d_writeM;
	output [`WORD_SIZE-1:0] d_address;
	wire [`WORD_SIZE-1:0] d_address;

	inout [`WORD_SIZE-1:0] d_data;
	wire [`WORD_SIZE-1:0] d_data;

	output [`WORD_SIZE-1:0] num_inst;
	reg [`WORD_SIZE-1:0] num_inst;
	output [`WORD_SIZE-1:0] output_port;
	wire [`WORD_SIZE-1:0] output_port;
	output is_halted;
	wire is_halted;

	initial num_inst = -2;
	wire stalled;
	wire flushed;
	wire valid;

	wire complete1;
	wire complete2;
	wire MEM_WB_Write;

    Datapath dpath (
		.readM1(i_readM), .address1(i_address), .data1(i_data),
		.readM2(d_readM), .writeM2(d_writeM), .address2(d_address), .data2(d_data),
		.reset_n(Reset_N), .clk(Clk), .output_port(output_port), .is_halted(is_halted), .stalled(stalled), .flushed(flushed), .valid(valid), .complete1(complete1), .complete2(complete2), .MEM_WB_Write(MEM_WB_Write));

		cache cachee (
			.address1(i_address), .data1(i_data), .readM1(i_readM), .address2(d_address), .data2(d_data), .readM2(d_readM), .writeM2(d_writeM),
			.complete1(complete1), .complete2(complete2), .clk(Clk), .reset_n(Reset_N)
			);

	always@(posedge Clk) begin
		//assert(stalled & flushed ==0);
		//$display("+++++++++++++++valid %x numinst was ", valid);
		if(valid && MEM_WB_Write) begin
			num_inst += 1;
		end
	//else $display("SKIPPING");
		//$display("Complete1, 2: %x, %x", complete1, complete2);
	end

endmodule

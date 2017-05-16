`include "opcodes.v"

module Stage1(PcUpdateTarget, PCMux, Pc, PcWrite, inst, readM, address, data, clk, reset_n);
	input [`WORD_SIZE-1:0] PcUpdateTarget;
	output [`WORD_SIZE-1:0] Pc;
	output reg [`WORD_SIZE-1:0] inst;
	output reg readM;
	output reg [`WORD_SIZE-1:0] address;
	inout [`WORD_SIZE-1:0] data;
	input PcWrite;
	input PCMux;
	assign data = 16'bz;
	input clk;
	input reset_n;
	
	reg [`WORD_SIZE-1:0] internalPc;
	
	initial begin
		internalPc = -1;
		readM = 0;
	end
	
	assign Pc = internalPc + 1;
	
	always @(data) begin
		inst = data;
		$display("inst: %x, address: %x", inst, address);
	end
	
	always @(posedge clk) begin
		//$display("inst: %x, address: %x", inst, address);
		if(PcWrite) begin
			internalPc = PCMux ? PcUpdateTarget : Pc;
			readM = 1;
		end
		else readM = 0;
		address = internalPc;
		
		//$display("Stage1: PCWrite: %x, InternalPC: %x, PCMux: %x", PcWrite,internalPc, PCMux);
		
		if(!reset_n) begin
			internalPc = -1;
			readM = 0;
		end
	end
	
endmodule
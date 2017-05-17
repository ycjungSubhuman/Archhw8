`include "opcodes.v"

module RegisterFiles(ctrlRegWrite, readReg1, readReg2, writeReg, writeData, clk, reset_n, readData1, readData2);	 
	input ctrlRegWrite;
	input [1:0] readReg1;
	input [1:0] readReg2;	
	input [1:0] writeReg;
	input [`WORD_SIZE-1:0] writeData; 
	input clk;														
	input reset_n;														
	output reg [`WORD_SIZE-1:0] readData1;
	output reg [`WORD_SIZE-1:0] readData2; 
																					 
	reg [`WORD_SIZE-1:0] registers[`NUM_REGS-1:0];
	reg readData1_nxt, readData2_nxt;
	
	initial begin
		registers[0] = 0;
		registers[1] = 0;
		registers[2] = 0;
		registers[3] = 0;
	end
	
	always @(*) begin
		if(writeReg == readReg1 && ctrlRegWrite)
			readData1 = writeData;
		else
			readData1 = registers[readReg1];
		if(writeReg == readReg2 && ctrlRegWrite)
			readData2 = writeData;
		else
			readData2 = registers[readReg2];
		$display("r0: %x, r1: %x, r2: %x, r3: %x", registers[0], registers[1], registers[2], registers[3]);;
	end
	
	always @(posedge clk) begin
		if(ctrlRegWrite) registers[writeReg] = writeData;
		//registers[0] = 0;

	end	
	  
endmodule
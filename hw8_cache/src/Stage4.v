`include "opcodes.v"

module Stage4(EX_MEM_Write, Pc,
	ALUOut, RegWriteTarget, MemWriteData,
	PcVal, MemData, ALUOut_OUT, RegWriteTarget_OUT,
	MemRead, MemWrite, Valid, OutputData,
	RegWriteSrc, RegWrite, IsHalted, PCMux, IsFlush_OUT, Valid_OUT,
	RegWriteSrc_OUT, RegWrite_OUT, MEM_RegWriteData, IsHalted_OUT, OutputData_OUT,
	readM, writeM, address, data,
	clk, reset_n
	);
	//Data inout
	input EX_MEM_Write;
	input [`WORD_SIZE-1:0] Pc;
	input [`WORD_SIZE-1:0] ALUOut;
	input [1:0] RegWriteTarget;
	input [`WORD_SIZE-1:0] MemWriteData;
	output [`WORD_SIZE-1:0] PcVal;
	assign PcVal = Pc_REG;
	output reg [`WORD_SIZE-1:0] MemData;
	output [`WORD_SIZE-1:0] ALUOut_OUT;

	input Valid;
	output Valid_OUT;
	assign Valid_OUT = Valid_REG;
	input [`WORD_SIZE-1:0] OutputData;
	output [`WORD_SIZE-1:0] OutputData_OUT;
	assign OutputData_OUT = OutputData_REG;

	output [1:0] RegWriteTarget_OUT;
	output [1:0] RegWriteSrc_OUT;
	output RegWrite_OUT;
	output [`WORD_SIZE-1:0] MEM_RegWriteData;
	input PCMux;
	output IsFlush_OUT;

	input clk;
	input reset_n;

	//MEM Control Signals
	input MemRead;
	input MemWrite;

	//WB Control Signals
	input [1:0] RegWriteSrc;
	input RegWrite;
	input IsHalted;
	output IsHalted_OUT;

	//Control transfer

	assign RegWriteSrc_OUT = RegWriteSrc_REG;
	assign RegWrite_OUT = RegWrite_REG;
	assign ALUOut_OUT = ALUOut_REG;
	assign RegWriteTarget_OUT = RegWriteTarget_REG;
	assign IsHalted_OUT = IsHalted_REG;

	//Memory Communication
	output reg readM;
	output reg writeM;
	output reg [`WORD_SIZE-1:0] address;
	inout [`WORD_SIZE-1:0] data;
	reg [`WORD_SIZE-1:0] writeBuf;
	assign data = (writeM) ? writeBuf : 16'bz;

	//internal Register(EX/MEM)
	reg [`WORD_SIZE-1:0] Pc_REG;
	reg [`WORD_SIZE-1:0] ALUOut_REG;
	reg [1:0] RegWriteTarget_REG;
	reg [`WORD_SIZE-1:0] MemWriteData_REG;
	//MEM Control Signals
	reg MemRead_REG;
	reg MemWrite_REG;
	//WB Control Signals
	reg [1:0] RegWriteSrc_REG;
	reg RegWrite_REG;
	reg IsHalted_REG;
	reg PCMux_REG;
	reg Valid_REG;
	reg [`WORD_SIZE-1:0] OutputData_REG;

	assign ALUOut_OUT = ALUOut_REG;
	assign MEM_RegWriteData = ALUOut_REG;
	assign RegWriteSrc_OUT = RegWriteSrc_REG;
	assign RegWrite_OUT = RegWrite_REG;
	assign IsFlush_OUT = PCMux_REG;

	initial begin
	end

	always@(*) begin
		//$display("READDATA: %x ADDRESS: %x,", data, address);
		//if(IsFlush_OUT) $display("))))))))))))))))))))))))) PC+1: %x", Pc_REG);
		MemData = data;
	end

	always@(posedge clk) begin
		//Update Register values
		if(EX_MEM_Write) begin
			Pc_REG = Pc;
			ALUOut_REG = ALUOut;
			RegWriteTarget_REG = RegWriteTarget;
			MemWriteData_REG = MemWriteData;
			MemRead_REG = MemRead;
			MemWrite_REG = MemWrite;
			RegWriteSrc_REG = RegWriteSrc;
			RegWrite_REG = RegWrite;
			IsHalted_REG = IsHalted;
			PCMux_REG = PCMux; 
			$display("))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))PCMux_REG: %x", PCMux_REG);
			Valid_REG = Valid;
			OutputData_REG = OutputData;
		end

		address = ALUOut_REG;
		

		if(MemRead_REG == 1 || writeM == 1) begin
			readM = 1;
			writeM = 0;
		end
		else if (MemWrite_REG == 1) begin
			writeM = 1;
			readM = 0;
			writeBuf = MemWriteData;
		end
	   	if(!EX_MEM_Write) begin
			readM = 0;
			writeM = 0;
		end
		if(readM) $display("*******READ START*******");
		if(writeM) $display("*******WRITE START*******at %x data: %x", address, writeBuf);
		if(!reset_n) begin
			Pc_REG = Pc;
			ALUOut_REG = 0;
			RegWriteTarget_REG = 0;
			MemWriteData_REG = 0;
			MemRead_REG = 0;
			MemWrite_REG = 0;
			RegWriteSrc_REG = 0;
			RegWrite_REG = 0;
			IsHalted_REG = 0;
			PCMux_REG = 0;
			readM = 0;
			writeM = 0;
			Valid_REG = 0;
			address = 0;
			OutputData_REG = 0;
		end
	end

endmodule

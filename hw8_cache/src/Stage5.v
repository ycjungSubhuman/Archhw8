`include "opcodes.v"

module Stage5(MEM_WB_Write, Pc,
	ALUOut, RegWriteTarget, MemData, IsHalted,
	WriteData, RegWriteTarget_OUT,
	RegWriteSrc, RegWrite, Valid, OutputData,
	RegWrite_OUT, IsHalted_OUT, Valid_OUT, OutputData_OUT,
	clk, reset_n
	);
	//Data inout
	input MEM_WB_Write;
	input [`WORD_SIZE-1:0] Pc;
	input [`WORD_SIZE-1:0] ALUOut;
	input [1:0] RegWriteTarget;
	input [`WORD_SIZE-1:0] MemData;
	output reg [`WORD_SIZE-1:0] WriteData;
	output reg [1:0] RegWriteTarget_OUT;
	input IsHalted;
	input clk;
	input reset_n;

	input Valid;
	output Valid_OUT;
	assign Valid_OUT = Valid_REG;

	input [`WORD_SIZE-1:0] OutputData;
	output [`WORD_SIZE-1:0] OutputData_OUT;
	assign OutputData_OUT = OutputData_REG;

	//WB Control Signals
	input [1:0] RegWriteSrc;
	input RegWrite;
	output IsHalted_OUT;
	assign IsHalted_OUT = IsHalted_REG;

	//Control transfer
	output RegWrite_OUT;
	assign RegWrite_OUT = RegWrite_REG;
	assign RegWriteTarget_OUT = RegWriteTarget_REG;

	//internal Register(EX/MEM)
	reg [`WORD_SIZE-1:0] Pc_REG;
	reg [`WORD_SIZE-1:0] ALUOut_REG;
	reg [1:0] RegWriteTarget_REG;
	reg [`WORD_SIZE-1:0] MemData_REG;
	//WB Control Signals
	reg [1:0] RegWriteSrc_REG;
	reg RegWrite_REG;
	reg IsHalted_REG;
	reg Valid_REG;
	reg [`WORD_SIZE-1:0] OutputData_REG;

	always @(*) begin
		if(RegWriteSrc_REG == 0) WriteData = ALUOut_REG;
		else if(RegWriteSrc_REG == 1) WriteData = MemData_REG;
		else if(RegWriteSrc_REG == 2) WriteData = Pc_REG;
	end

	always @(posedge clk) begin

		if(MEM_WB_Write) begin
			Pc_REG = Pc;
			ALUOut_REG = ALUOut;
			RegWriteTarget_REG = RegWriteTarget;
			MemData_REG = MemData;
			RegWriteSrc_REG = RegWriteSrc;
			RegWrite_REG = RegWrite;
			IsHalted_REG = IsHalted;
			Valid_REG = Valid;
			OutputData_REG = OutputData;
		end

		if(!reset_n) begin
			Valid_REG = 0;
			OutputData_REG = 0;
		end
	end

endmodule

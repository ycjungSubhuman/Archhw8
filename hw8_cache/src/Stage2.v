`include "opcodes.v"
`include "Control.v"
`include "register_files.v"

module Stage2(Pc, inst,
	ReadData1, ReadData2, ImmediateExtended, Rs, Rt, Rd, PcVal,
	ALUOp, ALUSrc, OutputPortWrite, IsLHI, RegDest,
	MemRead, MemWrite,
	RegWriteSrc, RegWrite, IsBranch, IsJump, BranchProperty, IsJumpReg,
	WB_RegWriteData, WB_WriteReg, WB_RegWrite,
	IF_ID_Write, InsertBubble, IsFlush, BranchTarget, Valid, JumpTargetAddr,
	IsHalted, clk, reset_n
	);
	//Data inout
	input [`WORD_SIZE-1:0] Pc;
	input [`WORD_SIZE-1:0] inst;
	output [`WORD_SIZE-1:0] ReadData1;
	output [`WORD_SIZE-1:0] ReadData2;
	output reg [`WORD_SIZE-1:0] ImmediateExtended;
	output reg [1:0] Rs;
	output reg [1:0] Rt;
	output reg [1:0] Rd;
	output [`WORD_SIZE-1:0] PcVal;				  
	output reg IsHalted;
	assign IsHalted = (InsertBubble || IsFlush) ? 0 : _IsHalted;
	output reg [`WORD_SIZE-1:0] BranchTarget;
	assign PcVal = Pc_REG;
	input clk;
	input reset_n;
	input IsFlush;
	
	input IF_ID_Write;
	input InsertBubble;
	output Valid;
	assign Valid = !(InsertBubble || IsFlush);
	output [`WORD_SIZE-1:0] JumpTargetAddr;
	assign JumpTargetAddr = {Pc_REG[15:12], inst_REG[11:0]};
	
	//EX Control Signals
	output [2:0] ALUOp;
	output ALUSrc;
	output IsLHI;
	output [1:0] RegDest;
	output OutputPortWrite;
	assign OutputPortWrite = (InsertBubble || IsFlush) ? 0: _OutputPortWrite;
	
	//MEM Control Signals
	output MemRead;
	output MemWrite;
	assign MemRead = (InsertBubble || IsFlush)	? 0 : _MemRead;
	assign MemWrite = (InsertBubble || IsFlush)	? 0 : _MemWrite;
	
	//WB Control Signals
	output [1:0] RegWriteSrc;
	output RegWrite;
	assign RegWrite = (InsertBubble || IsFlush) ? 0: _RegWrite;
	
	//internal ID Control Signals
	output wire [1:0] BranchProperty;
	output wire IsJump;
	output wire IsBranch;
	output wire IsJumpReg;
	assign IsJump = (InsertBubble || IsFlush) ? 0: _IsJump;
	assign IsBranch = (InsertBubble || IsFlush) ? 0: _IsBranch;
	
	//internal Register(IF/ID)
	reg [`WORD_SIZE-1:0] Pc_REG;
	reg [`WORD_SIZE-1:0] inst_REG;
	
	//Write Back
	input [`WORD_SIZE-1:0] WB_RegWriteData;
	input [1:0] WB_WriteReg;
	input WB_RegWrite;							
	
	always @(*) begin
		//$display("Stage2 Rs: %x, Rt: %x, ReadData1: %x, ReadData2: %x", Rs, Rt, ReadData1, ReadData2);
		if(!InsertBubble || IsFlush) begin
			Rs = inst_REG[11:10];
			Rt = inst_REG[9:8];
			Rd = inst_REG[7:6];

			if(inst_REG[7])
				ImmediateExtended = {8'b11111111, inst_REG[7:0]};
			else
				ImmediateExtended = {8'b00000000, inst_REG[7:0]};
			BranchTarget = Pc_REG + ImmediateExtended;
			if(WB_RegWrite == 1) begin
				//$display("WB_RegWrite: %d, WB_WriteReg: %d, WB_RegWriteData: %d", WB_RegWrite, WB_WriteReg, WB_RegWriteData);
			end
		end
		else begin
		end
	end
	
	always @(posedge clk) begin
				//if(InsertBubble || IsFlush) $display("INSERTING BUBBLEEE");
		if(IF_ID_Write) begin
			Pc_REG = Pc;
			inst_REG = inst;
		end
		if(!reset_n) begin
			Pc_REG = 0;
			inst_REG = 0;
		end
	end

	wire _MemRead;
	wire _MemWrite;
	wire _RegWrite;
	wire _OutputPortWrite;
	wire _IsBranch;
	wire _IsJump;
	wire _IsHalted;
	
	RegisterFiles regfile(WB_RegWrite, Rs, Rt, WB_WriteReg, WB_RegWriteData, clk, reset_n, ReadData1, ReadData2);
	
	Control ctrl(inst_REG, 
	BranchProperty, _IsJump, _IsBranch, _OutputPortWrite, IsJumpReg, ALUOp, ALUSrc, 
	IsLHI, _MemRead, _MemWrite, RegWriteSrc, _RegWrite, RegDest, _IsHalted);
	
endmodule
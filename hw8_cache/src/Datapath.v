`include "opcodes.v"
`include "ALU.v"
`include "Stage1.v"
`include "Stage2.v"
`include "Stage3.v"
`include "Stage4.v"
`include "Stage5.v"
`include "Forward.v"
`include "Hazard.v"

module Datapath (
	readM1, address1, data1,
	readM2, writeM2, address2, data2,
	reset_n, clk, output_port, is_halted, stalled, flushed, valid, complete1, complete2, MEM_WB_Write);

	output wire readM1;
	output [`WORD_SIZE-1:0] address1;
	inout [`WORD_SIZE-1:0] data1;
	assign data1 = 16'bz;
	output stalled;
	output flushed;
	output MEM_WB_Write;

	output readM2;
	output writeM2;
	output [`WORD_SIZE-1:0] address2;
	inout [`WORD_SIZE-1:0] data2;
	output valid;
    assign valid = WB_Valid;

	input reset_n;
	input clk;
	output reg [15:0] output_port;
	output reg is_halted;

	input complete1;
	input complete2;

	always @(posedge clk) begin
		//$display("inst: %x, RegWrite_2_3: %x, RegWrite_3_4: %x, RegWrite_4_5: %x, WB_RegWrite: %x", inst, RegWrite_2_3, RegWrite_3_4, RegWrite_4_5, WB_RegWrite);
		//$display("stage 1 of %x finished : Rs:%x Rt:%x Exmemdest:%x Wbdest: %x, wb1: %x, w2, %x", inst, Rs_3_F, Rt_3_F, RegWriteTarget_4_5, WB_RegWriteTarget, RegWrite_4_5, WB_RegWrite);
	end

	//Stage1 ~ Stage2
	wire [`WORD_SIZE-1:0] PcUpdateTarget;
	wire [`WORD_SIZE-1:0] Pc_1_2;
	wire [`WORD_SIZE-1:0] inst;


	//Stage2 ~ Stage3
	wire [`WORD_SIZE-1:0] ReadData1;
	wire [`WORD_SIZE-1:0] ReadData2;
	wire [`WORD_SIZE-1:0] ImmediateExtended;
	wire [`WORD_SIZE-1:0] BranchTarget;
	wire [1:0] Rs;
	wire [1:0] Rt;
	wire [1:0] Rd;
	wire [`WORD_SIZE-1:0] Pc_2_3;
	wire [2:0] ALUOp_2_3;
	wire ALUSrc_2_3;
	wire IsLHI_2_3;
	wire [1:0] RegDest_2_3;
	wire MemRead_2_3;
	wire MemWrite_2_3;
	wire [1:0] RegWriteSrc_2_3;
	wire RegWrite_2_3;
	wire OutputPortWrite_2_3;
	wire IsHalted_2_3;
	assign stalled = InsertBubble;
	assign flushed = IsFlush;
	wire IsBranch_2_3;
	wire IsJump_2_3;
	wire [1:0] BranchProperty_2_3;
	wire IsJumpReg_2_3;
	wire Valid_2_3;
	wire [`WORD_SIZE-1:0] JumpTargetAddr_2_3;


	//Stage 5 ~ Stage2
	wire [`WORD_SIZE-1:0] WB_RegWriteData;
	wire WB_RegWrite;
	wire WB_Valid;


		//Forward ~ Stage3
	wire [1:0] ControlA;
	wire [1:0] ControlB;
	wire [1:0] Rs_3_F;
	wire [1:0] Rt_3_F;

	//Stage4 ~ Stage3
	wire [`WORD_SIZE-1:0] MEM_RegWriteData;

	//Stage3 ~ Stage4
	wire [`WORD_SIZE-1:0] Pc_3_4;
	wire [`WORD_SIZE-1:0] ALUOut_3_4;
	wire [1:0] RegWriteTarget_3_4;
	wire MemRead_3_4;
	wire MemWrite_3_4;
	wire [1:0] RegWriteSrc_3_4;
	wire RegWrite_3_4;
	wire [`WORD_SIZE-1:0] MemWriteData_3_4;
	wire IsHalted_3_4;
	wire Valid_3_4;
	wire [`WORD_SIZE-1:0] OutputData_3_4;

	wire [1:0] WB_RegWriteSrc;


	//Stage4 ~ Stage5
	wire [`WORD_SIZE-1:0] Pc_4_5;
	wire [`WORD_SIZE-1:0] MemData_4_5;
	wire [`WORD_SIZE-1:0] ALUOut_4_5;
	wire [1:0] RegWriteTarget_4_5;
	wire [1:0] RegWriteSrc_4_5;
	wire RegWrite_4_5;
	wire IsHalted_4_5;
	wire Valid_4_5;
	wire [`WORD_SIZE-1:0] OutputData_4_5;

	//Stage5 ~ Forward
	wire [1:0] WB_RegWriteTarget;

	//Hazard Detection
	wire PcWrite;
	wire IF_ID_Write;
	wire ID_EX_Write;
	wire EX_MEM_Write;
	wire MEM_WB_Write;
	wire InsertBubble;

	wire PCMux;
	wire IsFlush;

	Stage1 st1(PcUpdateTarget, PCMux, Pc_1_2, PcWrite, inst, readM1, address1, data1, clk, reset_n);

	Hazard hzd(PcWrite, IF_ID_Write, ID_EX_Write, EX_MEM_Write, MEM_WB_Write, InsertBubble, MemRead_3_4, MemWrite_3_4, clk, complete1, complete2, readM1, readM2, writeM2);

	Stage2 st2(Pc_1_2, inst,
	ReadData1, ReadData2, ImmediateExtended, Rs, Rt, Rd, Pc_2_3,
	ALUOp_2_3, ALUSrc_2_3, OutputPortWrite_2_3, IsLHI_2_3, RegDest_2_3,
	MemRead_2_3, MemWrite_2_3,
	RegWriteSrc_2_3, RegWrite_2_3, IsBranch_2_3, IsJump_2_3, BranchProperty_2_3, IsJumpReg_2_3,
	WB_RegWriteData, WB_RegWriteTarget, WB_RegWrite,
	IF_ID_Write, InsertBubble, IsFlush, BranchTarget, Valid_2_3, JumpTargetAddr_2_3,
	 IsHalted_2_3, clk, reset_n
	);

	Forward fwd(ControlA, ControlB, Rs_3_F, Rt_3_F, RegWriteTarget_4_5, WB_RegWriteTarget,
	RegWrite_4_5, WB_RegWrite);

	Stage3 st3(ID_EX_Write, Pc_2_3,
	ReadData1, ReadData2, ImmediateExtended, Rs, Rt, Rd,
	Pc_3_4, ALUOut_3_4, RegWriteTarget_3_4,
	ALUOp_2_3, ALUSrc_2_3, OutputPortWrite_2_3, IsLHI_2_3, RegDest_2_3,
	MemRead_2_3, MemWrite_2_3, Valid_2_3, JumpTargetAddr_2_3,
	RegWriteSrc_2_3, RegWrite_2_3, IsHalted_2_3, BranchTarget, IsBranch_2_3, IsJump_2_3, BranchProperty_2_3, IsJumpReg_2_3,
	MemRead_3_4, MemWrite_3_4,
	RegWriteSrc_3_4, RegWrite_3_4, MemWriteData_3_4,
	Rs_3_F, Rt_3_F, IsHalted_3_4,
	PcUpdateTarget, PCMux, Valid_3_4, IsFlush,
	ControlA, ControlB, WB_RegWriteData, MEM_RegWriteData, OutputData_3_4,
	clk, reset_n
	);


	Stage4 st4(EX_MEM_Write, Pc_3_4,
	ALUOut_3_4, RegWriteTarget_3_4, MemWriteData_3_4,
	Pc_4_5, MemData_4_5, ALUOut_4_5, RegWriteTarget_4_5,
	MemRead_3_4, MemWrite_3_4, Valid_3_4, OutputData_3_4,
	RegWriteSrc_3_4, RegWrite_3_4, IsHalted_3_4, PCMux, IsFlush, Valid_4_5,
	RegWriteSrc_4_5, RegWrite_4_5, MEM_RegWriteData, IsHalted_4_5, OutputData_4_5,
	readM2, writeM2, address2, data2,
	clk, reset_n
	);

	Stage5 st5(MEM_WB_Write, Pc_4_5,
	ALUOut_4_5, RegWriteTarget_4_5, MemData_4_5, IsHalted_4_5,
	WB_RegWriteData, WB_RegWriteTarget,
	RegWriteSrc_4_5, RegWrite_4_5, Valid_4_5, OutputData_4_5,
	WB_RegWrite, is_halted, WB_Valid, output_port,
	clk, reset_n
	);

endmodule

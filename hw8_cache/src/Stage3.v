`include "opcodes.v"

module Stage3(ID_EX_Write, Pc,
	ReadData1, ReadData2, ImmediateExtended, Rs, Rt, Rd,
	PcVal, ALUOut, RegWriteTarget,
	ALUOp, ALUSrc, OutputPortWrite, IsLHI, RegDest,
	MemRead, MemWrite, Valid, JumpTargetAddr,
	RegWriteSrc, RegWrite, IsHalted, BranchTarget, IsBranch, IsJump, BranchProperty, IsJumpReg,
	MemRead_OUT, MemWrite_OUT,
	RegWriteSrc_OUT, RegWrite_OUT, MemWriteData_OUT,
	Rs_OUT, Rt_OUT,	IsHalted_OUT,  BranchResult_OUT, PCMux_OUT, Valid_OUT, IsFlush,
	ControlA, ControlB, WB_RegWriteData, MEM_RegWriteData,	 OutputData_OUT,
	clk, reset_n
	);
	//Data inout
	input ID_EX_Write;
	input [`WORD_SIZE-1:0] Pc;
	input [`WORD_SIZE-1:0] ReadData1;
	input [`WORD_SIZE-1:0] ReadData2;
	input [`WORD_SIZE-1:0] ImmediateExtended;
	input [`WORD_SIZE-1:0] BranchTarget;
	input [`WORD_SIZE-1:0] JumpTargetAddr;
	input [1:0] Rs;
	input [1:0] Rt;
	input [1:0] Rd;
	input Valid;
	output Valid_OUT;
	assign Valid_OUT = Valid_REG & !IsFlush;
	output reg [`WORD_SIZE-1:0] PcVal;
	assign PcVal = Pc_REG;
	output reg [`WORD_SIZE-1:0] ALUOut;
	output reg [1:0] RegWriteTarget;
	output [1:0] Rs_OUT;
	output [1:0] Rt_OUT;
	output reg [`WORD_SIZE-1:0] MemWriteData_OUT;
	output reg [`WORD_SIZE-1:0] OutputData_OUT;
	input clk;
	input reset_n;
	output reg [`WORD_SIZE-1:0] BranchResult_OUT;
	output PCMux_OUT;
	input IsFlush;

	input IsBranch;
	input IsJump;
	input [1:0] BranchProperty;
	input IsJumpReg;

	//EX Control Signals
	input [2:0] ALUOp;
	input ALUSrc;
	input IsLHI;
	input [1:0] RegDest;
	input OutputPortWrite;

	//MEM Control Signals
	input MemRead;
	input MemWrite;

	//WB Control Signals
	input [1:0] RegWriteSrc;
	input RegWrite;
	input IsHalted;
	output IsHalted_OUT;
	assign IsHalted_OUT = (IsFlush) ? 0 : IsHalted_REG;

	//Forwarding
	input [1:0] ControlA;
	input [1:0] ControlB;
	input [`WORD_SIZE-1:0] WB_RegWriteData;
	input [`WORD_SIZE-1:0] MEM_RegWriteData;

	//Control transfer
	output reg MemRead_OUT;
	output reg MemWrite_OUT;
	output reg [1:0] RegWriteSrc_OUT;
	output RegWrite_OUT;
	assign MemRead_OUT = (IsFlush) ? 0 : MemRead_REG;
	assign MemWrite_OUT = (IsFlush) ? 0 : MemWrite_REG;
	assign RegWriteSrc_OUT = (IsFlush) ? 0 : RegWriteSrc_REG;
	assign RegWrite_OUT = (IsFlush) ? 0 : RegWrite_REG;

	//internal Register(ID/EX)
	reg [`WORD_SIZE-1:0] Pc_REG;
	reg [`WORD_SIZE-1:0] ReadData1_REG;
	reg [`WORD_SIZE-1:0] ReadData2_REG;
	reg [`WORD_SIZE-1:0] ImmediateExtended_REG;
	reg [1:0] Rs_REG;
	reg [1:0] Rt_REG;
	reg [1:0] Rd_REG;
	reg [`WORD_SIZE-1:0] BranchTarget_REG;
	assign Rs_OUT = Rs_REG;
	assign Rt_OUT = Rt_REG;

	//EX Control Signals
	reg [2:0] ALUOp_REG;
	reg ALUSrc_REG;
	reg IsLHI_REG;
	reg [1:0] RegDest_REG;
	reg IsBranch_REG;
	reg IsJump_REG;
	reg [1:0] BranchProperty_REG;
	reg IsJumpReg_REG;
	reg Valid_REG;



	//MEM Control Signals
	reg MemRead_REG;
	reg MemWrite_REG;
	//WB Control Signals
	reg [1:0] RegWriteSrc_REG;
	reg RegWrite_REG;
	reg IsHalted_REG;

	reg OutputPortWrite_REG;
	reg [`WORD_SIZE-1:0] JumpTargetAddr_REG;

	reg overflow;
	reg [`WORD_SIZE-1:0] operandA;
	reg [`WORD_SIZE-1:0] operandB;
	reg [`WORD_SIZE-1:0] ALUInterOut;
	wire BranchCond;
	wire zero;

	assign zero = ALUInterOut == 0;
	assign BranchCond = ((BranchProperty_REG==0) && !zero) || ((BranchProperty_REG==1) && zero)
		|| ((BranchProperty_REG==2) && !operandA[15] && !zero) || ((BranchProperty_REG==3) && operandA[15] && !zero);
	assign PCMux_OUT = (IsFlush) ? 0 : ((BranchCond && IsBranch_REG) || IsJump_REG);

	always @(*) begin
		if(ControlA == 0) operandA = ReadData1_REG;
		else if(ControlA == 1) operandA = MEM_RegWriteData;
		else if(ControlA == 2) operandA = WB_RegWriteData;
		if(ALUSrc_REG == 1)	operandB = ImmediateExtended_REG;
		else if(BranchProperty_REG == 2 || BranchProperty_REG == 3)	begin
			$display("^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^HOHOHOHOHOHOHOHOHOHOHOH");
			operandB = 0;
		end
		else begin
			if(ControlB == 0) operandB = ReadData2_REG;
			else if(ControlB == 1) operandB = MEM_RegWriteData;
			else if(ControlB == 2) operandB = WB_RegWriteData;
		end
		if(ControlB == 0) begin
			//$display("Took branch 0: data :%x", ReadData2_REG);
			MemWriteData_OUT = (IsFlush) ? 0 : ReadData2_REG;
		end
		else if(ControlB==1) begin
			//$display("Took branch 1: data :%x", MEM_RegWriteData);
			MemWriteData_OUT = (IsFlush) ? 0 : MEM_RegWriteData;
		end
		else begin
			//$display("Took branch 2: data :%x", WB_RegWriteData);
			MemWriteData_OUT = (IsFlush) ? 0 : WB_RegWriteData;
		end
		if(RegWriteSrc_REG == 2) RegWriteTarget = 2;
		else begin
			if(RegDest_REG == 0) RegWriteTarget = Rd_REG;
			else if(RegDest_REG == 1) RegWriteTarget = Rt_REG;
		end
		if(IsLHI_REG == 0) ALUOut = ALUInterOut;
		else if(IsLHI_REG == 1) begin
			ALUOut = ImmediateExtended_REG << 8;
			$display("holololo %x", ALUOut);
		end
		//$display("OperandA: %x, OperandB: %x, IsLHI_REG: %x, OutputPortWrite_REG: %x, RegWrite_REG: %x, ALUOut: %x, ALUOp: %x, RegWriteTarget: %x, ControlA: %x, ControlB: %x",
		//	operandA, operandB, IsLHI_REG, OutputPortWrite_REG, RegWrite_REG, ALUOut, ALUOp, RegWriteTarget, ControlA, ControlB);
		if(OutputPortWrite_REG && !IsFlush) begin
			OutputData_OUT = operandA;
			//$display("outputting: OutputData: %x, ControlA: %x", operandA, ControlA);
		end

		if(IsBranch_REG) begin
			BranchResult_OUT = BranchTarget_REG;
		end
		else if(IsJump_REG) begin
			if(IsJumpReg_REG) BranchResult_OUT = operandA;
			else BranchResult_OUT = JumpTargetAddr_REG;
		end
	end

	always @(posedge clk) begin
		if(ID_EX_Write) begin
			Pc_REG = Pc;
			ReadData1_REG = ReadData1;
			ReadData2_REG = ReadData2;
			ImmediateExtended_REG = ImmediateExtended;
			Rs_REG = Rs;
			Rt_REG = Rt;
			Rd_REG = Rd;
			ALUOp_REG = ALUOp;
			ALUSrc_REG = ALUSrc;
			IsLHI_REG = IsLHI;
			RegDest_REG = RegDest;
			MemRead_REG = MemRead;
			MemWrite_REG = MemWrite;
			RegWriteSrc_REG = RegWriteSrc;
			RegWrite_REG = RegWrite;
			OutputPortWrite_REG = OutputPortWrite;
			IsHalted_REG = IsHalted;
			BranchTarget_REG = BranchTarget;
		    IsBranch_REG = IsBranch;
			IsJump_REG = IsJump;
			BranchProperty_REG = BranchProperty;
			IsJumpReg_REG = IsJumpReg;
			Valid_REG = Valid;
			JumpTargetAddr_REG = JumpTargetAddr;
		end


		if(!reset_n) begin
			MemWrite_REG = 0;
			Pc_REG = Pc;
			ReadData1_REG = 0;
			ReadData2_REG = 0;
			ImmediateExtended_REG = 0;
			Rs_REG = 0;
			Rt_REG = 0;
			Rd_REG = 0;
			ALUOp_REG = 0;
			ALUSrc_REG = 0;
			IsLHI_REG = 0;
			RegDest_REG = 0;
			MemRead_REG = 0;
			MemWrite_REG = 0;
			RegWriteSrc_REG = 0;
			RegWrite_REG = 0;
			OutputPortWrite_REG = 0;
			IsHalted_REG = 0;
			BranchTarget_REG = 0;
		    IsBranch_REG = 0;
			IsJump_REG = 0;
			BranchProperty_REG = 0;
			IsJumpReg_REG = 0;
			Valid_REG = 0;
			JumpTargetAddr_REG = 0;
		end
	end

	ALU alu(overflow, ALUInterOut, operandA, operandB, ALUOp_REG);

endmodule

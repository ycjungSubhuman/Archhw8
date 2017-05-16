`include "opcodes.v"

module Forward(SelectA, SelectB, ID_EX_Rs, ID_EX_Rt, EX_MEM_Dest, MEM_WB_Dest,
	EX_MEM_RegWrite, MEM_WB_RegWrite);
	
	output reg [1:0] SelectA;
	output reg [1:0] SelectB;
	input [1:0] ID_EX_Rs;
	input [1:0] ID_EX_Rt;
	input [1:0] EX_MEM_Dest;
	input [1:0] MEM_WB_Dest;
	input EX_MEM_RegWrite;
	input MEM_WB_RegWrite;
	
	always @(*) begin																																							
		if(ID_EX_Rs == EX_MEM_Dest && EX_MEM_RegWrite) SelectA = 1;																	 
		else if(ID_EX_Rs == MEM_WB_Dest && MEM_WB_RegWrite) SelectA = 2;
		else SelectA = 0;
		//$display("SelectA: %x, Rs: %x, EMDest: %x, EMRegWrite: %x", SelectA, ID_EX_Rs, EX_MEM_Dest, EX_MEM_RegWrite);
		if(ID_EX_Rt == EX_MEM_Dest && EX_MEM_RegWrite) SelectB = 1;																	 
		else if(ID_EX_Rt == MEM_WB_Dest && MEM_WB_RegWrite) SelectB = 2;
		else SelectB = 0;
	end
	
endmodule
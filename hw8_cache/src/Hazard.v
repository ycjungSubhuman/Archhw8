module Hazard(PcWrite, IF_ID_Write, ID_EX_Write, EX_MEM_Write, MEM_WB_Write, InsertBubble, ID_EX_MemRead, ID_EX_MemWrite, clk, complete1, complete2, i_readM, d_readM, d_writeM);

	output reg PcWrite;
	output reg IF_ID_Write;
	output reg ID_EX_Write;
	output reg EX_MEM_Write;
	output reg MEM_WB_Write;
	output reg InsertBubble;
	input ID_EX_MemRead;
	input ID_EX_MemWrite;
	input clk;
	input complete1;
	input complete2;
	input i_readM;
	input d_readM;
	input d_writeM;

	reg reading_inst;
	reg grant_inst;
	reg grant_read;
	reg grant_write;
	reg reading;
	reg writing;


	//Stage 1 Add input PcWrite,
	//Stage 2 Add Input IF_ID_Write, input InsertBubble
	//Stage 3 Add output ID_EX_MemRead
	initial begin
		PcWrite = 1;
		IF_ID_Write = 1;
		ID_EX_Write = 1;
		EX_MEM_Write = 1;
		MEM_WB_Write = 1;
		InsertBubble = 0;
		reading_inst = 0;
		grant_inst = 0;
		grant_read = 0;
		grant_write = 0;
		reading = 0;
		writing = 0;
		forcebubble = 0;
		restore = 0;
	end
	reg forcebubble;
	reg restore;
	always @(*) begin
		if(restore) begin
		   	PcWrite = a;
			IF_ID_Write = b;
			ID_EX_Write = c;
			EX_MEM_Write = d;
			MEM_WB_Write = e;
			InsertBubble = f;
			restore = 0;
		end

		if(grant_inst && !writing && !reading) begin
			PcWrite = 1;
			IF_ID_Write = 1;
			ID_EX_Write = 1;
			EX_MEM_Write = 1;
			MEM_WB_Write = 1;
			InsertBubble = 0;
	 
		end
		
		
		/* stalling for d read prepare*/
		if(ID_EX_MemRead || ID_EX_MemWrite) begin
			if(grant_inst) begin
				forcebubble = 1;
			end
			PcWrite = 0;
			IF_ID_Write = 0;
			ID_EX_Write = 1;
			EX_MEM_Write = 1;
			MEM_WB_Write = 1;
			InsertBubble = 1;
//			reading = 1;			   
		end
		
				/* stalling for i read*/
		if(!grant_inst && i_readM) begin
			PcWrite = 0;
			IF_ID_Write = 0;
			ID_EX_Write = 0;
			EX_MEM_Write = 0;
			MEM_WB_Write = 0;
			InsertBubble = 0;
			reading_inst = 1;		   
		end
		
		if(forcebubble) begin
			a = PcWrite;
			b = IF_ID_Write;
			c = ID_EX_Write;
			d = EX_MEM_Write;
			e = MEM_WB_Write;
			f = InsertBubble;
		  	PcWrite = 0;
			IF_ID_Write = 0;
			ID_EX_Write = 1;
			EX_MEM_Write = 1;
			MEM_WB_Write = 1;
			InsertBubble = 1;
			forcebubble = 0;
			restore = 1;
		end
		
		else if(!reading && !reading_inst && !writing) begin
			PcWrite = 1;
			IF_ID_Write = 1;
			ID_EX_Write = 1;
			EX_MEM_Write = 1;
			MEM_WB_Write = 1;
			InsertBubble = 0;	 
		end




		if(!grant_read && d_readM) begin
			PcWrite = 0;
			IF_ID_Write = 0;
			ID_EX_Write = 0;
			EX_MEM_Write = 0;
			MEM_WB_Write = 0;
			InsertBubble = 0;
			reading = 1;			  
		end
		if(grant_read && !reading_inst && !writing) begin
			PcWrite = 1;
			IF_ID_Write = 1;
			ID_EX_Write = 1;
			EX_MEM_Write = 1;
			MEM_WB_Write = 1;
			InsertBubble = 0;
			reading = 0;			  
		end

		if(!grant_write && d_writeM) begin
			PcWrite = 0;
			IF_ID_Write = 0;
			ID_EX_Write = 0;
			EX_MEM_Write = 0;
			MEM_WB_Write = 0;
			InsertBubble = 0;
			writing = 1; 				
		end
		if(grant_write && !reading_inst && !reading) begin
			PcWrite = 1;
			IF_ID_Write = 1;
			ID_EX_Write = 1;
			EX_MEM_Write = 1;
			MEM_WB_Write = 1;
			InsertBubble = 0;
			writing = 0;			 
		end

	end
	reg a;
	reg b;
	reg c;
	reg d;
	reg e;
	reg f;

	always @(posedge clk) begin
		if(grant_inst) begin
			grant_inst = 0;
		end
		if(reading_inst && complete1) begin
			grant_inst = 1;
			reading_inst = 0;	
		end

		if(grant_read) begin
			grant_read = 0;
		end
		if(reading && complete2) begin
			grant_read = 1;
			reading=0;
		end

		if(grant_write) begin
			grant_write = 0;
		end
		if(writing && complete2) begin
			grant_write = 1;
			writing=0;
		end
		//if(InsertBubble && !IF_ID_Write) $display("Bubble");
		//else $display("NoBubble");
	end
endmodule

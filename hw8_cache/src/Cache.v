`timescale 1 ns / 1 ps
`define WORD_SIZE 16    // data and address word size 
`include "Memory.v"
										 
module cache (address1save, data1, readM1, complete1, address2save, data2, readM2, writeM2, complete2, clk, reset_n);
	input reg [`WORD_SIZE-1:0] address1save;
	inout data1;
	wire [`WORD_SIZE-1:0] data1;
	input reg readM1;
	output reg complete1;
	input reg [`WORD_SIZE-1:0] address2save;
	inout data2;
	wire [`WORD_SIZE-1:0] data2;
	input reg readM2;
	input reg writeM2;
	output reg complete2;
	input clk;
	input reset_n;
	
	reg [3:0] misscycle1;
	reg [3:0] misscycle2;
	
	reg [11:0] tag [0:3];
	reg [`WORD_SIZE-1:0] data [0:15];
	reg [3:0] valid;
	reg [3:0] dirty;
	
	reg i_readM;
	reg i_writeM;
	reg [`WORD_SIZE-1:0] i_address;
	wire [`WORD_SIZE-1:0] i_data;
	reg d_readM;
	reg d_writeM;
	reg [`WORD_SIZE-1:0] d_address;
	wire [`WORD_SIZE-1:0] d_data;
	
	reg [`WORD_SIZE-1:0] outputData1;
	reg [`WORD_SIZE-1:0] outputData2;
	reg [`WORD_SIZE-1:0] i_inputData;
	reg [`WORD_SIZE-1:0] d_inputData;
	reg readMed1;
	reg readMed2;
	reg writeMed2;
	reg [`WORD_SIZE-1:0] writeData;
	reg [`WORD_SIZE-1:0] address2;
	reg [`WORD_SIZE-1:0] address1;
	
	assign data1 = outputData1;
	assign data2 = complete2?outputData2:`WORD_SIZE'bz;
	assign i_data = i_readM?`WORD_SIZE'bz:i_inputData;
	assign d_data = d_readM?`WORD_SIZE'bz:d_inputData;
	
	reg [`WORD_SIZE-1:0] totalexecution;
	reg [`WORD_SIZE-1:0] hitcount;
	
	initial begin
		misscycle1 = 0;
		misscycle2 = 0;
		i_readM = 0;
		i_writeM = 0;
		d_readM = 0;
		d_writeM = 0;
		outputData1 = 0;
		outputData2 = 0;
		i_inputData = 0;
		d_inputData = 0;
		readMed1 = 0;
		readMed2 = 0;
		writeMed2 = 0;
		complete1 = 0;
		complete2 = 0;
		writeData = 0;
		totalexecution = 0;
		hitcount = 0;
		valid[0] = 0; valid[1] = 0; valid[2] = 0; valid[3] = 0;
		dirty[0] = 0; dirty[1] = 0; dirty[2] = 0; dirty[3] = 0;
	end
	
	always @(*) begin
		if(writeMed2 == 1) begin
			if(misscycle2 == 0)	begin
				if(readMed1 == 0 ||  (address1[3:2] != address2[3:2])) begin
					if(tag[address2[3:2]] == address2[15:4] && valid[address2[3:2]] == 1) begin
						$display("address[3:2]*4+address2[1:0]: %x, WriteData: %x", address2[3:2]*4+address2[1:0], writeData);
						data[address2[3:2]*4+address2[1:0]] = writeData;
						dirty[address2[3:2]] = 1;
						complete2 = 1;
						writeMed2 = 0;
						hitcount = hitcount+1;
					end
					else begin
						if(dirty[address2[3:2]] == 1) begin
							misscycle2 = 1;
							d_writeM = 1;
							d_inputData = data[address2[3:2]*4];
							d_address = {tag[address2[3:2]], address2[3:2], 2'b00};
						end
						else begin
							misscycle2 = 5;
							d_readM = 1;
							d_address = {address2[15:2], 2'b00};
						end
						complete2 = 0;
						hitcount = hitcount-1;
					end
				end
			end
		end
		else if(readMed2 == 1) begin
			if(misscycle2 == 0)	begin
				if(readMed1 == 0 ||  (address1[3:2] != address2[3:2])) begin
					if(tag[address2[3:2]] == address2[15:4] && valid[address2[3:2]] == 1) begin
						outputData2 = data[address2[3:2]*4+address2[1:0]];
						$display("address2 %x, OutputData2: %x", address2, outputData2);
						complete2 = 1;
						readMed2 = 0;
						hitcount = hitcount+1;
					end
					else begin
						if(dirty[address2[3:2]] == 1) begin
							misscycle2 = 1;
							d_writeM = 1;
							d_inputData = data[address2[3:2]*4];
							d_address = {tag[address2[3:2]], address2[3:2], 2'b00};
						end
						else begin
							misscycle2 = 5;
							d_readM = 1;
							d_address = {address2[15:2], 2'b00};
						end
						complete2 = 0;
						hitcount = hitcount-1; 
					end
				end
			end
		end
		if(readMed1 == 1) begin
			if(misscycle1 == 0) begin
				if(tag[address1[3:2]] == address1[15:4] && valid[address1[3:2]] == 1) begin
					outputData1 = data[address1[3:2]*4+address1[1:0]];
					//$display("address1 %x, OutputData1: %x", address1, outputData1);
					complete1 = 1;
					readMed1 = 0;
					hitcount = hitcount+1;
				end
				else begin
					if(dirty[address1[3:2]] == 1) begin
						misscycle1 = 1;
						i_writeM = 1;
						i_inputData = data[address1[3:2]*4];
						i_address = {tag[address1[3:2]], address1[3:2], 2'b00};
					end
					else begin					
						misscycle1 = 5;
						i_readM = 1;
						i_address = {address1[15:2], 2'b00};
					end
					complete1 = 0;
					hitcount = hitcount-1;
				end
			end
		end
		if(writeM2 == 1) begin
			writeMed2 = 1;
			complete2 = 0;
			writeData = data2;
			address2 = address2save;
			totalexecution = totalexecution+1; 
		end			 																																																																																																  
		if(readM1 == 1) begin
			readMed1 = 1;
			complete1 = 0;
			totalexecution = totalexecution+1;
			address1 = address1save;
		end
		if(readM2 == 1) begin
			readMed2 = 1;
			complete2 = 0;
			address2 = address2save;
			totalexecution = totalexecution+1;
		end
		//$display("TotalExecution: %d, HitCount: %d", totalexecution, hitcount);
	end
	
	always @(posedge clk) begin
		if(misscycle1 == 1) begin
			i_inputData = data[address1[3:2]*4+1];	  
			i_address = {tag[address1[3:2]], address1[3:2], 2'b01};
			misscycle1 = 2;
		end
		else if(misscycle1 == 2) begin
			i_inputData = data[address1[3:2]*4+2];	  
			i_address = {tag[address1[3:2]], address1[3:2], 2'b10};
			misscycle1 = 3;
		end
		else if(misscycle1 == 3) begin
			i_inputData = data[address1[3:2]*4+3];	  	
			i_address = {tag[address1[3:2]], address1[3:2], 2'b11};
			misscycle1 = 4;
		end
		else if(misscycle1 == 4) begin
			i_readM = 1;
			i_writeM = 0;
			i_address = {address1[15:2], 2'b00};
			dirty[address1[3:2]] = 0;
			misscycle1 = 5;
		end
		else if(misscycle1 == 5) begin
			data[address1[3:2]*4] = i_data;
			i_address = {address1[15:2], 2'b01};
			misscycle1 = 6;	
		end
		else if(misscycle1 == 6) begin
			data[address1[3:2]*4+1] = i_data;
			i_address = {address1[15:2], 2'b10};
			misscycle1 = 7;
		end
		else if(misscycle1 == 7) begin
			data[address1[3:2]*4+2] = i_data;
			i_address = {address1[15:2], 2'b11};
			misscycle1 = 8;
		end
		else if(misscycle1 == 8) begin
			data[address1[3:2]*4+3] = i_data;
			tag[address1[3:2]] = address1[15:4];
			valid[address1[3:2]] = 1;
			i_readM = 0;
			misscycle1 = 9;
		end
		else if(misscycle1 == 9) begin
			misscycle1 = 0;
		end
		if(readMed1 == 0 || (address1[3:2] != address2[3:2])) begin
			if(misscycle2 == 1) begin
				d_inputData = data[address2[3:2]*4+1];	  
				d_address = {tag[address2[3:2]], address2[3:2], 2'b01};
				misscycle2 = 2;
			end
			else if(misscycle2 == 2) begin
				d_inputData = data[address2[3:2]*4+2];	  
				d_address = {tag[address2[3:2]], address2[3:2], 2'b10};
				misscycle2 = 3;
			end
			else if(misscycle2 == 3) begin
				d_inputData = data[address2[3:2]*4+3];	  	
				d_address = {tag[address2[3:2]], address2[3:2], 2'b11};
				misscycle2 = 4;
			end
			else if(misscycle2 == 4) begin			   		  
				d_writeM = 0;
				d_readM = 1;
				d_address = {address2[15:2], 2'b00};
				dirty[address2[3:2]] = 0;
				misscycle2 = 5;
			end
		else if(misscycle2 == 5) begin
				data[address2[3:2]*4] = d_data;
				d_address = {address2[15:2], 2'b01};
				misscycle2 = 6;	
			end
			else if(misscycle2 == 6) begin
				data[address2[3:2]*4+1] = d_data;
				d_address = {address2[15:2], 2'b10};
				misscycle2 = 7;
			end
			else if(misscycle2 == 7) begin
				data[address2[3:2]*4+2] = d_data;
				d_address = {address2[15:2], 2'b11};
				misscycle2 = 8;
			end
			else if(misscycle2 == 8) begin
				data[address2[3:2]*4+3] = d_data;
				tag[address2[3:2]] = address2[15:4];
				valid[address2[3:2]] = 1;
				d_readM = 0;
				misscycle2 = 9;
			end
			else if(misscycle2 == 9) begin
				misscycle2 = 0;
			end
		end
		//$display("complete1: %x, readMed1: %x, misscycle1: %x, i_writeM: %x, address1: %x, tag[address1[3:2]]: %x, i_address: %x", complete1, readMed1, misscycle1, i_readM, address1, tag[address1[3:2]], i_address);
		//$display("complete2: %x, readM2: %x, readMed2: %x, misscycle2: %x, d_readM: %x, address2: %x, tag[address2[3:2]]: %x, d_address: %x, writeData: %x", complete2, readM2, readMed2, misscycle2, d_readM, address2, tag[address2[3:2]], d_address, writeData);
		$display("data: (%x, %x, %x, %x), (%x, %x, %x, %x), (%x, %x, %x, %x), (%x, %x, %x, %x)", data[0], data[1], data[2], data[3], data[4], data[5], data[6], data[7], data[8], data[9], data[10], data[11], data[12], data[13], data[14], data[15]);
		complete1 = 0;
		complete2 = 0;
	end
	
	Memory NUUT(!clk, reset_n, i_readM, i_writeM, i_address, i_data, d_readM, d_writeM, d_address, d_data);
endmodule

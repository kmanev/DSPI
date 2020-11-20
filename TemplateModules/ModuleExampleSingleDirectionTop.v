`timescale 1ns / 1ps
//The parameter values assigned are just an example and will need to be modified to match your system requirements
module ModuleExampleSingleDirectionTop #(
	//FORWARD PATH WIDTHS
	parameter integer DATA_WIDTH = 512, //multiple of 32-bits
	parameter integer STREAM_ID_NUM = 16, //number of addressable virtual streams
	parameter integer CHUNK_ID_NUM = 32, //maximum number of individually addressable chunks per packet
	parameter integer CHANNEL_ID_NUM = 1024, //number of addressable virtual channels per virtual stream
	parameter integer STATE_WIDTH = 32, //transfers intermediate stream state for PEs and addresses for memory transactions
	//BACKWARD PATH WIDTHS & ENCODING
	parameter integer INSTRUCTION_WIDTH = 2,//width in bits of backward path instructions
	parameter INSTRUCTION_CMD_IDLE = 2'd0,
	parameter INSTRUCTION_CMD_REQUEST = 2'd1,
	parameter INSTRUCTION_CMD_REWIND = 2'd2,
	parameter INSTRUCTION_CMD_RESET = 2'd3,
	parameter integer INSTRUCTION_PARAMETER_WIDTH = 16,
	//CONTROL TYPE PACKETS ENCODING
		//ABSOLUTE ADDRESSING
		parameter CP_A_EOS = 0, // End Of Stream
		parameter CP_A_CTRL_READ_RESPONSE_32b = 1,
		parameter CP_A_MEM_READ_REQUEST_512b = 2,
		parameter CP_A_MEM_READ_RESPONSE_512b = 3,
		parameter CP_A_MEM_WRITE_512b = 4,
		
		//RELATIVE ADDRESSING
		parameter CP_R_CTRL_READ_REQUEST_32b = 0,
		parameter CP_R_CTRL_WRITE_32b = 1,
	//DERIVED VALUES
	parameter integer STREAM_ID_WIDTH = $clog2(STREAM_ID_NUM),
	parameter integer CHUNK_ID_WIDTH = $clog2(CHUNK_ID_NUM),
	parameter integer CHANNEL_ID_WIDTH = $clog2(CHANNEL_ID_NUM),
	parameter integer NUM_32B_FIELDS = (DATA_WIDTH/32),
	parameter integer WIDTH_NUM_32B_FIELDS = $clog2(NUM_32B_FIELDS)
)(
	input clk,
	input rstn,
	
//DIRECTION ONE
	//FORWARD INTERFACE DATA
	input 		[DATA_WIDTH-1:0] 					Front_Data,
	input   	[1:0] 								Front_Type,
	input 											Front_Last,
    input   	[STREAM_ID_WIDTH-1:0] 				Front_StreamID,
    input   	[CHUNK_ID_WIDTH-1:0] 				Front_ChunkID,
    input   	[CHANNEL_ID_WIDTH-1:0] 				Front_ChannelID,
    input   	[STATE_WIDTH-1:0] 					Front_State,
	
	//BACKWARD INTERFACE DATA
	output reg 	[DATA_WIDTH-1:0] 					Back_Data,
	output reg  [1:0] 								Back_Type = 0,
	output reg 										Back_Last,
    output reg  [STREAM_ID_WIDTH-1:0] 				Back_StreamID,
    output reg  [CHUNK_ID_WIDTH-1:0] 				Back_ChunkID,
    output reg  [CHANNEL_ID_WIDTH-1:0] 				Back_ChannelID,
    output reg  [STATE_WIDTH-1:0] 					Back_State,
    
	//BACKWARD INTERFACE CTRL
    input   	[INSTRUCTION_WIDTH-1:0] 			Back_InstructionType,
    input   	[STREAM_ID_WIDTH-1:0] 				Back_InstructionStreamID,
    input   	[CHANNEL_ID_WIDTH-1:0] 				Back_InstructionChannelID,
    input  		[INSTRUCTION_PARAMETER_WIDTH-1:0] 	Back_InstructionParameter,
    
	//FORWARD INTERFACE CTRL
    output reg 	[INSTRUCTION_WIDTH-1:0] 			Front_InstructionType = INSTRUCTION_CMD_IDLE,
    output reg 	[STREAM_ID_WIDTH-1:0] 				Front_InstructionStreamID,
    output reg 	[CHANNEL_ID_WIDTH-1:0] 				Front_InstructionChannelID,
    output reg 	[INSTRUCTION_PARAMETER_WIDTH-1:0] 	Front_InstructionParameter
	
);
	wire controlTypePacketValid = Front_Type[1];
	wire dataTypePacketValid = Front_Type[0];
	
	// Handle control type packet addressing
	always @ (posedge clk) begin
		if(controlTypePacketValid) begin
			if(Front_ChunkID[CHUNK_ID_WIDTH-1]) begin //MSB of chunkID selects addressing type
				//Relative addressing control packet
				if(Front_ChannelID == 0) begin 
					//This module is the recipient of the current control packet
					case(Front_ChunkID[CHUNK_ID_WIDTH-2:0])
						CP_R_CTRL_READ_REQUEST_32b: begin // A control read request
							// * Front_State holds the address of the read operation
							// * the module must produce a CP_A_CTRL_READ_RESPONSE_32b
						end
						CP_R_CTRL_WRITE_32b: begin // A control write request
							// * Front_State holds the address of the write operation
							// * All 32-bit fields on the FrontFrontData bus hold the write value
						end
					endcase
				end else begin
					//This module is NOT the recipient of the current control packet
					// * The module must forward the packet with decremented selector(the packet could also move first through the pipeline in the module):
					Back_Data <= Front_Data;
					Back_Type <= Front_Type;
					Back_Last <= Front_Last;
					Back_StreamID <= Front_StreamID;
					Back_ChunkID <= Front_ChunkID;
					Back_ChannelID <= Front_ChannelID - 1;
					Back_State <= Front_State;
				end
			end else begin
				//Absolute addressing control packet
				//A module that does not need to support these operations can just forward the packet intact
				case(Front_ChunkID[CHUNK_ID_WIDTH-2:0])
					CP_A_EOS: begin
						//END OF STREAM on forwardInputStreamID, forwardInputChannelID
					end
					CP_A_CTRL_READ_RESPONSE_32b: begin
					end
					CP_A_MEM_READ_REQUEST_512b: begin
					end
					CP_A_MEM_READ_RESPONSE_512b: begin
					end
					CP_A_MEM_WRITE_512b: begin
					end
				endcase
			end
		end
		if(dataTypePacketValid) begin
			// A data packet.
			// Data is in Front_Data
			// on virtual channel Front_StreamID, Front_ChannelID
			// with dditional state identifiers Front_ChunkID, Front_State
		end
	end
endmodule

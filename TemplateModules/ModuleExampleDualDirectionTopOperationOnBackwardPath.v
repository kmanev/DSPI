 `timescale 1ns / 1ps
//The parameter values assigned are just an example and will need to be modified to match your system requirements
module ModuleExampleDualDirectionTopOperationOnBackwardPath #(
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
	input 		[DATA_WIDTH-1:0] 					dirOneFront_Data,
	input   	[1:0] 								dirOneFront_Type,
	input 											dirOneFront_Last,
    input   	[STREAM_ID_WIDTH-1:0] 				dirOneFront_StreamID,
    input   	[CHUNK_ID_WIDTH-1:0] 				dirOneFront_ChunkID,
    input   	[CHANNEL_ID_WIDTH-1:0] 				dirOneFront_ChannelID,
    input   	[STATE_WIDTH-1:0] 					dirOneFront_State,
	
	//BACKWARD INTERFACE DATA
	output reg 	[DATA_WIDTH-1:0] 					dirOneBack_Data,
	output reg  [1:0] 								dirOneBack_Type = 0,
	output reg 										dirOneBack_Last,
    output reg  [STREAM_ID_WIDTH-1:0] 				dirOneBack_StreamID,
    output reg  [CHUNK_ID_WIDTH-1:0] 				dirOneBack_ChunkID,
    output reg  [CHANNEL_ID_WIDTH-1:0] 				dirOneBack_ChannelID,
    output reg  [STATE_WIDTH-1:0] 					dirOneBack_State,
    
	//BACKWARD INTERFACE CTRL
    input   	[INSTRUCTION_WIDTH-1:0] 			dirOneBack_InstructionType,
    input   	[STREAM_ID_WIDTH-1:0] 				dirOneBack_InstructionStreamID,
    input   	[CHANNEL_ID_WIDTH-1:0] 				dirOneBack_InstructionChannelID,
    input  		[INSTRUCTION_PARAMETER_WIDTH-1:0] 	dirOneBack_InstructionParameter,
    
	//FORWARD INTERFACE CTRL
    output reg 	[INSTRUCTION_WIDTH-1:0] 			dirOneFront_InstructionType = INSTRUCTION_CMD_IDLE,
    output reg 	[STREAM_ID_WIDTH-1:0] 				dirOneFront_InstructionStreamID,
    output reg 	[CHANNEL_ID_WIDTH-1:0] 				dirOneFront_InstructionChannelID,
    output reg 	[INSTRUCTION_PARAMETER_WIDTH-1:0] 	dirOneFront_InstructionParameter,
	
//DIRECTION TWO
	//FORWARD INTERFACE DATA
	input 		[DATA_WIDTH-1:0] 					dirTwoFront_Data,
	input   	[1:0] 								dirTwoFront_Type,
	input 											dirTwoFront_Last,
    input   	[STREAM_ID_WIDTH-1:0] 				dirTwoFront_StreamID,
    input   	[CHUNK_ID_WIDTH-1:0] 				dirTwoFront_ChunkID,
    input   	[CHANNEL_ID_WIDTH-1:0] 				dirTwoFront_ChannelID,
    input   	[STATE_WIDTH-1:0] 					dirTwoFront_State,
	
	//BACKWARD INTERFACE DATA
	output reg 	[DATA_WIDTH-1:0] 					dirTwoBack_Data,
	output reg  [1:0] 								dirTwoBack_Type = 0,
	output reg 										dirTwoBack_Last,
    output reg  [STREAM_ID_WIDTH-1:0] 				dirTwoBack_StreamID,
    output reg  [CHUNK_ID_WIDTH-1:0] 				dirTwoBack_ChunkID,
    output reg  [CHANNEL_ID_WIDTH-1:0] 				dirTwoBack_ChannelID,
    output reg  [STATE_WIDTH-1:0] 					dirTwoBack_State,
    
	//BACKWARD INTERFACE CTRL
    input   	[INSTRUCTION_WIDTH-1:0] 			dirTwoBack_InstructionType,
    input   	[STREAM_ID_WIDTH-1:0] 				dirTwoBack_InstructionStreamID,
    input   	[CHANNEL_ID_WIDTH-1:0] 				dirTwoBack_InstructionChannelID,
    input  		[INSTRUCTION_PARAMETER_WIDTH-1:0] 	dirTwoBack_InstructionParameter,
    
	//FORWARD INTERFACE CTRL
    output reg 	[INSTRUCTION_WIDTH-1:0] 			dirTwoFront_InstructionType = INSTRUCTION_CMD_IDLE,
    output reg 	[STREAM_ID_WIDTH-1:0] 				dirTwoFront_InstructionStreamID,
    output reg 	[CHANNEL_ID_WIDTH-1:0] 				dirTwoFront_InstructionChannelID,
    output reg 	[INSTRUCTION_PARAMETER_WIDTH-1:0] 	dirTwoFront_InstructionParameter
);
	wire controlTypePacketValid = dirTwoFront_Type[1];
	wire dataTypePacketValid = dirTwoFront_Type[0];
	
	// Handle control type packet addressing
	always @ (posedge clk) begin
		if(controlTypePacketValid) begin
			if(dirTwoFront_ChunkID[CHUNK_ID_WIDTH-1]) begin //MSB of chunkID selects addressing type
				//Relative addressing control packet
				if(dirTwoFront_ChannelID == 0) begin 
					//This module is the recipient of the current control packet
					case(dirTwoFront_ChunkID[CHUNK_ID_WIDTH-2:0])
						CP_R_CTRL_READ_REQUEST_32b: begin // A control read request
							// * dirTwoFront_State holds the address of the read operation
							// * the module must produce a CP_A_CTRL_READ_RESPONSE_32b
						end
						CP_R_CTRL_WRITE_32b: begin // A control write request
							// * dirTwoFront_State holds the address of the write operation
							// * All 32-bit fields on the dirTwoFrontFrontData bus hold the write value
						end
					endcase
				end else begin
					//This module is NOT the recipient of the current control packet
					// * The module must forward the packet with decremented selector(the packet could also move first through the pipeline in the module):
					dirTwoBack_Data <= dirTwoFront_Data;
					dirTwoBack_Type <= dirTwoFront_Type;
					dirTwoBack_Last <= dirTwoFront_Last;
					dirTwoBack_StreamID <= dirTwoFront_StreamID;
					dirTwoBack_ChunkID <= dirTwoFront_ChunkID;
					dirTwoBack_ChannelID <= dirTwoFront_ChannelID - 1;
					dirTwoBack_State <= dirTwoFront_State;
				end
			end else begin
				//Absolute addressing control packet
				//A module that does not need to support these operations can just forward the packet intact
				case(dirTwoFront_ChunkID[CHUNK_ID_WIDTH-2:0])
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
			// Data is in dirTwoFront_Data
			// on virtual channel dirTwoFront_StreamID, dirTwoFront_ChannelID
			// with dditional state identifiers dirTwoFront_ChunkID, dirTwoFront_State
		end
	end
	//direction 2
	always @ (posedge clk) begin
		dirOneBack_Data <= dirOneFront_Data;
		dirOneBack_Type <= dirOneFront_Type;
		dirOneBack_Last <= dirOneFront_Last;
		dirOneBack_StreamID <= dirOneFront_StreamID;
		dirOneBack_ChunkID <= dirOneFront_ChunkID;
		dirOneBack_ChannelID <= dirOneFront_ChannelID;
		dirOneBack_State <= dirOneFront_State;
		dirOneFront_InstructionType <= dirOneBack_InstructionType;
		dirOneFront_InstructionStreamID <= dirOneBack_InstructionStreamID;
		dirOneFront_InstructionChannelID <= dirOneBack_InstructionChannelID;
		dirOneFront_InstructionParameter <= dirOneBack_InstructionParameter;
	end
endmodule

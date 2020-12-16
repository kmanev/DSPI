`timescale 1ns / 1ps

module TurnAround#(
	//FORWARD PATH WIDTHS
	parameter integer DATA_WIDTH = 512, //multiple of 32-bits
	parameter integer STREAM_ID_NUM = 16, //number of addressable virtual streams
	parameter integer CHUNK_ID_NUM = 32, //maximum number of individually addressable chunks per packet
	parameter integer CHANNEL_ID_NUM = 1024, //number of addressable virtual channels per virtual stream
	parameter integer STATE_WIDTH = 32, //transfers intermediate stream state for PEs and addresses for memory transactions
	//BACKWARD PATH WIDTHS & ENCODING
	parameter integer INSTRUCTION_WIDTH = 2,//width in bits of backward path instructions
	parameter INSTRUCTION_CMD_IDLE = 0,
	parameter integer INSTRUCTION_PARAMETER_WIDTH = 16,
	//DERIVED VALUES
	parameter integer STREAM_ID_WIDTH = $clog2(STREAM_ID_NUM),
	parameter integer CHUNK_ID_WIDTH = $clog2(CHUNK_ID_NUM),
	parameter integer CHANNEL_ID_WIDTH = $clog2(CHANNEL_ID_NUM),
	parameter integer NUM_32B_FIELDS = (DATA_WIDTH/32),
	parameter integer WIDTH_NUM_32B_FIELDS = $clog2(NUM_32B_FIELDS)
	)(
	input clk,
	input rstnIn,
	
//DIRECTION ONE
	//FORWARD INTERFACE DATA
	input 		[DATA_WIDTH-1:0] 					dirOneFront_Data,
	input   	[1:0] 								dirOneFront_Type,
	input 											dirOneFront_Last,
    input   	[STREAM_ID_WIDTH-1:0] 				dirOneFront_StreamID,
    input   	[CHUNK_ID_WIDTH-1:0] 				dirOneFront_ChunkID,
    input   	[CHANNEL_ID_WIDTH-1:0] 				dirOneFront_ChannelID,
    input   	[STATE_WIDTH-1:0] 					dirOneFront_State,
    
	//FORWARD INTERFACE CTRL
    output reg 	[INSTRUCTION_WIDTH-1:0] 			dirOneFront_InstructionType = INSTRUCTION_CMD_IDLE,
    output reg 	[STREAM_ID_WIDTH-1:0] 				dirOneFront_InstructionStreamID,
    output reg 	[CHANNEL_ID_WIDTH-1:0] 				dirOneFront_InstructionChannelID,
    output reg 	[INSTRUCTION_PARAMETER_WIDTH-1:0] 	dirOneFront_InstructionParameter,
	
//DIRECTION TWO
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
    input  		[INSTRUCTION_PARAMETER_WIDTH-1:0] 	dirTwoBack_InstructionParameter
);
	wire rstn;
	assign rstn = rstnIn;
		
    always @ (posedge clk) begin

		dirTwoBack_Type <= dirOneFront_Type;
		dirOneFront_InstructionType <= dirTwoBack_InstructionType;
		
		dirTwoBack_Data <= dirOneFront_Data;
		dirTwoBack_Last <= dirOneFront_Last;
		dirTwoBack_StreamID <= dirOneFront_StreamID;
		dirTwoBack_ChunkID <= dirOneFront_ChunkID;
		dirTwoBack_ChannelID <= dirOneFront_ChannelID;
		dirTwoBack_State <= dirOneFront_State;
		
		dirOneFront_InstructionStreamID <= dirTwoBack_InstructionStreamID;
		dirOneFront_InstructionChannelID <= dirTwoBack_InstructionChannelID;
		dirOneFront_InstructionParameter <= dirTwoBack_InstructionParameter;
	end
endmodule

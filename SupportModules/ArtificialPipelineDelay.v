	`timescale	1ns	/	1ps
/*	Used	for	testing	the	integrity	of	DSPI	by	adding	very	large	artificial	delays*/
module ArtificialPipelineDelay#(
	//MODULESPECIFIC
	parameter DIR_ONE_STAGES_DATA=100,
	parameter DIR_TWO_STAGES_DATA=100,
	parameter DIR_ONE_STAGES_CTRL=100,
	parameter DIR_TWO_STAGES_CTRL=100,

	//FORWARDPATHWIDTHS
	parameter integer DATA_WIDTH=512,
	parameter integer STREAM_ID_NUM=16,
	parameter integer CHUNK_ID_NUM=32,
	parameter integer CHANNEL_ID_NUM=1024,
	parameter integer STATE_WIDTH=32,
	parameter integer INSTRUCTION_WIDTH=2,
	parameter INSTRUCTION_CMD_IDLE=2'd0,
	parameter INSTRUCTION_CMD_REQUEST=2'd1,
	parameter INSTRUCTION_CMD_REWIND=2'd2,
	parameter INSTRUCTION_CMD_RESET=2'd3,
	parameter integer INSTRUCTION_parameter _WIDTH=16,
	//CONTROLTYPEPACKETSENCODING
		//ABSOLUTEADDRESSING
		parameter CP_A_EOS=0,
		parameter CP_A_CTRL_READ_RESPONSE_32b=1,
		parameter CP_A_MEM_READ_REQUEST_512b=2,
		parameter CP_A_MEM_READ_RESPONSE_512b=3,
		parameter CP_A_MEM_WRITE_512b=4,

		//RELATIVEADDRESSING
		parameter CP_R_CTRL_READ_REQUEST_32b=0,
		parameter CP_R_CTRL_WRITE_32b=1,
	//DERIVEDVALUES
	parameter integer STREAM_ID_WIDTH=$clog2(STREAM_ID_NUM),
	parameter integer CHUNK_ID_WIDTH=$clog2(CHUNK_ID_NUM),
	parameter integer CHANNEL_ID_WIDTH=$clog2(CHANNEL_ID_NUM),
	parameter integer NUM_32B_FIELDS=(DATA_WIDTH/32),
	parameter integer WIDTH_NUM_32B_FIELDS=$clog2(NUM_32B_FIELDS)
)(
	input	clk,
	input	rstn,
	
//DIRECTION	ONE
	//FORWARD	INTERFACE	DATA
	input			[DATA_WIDTH-1:0]						dirOneFront_Data,
	input			[1:0]									dirOneFront_Type,
	input													dirOneFront_Last,
	input			[STREAM_ID_WIDTH-1:0]					dirOneFront_StreamID,
	input			[CHUNK_ID_WIDTH-1:0]					dirOneFront_ChunkID,
	input			[CHANNEL_ID_WIDTH-1:0]					dirOneFront_ChannelID,
	input			[STATE_WIDTH-1:0]						dirOneFront_State,
	
	//BACKWARD	INTERFACE	DATA
	output	reg		[DATA_WIDTH-1:0]						dirOneBack_Data,
	output	reg		[1:0]									dirOneBack_Type = 0,
	output	reg												dirOneBack_Last,
	output	reg		[STREAM_ID_WIDTH-1:0]					dirOneBack_StreamID,
	output	reg		[CHUNK_ID_WIDTH-1:0]					dirOneBack_ChunkID,
	output	reg		[CHANNEL_ID_WIDTH-1:0]					dirOneBack_ChannelID,
	output	reg		[STATE_WIDTH-1:0]						dirOneBack_State,
	
	//BACKWARD	INTERFACE	CTRL
	input			[INSTRUCTION_WIDTH-1:0]					dirOneBack_InstructionType,
	input			[STREAM_ID_WIDTH-1:0]					dirOneBack_InstructionStreamID,
	input			[CHANNEL_ID_WIDTH-1:0]					dirOneBack_InstructionChannelID,
	input			[INSTRUCTION_PARAMETER_WIDTH-1:0]		dirOneBack_InstructionParameter,
	
	//FORWARD	INTERFACE	CTRL
	output	reg		[INSTRUCTION_WIDTH-1:0]					dirOneFront_InstructionType = INSTRUCTION_CMD_IDLE,
	output	reg		[STREAM_ID_WIDTH-1:0]					dirOneFront_InstructionStreamID,
	output	reg		[CHANNEL_ID_WIDTH-1:0]					dirOneFront_InstructionChannelID,
	output	reg		[INSTRUCTION_PARAMETER_WIDTH-1:0]		dirOneFront_InstructionParameter,
	
//DIRECTION	TWO
	//FORWARD	INTERFACE	DATA
	input			[DATA_WIDTH-1:0]						dirTwoFront_Data,
	input			[1:0]									dirTwoFront_Type,
	input													dirTwoFront_Last,
	input			[STREAM_ID_WIDTH-1:0]					dirTwoFront_StreamID,
	input			[CHUNK_ID_WIDTH-1:0]					dirTwoFront_ChunkID,
	input			[CHANNEL_ID_WIDTH-1:0]					dirTwoFront_ChannelID,
	input			[STATE_WIDTH-1:0]						dirTwoFront_State,
	
	//BACKWARD	INTERFACE	DATA
	output	reg		[DATA_WIDTH-1:0]						dirTwoBack_Data,
	output	reg		[1:0]									dirTwoBack_Type = 0,
	output	reg												dirTwoBack_Last,
	output	reg		[STREAM_ID_WIDTH-1:0]					dirTwoBack_StreamID,
	output	reg		[CHUNK_ID_WIDTH-1:0]					dirTwoBack_ChunkID,
	output	reg		[CHANNEL_ID_WIDTH-1:0]					dirTwoBack_ChannelID,
	output	reg		[STATE_WIDTH-1:0]						dirTwoBack_State,
	
	//BACKWARD	INTERFACE	INPUT
	input			[INSTRUCTION_WIDTH-1:0]					dirTwoBack_InstructionType,
	input			[STREAM_ID_WIDTH-1:0]					dirTwoBack_InstructionStreamID,
	input			[CHANNEL_ID_WIDTH-1:0]					dirTwoBack_InstructionChannelID,
	input			[INSTRUCTION_PARAMETER_WIDTH-1:0]		dirTwoBack_InstructionParameter,
	
	//BACKWARD	INTERFACE	OUTPUT
	output	reg		[INSTRUCTION_WIDTH-1:0]					dirTwoFront_InstructionType = INSTRUCTION_CMD_IDLE,
	output	reg		[STREAM_ID_WIDTH-1:0]					dirTwoFront_InstructionStreamID,
	output	reg		[CHANNEL_ID_WIDTH-1:0]					dirTwoFront_InstructionChannelID,
	output	reg		[INSTRUCTION_PARAMETER_WIDTH-1:0]		dirTwoFront_InstructionParameter
);
	integer i;
	reg[DATA_WIDTH+2+1+STREAM_ID_WIDTH+CHUNK_ID_WIDTH+CHANNEL_ID_WIDTH+STATE_WIDTH-1:0]dirOneData[0:DIR_ONE_STAGES_DATA-1];
	initial begin
		for(i=0;i<DIR_ONE_STAGES_DATA;i=i+1)
			dirOneData[i]<=0;
	end
	always@(posedge clk)begin
		dirOneData[0]<={dirOneFront_Data,dirOneFront_Type,dirOneFront_Last,dirOneFront_StreamID,dirOneFront_ChunkID,dirOneFront_ChannelID,dirOneFront_State};
		{dirOneBack_Data,dirOneBack_Type,dirOneBack_Last,dirOneBack_StreamID,dirOneBack_ChunkID,dirOneBack_ChannelID,dirOneBack_State}<=dirOneData[DIR_ONE_STAGES_DATA-1];
		for(i=0;i<DIR_ONE_STAGES_DATA-1;i=i+1)
			dirOneData[i+1]<=dirOneData[i];
	end

	reg[DATA_WIDTH+2+1+STREAM_ID_WIDTH+CHUNK_ID_WIDTH+CHANNEL_ID_WIDTH+STATE_WIDTH-1:0]dirTwoData[0:DIR_TWO_STAGES_DATA-1];
	initial	begin
		for(i=0;i<DIR_TWO_STAGES_DATA;i=i+1)
			dirTwoData[i]<=0;
	end
	always@(posedge clk)begin
		dirTwoData[0]<={dirTwoFront_Data,dirTwoFront_Type,dirTwoFront_Last,dirTwoFront_StreamID,dirTwoFront_ChunkID,dirTwoFront_ChannelID,dirTwoFront_State};
		{dirTwoBack_Data,dirTwoBack_Type,dirTwoBack_Last,dirTwoBack_StreamID,dirTwoBack_ChunkID,dirTwoBack_ChannelID,dirTwoBack_State}<=dirTwoData[DIR_TWO_STAGES_DATA-1];
		for(i=0;i<DIR_TWO_STAGES_DATA-1;i=i+1)
			dirTwoData[i+1]<=dirTwoData[i];
	end

	reg[INSTRUCTION_WIDTH+STREAM_ID_WIDTH+CHANNEL_ID_WIDTH+INSTRUCTION_PARAMETER_WIDTH-1:0]dirOneCtrl[0:DIR_ONE_STAGES_CTRL-1];
	initial begin
		for(i=0;i<DIR_ONE_STAGES_CTRL;i=i+1)
			dirOneCtrl[i]<=0;
	end
	always@(posedge clk)begin
		dirOneCtrl[0]<={dirOneBack_InstructionType,dirOneBack_InstructionStreamID,dirOneBack_InstructionChannelID,dirOneBack_InstructionParameter};
		{dirOneFront_InstructionType,dirOneFront_InstructionStreamID,dirOneFront_InstructionChannelID,dirOneFront_InstructionParameter}<=dirOneCtrl[DIR_ONE_STAGES_CTRL-1];
		for(i=0;i<DIR_ONE_STAGES_CTRL-1;i=i+1)
			dirOneCtrl[i+1]<=dirOneCtrl[i];
	end

	reg[INSTRUCTION_WIDTH+STREAM_ID_WIDTH+CHANNEL_ID_WIDTH+INSTRUCTION_PARAMETER_WIDTH-1:0]dirTwoCtrl[0:DIR_TWO_STAGES_CTRL-1];
	initial begin
		for(i=0;i<DIR_TWO_STAGES_CTRL;i=i+1)
			dirTwoCtrl[i]<=0;
	end
	always@(posedge clk)begin
		dirTwoCtrl[0]<={dirTwoBack_InstructionType,dirTwoBack_InstructionStreamID,dirTwoBack_InstructionChannelID,dirTwoBack_InstructionParameter};
		{dirTwoFront_InstructionType,dirTwoFront_InstructionStreamID,dirTwoFront_InstructionChannelID,dirTwoFront_InstructionParameter}<=dirTwoCtrl[DIR_TWO_STAGES_CTRL-1];
		for(i=0;i<DIR_TWO_STAGES_CTRL-1;i=i+1)
			dirTwoCtrl[i+1]<=dirTwoCtrl[i];
	end

endmodule

module dummyHead (
    input  logic clk,
	input  logic leftEar,
	output logic rightEar
);

always_ff @(posedge clk) begin
		rightEar <= leftEar;
end

endmodule
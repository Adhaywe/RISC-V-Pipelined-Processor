//-----------------------------
// SystemVerilog 
// datapath.sv
// 
// data path
// 25.02.2025
//-----------------------------


module datapath (input logic clk, reset,
				input logic [1:0] ResultSrc,
				input logic PCSrc, ALUSrc,
				input logic RegWrite,
				input logic [1:0] ImmSrc,
				input logic [2:0] ALUControl,
				output logic Zero,
				output logic [31:0] PC,
				input logic [31:0] Instr,
				output logic [31:0] ALUResult, WriteData,
				input logic [31:0] ReadData);

logic [31:0] PCNext, PCPlus4, PCTarget;
logic [31:0] ImmExt;
logic [31:0] SrcA, SrcB;
logic [31:0] Result;
parameter WIDTH = 32;

// next PC logic
flopr #(.WIDTH(WIDTH)) pcreg (.clk(clk), 
                              .reset(reset),
							  .d(PCNext), 
							  .q(PC));
 
adder pcadd4 (.a(PC), 
              .b(32'd4), 
			  .y(PCPlus4));

adder pcaddbranch(.a(PC), 
                  .b(ImmExt), 
				  .y(PCTarget));

mux2 #(.WIDTH(WIDTH)) pcmux (.d0(PCPlus4), 
                             .d1(PCTarget), 
							 .s(PCSrc), 
							 .y(PCNext));


// register file logic
regfile rf (.clk(clk), 
            .we3(RegWrite), 
			.a1(Instr[19:15]), 
			.a2(Instr[24:20]), 
			.a3(Instr[11:7]), 
			.wd3(Result), 
			.rd1(SrcA), 
			.rd2(WriteData));
 
extend ext (.instr(Instr[31:7]), 
            .immsrc(ImmSrc), 
			.immext(ImmExt));

// ALU logic
mux2 #(.WIDTH(WIDTH)) srcbmux (.d0(WriteData), 
                               .d1(ImmExt), 
							   .s(ALUSrc), 
							   .y(SrcB));

alu al (.a(SrcA), 
        .b(SrcB), 
		.ALUControl(ALUControl), 
		.ALUResult(ALUResult), 
		.Zero(Zero));

mux3 #(.WIDTH(WIDTH)) resultmux (.d0(ALUResult), 
                                 .d1(ReadData), 
								 .d2(PCPlus4), 
								 .s(ResultSrc), 
								 .y(Result));

endmodule
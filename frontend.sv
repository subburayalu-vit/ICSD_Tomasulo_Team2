`timescale 1ns/1ps

module frontend #(
    parameter logic [31:0] RESET_PC = 32'h0000_0000
)(
    input  logic clk,
    input  logic reset,
    input  logic [31:0] mem_inst,
    input  logic stall,

    output logic [31:0] pc,
    output logic [31:0] next_pc,
    output rv32i_types::DecodedInst decoded_inst
);

    import rv32i_types::*;

    // ============================================================
    // PC REGISTER
    // ============================================================

    always_ff @(posedge clk) begin
        if (reset)
            pc <= RESET_PC;
        else if (!stall)
            pc <= next_pc;
    end

    // ============================================================
    // NEXT PC
    // ============================================================

    always_comb begin
        next_pc = pc + 32'd4;
    end

    // ============================================================
    // INSTRUCTION DECODE
    // ============================================================

    always_comb begin

        // Default values
        decoded_inst = '0;

        decoded_inst.valid     = !reset;
        decoded_inst.supported = 1'b0;

        decoded_inst.pc       = pc;
        decoded_inst.opcode   = mem_inst[6:0];

        decoded_inst.rd       = mem_inst[11:7];
        decoded_inst.rs1      = mem_inst[19:15];
        decoded_inst.rs2      = mem_inst[24:20];

        decoded_inst.funct3   = mem_inst[14:12];
        decoded_inst.funct7   = mem_inst[31:25];

        decoded_inst.imm      = 32'h0000_0000;
        decoded_inst.op_name  = NOP;

        if (!reset) begin

            case (mem_inst[6:0])

                // ====================================================
                // R-TYPE
                // ====================================================

                OPCODE_R: begin

                    case (mem_inst[14:12])

                        // ADD / SUB
                        3'b000: begin

                            if (mem_inst[30] == 1'b0)
                                decoded_inst.op_name = ADD;
                            else
                                decoded_inst.op_name = SUB;

                            decoded_inst.supported = 1'b1;

                        end

                        // SLL
                        3'b001: begin

                            decoded_inst.op_name  = SLL;
                            decoded_inst.supported = 1'b1;

                        end

                        // SLT
                        3'b010: begin

                            decoded_inst.op_name  = SLT;
                            decoded_inst.supported = 1'b1;

                        end

                        // SLTU
                        3'b011: begin

                            decoded_inst.op_name  = SLTU;
                            decoded_inst.supported = 1'b1;

                        end

                        // XOR
                        3'b100: begin

                            decoded_inst.op_name  = XOR;
                            decoded_inst.supported = 1'b1;

                        end

                        // SRL / SRA
                        3'b101: begin

                            if (mem_inst[30] == 1'b0)
                                decoded_inst.op_name = SRL;
                            else
                                decoded_inst.op_name = SRA;

                            decoded_inst.supported = 1'b1;

                        end

                        // OR
                        3'b110: begin

                            decoded_inst.op_name  = OR;
                            decoded_inst.supported = 1'b1;

                        end

                        // AND
                        3'b111: begin

                            decoded_inst.op_name  = AND;
                            decoded_inst.supported = 1'b1;

                        end

                        default: begin

                            decoded_inst.op_name  = NOP;
                            decoded_inst.supported = 1'b0;

                        end

                    endcase

                end


                // ====================================================
                // I-TYPE ALU
                // ====================================================

                OPCODE_I_ALU: begin

                    case (mem_inst[14:12])

                        // ADDI
                        3'b000: begin

                            decoded_inst.op_name  = ADD;

                            decoded_inst.imm =
                                sign_extend(
                                    {20'b0, mem_inst[31:20]},
                                    12
                                );

                            decoded_inst.supported = 1'b1;

                        end

                        // SLLI
                        3'b001: begin

                            decoded_inst.op_name = SLL;

                            // Document specifies that shift
                            // immediates hold shamt in [4:0]
                            decoded_inst.imm =
                                {27'b0, mem_inst[24:20]};

                            decoded_inst.supported = 1'b1;

                        end

                        // SLTI
                        3'b010: begin

                            decoded_inst.op_name = SLT;

                            decoded_inst.imm =
                                sign_extend(
                                    {20'b0, mem_inst[31:20]},
                                    12
                                );

                            decoded_inst.supported = 1'b1;

                        end

                        // SLTIU
                        3'b011: begin

                            decoded_inst.op_name = SLTU;

                            decoded_inst.imm =
                                sign_extend(
                                    {20'b0, mem_inst[31:20]},
                                    12
                                );

                            decoded_inst.supported = 1'b1;

                        end

                        // XORI
                        3'b100: begin

                            decoded_inst.op_name = XOR;

                            decoded_inst.imm =
                                sign_extend(
                                    {20'b0, mem_inst[31:20]},
                                    12
                                );

                            decoded_inst.supported = 1'b1;

                        end

                        // SRLI / SRAI
                        3'b101: begin

                            decoded_inst.imm =
                                {27'b0, mem_inst[24:20]};

                            if (mem_inst[30] == 1'b0)
                                decoded_inst.op_name = SRL;
                            else
                                decoded_inst.op_name = SRA;

                            decoded_inst.supported = 1'b1;

                        end

                        // ORI
                        3'b110: begin

                            decoded_inst.op_name = OR;

                            decoded_inst.imm =
                                sign_extend(
                                    {20'b0, mem_inst[31:20]},
                                    12
                                );

                            decoded_inst.supported = 1'b1;

                        end

                        // ANDI
                        3'b111: begin

                            decoded_inst.op_name = AND;

                            decoded_inst.imm =
                                sign_extend(
                                    {20'b0, mem_inst[31:20]},
                                    12
                                );

                            decoded_inst.supported = 1'b1;

                        end

                        default: begin

                            decoded_inst.op_name  = NOP;
                            decoded_inst.supported = 1'b0;

                        end

                    endcase

                end


                // ====================================================
                // LUI
                // ====================================================

                OPCODE_LUI: begin

                    decoded_inst.op_name = ADD;

                    decoded_inst.imm =
                        {mem_inst[31:12], 12'b0};

                    decoded_inst.supported = 1'b1;

                end


                // ====================================================
                // AUIPC
                // ====================================================

                OPCODE_AUIPC: begin

                    decoded_inst.op_name = ADD;

                    decoded_inst.imm =
                        {mem_inst[31:12], 12'b0};

                    decoded_inst.supported = 1'b1;

                end


                // ====================================================
                // ALL OTHER INSTRUCTIONS
                // ====================================================

                default: begin

                    decoded_inst.op_name  = NOP;
                    decoded_inst.supported = 1'b0;

                end

            endcase

        end

    end

endmodule
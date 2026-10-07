`timescale 1ns/1ps

module tb_frontend;

    import rv32i_types::*;

    // ============================================================
    // SIGNALS
    // ============================================================

    logic clk;
    logic reset;
    logic stall;

    logic [31:0] mem_inst;

    logic [31:0] pc;
    logic [31:0] next_pc;

    DecodedInst decoded_inst;

    integer pass_count;
    integer fail_count;


    // ============================================================
    // DUT
    // ============================================================

    frontend #(
        .RESET_PC(32'h0000_0000)
    ) dut (
        .clk          (clk),
        .reset        (reset),
        .mem_inst     (mem_inst),
        .stall        (stall),
        .pc            (pc),
        .next_pc      (next_pc),
        .decoded_inst (decoded_inst)
    );


    // ============================================================
    // CLOCK
    // ============================================================

    initial begin

        clk = 1'b0;

        forever #5 clk = ~clk;

    end


    // ============================================================
    // INSTRUCTION MEMORY MODEL
    // ============================================================

    always_comb begin

        case (pc)

            // ====================================================
            // R-TYPE
            // ====================================================

            32'h0000_0000:
                mem_inst = enc_r(
                    7'b0000000,
                    5'd2,
                    5'd1,
                    3'b000,
                    5'd3,
                    OPCODE_R
                );                                      // ADD

            32'h0000_0004:
                mem_inst = enc_r(
                    7'b0100000,
                    5'd2,
                    5'd1,
                    3'b000,
                    5'd3,
                    OPCODE_R
                );                                      // SUB

            32'h0000_0008:
                mem_inst = enc_r(
                    7'b0000000,
                    5'd2,
                    5'd1,
                    3'b001,
                    5'd3,
                    OPCODE_R
                );                                      // SLL

            32'h0000_000c:
                mem_inst = enc_r(
                    7'b0000000,
                    5'd2,
                    5'd1,
                    3'b010,
                    5'd3,
                    OPCODE_R
                );                                      // SLT

            32'h0000_0010:
                mem_inst = enc_r(
                    7'b0000000,
                    5'd2,
                    5'd1,
                    3'b011,
                    5'd3,
                    OPCODE_R
                );                                      // SLTU

            32'h0000_0014:
                mem_inst = enc_r(
                    7'b0000000,
                    5'd2,
                    5'd1,
                    3'b100,
                    5'd3,
                    OPCODE_R
                );                                      // XOR

            32'h0000_0018:
                mem_inst = enc_r(
                    7'b0000000,
                    5'd2,
                    5'd1,
                    3'b101,
                    5'd3,
                    OPCODE_R
                );                                      // SRL

            32'h0000_001c:
                mem_inst = enc_r(
                    7'b0100000,
                    5'd2,
                    5'd1,
                    3'b101,
                    5'd3,
                    OPCODE_R
                );                                      // SRA

            32'h0000_0020:
                mem_inst = enc_r(
                    7'b0000000,
                    5'd2,
                    5'd1,
                    3'b110,
                    5'd3,
                    OPCODE_R
                );                                      // OR

            32'h0000_0024:
                mem_inst = enc_r(
                    7'b0000000,
                    5'd2,
                    5'd1,
                    3'b111,
                    5'd3,
                    OPCODE_R
                );                                      // AND


            // ====================================================
            // I-TYPE ALU
            // ====================================================

            32'h0000_0028:
                mem_inst = enc_i(
                    12'h005,
                    5'd1,
                    3'b000,
                    5'd3
                );                                      // ADDI

            32'h0000_002c:
                mem_inst = enc_i(
                    12'hfff,
                    5'd1,
                    3'b000,
                    5'd3
                );                                      // ADDI -1

            32'h0000_0030:
                mem_inst = enc_i(
                    12'h005,
                    5'd1,
                    3'b010,
                    5'd3
                );                                      // SLTI

            32'h0000_0034:
                mem_inst = enc_i(
                    12'h005,
                    5'd1,
                    3'b011,
                    5'd3
                );                                      // SLTIU

            32'h0000_0038:
                mem_inst = enc_i(
                    12'h005,
                    5'd1,
                    3'b100,
                    5'd3
                );                                      // XORI

            32'h0000_003c:
                mem_inst = enc_i(
                    12'h005,
                    5'd1,
                    3'b110,
                    5'd3
                );                                      // ORI


            // ====================================================
            // SHIFT IMMEDIATE
            // ====================================================

            32'h0000_0040:
                mem_inst = enc_shift(
                    5'd3,
                    5'd1,
                    3'b001,
                    5'd3,
                    1'b0
                );                                      // SLLI

            32'h0000_0044:
                mem_inst = enc_shift(
                    5'd3,
                    5'd1,
                    3'b101,
                    5'd3,
                    1'b0
                );                                      // SRLI

            32'h0000_0048:
                mem_inst = enc_shift(
                    5'd3,
                    5'd1,
                    3'b101,
                    5'd3,
                    1'b1
                );                                      // SRAI


            // ====================================================
            // LUI
            // ====================================================

            32'h0000_004c:
                mem_inst = {
                    20'h12345,
                    5'd3,
                    OPCODE_LUI
                };


            // ====================================================
            // AUIPC
            // ====================================================

            32'h0000_0050:
                mem_inst = {
                    20'h12345,
                    5'd3,
                    OPCODE_AUIPC
                };


            // ====================================================
            // UNSUPPORTED LOAD
            // ====================================================

            32'h0000_0054:
                mem_inst = enc_i_opcode(
                    12'h010,
                    5'd1,
                    3'b010,
                    5'd3,
                    OPCODE_I_LOAD
                );


            // ====================================================
            // UNSUPPORTED STORE
            // ====================================================

            32'h0000_0058:
                mem_inst = enc_s(
                    12'h010,
                    5'd2,
                    5'd1,
                    3'b010
                );


            // ====================================================
            // UNSUPPORTED BRANCH
            // ====================================================

            32'h0000_005c:
                mem_inst = enc_b(
                    13'h000,
                    5'd2,
                    5'd1,
                    3'b000
                );


            // ====================================================
            // UNSUPPORTED JAL
            // ====================================================

            32'h0000_0060:
                mem_inst = enc_j(
                    21'h00000,
                    5'd3
                );


            // ====================================================
            // UNSUPPORTED JALR
            // ====================================================

            32'h0000_0064:
                mem_inst = enc_i_opcode(
                    12'h010,
                    5'd1,
                    3'b000,
                    5'd3,
                    OPCODE_I_JALR
                );


            // ====================================================
            // FENCE
            // ====================================================

            32'h0000_0068:
                mem_inst = 32'h0000000f;


            // ====================================================
            // ECALL
            // ====================================================

            32'h0000_006c:
                mem_inst = 32'h00000073;


            // ====================================================
            // EBREAK
            // ====================================================

            32'h0000_0070:
                mem_inst = 32'h00100073;


            // ====================================================
            // DEFAULT = NOP
            // ====================================================

            default:
                mem_inst = 32'h00000013;

        endcase

    end


    // ============================================================
    // R-TYPE ENCODER
    // ============================================================

    function automatic [31:0] enc_r(
        input [6:0] funct7,
        input [4:0] rs2,
        input [4:0] rs1,
        input [2:0] funct3,
        input [4:0] rd,
        input [6:0] opcode
    );

        enc_r = {
            funct7,
            rs2,
            rs1,
            funct3,
            rd,
            opcode
        };

    endfunction


    // ============================================================
    // I-TYPE ALU ENCODER
    // ============================================================

    function automatic [31:0] enc_i(
        input [11:0] imm,
        input [4:0] rs1,
        input [2:0] funct3,
        input [4:0] rd
    );

        enc_i = {
            imm,
            rs1,
            funct3,
            rd,
            OPCODE_I_ALU
        };

    endfunction


    // ============================================================
    // GENERIC I-TYPE ENCODER
    // ============================================================

    function automatic [31:0] enc_i_opcode(
        input [11:0] imm,
        input [4:0] rs1,
        input [2:0] funct3,
        input [4:0] rd,
        input [6:0] opcode
    );

        enc_i_opcode = {
            imm,
            rs1,
            funct3,
            rd,
            opcode
        };

    endfunction


    // ============================================================
    // SHIFT ENCODER
    // ============================================================

    function automatic [31:0] enc_shift(
        input [4:0] shamt,
        input [4:0] rs1,
        input [2:0] funct3,
        input [4:0] rd,
        input sra
    );

        if (sra) begin

            enc_shift = {
                7'b0100000,
                shamt,
                rs1,
                funct3,
                rd,
                OPCODE_I_ALU
            };

        end
        else begin

            enc_shift = {
                7'b0000000,
                shamt,
                rs1,
                funct3,
                rd,
                OPCODE_I_ALU
            };

        end

    endfunction


    // ============================================================
    // S-TYPE ENCODER
    // ============================================================

    function automatic [31:0] enc_s(
        input [11:0] imm,
        input [4:0] rs2,
        input [4:0] rs1,
        input [2:0] funct3
    );

        enc_s = {
            imm[11:5],
            rs2,
            rs1,
            funct3,
            imm[4:0],
            OPCODE_S
        };

    endfunction


    // ============================================================
    // B-TYPE ENCODER
    // ============================================================

    function automatic [31:0] enc_b(
        input [12:0] imm,
        input [4:0] rs2,
        input [4:0] rs1,
        input [2:0] funct3
    );

        enc_b = {
            imm[12],
            imm[10:5],
            rs2,
            rs1,
            funct3,
            imm[4:1],
            imm[11],
            1'b0,
            OPCODE_B
        };

    endfunction


    // ============================================================
    // J-TYPE ENCODER
    // ============================================================

    function automatic [31:0] enc_j(
        input [20:0] imm,
        input [4:0] rd
    );

        enc_j = {
            imm[20],
            imm[10:1],
            imm[11],
            imm[19:12],
            rd,
            OPCODE_J
        };

    endfunction


    // ============================================================
    // DECODE CHECK TASK
    // ============================================================

    task automatic check_decode(
        input [31:0] expected_pc,
        input [4:0] expected_rd,
        input alu_op_t expected_op,
        input [31:0] expected_imm,
        input expected_supported
    );

        begin

            #1;

            if (
                decoded_inst.valid == 1'b1 &&
                decoded_inst.pc == expected_pc &&
                decoded_inst.rd == expected_rd &&
                decoded_inst.op_name == expected_op &&
                decoded_inst.imm == expected_imm &&
                decoded_inst.supported == expected_supported
            ) begin

                $display(
                    "PASS | PC=%08h | RD=%0d | OP=%0d | IMM=%08h | SUP=%b",
                    decoded_inst.pc,
                    decoded_inst.rd,
                    decoded_inst.op_name,
                    decoded_inst.imm,
                    decoded_inst.supported
                );

                pass_count = pass_count + 1;

            end
            else begin

                $display("FAIL");
                $display(
                    "  ACTUAL   : PC=%08h RD=%0d OP=%0d IMM=%08h SUP=%b",
                    decoded_inst.pc,
                    decoded_inst.rd,
                    decoded_inst.op_name,
                    decoded_inst.imm,
                    decoded_inst.supported
                );

                $display(
                    "  EXPECTED : PC=%08h RD=%0d OP=%0d IMM=%08h SUP=%b",
                    expected_pc,
                    expected_rd,
                    expected_op,
                    expected_imm,
                    expected_supported
                );

                fail_count = fail_count + 1;

            end

        end

    endtask


    // ============================================================
    // UNSUPPORTED CHECK
    // ============================================================

    task automatic check_unsupported(
        input [31:0] expected_pc
    );

        begin

            #1;

            if (
                decoded_inst.valid == 1'b1 &&
                decoded_inst.pc == expected_pc &&
                decoded_inst.supported == 1'b0 &&
                decoded_inst.op_name == NOP
            ) begin

                $display(
                    "PASS | Unsupported instruction at PC=%08h -> NOP",
                    expected_pc
                );

                pass_count = pass_count + 1;

            end
            else begin

                $display(
                    "FAIL | Unsupported instruction at PC=%08h",
                    expected_pc
                );

                $display(
                    "  ACTUAL: valid=%b supported=%b op=%0d",
                    decoded_inst.valid,
                    decoded_inst.supported,
                    decoded_inst.op_name
                );

                fail_count = fail_count + 1;

            end

        end

    endtask


    // ============================================================
    // MAIN TEST
    // ============================================================

    initial begin

        pass_count = 0;
        fail_count = 0;

        reset = 1'b1;
        stall = 1'b0;

        // ========================================================
        // RESET
        // ========================================================

        #1;

        if (decoded_inst.valid == 1'b0) begin

            $display("PASS | valid=0 during reset");

            pass_count = pass_count + 1;

        end
        else begin

            $display("FAIL | valid should be 0 during reset");

            fail_count = fail_count + 1;

        end


        @(posedge clk);
        #1;

        if (pc == 32'h00000000) begin

            $display("PASS | PC reset = 0");

            pass_count = pass_count + 1;

        end
        else begin

            $display(
                "FAIL | PC reset expected 0, got %08h",
                pc
            );

            fail_count = fail_count + 1;

        end


        // Release reset
        reset = 1'b0;


        // ========================================================
        // R-TYPE
        // ========================================================

        check_decode(
            32'h00000000,
            5'd3,
            ADD,
            32'h00000000,
            1'b1
        );

        @(posedge clk);

        check_decode(
            32'h00000004,
            5'd3,
            SUB,
            32'h00000000,
            1'b1
        );

        @(posedge clk);

        check_decode(
            32'h00000008,
            5'd3,
            SLL,
            32'h00000000,
            1'b1
        );

        @(posedge clk);

        check_decode(
            32'h0000000c,
            5'd3,
            SLT,
            32'h00000000,
            1'b1
        );

        @(posedge clk);

        check_decode(
            32'h00000010,
            5'd3,
            SLTU,
            32'h00000000,
            1'b1
        );

        @(posedge clk);

        check_decode(
            32'h00000014,
            5'd3,
            XOR,
            32'h00000000,
            1'b1
        );

        @(posedge clk);

        check_decode(
            32'h00000018,
            5'd3,
            SRL,
            32'h00000000,
            1'b1
        );

        @(posedge clk);

        check_decode(
            32'h0000001c,
            5'd3,
            SRA,
            32'h00000000,
            1'b1
        );

        @(posedge clk);

        check_decode(
            32'h00000020,
            5'd3,
            OR,
            32'h00000000,
            1'b1
        );

        @(posedge clk);

        check_decode(
            32'h00000024,
            5'd3,
            AND,
            32'h00000000,
            1'b1
        );


        // ========================================================
        // I-TYPE ALU
        // ========================================================

        @(posedge clk);

        check_decode(
            32'h00000028,
            5'd3,
            ADD,
            32'h00000005,
            1'b1
        );

        @(posedge clk);

        check_decode(
            32'h0000002c,
            5'd3,
            ADD,
            32'hffffffff,
            1'b1
        );

        @(posedge clk);

        check_decode(
            32'h00000030,
            5'd3,
            SLT,
            32'h00000005,
            1'b1
        );

        @(posedge clk);

        check_decode(
            32'h00000034,
            5'd3,
            SLTU,
            32'h00000005,
            1'b1
        );

        @(posedge clk);

        check_decode(
            32'h00000038,
            5'd3,
            XOR,
            32'h00000005,
            1'b1
        );

        @(posedge clk);

        check_decode(
            32'h0000003c,
            5'd3,
            OR,
            32'h00000005,
            1'b1
        );


        // ========================================================
        // SHIFT IMMEDIATE
        // ========================================================

        @(posedge clk);

        check_decode(
            32'h00000040,
            5'd3,
            SLL,
            32'h00000003,
            1'b1
        );

        @(posedge clk);

        check_decode(
            32'h00000044,
            5'd3,
            SRL,
            32'h00000003,
            1'b1
        );

        @(posedge clk);

        check_decode(
            32'h00000048,
            5'd3,
            SRA,
            32'h00000003,
            1'b1
        );


        // ========================================================
        // LUI
        // ========================================================

        @(posedge clk);

        check_decode(
            32'h0000004c,
            5'd3,
            ADD,
            32'h12345000,
            1'b1
        );


        // ========================================================
        // AUIPC
        // ========================================================

        @(posedge clk);

        check_decode(
            32'h00000050,
            5'd3,
            ADD,
            32'h12345000,
            1'b1
        );


        // ========================================================
        // UNSUPPORTED INSTRUCTIONS
        // ========================================================

        @(posedge clk);

        check_unsupported(32'h00000054);

        @(posedge clk);

        check_unsupported(32'h00000058);

        @(posedge clk);

        check_unsupported(32'h0000005c);

        @(posedge clk);

        check_unsupported(32'h00000060);

        @(posedge clk);

        check_unsupported(32'h00000064);

        @(posedge clk);

        check_unsupported(32'h00000068);

        @(posedge clk);

        check_unsupported(32'h0000006c);

        @(posedge clk);

        check_unsupported(32'h00000070);


        // ========================================================
        // PC STALL TEST
        // ========================================================

        reset = 1'b1;

        @(posedge clk);
        #1;

        reset = 1'b0;
        stall = 1'b0;

        @(posedge clk);
        #1;

        if (pc == 32'h00000004) begin

            $display("PASS | PC advanced to 4");

            pass_count = pass_count + 1;

        end
        else begin

            $display(
                "FAIL | PC expected 4, got %08h",
                pc
            );

            fail_count = fail_count + 1;

        end


        stall = 1'b1;

        @(posedge clk);
        #1;

        if (pc == 32'h00000004) begin

            $display("PASS | PC held during stall");

            pass_count = pass_count + 1;

        end
        else begin

            $display(
                "FAIL | PC changed during stall: %08h",
                pc
            );

            fail_count = fail_count + 1;

        end


        stall = 1'b0;

        @(posedge clk);
        #1;

        if (pc == 32'h00000008) begin

            $display("PASS | PC resumed after stall");

            pass_count = pass_count + 1;

        end
        else begin

            $display(
                "FAIL | PC did not resume: %08h",
                pc
            );

            fail_count = fail_count + 1;

        end


        // ========================================================
        // FINAL RESULT
        // ========================================================

        $display("");
        $display("================================================");
        $display("       FRONTEND / RV32I TEST RESULT");
        $display("================================================");

        $display("PASS COUNT = %0d", pass_count);
        $display("FAIL COUNT = %0d", fail_count);

        $display("================================================");

        if (fail_count == 0)
            $display("*** ALL TESTS PASS ***");
        else
            $display("*** TESTS FAILED ***");

        $display("================================================");

        $finish;

    end

endmodule
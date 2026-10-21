
`timescale 1ns/1ps

module tb_tomasulo_core;

    import rv32i_types::*;

    // Inputs to the core
    DecodedInst decoded_inst;

    logic [3:0] rat_tag1, rat_tag2;
    logic [31:0] arf_read_data1, arf_read_data2;
    logic rs_has_free;
    logic [3:0] rs_free_tag;

    logic cdb_valid;
    logic [3:0] cdb_tag;
    logic [31:0] cdb_data;

    // Outputs from the core
    logic rs_alloc_en;
    logic [3:0] rs_alloc_op;
    logic [31:0] rs_alloc_Vj, rs_alloc_Vk;
    logic [3:0] rs_alloc_Qj, rs_alloc_Qk;
    logic [4:0] rs_alloc_dest;

    logic issue_en;
    logic [4:0] issue_dest;
    logic [3:0] issue_tag;

    logic [4:0] lookup_reg1, lookup_reg2;
    logic stall_frontend;

    // DUT: Design Under Test
    tomasulo_core dut (
        .decoded_inst(decoded_inst),
        .rat_tag1(rat_tag1),
        .rat_tag2(rat_tag2),
        .arf_read_data1(arf_read_data1),
        .arf_read_data2(arf_read_data2),
        .rs_has_free(rs_has_free),
        .rs_free_tag(rs_free_tag),
        .rs_alloc_en(rs_alloc_en),
        .rs_alloc_op(rs_alloc_op),
        .rs_alloc_Vj(rs_alloc_Vj),
        .rs_alloc_Vk(rs_alloc_Vk),
        .rs_alloc_Qj(rs_alloc_Qj),
        .rs_alloc_Qk(rs_alloc_Qk),
        .rs_alloc_dest(rs_alloc_dest),
        .issue_en(issue_en),
        .issue_dest(issue_dest),
        .issue_tag(issue_tag),
        .lookup_reg1(lookup_reg1),
        .lookup_reg2(lookup_reg2),
        .cdb_valid(cdb_valid),
        .cdb_tag(cdb_tag),
        .cdb_data(cdb_data),
        .stall_frontend(stall_frontend)
    );

    initial begin
        // Initialize all inputs
        decoded_inst = '0;
        rat_tag1 = NONE;
        rat_tag2 = NONE;
        arf_read_data1 = 0;
        arf_read_data2 = 0;
        rs_has_free = 1;
        rs_free_tag = ALU1;
        cdb_valid = 0;
        cdb_tag = NONE;
        cdb_data = 0;

        #10;

        // TEST 1: ADD x5, x1, x2
        decoded_inst.valid = 1;
        decoded_inst.supported = 1;
        decoded_inst.opcode = OPCODE_R;
        decoded_inst.rd = 5;
        decoded_inst.rs1 = 1;
        decoded_inst.rs2 = 2;
        decoded_inst.op_name = ADD;

        arf_read_data1 = 10;
        arf_read_data2 = 20;

        #10;
        $display("TEST 1: ADD");
        $display("issue_en=%0b dest=%0d tag=%0d Vj=%0d Vk=%0d",
                 issue_en, issue_dest, issue_tag,
                 rs_alloc_Vj, rs_alloc_Vk);

        if (issue_en && rs_alloc_Vj == 10 && rs_alloc_Vk == 20)
            $display("PASS: ADD operands and issue");
        else
            $display("FAIL: ADD operands and issue");

        // TEST 2: Source operand waiting for ALU2
        rat_tag1 = ALU2;
        rat_tag2 = NONE;
        cdb_valid = 0;

        #10;
        $display("TEST 2: Dependency");
        $display("Qj=%0d Vj=%0d", rs_alloc_Qj, rs_alloc_Vj);

        if (rs_alloc_Qj == ALU2)
            $display("PASS: Dependency tag propagated");
        else
            $display("FAIL: Dependency tag");

        // TEST 3: CDB bypass
        cdb_valid = 1;
        cdb_tag = ALU2;
        cdb_data = 99;

        #10;
        $display("TEST 3: CDB bypass");
        $display("Qj=%0d Vj=%0d", rs_alloc_Qj, rs_alloc_Vj);

        if (rs_alloc_Qj == NONE && rs_alloc_Vj == 99)
            $display("PASS: CDB bypass");
        else
            $display("FAIL: CDB bypass");

        // TEST 4: Reservation station full
        cdb_valid = 0;
        rs_has_free = 0;

        #10;
        $display("TEST 4: RS full");
        $display("stall_frontend=%0b", stall_frontend);

        if (stall_frontend)
            $display("PASS: Frontend stalls");
        else
            $display("FAIL: Frontend stall");

        // TEST 5: Invalid instruction
        decoded_inst.valid = 0;
        rs_has_free = 1;

        #10;
        $display("TEST 5: Invalid instruction");

        if (!issue_en && !stall_frontend)
            $display("PASS: Invalid instruction not issued");
        else
            $display("FAIL: Invalid instruction handling");

        // TEST 6: LUI uses zero as operand 1 and immediate as operand 2
        decoded_inst.valid = 1;
        decoded_inst.supported = 1;
        decoded_inst.opcode = OPCODE_LUI;
        decoded_inst.rd = 5;
        decoded_inst.rs1 = 0;
        decoded_inst.rs2 = 0;
        decoded_inst.imm = 32'h12345000;
        rat_tag1 = ALU2;
        rat_tag2 = ALU2;
        cdb_valid = 0;
        rs_has_free = 1;

        #10;
        $display("TEST 6: LUI");
        if (rs_alloc_Vj == 0 &&
            rs_alloc_Vk == 32'h12345000 &&
            rs_alloc_Qj == NONE &&
            rs_alloc_Qk == NONE)
            $display("PASS: LUI operand selection");
        else
            $display("FAIL: LUI operand selection");

        // TEST 7: AUIPC uses PC as operand 1
        decoded_inst.opcode = OPCODE_AUIPC;
        decoded_inst.pc = 32'h1000;
        decoded_inst.imm = 32'h20;

        #10;
        $display("TEST 7: AUIPC");
        if (rs_alloc_Vj == 32'h1000 &&
            rs_alloc_Vk == 32'h20 &&
            rs_alloc_Qj == NONE &&
            rs_alloc_Qk == NONE)
            $display("PASS: AUIPC operand selection");
        else
            $display("FAIL: AUIPC operand selection");

        // TEST 8: x0 always supplies zero
        decoded_inst.opcode = OPCODE_R;
        decoded_inst.rs1 = 0;
        decoded_inst.rs2 = 0;
        rat_tag1 = ALU2;
        rat_tag2 = ALU1;
        arf_read_data1 = 123;
        arf_read_data2 = 456;

        #10;
        $display("TEST 8: x0 operands");
        if (rs_alloc_Vj == 0 && rs_alloc_Vk == 0 &&
            rs_alloc_Qj == NONE && rs_alloc_Qk == NONE)
            $display("PASS: x0 returns zero");
        else
            $display("FAIL: x0 handling");

        // TEST 9: I-type uses immediate as operand 2
        decoded_inst.opcode = OPCODE_I_ALU;
        decoded_inst.rs1 = 1;
        decoded_inst.rs2 = 0;
        decoded_inst.imm = 32'hFFFFFFFC;
        rat_tag1 = NONE;
        arf_read_data1 = 7;

        #10;
        $display("TEST 9: I-type immediate");
        if (rs_alloc_Vj == 7 &&
            rs_alloc_Vk == 32'hFFFFFFFC &&
            rs_alloc_Qk == NONE)
            $display("PASS: I-type immediate selection");
        else
            $display("FAIL: I-type immediate selection");

        // TEST 10: Unsupported instruction must not issue
        decoded_inst.opcode = OPCODE_I_ALU;
        decoded_inst.supported = 0;

        #10;
        $display("TEST 10: Unsupported instruction");
        if (!issue_en && !rs_alloc_en && !stall_frontend)
            $display("PASS: Unsupported instruction not issued");
        else
            $display("FAIL: Unsupported instruction handling");

        $display("All tests completed.");
        $finish;
    end

endmodule

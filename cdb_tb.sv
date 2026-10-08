`timescale 1ns/1ps

module cdb_tb;

    logic clk;
    logic reset;

    logic        alu1_valid;
    logic [3:0]  alu1_tag;
    logic [31:0] alu1_data;

    logic        alu2_valid;
    logic [3:0]  alu2_tag;
    logic [31:0] alu2_data;

    logic        alu3_valid;
    logic [3:0]  alu3_tag;
    logic [31:0] alu3_data;

    logic        cdb_valid;
    logic [3:0]  cdb_tag;
    logic [31:0] cdb_data;

    cdb dut (
        .clk        (clk),
        .reset      (reset),

        .alu1_valid (alu1_valid),
        .alu1_tag   (alu1_tag),
        .alu1_data  (alu1_data),

        .alu2_valid (alu2_valid),
        .alu2_tag   (alu2_tag),
        .alu2_data  (alu2_data),

        .alu3_valid (alu3_valid),
        .alu3_tag   (alu3_tag),
        .alu3_data  (alu3_data),

        .cdb_valid  (cdb_valid),
        .cdb_tag    (cdb_tag),
        .cdb_data   (cdb_data)
    );

    initial begin
        clk = 0;
        forever #5 clk = ~clk;
    end

    initial begin

        reset = 1;

        alu1_valid = 0;
        alu1_tag   = 0;
        alu1_data  = 0;

        alu2_valid = 0;
        alu2_tag   = 0;
        alu2_data  = 0;

        alu3_valid = 0;
        alu3_tag   = 0;
        alu3_data  = 0;

        #10;

        reset = 0;

        // Test 1: No result
        #10;
        check(0, 0, 0, "No result");

        // Test 2: ALU1 only
        alu1_valid = 1;
        alu1_tag   = 4'd1;
        alu1_data  = 32'h11111111;
        #10;
        check(1, 1, 32'h11111111, "ALU1 only");

        // Test 3: ALU2 only
        alu1_valid = 0;
        alu2_valid = 1;
        alu2_tag   = 4'd2;
        alu2_data  = 32'h22222222;
        #10;
        check(1, 2, 32'h22222222, "ALU2 only");

        // Test 4: ALU3 only
        alu2_valid = 0;
        alu3_valid = 1;
        alu3_tag   = 4'd3;
        alu3_data  = 32'h33333333;
        #10;
        check(1, 3, 32'h33333333, "ALU3 only");

        // Test 5: ALU1 + ALU2 -> ALU1 wins
        alu1_valid = 1;
        alu1_tag   = 4'd1;
        alu1_data  = 32'hAAAA1111;
        alu2_valid = 1;
        alu2_tag   = 4'd2;
        alu2_data  = 32'hBBBB2222;
        alu3_valid = 0;
        #10;
        check(1, 1, 32'hAAAA1111, "ALU1 priority over ALU2");

        // Test 6: ALU2 + ALU3 -> ALU2 wins
        alu1_valid = 0;
        alu2_valid = 1;
        alu3_valid = 1;
        #10;
        check(1, 2, 32'hBBBB2222, "ALU2 priority over ALU3");

        // Test 7: All three -> ALU1 wins
        alu1_valid = 1;
        #10;
        check(1, 1, 32'hAAAA1111, "ALU1 priority over all");

        // Test 8: Back to idle
        alu1_valid = 0;
        alu2_valid = 0;
        alu3_valid = 0;
        #10;
        check(0, 0, 0, "Return to idle");

        $display("====================================");
        $display("CDB TEST COMPLETE");
        $display("====================================");

        $finish;
    end

    task check(
        input logic        exp_valid,
        input logic [3:0]  exp_tag,
        input logic [31:0] exp_data,
        input string       test_name
    );
        if (cdb_valid !== exp_valid ||
            cdb_tag   !== exp_tag   ||
            cdb_data  !== exp_data) begin

            $error("FAIL: %s | Expected: valid=%0d tag=%0d data=%h | Actual: valid=%0d tag=%0d data=%h",
                   test_name,
                   exp_valid, exp_tag, exp_data,
                   cdb_valid, cdb_tag, cdb_data);
        end
        else begin
            $display("PASS: %s", test_name);
        end
    endtask

endmodule
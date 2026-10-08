`include "uvm_macros.svh"
import uvm_pkg::*;

class cdb_sequence extends uvm_sequence #(cdb_transaction);

    `uvm_object_utils(cdb_sequence)

    function new(string name = "cdb_sequence");
        super.new(name);
    endfunction

    task body();
        cdb_transaction tr;

        // Test 1: No result
        tr = cdb_transaction::type_id::create("tr");
        start_item(tr);
        tr.reset = 0;
        tr.alu1_valid = 0;
        tr.alu2_valid = 0;
        tr.alu3_valid = 0;
        finish_item(tr);

        // Test 2: ALU1 only
        tr = cdb_transaction::type_id::create("tr");
        start_item(tr);
        tr.reset = 0;
        tr.alu1_valid = 1;
        tr.alu1_tag = 4'd1;
        tr.alu1_data = 32'h11111111;
        tr.alu2_valid = 0;
        tr.alu3_valid = 0;
        finish_item(tr);

        // Test 3: ALU2 only
        tr = cdb_transaction::type_id::create("tr");
        start_item(tr);
        tr.reset = 0;
        tr.alu1_valid = 0;
        tr.alu2_valid = 1;
        tr.alu2_tag = 4'd2;
        tr.alu2_data = 32'h22222222;
        tr.alu3_valid = 0;
        finish_item(tr);

        // Test 4: ALU3 only
        tr = cdb_transaction::type_id::create("tr");
        start_item(tr);
        tr.reset = 0;
        tr.alu1_valid = 0;
        tr.alu2_valid = 0;
        tr.alu3_valid = 1;
        tr.alu3_tag = 4'd3;
        tr.alu3_data = 32'h33333333;
        finish_item(tr);

        // Test 5: ALU1 + ALU2 -> ALU1 wins
        tr = cdb_transaction::type_id::create("tr");
        start_item(tr);
        tr.reset = 0;
        tr.alu1_valid = 1;
        tr.alu1_tag = 4'd1;
        tr.alu1_data = 32'hAAAA1111;
        tr.alu2_valid = 1;
        tr.alu2_tag = 4'd2;
        tr.alu2_data = 32'hBBBB2222;
        tr.alu3_valid = 0;
        finish_item(tr);

        // Test 6: ALU2 + ALU3 -> ALU2 wins
        tr = cdb_transaction::type_id::create("tr");
        start_item(tr);
        tr.reset = 0;
        tr.alu1_valid = 0;
        tr.alu2_valid = 1;
        tr.alu2_tag = 4'd2;
        tr.alu2_data = 32'hBBBB2222;
        tr.alu3_valid = 1;
        tr.alu3_tag = 4'd3;
        tr.alu3_data = 32'hCCCC3333;
        finish_item(tr);

        // Test 7: All three -> ALU1 wins
        tr = cdb_transaction::type_id::create("tr");
        start_item(tr);
        tr.reset = 0;
        tr.alu1_valid = 1;
        tr.alu1_tag = 4'd1;
        tr.alu1_data = 32'hAAAA1111;
        tr.alu2_valid = 1;
        tr.alu2_tag = 4'd2;
        tr.alu2_data = 32'hBBBB2222;
        tr.alu3_valid = 1;
        tr.alu3_tag = 4'd3;
        tr.alu3_data = 32'hCCCC3333;
        finish_item(tr);

        // Test 8: Reset / idle
tr = cdb_transaction::type_id::create("tr");
start_item(tr);
tr.reset      = 1;

tr.alu1_valid = 0;
tr.alu1_tag   = 4'd0;
tr.alu1_data  = 32'd0;

tr.alu2_valid = 0;
tr.alu2_tag   = 4'd0;
tr.alu2_data  = 32'd0;

tr.alu3_valid = 0;
tr.alu3_tag   = 4'd0;
tr.alu3_data  = 32'd0;

finish_item(tr);

    endtask

endclass
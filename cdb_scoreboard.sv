`include "uvm_macros.svh"
import uvm_pkg::*;

class cdb_scoreboard extends uvm_scoreboard;

    `uvm_component_utils(cdb_scoreboard)

    uvm_analysis_imp #(cdb_transaction, cdb_scoreboard) analysis_port;

    function new(string name = "cdb_scoreboard",
                 uvm_component parent = null);
        super.new(name, parent);
        analysis_port = new("analysis_port", this);
    endfunction

    function void write(cdb_transaction tr);

        bit        exp_valid;
        bit [3:0]  exp_tag;
        bit [31:0] exp_data;

        // Default: no broadcast
        exp_valid = 0;
        exp_tag   = 4'd0;
        exp_data  = 32'd0;

        if (!tr.reset) begin

            // Fixed priority: ALU1 > ALU2 > ALU3
            if (tr.alu1_valid) begin
                exp_valid = 1;
                exp_tag   = tr.alu1_tag;
                exp_data  = tr.alu1_data;
            end
            else if (tr.alu2_valid) begin
                exp_valid = 1;
                exp_tag   = tr.alu2_tag;
                exp_data  = tr.alu2_data;
            end
            else if (tr.alu3_valid) begin
                exp_valid = 1;
                exp_tag   = tr.alu3_tag;
                exp_data  = tr.alu3_data;
            end
        end

        if (tr.actual_valid !== exp_valid)
            `uvm_error("CDB_MISMATCH",
                $sformatf("VALID mismatch: Expected=%0d Actual=%0d",
                          exp_valid, tr.actual_valid));

        if (tr.actual_tag !== exp_tag)
            `uvm_error("CDB_MISMATCH",
                $sformatf("TAG mismatch: Expected=%0d Actual=%0d",
                          exp_tag, tr.actual_tag));

        if (tr.actual_data !== exp_data)
            `uvm_error("CDB_MISMATCH",
                $sformatf("DATA mismatch: Expected=%h Actual=%h",
                          exp_data, tr.actual_data));

        `uvm_info("CDB_SCOREBOARD",
                  "Expected CDB result compared with DUT result",
                  UVM_LOW);

    endfunction

endclass
`include "uvm_macros.svh"
import uvm_pkg::*;

class cdb_monitor extends uvm_monitor;

    `uvm_component_utils(cdb_monitor)

    virtual cdb_if vif;
    uvm_analysis_port #(cdb_transaction) analysis_port;

    function new(string name = "cdb_monitor",
                 uvm_component parent = null);
        super.new(name, parent);
        analysis_port = new("analysis_port", this);
    endfunction

    function void build_phase(uvm_phase phase);
        super.build_phase(phase);

        if (!uvm_config_db#(virtual cdb_if)::get(
                this, "", "vif", vif))
            `uvm_fatal("MONITOR", "Virtual interface not found")
    endfunction

    task run_phase(uvm_phase phase);
        cdb_transaction tr;

        forever begin

            // Wait for the clock edge
            @(posedge vif.clk);

            // Allow DUT combinational outputs to settle
            #1step;

            // Create transaction
            tr = cdb_transaction::type_id::create("tr");

            // Capture inputs
            tr.reset = vif.reset;

            tr.alu1_valid = vif.alu1_valid;
            tr.alu1_tag   = vif.alu1_tag;
            tr.alu1_data  = vif.alu1_data;

            tr.alu2_valid = vif.alu2_valid;
            tr.alu2_tag   = vif.alu2_tag;
            tr.alu2_data  = vif.alu2_data;

            tr.alu3_valid = vif.alu3_valid;
            tr.alu3_tag   = vif.alu3_tag;
            tr.alu3_data  = vif.alu3_data;

            // Capture DUT CDB output after it has settled
            tr.actual_valid = vif.cdb_valid;
            tr.actual_tag   = vif.cdb_tag;
            tr.actual_data  = vif.cdb_data;

            // Send transaction to scoreboard
            analysis_port.write(tr);

        end
    endtask

endclass
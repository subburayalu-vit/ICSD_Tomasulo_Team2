`include "uvm_macros.svh"
import uvm_pkg::*;

class cdb_driver extends uvm_driver #(cdb_transaction);

    `uvm_component_utils(cdb_driver)

    virtual cdb_if vif;

    function new(string name = "cdb_driver",
                 uvm_component parent = null);
        super.new(name, parent);
    endfunction

    function void build_phase(uvm_phase phase);
        super.build_phase(phase);

        if (!uvm_config_db#(virtual cdb_if)::get(
                this, "", "vif", vif))
            `uvm_fatal("DRIVER", "Virtual interface not found")
    endfunction

    task run_phase(uvm_phase phase);
        cdb_transaction tr;

        forever begin
            seq_item_port.get_next_item(tr);

            vif.reset = tr.reset;

            vif.alu1_valid = tr.alu1_valid;
            vif.alu1_tag   = tr.alu1_tag;
            vif.alu1_data  = tr.alu1_data;

            vif.alu2_valid = tr.alu2_valid;
            vif.alu2_tag   = tr.alu2_tag;
            vif.alu2_data  = tr.alu2_data;

            vif.alu3_valid = tr.alu3_valid;
            vif.alu3_tag   = tr.alu3_tag;
            vif.alu3_data  = tr.alu3_data;

            @(posedge vif.clk);

            seq_item_port.item_done();
        end
    endtask

endclass
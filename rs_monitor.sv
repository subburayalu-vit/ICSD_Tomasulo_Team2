`include "uvm_macros.svh"
import uvm_pkg::*;

class rs_monitor extends uvm_monitor;

    `uvm_component_utils(rs_monitor)

    virtual rs_if vif;

    uvm_analysis_port #(rs_transaction) analysis_port;


    function new(string name = "rs_monitor",
                 uvm_component parent = null);

        super.new(name, parent);

        analysis_port = new("analysis_port", this);

    endfunction


    function void build_phase(uvm_phase phase);

        super.build_phase(phase);

        if (!uvm_config_db#(virtual rs_if)::get(this, "", "vif", vif))
            `uvm_fatal("MONITOR",
                       "Virtual interface not found")

    endfunction


    task run_phase(uvm_phase phase);

        rs_transaction tr;

        forever begin

            // Capture the transaction at the clock edge
            @(posedge vif.clk);

            tr = rs_transaction::type_id::create("tr");

            // Capture inputs that were used by the DUT
            tr.reset      = vif.reset;

            tr.alloc_en   = vif.alloc_en;
            tr.alloc_op   = vif.alloc_op;
            tr.alloc_Vj   = vif.alloc_Vj;
            tr.alloc_Vk   = vif.alloc_Vk;
            tr.alloc_Qj   = vif.alloc_Qj;
            tr.alloc_Qk   = vif.alloc_Qk;
            tr.alloc_dest = vif.alloc_dest;

            tr.cdb_valid  = vif.cdb_valid;
            tr.cdb_tag    = vif.cdb_tag;
            tr.cdb_data   = vif.cdb_data;


            // Wait for DUT nonblocking assignments to complete
            #1step;


            // Capture resulting DUT state
            for (int i = 0; i < 3; i++) begin

                tr.actual_busy[i] = vif.rs_entries[i].busy;
                tr.actual_qj[i]   = vif.rs_entries[i].Qj;
                tr.actual_qk[i]   = vif.rs_entries[i].Qk;

            end

            tr.actual_ready = vif.ready;


            // Send complete transaction to scoreboard
            analysis_port.write(tr);

        end

    endtask

endclass
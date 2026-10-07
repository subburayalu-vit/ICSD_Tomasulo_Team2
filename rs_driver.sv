`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 07.10.2026 01:34:15
// Design Name: 
// Module Name: rs_driver
// Project Name: 
// Target Devices: 
// Tool Versions: 
// Description: 
// 
// Dependencies: 
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////////////////


`include "uvm_macros.svh"
import uvm_pkg::*;

class rs_driver extends uvm_driver #(rs_transaction);

    `uvm_component_utils(rs_driver)

    virtual rs_if vif;

    function new(string name = "rs_driver", uvm_component parent = null);
        super.new(name, parent);
    endfunction

    function void build_phase(uvm_phase phase);
        super.build_phase(phase);

        if (!uvm_config_db#(virtual rs_if)::get(this, "", "vif", vif))
            `uvm_fatal("DRIVER", "Virtual interface not found")
    endfunction

    task run_phase(uvm_phase phase);

    forever begin
        seq_item_port.get_next_item(req);

        vif.reset     <= req.reset;
        vif.alloc_en  <= req.alloc_en;
        vif.alloc_op  <= req.alloc_op;
        vif.alloc_Vj  <= req.alloc_Vj;
        vif.alloc_Vk  <= req.alloc_Vk;
        vif.alloc_Qj  <= req.alloc_Qj;
        vif.alloc_Qk  <= req.alloc_Qk;
        vif.alloc_dest <= req.alloc_dest;

        vif.cdb_valid <= req.cdb_valid;
        vif.cdb_tag   <= req.cdb_tag;
        vif.cdb_data  <= req.cdb_data;

        @(posedge vif.clk);

        seq_item_port.item_done();
    end

endtask

endclass

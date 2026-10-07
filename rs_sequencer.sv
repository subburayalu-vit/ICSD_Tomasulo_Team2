`include "uvm_macros.svh"
import uvm_pkg::*;

class rs_sequencer extends uvm_sequencer #(rs_transaction);

    `uvm_component_utils(rs_sequencer)

    function new(string name = "rs_sequencer",
                 uvm_component parent = null);
        super.new(name, parent);
    endfunction

endclass
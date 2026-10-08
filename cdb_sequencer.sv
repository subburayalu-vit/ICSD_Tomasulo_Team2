`include "uvm_macros.svh"
import uvm_pkg::*;

class cdb_sequencer extends uvm_sequencer #(cdb_transaction);

    `uvm_component_utils(cdb_sequencer)

    function new(string name = "cdb_sequencer",
                 uvm_component parent = null);
        super.new(name, parent);
    endfunction

endclass
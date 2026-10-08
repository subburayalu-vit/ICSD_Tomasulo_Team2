`include "uvm_macros.svh"
import uvm_pkg::*;

class cdb_agent extends uvm_agent;

    `uvm_component_utils(cdb_agent)

    cdb_sequencer sequencer;
    cdb_driver    driver;
    cdb_monitor   monitor;

    function new(string name = "cdb_agent",
                 uvm_component parent = null);
        super.new(name, parent);
    endfunction

    function void build_phase(uvm_phase phase);
        super.build_phase(phase);

        sequencer = cdb_sequencer::type_id::create("sequencer", this);
        driver    = cdb_driver::type_id::create("driver", this);
        monitor   = cdb_monitor::type_id::create("monitor", this);
    endfunction

    function void connect_phase(uvm_phase phase);
        super.connect_phase(phase);

        driver.seq_item_port.connect(
            sequencer.seq_item_export
        );
    endfunction

endclass
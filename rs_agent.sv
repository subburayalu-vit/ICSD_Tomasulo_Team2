`include "uvm_macros.svh"
import uvm_pkg::*;

class rs_agent extends uvm_agent;

    `uvm_component_utils(rs_agent)

    rs_sequencer sequencer;
    rs_driver    driver;
    rs_monitor   monitor;

    function new(string name = "rs_agent",
                 uvm_component parent = null);
        super.new(name, parent);
    endfunction

    function void build_phase(uvm_phase phase);
        super.build_phase(phase);

        sequencer = rs_sequencer::type_id::create("sequencer", this);
        driver    = rs_driver::type_id::create("driver", this);
        monitor   = rs_monitor::type_id::create("monitor", this);
    endfunction

    function void connect_phase(uvm_phase phase);
        super.connect_phase(phase);

        driver.seq_item_port.connect(sequencer.seq_item_export);
    endfunction

endclass
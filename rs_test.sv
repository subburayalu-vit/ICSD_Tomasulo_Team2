`include "uvm_macros.svh"
import uvm_pkg::*;

class rs_test extends uvm_test;

    `uvm_component_utils(rs_test)

    rs_env env;

    function new(string name = "rs_test",
                 uvm_component parent = null);
        super.new(name, parent);
    endfunction

    function void build_phase(uvm_phase phase);
        super.build_phase(phase);

        env = rs_env::type_id::create("env", this);
    endfunction

    task run_phase(uvm_phase phase);

        rs_sequence seq;

        phase.raise_objection(this);

        seq = rs_sequence::type_id::create("seq");
        seq.start(env.agent.sequencer);

        phase.drop_objection(this);

    endtask

endclass
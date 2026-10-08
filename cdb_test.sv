`include "uvm_macros.svh"
import uvm_pkg::*;

class cdb_test extends uvm_test;

    `uvm_component_utils(cdb_test)

    cdb_env env;

    function new(string name = "cdb_test",
                 uvm_component parent = null);
        super.new(name, parent);
    endfunction

    function void build_phase(uvm_phase phase);
        super.build_phase(phase);

        env = cdb_env::type_id::create("env", this);
    endfunction

    task run_phase(uvm_phase phase);
        cdb_sequence seq;

        phase.raise_objection(this);

        seq = cdb_sequence::type_id::create("seq");
        seq.start(env.agent.sequencer);

        phase.drop_objection(this);
    endtask

endclass
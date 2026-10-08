`include "uvm_macros.svh"
import uvm_pkg::*;

class cdb_env extends uvm_env;

    `uvm_component_utils(cdb_env)

    cdb_agent      agent;
    cdb_scoreboard scoreboard;

    function new(string name = "cdb_env",
                 uvm_component parent = null);
        super.new(name, parent);
    endfunction

    function void build_phase(uvm_phase phase);
        super.build_phase(phase);

        agent      = cdb_agent::type_id::create("agent", this);
        scoreboard = cdb_scoreboard::type_id::create("scoreboard", this);
    endfunction

    function void connect_phase(uvm_phase phase);
        super.connect_phase(phase);

        agent.monitor.analysis_port.connect(
            scoreboard.analysis_port
        );
    endfunction

endclass
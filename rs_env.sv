`include "uvm_macros.svh"
import uvm_pkg::*;

class rs_env extends uvm_env;

    `uvm_component_utils(rs_env)

    rs_agent      agent;
    rs_scoreboard scoreboard;

    function new(string name = "rs_env",
                 uvm_component parent = null);
        super.new(name, parent);
    endfunction

    function void build_phase(uvm_phase phase);
        super.build_phase(phase);

        agent = rs_agent::type_id::create("agent", this);
        scoreboard = rs_scoreboard::type_id::create("scoreboard", this);

    endfunction

    function void connect_phase(uvm_phase phase);
        super.connect_phase(phase);

        if (agent == null)
            `uvm_fatal("ENV", "agent is NULL")

        if (agent.monitor == null)
            `uvm_fatal("ENV", "agent.monitor is NULL")

        if (scoreboard == null)
            `uvm_fatal("ENV", "scoreboard is NULL")

        agent.monitor.analysis_port.connect(
            scoreboard.analysis_port
        );

    endfunction

endclass
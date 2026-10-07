`include "uvm_macros.svh"
import uvm_pkg::*;

`include "rs_transaction.sv"
`include "rs_sequencer.sv"
`include "rs_driver.sv"
`include "rs_monitor.sv"
`include "rs_sequence.sv"
`include "rs_agent.sv"
`include "rs_scoreboard.sv"
`include "rs_env.sv"
`include "rs_test.sv"

module tb_top;

    logic clk;

    // Clock
    initial begin
        clk = 0;
        forever #5 clk = ~clk;
    end

    // Interface
    rs_if vif(clk);

    // DUT
    reservation_station dut (
        .clk        (clk),
        .reset      (vif.reset),

        .alloc_en   (vif.alloc_en),
        .alloc_op   (vif.alloc_op),
        .alloc_Vj   (vif.alloc_Vj),
        .alloc_Vk   (vif.alloc_Vk),
        .alloc_Qj   (vif.alloc_Qj),
        .alloc_Qk   (vif.alloc_Qk),
        .alloc_dest (vif.alloc_dest),

        .cdb_valid  (vif.cdb_valid),
        .cdb_tag    (vif.cdb_tag),
        .cdb_data   (vif.cdb_data),

        .has_free   (vif.has_free),
        .free_tag   (vif.free_tag),
        .ready      (vif.ready),

        .rs_entries (vif.rs_entries)
    );

    // Give interface to UVM
    initial begin

        uvm_config_db#(virtual rs_if)::set(
            null,
            "*",
            "vif",
            vif
        );

        run_test("rs_test");

    end

endmodule
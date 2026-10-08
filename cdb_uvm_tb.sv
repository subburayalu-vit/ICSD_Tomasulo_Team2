`include "uvm_macros.svh"
import uvm_pkg::*;
`include "cdb_transaction.sv"
`include "cdb_sequence.sv"
`include "cdb_driver.sv"
`include "cdb_sequencer.sv"
`include "cdb_monitor.sv"
`include "cdb_scoreboard.sv"
`include "cdb_agent.sv"
`include "cdb_env.sv"
`include "cdb_test.sv"

module cdb_uvm_tb;

    logic clk;

    cdb_if vif(clk);

    cdb dut (
        .clk        (clk),
        .reset      (vif.reset),

        .alu1_valid (vif.alu1_valid),
        .alu1_tag   (vif.alu1_tag),
        .alu1_data  (vif.alu1_data),

        .alu2_valid (vif.alu2_valid),
        .alu2_tag   (vif.alu2_tag),
        .alu2_data  (vif.alu2_data),

        .alu3_valid (vif.alu3_valid),
        .alu3_tag   (vif.alu3_tag),
        .alu3_data  (vif.alu3_data),

        .cdb_valid  (vif.cdb_valid),
        .cdb_tag    (vif.cdb_tag),
        .cdb_data   (vif.cdb_data)
    );

    initial begin
        clk = 0;
        forever #5 clk = ~clk;
    end

    initial begin
        uvm_config_db#(virtual cdb_if)::set(
            null,
            "*",
            "vif",
            vif
        );

        run_test("cdb_test");
    end

endmodule
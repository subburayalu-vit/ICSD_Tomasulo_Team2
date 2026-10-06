`timescale 1ns/1ps
module tb_top;
  import uvm_pkg::*;
  import rv32i_types_pkg::*;
  import rat_arf_uvm_pkg::*;
  `include "uvm_macros.svh"

  logic clk = 1'b0;
  always #5 clk = ~clk;

  rat_arf_if vif(clk);

  rat_arf_subsystem dut (
    .clk(clk),
    .reset(vif.reset),
    .issue_en(vif.issue_en),
    .issue_dest(vif.issue_dest),
    .issue_tag(vif.issue_tag),
    .cdb_valid(vif.cdb_valid),
    .cdb_tag(vif.cdb_tag),
    .cdb_dest(vif.cdb_dest),
    .cdb_data(vif.cdb_data),
    .lookup_reg1(vif.lookup_reg1),
    .lookup_reg2(vif.lookup_reg2),
    .tag1(vif.tag1),
    .tag2(vif.tag2),
    .cdb_match(vif.cdb_match),
    .read_data1(vif.read_data1),
    .read_data2(vif.read_data2)
  );

  initial begin
    vif.reset=0; vif.issue_en=0; vif.issue_dest=0; vif.issue_tag=TAG_NONE;
    vif.cdb_valid=0; vif.cdb_tag=TAG_NONE; vif.cdb_dest=0; vif.cdb_data=0;
    vif.lookup_reg1=0; vif.lookup_reg2=0;
    uvm_config_db#(virtual rat_arf_if)::set(null, "uvm_test_top.env.*", "vif", vif);
    run_test("rat_arf_test");
  end
endmodule

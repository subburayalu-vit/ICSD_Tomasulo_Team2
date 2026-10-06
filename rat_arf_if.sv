interface rat_arf_if(input logic clk);
  import rv32i_types_pkg::*;

  logic reset;
  logic issue_en;
  logic [4:0] issue_dest;
  RSTag issue_tag;
  logic cdb_valid;
  RSTag cdb_tag;
  logic [4:0] cdb_dest;
  logic [31:0] cdb_data;
  logic [4:0] lookup_reg1;
  logic [4:0] lookup_reg2;
  RSTag tag1;
  RSTag tag2;
  logic cdb_match;
  logic [31:0] read_data1;
  logic [31:0] read_data2;

  clocking drv_cb @(posedge clk);
    output reset, issue_en, issue_dest, issue_tag;
    output cdb_valid, cdb_tag, cdb_dest, cdb_data;
    output lookup_reg1, lookup_reg2;
  endclocking

  clocking mon_cb @(posedge clk);
    input reset, issue_en, issue_dest, issue_tag;
    input cdb_valid, cdb_tag, cdb_dest, cdb_data;
    input lookup_reg1, lookup_reg2;
    input tag1, tag2, cdb_match, read_data1, read_data2;
  endclocking
endinterface

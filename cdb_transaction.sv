`include "uvm_macros.svh"
import uvm_pkg::*;

class cdb_transaction extends uvm_sequence_item;

    rand bit        reset;

    rand bit        alu1_valid;
    rand bit [3:0]  alu1_tag;
    rand bit [31:0] alu1_data;

    rand bit        alu2_valid;
    rand bit [3:0]  alu2_tag;
    rand bit [31:0] alu2_data;

    rand bit        alu3_valid;
    rand bit [3:0]  alu3_tag;
    rand bit [31:0] alu3_data;

    bit        actual_valid;
    bit [3:0]  actual_tag;
    bit [31:0] actual_data;

    function new(string name = "cdb_transaction");
        super.new(name);
    endfunction

    `uvm_object_utils(cdb_transaction)

endclass
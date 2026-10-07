`include "uvm_macros.svh"
import uvm_pkg::*;

class rs_transaction extends uvm_sequence_item;

    // =========================
    // Inputs driven to DUT
    // =========================
    rand bit        reset;
    rand bit        alloc_en;
    rand bit [3:0]  alloc_op;
    rand bit [31:0] alloc_Vj;
    rand bit [31:0] alloc_Vk;
    rand bit [3:0]  alloc_Qj;
    rand bit [3:0]  alloc_Qk;
    rand bit [4:0]  alloc_dest;

    rand bit        cdb_valid;
    rand bit [3:0]  cdb_tag;
    rand bit [31:0] cdb_data;


    // =========================
    // Actual DUT state
    // =========================
    bit        actual_busy [3];
    bit [3:0]  actual_qj   [3];
    bit [3:0]  actual_qk   [3];
    bit [2:0]  actual_ready;


    // =========================
    // Constructor
    // =========================
    function new(string name = "rs_transaction");
        super.new(name);
    endfunction


    // =========================
    // Factory registration
    // =========================
    `uvm_object_utils(rs_transaction)

endclass
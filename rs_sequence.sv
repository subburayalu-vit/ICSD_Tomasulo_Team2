`include "uvm_macros.svh"
import uvm_pkg::*;

class rs_sequence extends uvm_sequence #(rs_transaction);

    `uvm_object_utils(rs_sequence)

    function new(string name = "rs_sequence");
        super.new(name);
    endfunction


    task body();

        rs_transaction tr;


        // ==================================================
        // 1. RESET
        // ==================================================

        tr = rs_transaction::type_id::create("reset_tr");

        start_item(tr);

        tr.reset      = 1;
        tr.alloc_en   = 0;
        tr.cdb_valid  = 0;

        finish_item(tr);


        // ==================================================
        // 2. RELEASE RESET
        // ==================================================

        tr = rs_transaction::type_id::create("release_reset");

        start_item(tr);

        tr.reset      = 0;
        tr.alloc_en   = 0;
        tr.cdb_valid  = 0;

        finish_item(tr);


        // ==================================================
        // 3. ALLOCATE ALU1
        // ==================================================

        tr = rs_transaction::type_id::create("alloc_alu1");

        start_item(tr);

        tr.reset      = 0;
        tr.alloc_en   = 1;
        tr.alloc_op   = 4'd0;

        tr.alloc_Vj   = 32'd10;
        tr.alloc_Vk   = 32'd20;

        tr.alloc_Qj   = 4'd0;
        tr.alloc_Qk   = 4'd0;

        tr.alloc_dest = 5'd3;

        tr.cdb_valid  = 0;

        finish_item(tr);


        // ==================================================
        // 4. ALLOCATE ALU2
        //    Waiting for ALU1
        // ==================================================

        tr = rs_transaction::type_id::create("alloc_alu2");

        start_item(tr);

        tr.reset      = 0;
        tr.alloc_en   = 1;
        tr.alloc_op   = 4'd1;

        tr.alloc_Vj   = 32'd0;
        tr.alloc_Vk   = 32'd5;

        tr.alloc_Qj   = 4'd1;
        tr.alloc_Qk   = 4'd0;

        tr.alloc_dest = 5'd4;

        tr.cdb_valid  = 0;

        finish_item(tr);


        // ==================================================
        // 5. ALLOCATE ALU3
        // ==================================================

        tr = rs_transaction::type_id::create("alloc_alu3");

        start_item(tr);

        tr.reset      = 0;
        tr.alloc_en   = 1;
        tr.alloc_op   = 4'd2;

        tr.alloc_Vj   = 32'd30;
        tr.alloc_Vk   = 32'd40;

        tr.alloc_Qj   = 4'd0;
        tr.alloc_Qk   = 4'd0;

        tr.alloc_dest = 5'd5;

        tr.cdb_valid  = 0;

        finish_item(tr);


        // ==================================================
        // 6. FOURTH ALLOCATION
        //    RS FULL -> SHOULD NOT ALLOCATE
        // ==================================================

        tr = rs_transaction::type_id::create("alloc_fourth");

        start_item(tr);

        tr.reset      = 0;
        tr.alloc_en   = 1;
        tr.alloc_op   = 4'd3;

        tr.alloc_Vj   = 32'd50;
        tr.alloc_Vk   = 32'd60;

        tr.alloc_Qj   = 4'd0;
        tr.alloc_Qk   = 4'd0;

        tr.alloc_dest = 5'd6;

        tr.cdb_valid  = 0;

        finish_item(tr);


        // ==================================================
        // 7. CDB BROADCAST FROM ALU1
        //
        // ALU1 -> released
        // ALU2 -> Qj wakes
        // ==================================================

        tr = rs_transaction::type_id::create("cdb_alu1");

        start_item(tr);

        tr.reset      = 0;
        tr.alloc_en   = 0;

        tr.cdb_valid  = 1;
        tr.cdb_tag    = 4'd1;
        tr.cdb_data   = 32'd30;

        finish_item(tr);


        // ==================================================
        // 8. IDLE
        // ==================================================

        tr = rs_transaction::type_id::create("idle");

        start_item(tr);

        tr.reset      = 0;
        tr.alloc_en   = 0;
        tr.cdb_valid  = 0;

        finish_item(tr);


        // ==================================================
        // 9. REUSE ALU1
        // ==================================================

        tr = rs_transaction::type_id::create("reuse_alu1");

        start_item(tr);

        tr.reset      = 0;
        tr.alloc_en   = 1;
        tr.alloc_op   = 4'd4;

        tr.alloc_Vj   = 32'd70;
        tr.alloc_Vk   = 32'd80;

        tr.alloc_Qj   = 4'd0;
        tr.alloc_Qk   = 4'd0;

        tr.alloc_dest = 5'd7;

        tr.cdb_valid  = 0;

        finish_item(tr);


        // ==================================================
        // 10. RESET FOR CORNER CASE
        // ==================================================

        tr = rs_transaction::type_id::create("corner_reset");

        start_item(tr);

        tr.reset      = 1;
        tr.alloc_en   = 0;
        tr.cdb_valid  = 0;

        finish_item(tr);


        // ==================================================
        // 11. RELEASE RESET
        // ==================================================

        tr = rs_transaction::type_id::create("corner_release");

        start_item(tr);

        tr.reset      = 0;
        tr.alloc_en   = 0;
        tr.cdb_valid  = 0;

        finish_item(tr);


        // ==================================================
        // 12. ALLOCATE ALU1
        //
        // ALU1 waits for ALU2
        // Qj = TAG2
        // ==================================================

        tr = rs_transaction::type_id::create("different_dep_alu1");

        start_item(tr);

        tr.reset      = 0;
        tr.alloc_en   = 1;
        tr.alloc_op   = 4'd5;

        tr.alloc_Vj   = 32'd100;
        tr.alloc_Vk   = 32'd200;

        tr.alloc_Qj   = 4'd2;
        tr.alloc_Qk   = 4'd0;

        tr.alloc_dest = 5'd8;

        tr.cdb_valid  = 0;

        finish_item(tr);


        // ==================================================
        // 13. ALLOCATE ALU2
        //
        // ALU2 is READY
        //
        // ALU2 will be the producer of TAG2.
        // ==================================================

        tr = rs_transaction::type_id::create("producer_alu2");

        start_item(tr);

        tr.reset      = 0;
        tr.alloc_en   = 1;
        tr.alloc_op   = 4'd6;

        tr.alloc_Vj   = 32'd300;
        tr.alloc_Vk   = 32'd400;

        tr.alloc_Qj   = 4'd0;
        tr.alloc_Qk   = 4'd0;

        tr.alloc_dest = 5'd9;

        tr.cdb_valid  = 0;

        finish_item(tr);


        // ==================================================
        // 14. ALLOCATE ALU3
        //
        // ALU3 waits for ALU1.
        // Qj = TAG1
        // ==================================================

        tr = rs_transaction::type_id::create("different_dep_alu3");

        start_item(tr);

        tr.reset      = 0;
        tr.alloc_en   = 1;
        tr.alloc_op   = 4'd7;

        tr.alloc_Vj   = 32'd500;
        tr.alloc_Vk   = 32'd600;

        tr.alloc_Qj   = 4'd1;
        tr.alloc_Qk   = 4'd0;

        tr.alloc_dest = 5'd10;

        tr.cdb_valid  = 0;

        finish_item(tr);


        // ==================================================
        // 15. CDB TAG2
        //
        // ALU1 should wake.
        // ALU3 must continue waiting for TAG1.
        //
        // ALU2 is released because TAG2 is its own tag.
        // ==================================================

        tr = rs_transaction::type_id::create("cdb_tag2");

        start_item(tr);

        tr.reset      = 0;
        tr.alloc_en   = 0;

        tr.cdb_valid  = 1;
        tr.cdb_tag    = 4'd2;
        tr.cdb_data   = 32'd999;

        finish_item(tr);


        // ==================================================
        // 16. CDB TAG1
        //
        // ALU1 is released.
        // ALU3 wakes because Qj = TAG1.
        // ==================================================

        tr = rs_transaction::type_id::create("cdb_tag1");

        start_item(tr);

        tr.reset      = 0;
        tr.alloc_en   = 0;

        tr.cdb_valid  = 1;
        tr.cdb_tag    = 4'd1;
        tr.cdb_data   = 32'd777;

        finish_item(tr);


        // ==================================================
        // 17. FINAL IDLE
        // ==================================================

        tr = rs_transaction::type_id::create("final_idle");

        start_item(tr);

        tr.reset      = 0;
        tr.alloc_en   = 0;
        tr.cdb_valid  = 0;

        finish_item(tr);
        
        // ==================================================
// 18. RESET FOR SAME-TAG DEPENDENCY TEST
// ==================================================

tr = rs_transaction::type_id::create("same_tag_reset");

start_item(tr);

tr.reset      = 1;
tr.alloc_en   = 0;
tr.cdb_valid  = 0;

finish_item(tr);


// ==================================================
// 19. RELEASE RESET
// ==================================================

tr = rs_transaction::type_id::create("same_tag_release");

start_item(tr);

tr.reset      = 0;
tr.alloc_en   = 0;
tr.cdb_valid  = 0;

finish_item(tr);


// ==================================================
// 20. ALLOCATE ALU1
//
// BOTH operands wait for TAG2
// ==================================================

tr = rs_transaction::type_id::create("same_tag_alu1");

start_item(tr);

tr.reset      = 0;
tr.alloc_en   = 1;
tr.alloc_op   = 4'd8;

tr.alloc_Vj   = 32'd0;
tr.alloc_Vk   = 32'd0;

tr.alloc_Qj   = 4'd2;
tr.alloc_Qk   = 4'd2;

tr.alloc_dest = 5'd11;

tr.cdb_valid  = 0;

finish_item(tr);


// ==================================================
// 21. ALLOCATE ALU2
//
// Make ALU2 ready so TAG2 has a producer.
// ==================================================

tr = rs_transaction::type_id::create("same_tag_alu2");

start_item(tr);

tr.reset      = 0;
tr.alloc_en   = 1;
tr.alloc_op   = 4'd9;

tr.alloc_Vj   = 32'd111;
tr.alloc_Vk   = 32'd222;

tr.alloc_Qj   = 4'd0;
tr.alloc_Qk   = 4'd0;

tr.alloc_dest = 5'd12;

tr.cdb_valid  = 0;

finish_item(tr);


// ==================================================
// 22. CDB TAG2
//
// BOTH Qj and Qk of ALU1 should clear.
// ALU2 itself should release.
// ==================================================

tr = rs_transaction::type_id::create("same_tag_cdb");

start_item(tr);

tr.reset      = 0;
tr.alloc_en   = 0;

tr.cdb_valid  = 1;
tr.cdb_tag    = 4'd2;
tr.cdb_data   = 32'd333;

finish_item(tr);


// ==================================================
// 23. FINAL IDLE
// ==================================================

tr = rs_transaction::type_id::create("same_tag_final_idle");

start_item(tr);

tr.reset      = 0;
tr.alloc_en   = 0;
tr.cdb_valid  = 0;

finish_item(tr);

// ==================================================
// 24. RESET FOR UNMATCHED CDB TEST
// ==================================================

tr = rs_transaction::type_id::create("unmatched_reset");

start_item(tr);

tr.reset      = 1;
tr.alloc_en   = 0;
tr.cdb_valid  = 0;

finish_item(tr);


// ==================================================
// 25. RELEASE RESET
// ==================================================

tr = rs_transaction::type_id::create("unmatched_release");

start_item(tr);

tr.reset      = 0;
tr.alloc_en   = 0;
tr.cdb_valid  = 0;

finish_item(tr);


// ==================================================
// 26. ALLOCATE ALU1
//
// ALU1 waits for TAG2.
// ==================================================

tr = rs_transaction::type_id::create("unmatched_alu1");

start_item(tr);

tr.reset      = 0;
tr.alloc_en   = 1;
tr.alloc_op   = 4'd10;

tr.alloc_Vj   = 32'd100;
tr.alloc_Vk   = 32'd200;

tr.alloc_Qj   = 4'd2;
tr.alloc_Qk   = 4'd0;

tr.alloc_dest = 5'd13;

tr.cdb_valid  = 0;

finish_item(tr);


// ==================================================
// 27. BROADCAST UNMATCHED TAG3
//
// ALU1 is waiting for TAG2.
// Therefore NOTHING should change.
//
// Qj must remain TAG2.
// ==================================================

tr = rs_transaction::type_id::create("unmatched_cdb");

start_item(tr);

tr.reset      = 0;
tr.alloc_en   = 0;

tr.cdb_valid  = 1;
tr.cdb_tag    = 4'd3;
tr.cdb_data   = 32'd999;

finish_item(tr);


// ==================================================
// 28. FINAL IDLE
// ==================================================

tr = rs_transaction::type_id::create("unmatched_final_idle");

start_item(tr);

tr.reset      = 0;
tr.alloc_en   = 0;
tr.cdb_valid  = 0;

finish_item(tr);

// ==================================================
// 29. RESET FOR ALLOCATION + CDB TEST
// ==================================================

tr = rs_transaction::type_id::create("same_cycle_reset");

start_item(tr);

tr.reset      = 1;
tr.alloc_en   = 0;
tr.cdb_valid  = 0;

finish_item(tr);


// ==================================================
// 30. RELEASE RESET
// ==================================================

tr = rs_transaction::type_id::create("same_cycle_release");

start_item(tr);

tr.reset      = 0;
tr.alloc_en   = 0;
tr.cdb_valid  = 0;

finish_item(tr);


// ==================================================
// 31. ALLOCATE ALU1
//
// ALU1 will be waiting for TAG2.
// ==================================================

tr = rs_transaction::type_id::create("same_cycle_alu1");

start_item(tr);

tr.reset      = 0;
tr.alloc_en   = 1;
tr.alloc_op   = 4'd11;

tr.alloc_Vj   = 32'd100;
tr.alloc_Vk   = 32'd200;

tr.alloc_Qj   = 4'd2;
tr.alloc_Qk   = 4'd0;

tr.alloc_dest = 5'd14;

tr.cdb_valid  = 0;

finish_item(tr);


// ==================================================
// 32. ALLOCATE ALU2
//
// ALU2 is ready and will later broadcast TAG2.
// ==================================================

tr = rs_transaction::type_id::create("same_cycle_alu2");

start_item(tr);

tr.reset      = 0;
tr.alloc_en   = 1;
tr.alloc_op   = 4'd12;

tr.alloc_Vj   = 32'd300;
tr.alloc_Vk   = 32'd400;

tr.alloc_Qj   = 4'd0;
tr.alloc_Qk   = 4'd0;

tr.alloc_dest = 5'd15;

tr.cdb_valid  = 0;

finish_item(tr);


// ==================================================
// 33. ALLOCATION + CDB IN SAME CYCLE
//
// Allocate ALU3 while ALU2 broadcasts TAG2.
//
// Expected:
//   - ALU3 gets allocated into the remaining free entry
//   - ALU1 wakes because Qj = TAG2
//   - ALU2 is released
// ==================================================

tr = rs_transaction::type_id::create("alloc_and_cdb");

start_item(tr);

tr.reset      = 0;

tr.alloc_en   = 1;
tr.alloc_op   = 4'd13;

tr.alloc_Vj   = 32'd500;
tr.alloc_Vk   = 32'd600;

tr.alloc_Qj   = 4'd0;
tr.alloc_Qk   = 4'd0;

tr.alloc_dest = 5'd16;


// CDB simultaneously broadcasts ALU2
tr.cdb_valid  = 1;
tr.cdb_tag    = 4'd2;
tr.cdb_data   = 32'd700;

finish_item(tr);


// ==================================================
// 34. FINAL IDLE
// ==================================================

tr = rs_transaction::type_id::create("same_cycle_final_idle");

start_item(tr);

tr.reset      = 0;
tr.alloc_en   = 0;
tr.cdb_valid  = 0;

finish_item(tr);

// ==================================================
// 35. ALLOCATE ALU1
// ==================================================

tr = rs_transaction::type_id::create("reset_test_alu1");

start_item(tr);

tr.reset      = 0;
tr.alloc_en   = 1;
tr.alloc_op   = 4'd14;

tr.alloc_Vj   = 32'd10;
tr.alloc_Vk   = 32'd20;

tr.alloc_Qj   = 4'd0;
tr.alloc_Qk   = 4'd0;

tr.alloc_dest = 5'd17;

tr.cdb_valid  = 0;

finish_item(tr);


// ==================================================
// 36. ALLOCATE ALU2
// ==================================================

tr = rs_transaction::type_id::create("reset_test_alu2");

start_item(tr);

tr.reset      = 0;
tr.alloc_en   = 1;
tr.alloc_op   = 4'd15;

tr.alloc_Vj   = 32'd30;
tr.alloc_Vk   = 32'd40;

tr.alloc_Qj   = 4'd1;
tr.alloc_Qk   = 4'd0;

tr.alloc_dest = 5'd18;

tr.cdb_valid  = 0;

finish_item(tr);


// ==================================================
// 37. ALLOCATE ALU3
// ==================================================

tr = rs_transaction::type_id::create("reset_test_alu3");

start_item(tr);

tr.reset      = 0;
tr.alloc_en   = 1;
tr.alloc_op   = 4'd0;

tr.alloc_Vj   = 32'd50;
tr.alloc_Vk   = 32'd60;

tr.alloc_Qj   = 4'd0;
tr.alloc_Qk   = 4'd2;

tr.alloc_dest = 5'd19;

tr.cdb_valid  = 0;

finish_item(tr);


// ==================================================
// 38. RESET WHILE RS IS OCCUPIED
// ==================================================

tr = rs_transaction::type_id::create("reset_while_occupied");

start_item(tr);

tr.reset      = 1;
tr.alloc_en   = 0;
tr.cdb_valid  = 0;

finish_item(tr);


// ==================================================
// 39. FINAL IDLE
// ==================================================

tr = rs_transaction::type_id::create("final_reset_idle");

start_item(tr);

tr.reset      = 0;
tr.alloc_en   = 0;
tr.cdb_valid  = 0;

finish_item(tr);

    endtask

endclass
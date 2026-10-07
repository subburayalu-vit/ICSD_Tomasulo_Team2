`include "uvm_macros.svh"
import uvm_pkg::*;

class rs_scoreboard extends uvm_scoreboard;

    `uvm_component_utils(rs_scoreboard)

    uvm_analysis_imp #(rs_transaction, rs_scoreboard) analysis_port;

    // Expected state
    bit        exp_busy [3];
    bit [3:0]  exp_qj   [3];
    bit [3:0]  exp_qk   [3];

    function new(string name = "rs_scoreboard",
                 uvm_component parent = null);

        super.new(name, parent);

        analysis_port = new("analysis_port", this);

        for (int i = 0; i < 3; i++) begin
            exp_busy[i] = 0;
            exp_qj[i]   = 0;
            exp_qk[i]   = 0;
        end

    endfunction


    function void write(rs_transaction tr);

        // ==========================================
        // RESET
        // ==========================================

        if (tr.reset) begin

            for (int i = 0; i < 3; i++) begin
                exp_busy[i] = 0;
                exp_qj[i]   = 0;
                exp_qk[i]   = 0;
            end

        end

        else begin

            // ======================================
            // ALLOCATION
            // ======================================

            if (tr.alloc_en) begin

                for (int i = 0; i < 3; i++) begin

                    if (!exp_busy[i]) begin

                        exp_busy[i] = 1;
                        exp_qj[i]   = tr.alloc_Qj;
                        exp_qk[i]   = tr.alloc_Qk;

                        break;

                    end

                end

            end


            // ======================================
            // CDB WAKEUP + RELEASE
            // ======================================

            if (tr.cdb_valid) begin

                for (int i = 0; i < 3; i++) begin

                    // Wake up Qj
                    if (exp_busy[i] &&
                        exp_qj[i] == tr.cdb_tag) begin

                        exp_qj[i] = 0;

                    end


                    // Wake up Qk
                    if (exp_busy[i] &&
                        exp_qk[i] == tr.cdb_tag) begin

                        exp_qk[i] = 0;

                    end


                    // Release entry whose tag matches CDB
                    if (exp_busy[i] &&
                        (i + 1) == tr.cdb_tag) begin

                        exp_busy[i] = 0;
                        exp_qj[i]   = 0;
                        exp_qk[i]   = 0;

                    end

                end

            end

        end


        // ==========================================
        // COMPARE EXPECTED vs ACTUAL
        // ==========================================

        for (int i = 0; i < 3; i++) begin

            if (exp_busy[i] !== tr.actual_busy[i]) begin

                `uvm_error(
                    "RS_MISMATCH",
                    $sformatf(
                        "ALU%0d BUSY mismatch: Expected=%0d Actual=%0d",
                        i+1,
                        exp_busy[i],
                        tr.actual_busy[i]
                    )
                );

            end


            if (exp_qj[i] !== tr.actual_qj[i]) begin

                `uvm_error(
                    "RS_MISMATCH",
                    $sformatf(
                        "ALU%0d Qj mismatch: Expected=%0d Actual=%0d",
                        i+1,
                        exp_qj[i],
                        tr.actual_qj[i]
                    )
                );

            end


            if (exp_qk[i] !== tr.actual_qk[i]) begin

                `uvm_error(
                    "RS_MISMATCH",
                    $sformatf(
                        "ALU%0d Qk mismatch: Expected=%0d Actual=%0d",
                        i+1,
                        exp_qk[i],
                        tr.actual_qk[i]
                    )
                );

            end
if (tr.actual_ready[i] !==
    (exp_busy[i] && exp_qj[i] == 4'd0 && exp_qk[i] == 4'd0)) begin

    `uvm_error(
        "RS_MISMATCH",
        $sformatf(
            "ALU%0d READY mismatch: Expected=%0d Actual=%0d",
            i+1,
            (exp_busy[i] && exp_qj[i] == 4'd0 && exp_qk[i] == 4'd0),
            tr.actual_ready[i]
        )
    );

end
        end


        `uvm_info(
            "SCOREBOARD",
            "Expected state compared with DUT state",
            UVM_LOW
        );

    endfunction

endclass
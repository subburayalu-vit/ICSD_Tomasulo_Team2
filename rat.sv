module rat #(
    parameter int NUM_REGS = 32
) (
    input  logic clk,
    input  logic reset,
    input  logic issue_en,
    input  logic [4:0] issue_dest,
    input  rv32i_types_pkg::RSTag issue_tag,
    input  logic cdb_valid,
    input  rv32i_types_pkg::RSTag cdb_tag,
    input  logic [4:0] lookup_reg1,
    input  logic [4:0] lookup_reg2,
    output rv32i_types_pkg::RSTag tag1,
    output rv32i_types_pkg::RSTag tag2,
    output logic cdb_match
);
    import rv32i_types_pkg::*;

    RSTag tag [0:NUM_REGS-1];

    always_comb begin
        if (lookup_reg1 == 5'd0)
            tag1 = TAG_NONE;
        else
            tag1 = tag[lookup_reg1];

        if (lookup_reg2 == 5'd0)
            tag2 = TAG_NONE;
        else
            tag2 = tag[lookup_reg2];
    end

    always_comb begin
        cdb_match = 1'b0;
        if (cdb_valid) begin
            for (int i = 1; i < NUM_REGS; i++) begin
                if (tag[i] == cdb_tag)
                    cdb_match = 1'b1;
            end
        end
    end

    always_ff @(posedge clk) begin
        if (reset) begin
            for (int i = 0; i < NUM_REGS; i++)
                tag[i] <= TAG_NONE;
        end else begin
            // Broadcast clear. The nonblocking assignment is overridden
            // below by rename when the same architectural register is
            // simultaneously renamed; rename therefore has priority.
            for (int i = 1; i < NUM_REGS; i++) begin
                if (cdb_valid && tag[i] == cdb_tag)
                    tag[i] <= TAG_NONE;
            end

            // Rename at issue.
            if (issue_en && issue_dest != 5'd0)
                tag[issue_dest] <= issue_tag;

            // x0 is permanently NONE.
            tag[0] <= TAG_NONE;
        end
    end
endmodule

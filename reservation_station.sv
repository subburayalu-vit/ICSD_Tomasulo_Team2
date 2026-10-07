
typedef enum logic [3:0] {
    TAG_NONE = 4'd0,
    TAG_ALU1 = 4'd1,
    TAG_ALU2 = 4'd2,
    TAG_ALU3 = 4'd3
} RSTag;

typedef struct packed {
    logic        busy;
    logic [3:0]  op;
    logic [31:0] Vj;
    logic [31:0] Vk;
    RSTag        Qj;
    RSTag        Qk;
    logic [4:0]  dest;
} RSEntry;

module reservation_station(
    input clk,
    input reset,
    input alloc_en,
    input [3:0] alloc_op,
    input [31:0] alloc_Vj,
    input [31:0] alloc_Vk,
    input RSTag alloc_Qj,
    input RSTag alloc_Qk,
    input [4:0] alloc_dest,
    input cdb_valid,
    input RSTag cdb_tag,
    input [31:0] cdb_data,
    output logic has_free,
    output RSTag free_tag,
    output logic [2:0] ready,
    output RSEntry rs_entries [3]
);



always_comb begin
    has_free = 1'b0;
    free_tag = TAG_NONE;

    if (rs_entries[0].busy == 1'b0) begin
        has_free = 1'b1;
        free_tag = TAG_ALU1;
    end
    else if (rs_entries[1].busy == 1'b0) begin
        has_free = 1'b1;
        free_tag = TAG_ALU2;
    end
    else if (rs_entries[2].busy == 1'b0) begin
        has_free = 1'b1;
        free_tag = TAG_ALU3;
    end
end

always_ff @(posedge clk) begin
    if (reset) begin
        rs_entries[0] <= '0;
        rs_entries[1] <= '0;
        rs_entries[2] <= '0;
    end
    else begin

        // Allocation
        if (alloc_en && has_free) begin

            if (free_tag == TAG_ALU1) begin
                rs_entries[0].busy <= 1'b1;
                rs_entries[0].op   <= alloc_op;
                rs_entries[0].Vj   <= alloc_Vj;
                rs_entries[0].Vk   <= alloc_Vk;
                rs_entries[0].Qj   <= alloc_Qj;
                rs_entries[0].Qk   <= alloc_Qk;
                rs_entries[0].dest <= alloc_dest;
            end

            else if (free_tag == TAG_ALU2) begin
                rs_entries[1].busy <= 1'b1;
                rs_entries[1].op   <= alloc_op;
                rs_entries[1].Vj   <= alloc_Vj;
                rs_entries[1].Vk   <= alloc_Vk;
                rs_entries[1].Qj   <= alloc_Qj;
                rs_entries[1].Qk   <= alloc_Qk;
                rs_entries[1].dest <= alloc_dest;
            end

            else if (free_tag == TAG_ALU3) begin
                rs_entries[2].busy <= 1'b1;
                rs_entries[2].op   <= alloc_op;
                rs_entries[2].Vj   <= alloc_Vj;
                rs_entries[2].Vk   <= alloc_Vk;
                rs_entries[2].Qj   <= alloc_Qj;
                rs_entries[2].Qk   <= alloc_Qk;
                rs_entries[2].dest <= alloc_dest;
            end
        end

        // CDB wakeup and release
        for (int i = 0; i < 3; i++) begin

            // Wake up operand j
            if (rs_entries[i].busy &&
                cdb_valid &&
                rs_entries[i].Qj == cdb_tag) begin

                rs_entries[i].Vj <= cdb_data;
                rs_entries[i].Qj <= TAG_NONE;
            end

            // Wake up operand k
            if (rs_entries[i].busy &&
                cdb_valid &&
                rs_entries[i].Qk == cdb_tag) begin

                rs_entries[i].Vk <= cdb_data;
                rs_entries[i].Qk <= TAG_NONE;
            end

            // Release RS entry when its own result is broadcast
            if (rs_entries[i].busy &&
                cdb_valid &&
                ((i == 0 && cdb_tag == TAG_ALU1) ||
                 (i == 1 && cdb_tag == TAG_ALU2) ||
                 (i == 2 && cdb_tag == TAG_ALU3))) begin

                rs_entries[i].busy <= 1'b0;
            end

        end
    end
end

always_comb begin
    for (int i = 0; i < 3; i++) begin
        ready[i] = rs_entries[i].busy &&
                   (rs_entries[i].Qj == TAG_NONE) &&
                   (rs_entries[i].Qk == TAG_NONE);
    end
end

endmodule

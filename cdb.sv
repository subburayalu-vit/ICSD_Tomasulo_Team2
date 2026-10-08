module cdb #(
    parameter int TAG_WIDTH = 4
)(
    input  logic              clk,
    input  logic              reset,

    input  logic              alu1_valid,
    input  logic [TAG_WIDTH-1:0] alu1_tag,
    input  logic [31:0]       alu1_data,

    input  logic              alu2_valid,
    input  logic [TAG_WIDTH-1:0] alu2_tag,
    input  logic [31:0]       alu2_data,

    input  logic              alu3_valid,
    input  logic [TAG_WIDTH-1:0] alu3_tag,
    input  logic [31:0]       alu3_data,

    output logic              cdb_valid,
    output logic [TAG_WIDTH-1:0] cdb_tag,
    output logic [31:0]       cdb_data
);

    always_comb begin

        // Default: no result broadcast
        cdb_valid = 1'b0;
        cdb_tag   = '0;
        cdb_data  = 32'b0;

        // Fixed priority: ALU1 > ALU2 > ALU3
        if (alu1_valid) begin
            cdb_valid = 1'b1;
            cdb_tag   = alu1_tag;
            cdb_data  = alu1_data;
        end
        else if (alu2_valid) begin
            cdb_valid = 1'b1;
            cdb_tag   = alu2_tag;
            cdb_data  = alu2_data;
        end
        else if (alu3_valid) begin
            cdb_valid = 1'b1;
            cdb_tag   = alu3_tag;
            cdb_data  = alu3_data;
        end

    end

endmodule
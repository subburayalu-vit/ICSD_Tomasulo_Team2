module rat_arf_subsystem (
    input  logic clk,
    input  logic reset,
    input  logic issue_en,
    input  logic [4:0] issue_dest,
    input  rv32i_types_pkg::RSTag issue_tag,
    input  logic cdb_valid,
    input  rv32i_types_pkg::RSTag cdb_tag,
    input  logic [4:0] cdb_dest,
    input  logic [31:0] cdb_data,
    input  logic [4:0] lookup_reg1,
    input  logic [4:0] lookup_reg2,
    output rv32i_types_pkg::RSTag tag1,
    output rv32i_types_pkg::RSTag tag2,
    output logic cdb_match,
    output logic [31:0] read_data1,
    output logic [31:0] read_data2
);
    import rv32i_types_pkg::*;

    rat u_rat (
        .clk(clk),
        .reset(reset),
        .issue_en(issue_en),
        .issue_dest(issue_dest),
        .issue_tag(issue_tag),
        .cdb_valid(cdb_valid),
        .cdb_tag(cdb_tag),
        .lookup_reg1(lookup_reg1),
        .lookup_reg2(lookup_reg2),
        .tag1(tag1),
        .tag2(tag2),
        .cdb_match(cdb_match)
    );

    // Per the specification, ARF write enable is qualified by RAT cdb_match.
    logic arf_cdb_valid;
    assign arf_cdb_valid = cdb_valid & cdb_match;

    arf u_arf (
        .clk(clk),
        .reset(reset),
        .cdb_valid(arf_cdb_valid),
        .cdb_dest(cdb_dest),
        .cdb_data(cdb_data),
        .read_addr1(lookup_reg1),
        .read_addr2(lookup_reg2),
        .read_data1(read_data1),
        .read_data2(read_data2)
    );
endmodule

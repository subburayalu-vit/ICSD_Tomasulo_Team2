interface cdb_if(input logic clk);

    logic reset;

    logic        alu1_valid;
    logic [3:0]  alu1_tag;
    logic [31:0] alu1_data;

    logic        alu2_valid;
    logic [3:0]  alu2_tag;
    logic [31:0] alu2_data;

    logic        alu3_valid;
    logic [3:0]  alu3_tag;
    logic [31:0] alu3_data;

    logic        cdb_valid;
    logic [3:0]  cdb_tag;
    logic [31:0] cdb_data;

endinterface
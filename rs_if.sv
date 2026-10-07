interface rs_if(input logic clk);

    logic reset;

    logic        alloc_en;
    logic [3:0]  alloc_op;
    logic [31:0] alloc_Vj;
    logic [31:0] alloc_Vk;
    logic [3:0]  alloc_Qj;
    logic [3:0]  alloc_Qk;
    logic [4:0]  alloc_dest;

    logic        cdb_valid;
    logic [3:0]  cdb_tag;
    logic [31:0] cdb_data;

    logic        has_free;
    logic [3:0]  free_tag;
    logic [2:0]  ready;

    // DUT observation
    RSEntry rs_entries [3];

endinterface
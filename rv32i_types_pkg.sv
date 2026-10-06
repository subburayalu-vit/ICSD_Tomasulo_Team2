package rv32i_types_pkg;
  typedef enum logic [3:0] {
    TAG_NONE  = 4'd0,
    TAG_ALU1  = 4'd1,
    TAG_ALU2  = 4'd2,
    TAG_ALU3  = 4'd3,
    TAG_MUL1  = 4'd4,
    TAG_MUL2  = 4'd5,
    TAG_LOAD1 = 4'd6,
    TAG_LOAD2 = 4'd7,
    TAG_STORE1= 4'd8,
    TAG_STORE2= 4'd9
  } RSTag;
endpackage

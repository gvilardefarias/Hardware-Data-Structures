module priority_queue 
#(
  DATA_LENGTH = 32
)
(
  input  logic                   CLK,
  input  logic                   RSTn,

  input  logic                   i_write,    // 1 for write | 0 for read
  input  logic                   i_valid,
  input  logic [DATA_LENGTH-1:0] i_data,

  output logic                   o_full,
  output logic                   o_empty,
  output logic                   o_valid,
  output logic [DATA_LENGTH-1:0] o_data
);





endmodule

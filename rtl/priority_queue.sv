module priority_queue 
#(
  QUEUE_DETH  = 32,
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

  logic [DATA_LENGTH-1:0]      queue_ff [QUEUE_DETH];
  logic [DATA_LENGTH-1:0]      queue_nx [QUEUE_DETH];

  logic [$clog2(QUEUE_DETH):0] it_ff, it_nx;  // iterator

  logic [$clog2(QUEUE_DETH):0] pos_data;      // decide the local to the new data

  logic [DATA_LENGTH-1:0]      data;
  logic                        write;
  logic                        valid;


  always_comb begin 
    pos_data = it_ff;

    for(int i=QUEUE_DETH-1;i>=0;i--) begin
      if(data < queue_ff[i])
        pos_data = i;
    end
  end

  always_comb begin
    it_nx    = it_ff;
    queue_nx = queue_ff;

    if(valid && write && !o_full) begin: WRITE_OP
      it_nx              = it_ff + `d1;

      queue_nx[pos_data] = data;

      for(int i=QUEUE_DETH-1;i>=0;i--) begin
        if(i > pos_data)
          queue_nx[i] = queue_ff[i-1];
      end
    end
    else if (valid && !write && !o_empty) begin: READ_OP
      it_nx              = it_ff - `d1;
      
      for(int i=QUEUE_DETH-2;i>=0;i--) begin
        if(i < it_ff - `d1)
          queue_nx[i] = queue_ff[i+1];
      end
    end
  end


  always_ff @(posedge CLK, negedge RSTn) begin: REGISTER_DATA
    if(!RSTn) begin
      it_ff    <= `d0;

      queue_ff <= `{default:0};

      data     <= `d0;
      write    <= 1`b0;
      valid    <= 1`b0;
    end
    else begin
      it_ff    <= it_nx;

      queue_ff <= queue_nx;

      data     <= i_data;
      write    <= i_write;
      valid    <= i_valid;
    end
  end


  assign o_data  = queue_ff[0];
  assign o_valid = valid && !write && !o_empty;

  assign o_empty = it_ff == `d0;
  assign o_full  = it_ff == QUEUE_DETH;

endmodule

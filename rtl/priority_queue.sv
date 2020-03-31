module priority_queue 
#(
  QUEUE_DETH  = 30,
  DATA_LENGTH = 10
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

  logic [0:QUEUE_DETH-1]       comparator;    // comparator to decide the local to put new data

  logic [DATA_LENGTH-1:0]      data;
  logic                        write;
  logic                        valid;

  logic                        empty;
  logic                        full;


  always_comb begin 
    for(int i=QUEUE_DETH-1;i>=0;i--) begin
      if((data < queue_ff[i] && i < it_ff) || i == it_ff)  // if the data is smaller then the data in the queue length
        comparator[i] = 1'b1;
      else
        comparator[i] = 1'b0;
    end
  end

  always_comb begin
    it_nx    = it_ff;
    queue_nx = queue_ff;

    if(valid && write && !full) begin: WRITE_OP
      it_nx = it_ff + 1'd1;

      for(int i=QUEUE_DETH-1;i>0;i--) begin
        if(comparator[i] && !comparator[i-1])  // the edge that changes to bigger to smaller to receive the data
          queue_nx[i] = data;
        else if(comparator[i-1])               // if in pos-1 the value is smaller then shift to right
          queue_nx[i] = queue_ff[i-1];
      end

      if(comparator[0])
        queue_nx[0] = data;
    end
    else if (valid && !write && !empty) begin: READ_OP
      it_nx = it_ff - 1'd1;
      
      for(int i=QUEUE_DETH-2;i>=0;i--) begin
        if(i < it_ff - 1'd1)
          queue_nx[i] = queue_ff[i+1];
      end
    end
  end


  always_ff @(posedge CLK, negedge RSTn) begin: REGISTER_DATA
    if(!RSTn) begin
      it_ff    <= 'd0;

      queue_ff <= '{default:0};

      data     <= 'd0;
      write    <= 1'b0;
      valid    <= 1'b0;
    end
    else begin
      it_ff    <= it_nx;

      queue_ff <= queue_nx;

      data     <= i_data;
      write    <= i_write;
      valid    <= i_valid;
    end
  end


  assign empty   = it_ff == 'd0;
  assign full    = it_ff == QUEUE_DETH;

  assign o_empty = it_nx == 'd0;
  assign o_full  = it_nx == QUEUE_DETH;

  assign o_data  = queue_ff[0];
  assign o_valid = valid && !write && !empty;

endmodule

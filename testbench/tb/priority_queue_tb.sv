module priority_queue_tb();

  localparam QUEUE_DETH  = 32;
  localparam DATA_LENGTH = 32;

  logic                   CLK;
  logic                   RSTn;

  logic                   i_write;
  logic                   i_valid;
  logic [DATA_LENGTH-1:0] i_data;

  logic                   o_full;
  logic                   o_empty;
  logic                   o_valid;
  logic [DATA_LENGTH-1:0] o_data; 

  logic [DATA_LENGTH-1:0] data;


  priority_queue 
  #(
    QUEUE_DETH,
    DATA_LENGTH
  ) u_prty_queue (.*);


  initial begin: CLK_GENERATION
    CLK = 0;

    forever #(`CLK_PERIOD/2)
      CLK = !CLK;
  end

  initial begin: RST_GENERATION
    RSTn = 1;
    #1
    RSTn = 0;

    repeat(2) @(negedge CLK);

    RSTn = 1;
  end


  initial begin
    i_write = 0;
    i_valid = 0;
    i_data  = 0;

    @(posedge RSTn);
    @(posedge CLK);

    write(12);
    write(1);
    write(2);
    write(14);

    read(data);
    read(data);
    read(data);
    read(data);

    $finish();
  end


  task write(input int data);
    if(o_full)
      $display("Error - The queue is full | Data: %d", data);
    else
      $display("Write data: %d", data);

    i_write = 1;
    i_valid = !o_full;
    i_data  = data;

    @(posedge CLK);

    i_valid = 0;
  endtask

  task read(output int data);
    i_write = 0;
    i_valid = !o_empty;

    @(posedge CLK);

    i_valid = 0;

    data    = o_valid ? o_data:'hx;

    if(o_valid)
      $display("Read data: %d", data);
    else
      $display("Error - The queue is empty");
  endtask

endmodule

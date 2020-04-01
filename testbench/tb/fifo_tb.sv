module fifo_tb
	#(
		parameter SIZEDATA = 32,
		parameter DEPTHFIFO = 8,
		localparam BITSCONT = $clog2(DEPTHFIFO)
	);

	logic clk_i;
	logic rstn_i;

	logic valid_i;
	logic [SIZEDATA-1:0]data_i;
	logic ready_o;

	logic valid_o;
	logic [SIZEDATA-1:0]data_o;
	logic ready_i;
	//---------------------------------------//         
	//				 refmod					 //
	//---------------------------------------//
	logic [SIZEDATA-1:0] refmod [DEPTHFIFO];
	logic [BITSCONT-1:0] contador_w;
	logic [BITSCONT-1:0] contador_r;
	//---------------------------------------//

	int contador_resultado;

	fifo 
	#(
		.SIZEDATA(SIZEDATA),
		.DEPTHFIFO(DEPTHFIFO),
		.BITSCONT(BITSCONT)
	) f1 (
		.clk_i(clk_i),
		.rstn_i(rstn_i),

		.valid_i(valid_i),
		.data_i(data_i),
		.ready_o(ready_o),

		.valid_o(valid_o),
		.data_o(data_o),
		.ready_i(ready_i)
	);

	task reset();//reset do sistema
		rstn_i = 0;
		contador_r = 0;
		contador_w = 0;
		clock(2);
		rstn_i = 1;
	endtask

	task carregamento_fifo(int n_elementos);//carrega dados na fifo e no refmod
		int dado;
		for(int i = 0; i < n_elementos; i++)
		begin
			if(ready_o)
			begin
				dado = $urandom;
				refmod[contador_w] = dado;
				valid_i = 1'b1;
				data_i = dado;
				clock(1);
				contador_w = contador_w + 1'b1;
				valid_i = 0;
			end
	end
	endtask

	task descarregamento_fifo();//descarrega um valor da fifo e compara com o do refmod
		while(valid_o)
		begin
			ready_i = 1'b1;
			clock(1);
			if(data_o != refmod[contador_r])
				begin
					contador_resultado = contador_resultado + 1; 
					$display("ERRO VALOR %d", contador_r);
				end
			ready_i = 1'b0;
			contador_r = contador_r + 1;
		end
	endtask

	task descarregamento_n_elementos_fifo(int n_saidas);
		for(int i = 0; i < n_saidas; i++)
		begin
			if(valid_o)
			begin
				ready_i = 1'b1;
				clock(1);
				if(data_o != refmod[contador_r])
				begin
					contador_resultado = contador_resultado + 1; 
					$display("ERRO VALOR %d", contador_r);
				end
			ready_i = 1'b0;
			contador_r = contador_r + 1;
			end
		end
	endtask

	task carregamento_descarregamento_fifo(int repeticoes, int n_elementos_i, int n_elementos_o);//carrega dados na fifo e no refmof
		for(int i = 0; i < repeticoes; i++)                           							 //e descarrega e compara após um delay
		begin
			carregamento_fifo(n_elementos_i);
			descarregamento_n_elementos_fifo(n_elementos_o);
		end
	endtask

	task clock(int numero);//passa "n" clock's, sendo "n" um parâmetro de entrada
    	for(int i = 0; i<numero;i++)
      	begin
        	#1 clk_i = 0;
        	#1 clk_i = 1;
      	end
    endtask

	initial
	begin
		reset();
		valid_i = 1;
		data_i = 5;
		clock(1);
		valid_i = 0;
		ready_i = 1;
		clock(1);
		ready_i = 0;
		reset();
		carregamento_fifo(12);
		descarregamento_fifo();
		reset();
		carregamento_descarregamento_fifo(8, 4, 2);
	end
endmodule
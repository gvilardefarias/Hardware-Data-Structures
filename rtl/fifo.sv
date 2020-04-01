module fifo
	#(
		parameter SIZEDATA = 32,
		parameter DEPTHFIFO = 8,
		parameter BITSCONT = $clog2(DEPTHFIFO)
	)(
		input  logic clk_i,
		input  logic rstn_i,

		input  logic valid_i,
		input  logic [SIZEDATA-1:0]data_i,
		output logic ready_o,

		output logic valid_o,
		output logic [SIZEDATA-1:0]data_o,
		input  logic ready_i
	);

	logic [SIZEDATA-1:0]  registradores [DEPTHFIFO];
	logic [BITSCONT-1:0]  cont_w;
	logic [BITSCONT-1:0]  cont_r;
	logic [DEPTHFIFO-1:0] registro;

	assign valid_o = |registro;
	assign ready_o = !(&registro);

// ================================================================
//              		Logica de armazenamento      
// ================================================================
	always_ff@(posedge clk_i, negedge rstn_i)
	begin
		if(!rstn_i)
		begin	
			registro <= 0;
		end
		else if(valid_i && ready_i)
		begin
			if(valid_o && ready_o)
			begin	
				registradores[cont_w] <= data_i;
				registro[cont_w] <= 1'b1;
				data_o <= registradores[cont_r];
				registro[cont_r] <= 1'b0;
			end
			else if(valid_o)
			begin
				data_o <= registradores[cont_r];
				registro[cont_r] <= 1'b0;
			end
			else if(ready_o)
			begin
				registradores[cont_w] <= data_i;
				registro[cont_w] <= 1'b1;
			end	
		end
		else if(valid_i && ready_o)	
		begin
			registradores[cont_w] <= data_i;
			registro[cont_w] <= 1'b1;
		end
		else if(ready_i)
		begin
			data_o <= registradores[cont_r];
			registro[cont_r] <= 1'b0;
		end	
	end
// ================================================================
//              		Logica de endereçamento      
// ================================================================
	always_ff@(posedge clk_i, negedge rstn_i)
	begin
		if(!rstn_i)
		begin
			cont_r <= 0;
			cont_w <= 0;
		end
		else if(valid_i && ready_i)
		begin
			if(ready_o && valid_o)
			begin
				cont_w <= cont_w + 1'b1;
				cont_r <= cont_r + 1'b1;
			end
			else if(valid_o)
				cont_r <= cont_r + 1'b1;
			else if(ready_o)
				cont_w <= cont_w + 1'b1;
		end	
		else if(valid_i && ready_o)
		begin
			cont_w <= cont_w + 1'b1;
		end
		else if(ready_i && valid_o)
		begin
			cont_r <= cont_r + 1'b1;
		end
		else if(cont_r == DEPTHFIFO-1 && cont_w == DEPTHFIFO-1)
		begin
			cont_r <= 0;
			cont_w <= 0;
		end
		else if(cont_r == DEPTHFIFO-1)
		begin
			cont_r <= 0;
		end
		else if(cont_w == DEPTHFIFO-1)
		begin
			cont_w <= 0;
		end	
	end
endmodule
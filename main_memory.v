module main_memory(
	input wire clk,
	input wire rst,
	input wire mem_req,
	input wire mem_write,
	input wire [31:0] mem_addr,
	input wire [31:0] mem_wdata,
	output reg [127:0] mem_rdata, // From Main Memory to CPU (new Cache)
	output wire mem_ready
);
	
	// To create Latency
	localparam IDLE = 2'b00;
	localparam ACCESS = 2'b01;
	localparam READY = 2'b10;
	reg [3:0] delay_counter;
	
	reg [1:0] state, next_state;
	
	
	reg [127:0] ram [0:15];
	integer i; // Dummy Data
	initial begin
		for(i = 0; i < 16; i = i + 1) begin
			ram[i] = {32'h44444444, 32'h33333333, 32'h22222222, 32'h11111111};
		end
	end

	// Ram Indexing
	wire [3:0] offset = mem_addr[3:0]; // There are 16 byte in 128 bit, we parse that
	wire [3:0] ram_index = mem_addr[7:4]; // 16(2^4)x128 ram indexing
	
	assign mem_ready = (state == READY);

	always @(posedge clk) begin
		if(rst) begin
			state <= IDLE;
			delay_counter <= 4'b0000;
		end
		else begin
			state <= next_state;
			case(state)
				IDLE: begin
					delay_counter <= 4'b0000;
				end
				ACCESS: begin
					delay_counter <= delay_counter + 1'b1;
					if(delay_counter == 4'b1001) begin
						if(mem_write == 1'b1) begin // Cache is writen from Cache to Main Memory
							if(offset[3:2] == 2'b00) ram[ram_index][31:0] <= mem_wdata;
							else if(offset[3:2] == 2'b01) ram[ram_index][63:32] <= mem_wdata;
							else if(offset[3:2] == 2'b10) ram[ram_index][95:64] <= mem_wdata;
							else ram[ram_index][127:96] <= mem_wdata;
						end
						else begin // Ram's data is writen to Cache
							mem_rdata <= ram[ram_index];
						end
					end
				end
				READY: begin
					// Just holds old datas with stability
				end
			endcase
		end
	end
	
	always @(*) begin
		next_state = state;
		
		case(state)
			IDLE: begin
				if(mem_req) begin
					next_state = ACCESS;
				end
				else begin
					next_state = IDLE;
				end
			end
			ACCESS: begin
				if(delay_counter == 4'b1001) begin
					next_state = READY;
				end
				else begin
					next_state = ACCESS;
				end
			end
			READY: begin
				if(!mem_req) begin // Cache finished its work
					next_state = IDLE;
				end
				else begin
					next_state = READY;
				end
			end
			default: next_state = IDLE;
		endcase
	end
endmodule

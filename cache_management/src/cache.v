module cache(
	input wire clk,
	input wire rst,
	input wire cpu_req,
	input wire cpu_write,
	input wire [31:0] cpu_addr,
	input wire [31:0] cpu_wdata,
	output wire [31:0] cpu_rdata,
	output wire cpu_ready,
	output wire mem_req,
	output wire [31:0] mem_addr,
	output wire [31:0] mem_wdata,
	output wire mem_write,
	input wire [127:0] mem_rdata,
	input wire mem_ready
);

	localparam IDLE = 2'b00;
	localparam COMPARE = 2'b01;
	localparam ALLOCATE = 2'b10;
	localparam WRITE_MEM =2'b11;
	
	reg [1:0] state,next_state;
	
	reg valid_array [0:7]; // First bit of Cache Line - NOTE:There are 8 Cache Line
	reg [24:0] tag_array [0:7]; // Tag of Cache Line
	reg [127:0] data_array [0:7]; // Cache Line
	
	// cpu_addr parsing
	wire [3:0] offset = cpu_addr[3:0]; // For 16 (2^4) byte Cache Line
	wire [2:0] index = cpu_addr[6:4]; // For 8 (2^3) Cache Row
	wire [24:0] tag = cpu_addr[31:7]; // The other 25 bit
	
	wire valid_bit = valid_array[index]; // The valid values provide us to be sure datas correctness.
	wire [24:0] stored_tag = tag_array[index]; 
	
	wire hit = ((valid_bit == 1'b1) && (stored_tag == tag));
	
	assign mem_addr = {cpu_addr[31:4] , 4'b0000}; // Mod(%) 0f 16 to get 128 bit Cache Line
	assign mem_wdata = cpu_wdata; // Data goes from CPU to Cache and MainMemory
	
	
	wire [127:0] current_cache_line = data_array[index];
	// If you want to read cpu_rdata, There is 4(128/32) cache option and them offsets just can start(word-alligned) with 0000(0), 0100(4), 1000(8), 1100(12)
	// So we can eleminate easily cache that includes wanted data.
	// A cache line(128-bit) stores 4 cache(32-bit), so we parse it.
	assign cpu_rdata = ( (offset[3:2]==2'b00) ? current_cache_line[31:0]:
								(offset[3:2]==2'b01) ? current_cache_line[63:32]:
								(offset[3:2]==2'b10) ? current_cache_line[95:64]:
								current_cache_line[127:96] );
								
	assign mem_req = (state == ALLOCATE) || (state == WRITE_MEM);
	assign mem_write = (state == WRITE_MEM);
	assign cpu_ready = ((state == COMPARE) && hit && !cpu_write) || ((state == WRITE_MEM) && mem_ready);
	
	
	integer i; // For valid_array reset
	
	always @(posedge clk) begin
		if(rst) begin
			state <= IDLE;
			for(i=0; i<8; i=i+1) begin
				valid_array[i] <= 1'b0;
				// we cannot do directly valid_array = 8'b00000000; because the array 7x1 not 1x7.
			end
		end
		else begin
			state <= next_state;
			if((state == ALLOCATE) && (mem_ready == 1'b1)) begin
				valid_array[index] <= 1'b1; // When the conditions are provided, we hit Cache Line.
				tag_array[index] <= tag; // The hitted datas can be usable yet.
				data_array[index] <= mem_rdata; // The data that comes form the memory.
			end
			
			// The condition provides to write new datas to Cache
			if((state == COMPARE) && (hit) && (cpu_write == 1'b1)) begin
				if(offset[3:2] == 2'b00) data_array[index][31:0] <= cpu_wdata;
				else if(offset[3:2] == 2'b01) data_array[index][63:32] <= cpu_wdata;
				else if(offset[3:2] == 2'b10) data_array[index][95:64] <= cpu_wdata;
				else data_array[index][127:96] <= cpu_wdata;
			end
			
		end
	end
	
	
	always @(*) begin
		next_state = state;
		
		case (state)
			IDLE: begin
				if(cpu_req) begin
					next_state=COMPARE;
				end
				else begin
					next_state=IDLE;
				end
			end
			COMPARE: begin
				if(!hit) begin // When there is no wanted data in the cache, we have to allocate
					next_state=ALLOCATE;
				end
				else begin
					if(cpu_write) begin
						next_state = WRITE_MEM;
					end
					else begin
						next_state=IDLE;
					end
				end
			end
			ALLOCATE: begin
				if(mem_ready) begin
					next_state=COMPARE;
				end
			end
			WRITE_MEM: begin
				if(mem_ready) begin // These ready signals provide to start-stop communication.
					next_state = IDLE;
				end
			end
		endcase
	end
	
endmodule

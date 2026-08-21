`timescale 1ns/1ps
module testbench;
	reg clk;
	reg rst;
	reg cpu_req;
	reg cpu_write;
	reg [31:0] cpu_addr;
	reg [31:0] cpu_wdata;
	
	wire [31:0] cpu_rdata;
	wire cpu_ready;
	
	wire mem_req;
	wire [31:0] mem_addr;
	wire [31:0] mem_wdata;
	wire mem_write;
	wire [127:0] mem_rdata;
	wire mem_ready;

	cache cache_uut(
		.clk(clk),
		.rst(rst),
		.cpu_req(cpu_req),
		.cpu_write(cpu_write),
		.cpu_addr(cpu_addr),
		.cpu_wdata(cpu_wdata),
		.cpu_rdata(cpu_rdata),
		.cpu_ready(cpu_ready),
		.mem_req(mem_req),
		.mem_addr(mem_addr),
		.mem_wdata(mem_wdata),
		.mem_write(mem_write),
		.mem_rdata(mem_rdata),
		.mem_ready(mem_ready)
	);
	main_memory mem_uut(
		.clk(clk),
		.rst(rst),
		.mem_req(mem_req),
		.mem_write(mem_write),
		.mem_addr(mem_addr),
		.mem_wdata(mem_wdata),
		.mem_rdata(mem_rdata),
		.mem_ready(mem_ready)
	);
	
	always #5 clk =~clk;
	
	initial begin
		// Waveform
		$dumpfile("sim_cache_management.vcd"); 
		$dumpvars(0, testbench);

		clk = 0;
		rst = 1;
		cpu_req = 0;
		cpu_write = 0;
		cpu_addr = 0;
		cpu_wdata = 0;

		#20;
		rst = 0;
		#10;

		
		// ---------------------------------------------------------
		// Scenario 1: Cache Miss 
		// CPU wants an unreaden data address. 
		// Main Memory occurs 10 Clock Cycle latency.
		// ---------------------------------------------------------
		cpu_addr = 32'h000000A4; 
		cpu_write = 0;           // Process  type: Reading
		cpu_req = 1;             // CPU start signal
		
		// CPU waits (Stall) until cpu_ready = 1
		wait(cpu_ready == 1);
		@(posedge clk);          // Just wait 1 more Clock Cycle to catch Singal correctly.
		cpu_req = 0;             // CPU closed
		
		#30; // To clear obtain

		// ---------------------------------------------------------
		// Scenario 2: Cache Hit 
		// Data in the Cache. Cpu doesn't send any signal to Main Memory.
		// Process should be completed in 1 Clock Cycle
		// ---------------------------------------------------------
		cpu_addr = 32'h000000A4; // Same address
		cpu_write = 0;           
		cpu_req = 1;             
		
		while (cpu_ready == 0) begin
			@(posedge clk);
		end
		cpu_req = 0;
		
		#30;

		// ---------------------------------------------------------
		// Scenario 3: Write-Through
		// CPU wants to write new data at the same address
		// First Cache delibaretly update, then wait to write to Main Memory
		// ---------------------------------------------------------
		cpu_addr = 32'h000000A4; 
		cpu_wdata = 32'hDEADBEEF; // New data
		cpu_write = 1;            // Process type: Write
		cpu_req = 1;
		
		wait(cpu_ready == 1);
		@(posedge clk);
		cpu_req = 0;
		cpu_write = 0;

		#50;
		
		$finish;
	end
endmodule
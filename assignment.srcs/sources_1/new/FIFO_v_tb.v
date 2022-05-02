`timescale 1 ns / 100 ps
//////////////////////////////////////////////////////////////////////////////////
// Company:                                                                       
// Engineer:                                                                      
//                                                                                
// Create Date: 04/30/2022 12:32:10 PM                                            
// Design Name:                                                                   
// Module Name: FIFO_v_tb                                                             
// Project Name:                                                                  
// Target Devices:                                                                
// Tool Versions:                                                                 
// Description:                                                                   
//                                                                                
// Dependencies:                                                                  
//                                                                                
// Revision:                                                                      
// Revision 0.01 - File Created                                                   
// Additional Comments:                                                           
//                                                                                
//////////////////////////////////////////////////////////////////////////////////
module FIFO_v_tb();
    reg clock;
    reg write_en;
    reg read_en;
    reg n_reset;
    reg [23:0] data_in;
    wire [23:0] data_out;
    wire [4:0] data_count;
    wire full;
    wire empty;
    wire almost_full;
    wire almost_empty;
    wire err;
	reg [23:0] test_vec;
    FIFO main (
        .data_out(data_out), 
        .data_count(data_count), 
        .empty(empty), 
        .full(full), 
        .almost_empty(almost_empty), 
        .almost_full(almost_full), 
        .err(err), 
        .data_in(data_in), 
        .write_en(write_en), 
        .read_en(read_en), 
        .n_reset(n_reset), 
        .clock(clock)
        );
    initial begin
			clock = 1'b 0;
            data_in = 24'b 0;
            write_en = 1'b 0;
            read_en = 1'b 0;
			n_reset = 1'b 0;
    end
	always 
			#10 clock = ~clock;
	always 
		begin
			#30 
			n_reset = 1'b 1;
			for(test_vec=0; test_vec < 17; test_vec = test_vec + 1)
				begin
					#20 
					write_en = 1'b 1;
					data_in = test_vec;
					#20 
					write_en = 1'b 0;		
				end				
			for(test_vec=0; test_vec < 17; test_vec = test_vec + 1)
				begin
					#20 
					read_en = 1'b 1;
					#20 
					read_en = 1'b 0;		
				end		
			for(test_vec=0; test_vec < 15; test_vec = test_vec + 1)
				begin
					#20 
					write_en = 1'b 1;
					data_in = test_vec;
					#20 
					write_en = 1'b 0;		
				end						
			for(test_vec=0; test_vec < 11; test_vec = test_vec + 1)
				begin
					#20 
					read_en = 1'b 1;
					#20 
					read_en = 1'b 0;		
				end					
			for(test_vec=0; test_vec < 11; test_vec = test_vec + 1)
				begin
					#20 
					read_en = 1'b 1;
					write_en = 1'b 1;
					data_in = test_vec;
					#20 
					read_en = 1'b 0;
					write_en = 1'b 0;					
				end							
			for(test_vec=0; test_vec < 7; test_vec = test_vec + 1)
				begin
					#20 
					read_en = 1'b 1;
					#20 
					read_en = 1'b 0;		
				end				
			for(test_vec=0; test_vec < 13; test_vec = test_vec + 1)
				begin
					#20 
					write_en = 1'b 1;
					data_in = test_vec;
					#20 
					write_en = 1'b 0;		
				end
			#10	
			n_reset = 1'b 1;
		end
endmodule 
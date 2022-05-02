`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 04/30/2022 03:16:50 PM
// Design Name: 
// Module Name: FIFO
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

module FIFO #(parameter ADDR_W = 4, DATA_W = 24, BUFF_L = 16, ALMST_F = 3, ALMST_E = 3) 
			(
			output reg [DATA_W- 1:0]data_out,
			output reg [ADDR_W:0]data_count,
			output reg	empty,
			output reg	full,
			output reg	almost_empty,
			output reg	almost_full,
			output reg	err,
			input wire[DATA_W -1:0]	data_in,
			input wire write_en,
			input wire read_en,
			input wire n_reset,
			input wire clock
			);		
			reg [DATA_W-1 : 0] 	mem_array [0:(2**ADDR_W)-1];
			reg	[ADDR_W-1 : 0]	rd_ptr, wr_ptr;
			reg	[ADDR_W-1 : 0]	rd_ptr_nxt, wr_ptr_nxt;
			reg	full_ff, empty_ff;
			reg	full_ff_nxt, empty_ff_nxt;
			reg	almst_f_ff, almst_e_ff;
			reg	almst_f_ff_nxt, almst_e_ff_nxt;
			reg	[ADDR_W : 0] q_reg, q_nxt;
			reg	q_add, q_sub;
//// ------------------------------------------------------------------------------------------------
	always @ (posedge clock)
		begin
			if(n_reset == 1'b 0)
				begin
					rd_ptr <= {(ADDR_W-1){1'b 0}};
					wr_ptr <= {(ADDR_W-1){1'b 0}};
					full_ff <= 1'b 0;
					empty_ff <= 1'b 1;
					almst_f_ff <= 1'b 0;
					almst_e_ff <= 1'b 1;
					q_reg <= {(ADDR_W){1'b 0}};
				end
			else
				begin
					rd_ptr <= rd_ptr_nxt;
					wr_ptr <= wr_ptr_nxt;
					full_ff <= full_ff_nxt;
					empty_ff <= empty_ff_nxt;
					almst_f_ff <= almst_f_ff_nxt;
					almst_e_ff <= almst_e_ff_nxt;
					q_reg <= q_nxt;
				 end
		end
//// ------------------------------------------------------------------------------------------------
	always @ ( almst_e_ff, almst_f_ff, q_reg)
		begin
			almst_e_ff_nxt = almst_e_ff;
			almst_f_ff_nxt = almst_f_ff;							
			if(q_reg < ALMST_E)
				almst_e_ff_nxt = 1'b 1;
			else
				almst_e_ff_nxt = 1'b 0;

			if(q_reg > BUFF_L-ALMST_F)
				almst_f_ff_nxt = 1'b 1;
			else
				almst_f_ff_nxt = 1'b 0;
		end
//// ------------------------------------------------------------------------------------------------	
	always @ (write_en, read_en, wr_ptr, rd_ptr, empty_ff, full_ff, q_reg)
		begin
			wr_ptr_nxt = wr_ptr ;	
			rd_ptr_nxt = rd_ptr;
			full_ff_nxt = full_ff;
			empty_ff_nxt = empty_ff;
			q_add = 1'b 0;
			q_sub = 1'b 0;	
			if(write_en == 1'b 1 & read_en == 1'b 0)
				begin
					if(full_ff == 1'b 0)
						begin
							if(wr_ptr < BUFF_L-1)									
								begin
									q_add = 1'b 1;
									wr_ptr_nxt = wr_ptr + 1;
									empty_ff_nxt = 1'b 0;
								end
							else
								begin
									wr_ptr_nxt = {(ADDR_W-1){1'b 0}};
									empty_ff_nxt = 1'b 0;
								end
							if( (wr_ptr+1 == rd_ptr) || ((wr_ptr == BUFF_L-1) && (rd_ptr == 1'b 0)))   
								full_ff_nxt = 1'b 1;
						end
				end
			if( (write_en == 1'b 0) && (read_en == 1'b 1))
				begin					
					if(empty_ff == 1'b 0) 
						begin
							if(rd_ptr < BUFF_L-1 )													
								begin
									if(q_reg > 0)
										q_sub = 1'b 1;
									else
										q_sub = 1'b 0;
									rd_ptr_nxt = rd_ptr + 1;
									full_ff_nxt = 1'b 0;
								end
							else	
								begin
									rd_ptr_nxt = {(ADDR_W-1){1'b 0}}; 
									full_ff_nxt = 1'b 0;		
								end
							if( (rd_ptr  + 1 == wr_ptr) || ((rd_ptr == BUFF_L -1) && (wr_ptr == 1'b 0 )))  
								empty_ff_nxt = 1'b 1;
						end
				end
			if( (write_en == 1'b 1) && (read_en == 1'b 1)) 
				begin
					if(wr_ptr < BUFF_L -1) 
						wr_ptr_nxt = wr_ptr  + 1;	
					else											
						wr_ptr_nxt =  {(ADDR_W-1){1'b 0}}; 
					
					if(rd_ptr < BUFF_L -1) 
						rd_ptr_nxt = rd_ptr + 1;		
					else
						rd_ptr_nxt = {(ADDR_W-1){1'b 0}}; 
				end
		end
//// ----------------------------------------------------------------------
	always @ (posedge clock)
		begin
			if( n_reset == 1'b 0)
				begin
					mem_array[rd_ptr] <=  {(DATA_W-1){1'b 0}}; 
					data_out <= {(DATA_W-1){1'b 0}}; 
					err <= 1'b 0;
				end
			else
				begin
					if( (write_en == 1'b 1) && (full_ff == 1'b 0) )
						begin
							mem_array[wr_ptr] <=  data_in;
							err <= 1'b 0;						
						end
					else if( (write_en == 1'b 1) && (full_ff == 1'b 1))  
						err <= 1'b 1;
					if( (read_en == 1'b 1) && (empty_ff == 1'b 0))
						begin
							data_out <= mem_array[rd_ptr];
							err <= 1'b 0;
						end
					else if( (read_en == 1'b 1) && (empty_ff == 1'b 1))
						err <= 1'b 1;		
				end	
		end	
//// ------------------------------------------------------------------------------------------------
	always @ ( q_sub, q_add, q_reg)
		begin
			case( {q_sub , q_add} )
				2'b 01 :
						q_nxt = q_reg + 1;
				2'b 10 :
						q_nxt = q_reg - 1;
				default :
						q_nxt = q_reg;
			endcase 	
		end
//// ------------------------------------------------------------------------------------------------
	always @ (full_ff, empty_ff, almst_e_ff, almst_f_ff, q_reg)
		begin
			full = full_ff;
			empty = empty_ff;
			almost_empty = almst_e_ff; 
			almost_full = almst_f_ff;
			data_count = q_reg;
		end			
endmodule


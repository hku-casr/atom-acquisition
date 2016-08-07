module packet_sim
#(parameter AMBER_TIME = 32'd10)
(input clk,
input ce,
input reset,
input fifo_empty,
input [63:0] data_in,
input [13:0] payload_len,
input [13:0] period, 
output reg fifo_rd=1'b0,
output reg [63:0] dout=64'b0,
output reg valid=1'b0,
output reg eof=1'b0
);

// State encoding
localparam STATE_IDLE = 2'd0;
localparam STATE_PACK = 2'd1;
localparam STATE_PACKDELAY = 2'd2;
//localparam STATE_GOING_GREEN = 2'd3;

// State register
reg [1:0] state = 2'b0;

// Register for amber timer counter
reg [13:0] packer_delay = 16'b0;
reg [13:0] packer_cnt = 16'b0;
reg [13:0] temp_pl;
reg [13:0] temp_prd_minus1;
always @(posedge clk) begin
if (reset == 1'b1) begin
  state <= STATE_IDLE;
  fifo_rd <= 1'b0;
  dout <= 0;
  valid <= 1'b0;
  eof <= 1'b0;
  packer_delay <=0;
  packer_cnt <= 0;
end else begin
  fifo_rd <= 1'b0;
  dout <= 0;
  valid <= 1'b0;
  eof <= 1'b0;
  case(state)
	STATE_IDLE: begin
		fifo_rd <= 1'b0;
		dout <= 0;
		valid <= 1'b0;
		eof <= 1'b0;
		temp_pl <= payload_len ; 
		temp_prd_minus1  <= period -1;
		if (fifo_empty == 1'b1) begin
			state <= STATE_IDLE;
		end else begin
			state <= STATE_PACK;
		end
	end
	STATE_PACK: begin
		fifo_rd <= 1'b1;
		dout <= data_in;
		valid <= 1'b1;
		if( packer_cnt < temp_prd_minus1) begin           //for timing introduced temp_reg=period
			packer_cnt <= packer_cnt + 1;
			eof <= 1'b0;
			if (fifo_empty == 1'b1) begin
				state <= STATE_IDLE;
			end else begin
				state <= STATE_PACK;
			end
		end else begin
			packer_cnt <= 0;
			state <= STATE_PACKDELAY;
			eof <=1'b1; 	//last 64 bit data is sent
		end	
	end 
	STATE_PACKDELAY: begin         //wait for pack_delay
		fifo_rd <= 1'b0;
		dout <= data_in;
		valid <= 1'b0;
		eof <=1'b0;
		packer_cnt <= 0;      //just to play safe
		if( packer_delay <= temp_pl) begin
			packer_delay <= packer_delay +1;
			state <= STATE_PACKDELAY;
		end else begin
			packer_delay <= 0;       
			state <= STATE_IDLE;  
		end	
	end 			  
	default: begin
		state <= STATE_IDLE;
	end
  endcase
end
end

endmodule

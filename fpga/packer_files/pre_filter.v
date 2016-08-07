module pre_filter1
(input clk,
input ce, //dummy needed for simulink
input reset,
input [12:0] packer_len,
input enable,
//input [9:0] dcount,
output reg fifo_wr1 ,
output reg fifo_wr2 ,
output reg fifo_wr3 ,
output reg fifo_wr4 
);

// State encoding
localparam STATE_IDLE = 3'd0;
localparam STATE_WR1 = 3'd1;
localparam STATE_WR2 = 3'd2;
localparam STATE_WR3 = 3'd3;
localparam STATE_WR4 = 3'd4;
//localparam STATE_GOING_GREEN = 2'd3;

// State register
reg [2:0] state = 3'd0;
reg[12:0] cnt= 13'd0;
reg [12:0] temp_len =13'b0;
// Register for amber timer counter

initial begin
fifo_wr1<= 1'b0;
fifo_wr2<= 1'b0;
fifo_wr3<= 1'b0;
fifo_wr4<= 1'b0;
end

always @(posedge clk) begin
if (reset == 1'b1) begin
	fifo_wr1<= 1'b0;
	fifo_wr2<= 1'b0;
	fifo_wr3<= 1'b0;
	fifo_wr4<= 1'b0;
	cnt <= 0;
	state <= STATE_IDLE;
end else begin
   fifo_wr1<= 1'b0;
	fifo_wr2<= 1'b0;
	fifo_wr3<= 1'b0;
	fifo_wr4<= 1'b0;
	case(state)
	STATE_IDLE: begin
		cnt <= 0;
		if (enable == 1'b1) begin //we can change later if (fifo_empty == 1'b1) begin
			temp_len <= packer_len - 1;   //-1 for timing
			state <= STATE_WR1;
		end else begin
			state <= STATE_IDLE;
		end
	end
	STATE_WR1: begin
		fifo_wr1<= 1'b1;
		fifo_wr2<= 1'b1;
		fifo_wr3<= 1'b0;
		fifo_wr4<= 1'b0;
		if (enable == 1'b0) begin
			state <= STATE_IDLE;
		end else if( cnt < temp_len) begin           
			state <= STATE_WR1; 			
			cnt <= cnt + 1;
		end else begin
			state <= STATE_WR2;
			cnt<= 0;
		end	
	end 
	STATE_WR2: begin
		fifo_wr1<= 1'b0;
		fifo_wr2<= 1'b0;
		fifo_wr3<= 1'b1;
		fifo_wr4<= 1'b1;
		if (enable == 1'b0) begin
			state <= STATE_IDLE;
		end else if( cnt < temp_len) begin           
			state <= STATE_WR2; 			
			cnt <= cnt + 1;
		end else begin
			state <= STATE_WR1;
			cnt<= 0;
		end	
	end 
	default: begin
	   fifo_wr1<= 1'b0;
		fifo_wr2<= 1'b0;
		fifo_wr3<= 1'b0;
		fifo_wr4<= 1'b0;
		state <= STATE_IDLE;
		cnt<= 0;
	end
  endcase
end
end

endmodule

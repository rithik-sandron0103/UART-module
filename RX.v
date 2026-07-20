module Rx #(
    parameter integer CLK_FREQ = 50000000,  // System clock frequency in Hz
    parameter integer BAUD_RATE = 115200    // Baud rate in bps
)
         (input clk,
          input rst,
          input rx,                  // Serial UART reception input line
          output reg [7:0] data_out, // Parallel data byte received
          output reg rx_done);

    // Local Parameter Calculations
    localparam integer CLK_PER_BIT = CLK_FREQ / BAUD_RATE;
    localparam integer MID_POINT = CLK_PER_BIT / 2;         // Midpoint count for sampling the start bit accurately
    localparam integer COUNTER_WIDTH = $clog2(CLK_PER_BIT); // Ceiling of log base 2 => minimum number of bits required to represent 'clock per bit'

    parameter IDLE = 3'd0,
             START = 3'd1,
              DATA = 3'd2,
              STOP = 3'd3,
              DONE = 3'd4;

    reg [2:0] state, next_state;

    // Next-State Combinational logic
    always @(*) begin
        case(state)
            IDLE: next_state = rx ? IDLE : START;
            START: next_state = (count == MID_POINT - 1) ? DATA : START; // Mid-bit Sampling
            DATA: next_state = (bit_counter == 4'd7) && baud_tick ? STOP : DATA;
            STOP: next_state = baud_tick ? DONE : STOP;
            DONE: next_state = IDLE;
            default: next_state = IDLE;
        endcase
    end

    reg baud_tick;            // High for 1 clock cycle at each baud rate interval
    reg [13:0] count;         // Baud rate generator counter
    reg [3:0] bit_counter;    // Counts the number of data bits transmitted (0 to 7)
    reg [7:0] rx_data_buffer; // Internal shift register to assemble incoming serial bits

    // Sequential logic
    always @(posedge clk) begin
        if (rst) begin
            state <= IDLE;
            count <= {COUNTER_WIDTH{1'b0}};
            bit_counter <= 4'b0;
            rx_data_buffer <= 8'b0;
            rx_done <= 1'b0;
        end
        else begin
            // State Updation
            state <= next_state;
            // Flagging done
            rx_done <= (state == DONE);

            // Baud Tick Generator
            if (state == IDLE) begin
                count <= {COUNTER_WIDTH{1'b0}};
                baud_tick <= 1'b0;
            end
            else begin
                if (count == CLK_PER_BIT - 1) begin
                    baud_tick <= 1'b1;
                    count <= {COUNTER_WIDTH{1'b0}};
                end
                else begin 
                    baud_tick <= 1'b0;
                    count <= count+1;
                end
            end

            // Datapath Operations
            case(state)
                START: begin
                    if (count == MID_POINT - 1) begin //Reset counter at midpoint of start bit
                        count <= {COUNTER_WIDTH{1'b0}};
                        bit_counter <= 4'b0;
                    end
                end
                DATA: begin
                    if (baud_tick) begin
                        bit_counter <= bit_counter+1;
                        rx_data_buffer <= {rx,rx_data_buffer[7:1]}; // Shift incoming serial bit into the MSB position
                    end
                end
                STOP: if (baud_tick) data_out <= rx_data_buffer;
            endcase  
        end
    end
endmodule
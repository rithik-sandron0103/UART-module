module Tx(input clk, 
          input rst, 
          input txstart,
          input [7:0] data_in,  // Parallel data byte to be transmitted
          output reg tx,        // Serial UART transmission output line
          output txbusy
          );

    parameter IDLE = 3'd0,
             START = 3'd1,
              DATA = 3'd2,
              STOP = 3'd3,
              DONE = 3'd4;

    reg [2:0] state, next_state;

    // Next-State Combinational logic
    always @(*) begin
        case(state)
        IDLE: next_state = txstart ? START : IDLE; 
        START: next_state = baud_tick ? DATA : START;
        DATA: next_state = (bit_counter == 4'd7) && baud_tick ? STOP : DATA;
        STOP: next_state = baud_tick ? DONE : STOP;
        DONE: next_state = IDLE;
        default: next_state = IDLE;
        endcase
    end

    reg baud_tick;            // High for 1 clock cycle at each baud rate interval
    reg [13:0] count;         // Baud rate generator counter (Counts from 0 to 5199)
    reg [3:0] bit_counter;    // Counts the number of data bits transmitted (0 to 7)
    reg [7:0] tx_data_buffer; // Internal shift register to hold and serialize data

    // Sequential logic
    always @(posedge clk) begin
        if (rst) begin            
            state <= IDLE;
            count <= 14'b0;
            baud_tick <= 1'b0;
            bit_counter <= 4'b0;
            tx_data_buffer <= 8'b0;
        end
        else begin
            // Baud rate generator
            if (count == 14'd5199) begin
                count <= 14'b0;
                baud_tick <= 1'b1;
            end
            else begin
                count <= count+1;
                baud_tick <= 1'b0;
            end

            // State Updation
            state <= next_state; 

            // Datapath operations for each state
            case(state)
                IDLE: if (txstart) tx_data_buffer <= data_in; // Capture parallel input byte into buffer
                START: if (baud_tick) bit_counter <= 4'b0;// Reset bit counter at the start of data transmission
                DATA: begin
                    if (baud_tick) begin
                        bit_counter <= bit_counter+1;
                        tx_data_buffer <= tx_data_buffer >> 1; // Shift right so the next bit is at LSB [0]
                    end
                end
            endcase
        end
    end

    // Output logic
    assign txbusy = (state != IDLE);

    always @(*) begin
        case(state)
            START: tx <= 1'b0;
            DATA: tx <= tx_data_buffer[0]; //Since the LSB gets updated for every baud_tick, the input comes out sequentially
            default: tx <= 1'b1;
        endcase
    end
    
endmodule
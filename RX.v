module Rx(input clk,
          input rst,
          input rx,
          output reg [7:0] data_out,
          output reg rx_done);

    parameter IDLE = 0, START = 1, DATA = 2, STOP = 3, DONE = 4;
    reg [2:0] state, next_state;

    //Combinational block
    always @(*) begin
        case(state)
            IDLE: next_state = rx ? IDLE : START;
            START: next_state = (count == 2599) ? DATA : START;
            DATA: next_state = (bit_counter == 7) && baud_tick ? STOP : DATA;
            STOP: next_state = baud_tick ? DONE : STOP;
            DONE: next_state = IDLE;
            default: next_state = IDLE;
        endcase
    end

    reg baud_tick;
    reg [13:0] count;
    reg [3:0] bit_counter;
    reg [7:0] rx_data_buffer;

    //Sequential block
    always @(posedge clk) begin
        if (rst) begin
            count <= 0;
            bit_counter <= 0;
            rx_data_buffer <= 0;
            state <= 0;
            rx_done <= 0;
        end
        else begin
            state <= next_state;
            rx_done <= (state == DONE);

            //Baud Tick Generator
            if (state == IDLE) begin
                count <= 0;
                baud_tick <= 0;
            end
            else begin
                if (count == 5199) begin
                    baud_tick <= 1;
                    count <= 0;
                end
                else begin 
                    baud_tick <= 0;
                    count <= count+1;
                end
            end
            //16x over-sampling
            case(state)
                START: begin
                    if (count == 2599) begin //Reset counter at midpoint of start bit
                        count <= 0;
                        bit_counter <= 0;
                    end
                end
                DATA: begin
                    if (baud_tick) begin
                        bit_counter <= bit_counter+1;
                        rx_data_buffer <= {rx,rx_data_buffer[7:1]}; //Shift in MSB-to-LSB
                    end
                end
                STOP: if (baud_tick) data_out <= rx_data_buffer;
            endcase  
        end
    end
endmodule
module Tx(input clk, 
          input rst, 
          input txstart, 
          input [7:0] data_in,
          output reg tx,
          output txbusy);

    parameter IDLE = 0, START = 1, DATA = 2, STOP = 3, DONE = 4;
    reg [2:0] state, next_state;

    //Combinational block
    always @(*) begin
        case(state)
        IDLE: next_state = txstart ? START : IDLE; 
        START: next_state = baud_tick ? DATA : START;
        DATA: next_state = (bit_counter == 7) && baud_tick ? STOP : DATA;
        STOP: next_state = baud_tick ? DONE : STOP;
        DONE: next_state = IDLE;
        default: next_state = IDLE;
        endcase
    end

    reg baud_tick;
    reg [13:0] count;
    reg [3:0] bit_counter;
    reg [7:0] tx_data_buffer;

    //Sequential block
    always @(posedge clk) begin
        if (rst) begin
            count <= 0;
            baud_tick <= 0;
            state <= 0;
            bit_counter <= 0;
            tx_data_buffer <= 0;
        end
        else begin
            if (count == 5199) begin
                count <= 0;
                baud_tick <= 1;
            end
            else begin
                count <= count+1;
                baud_tick <= 0;
            end

            state<=next_state;

            case(state)
                IDLE: if (txstart) tx_data_buffer <= data_in; //The entire 8 bits are taken in parallely into a buffer
                START: if (baud_tick) bit_counter <= 0;
                DATA: begin
                    if (baud_tick) begin
                        bit_counter <= bit_counter+1;
                        tx_data_buffer <= tx_data_buffer>>1; //Right-shifting so that LSB gets updated
                    end
                end
            endcase
        end
    end

    //Output logic
    assign txbusy = (state != 0);
    always @(*) begin
        case(state)
            START: tx <= 1'b0;
            DATA: tx <= tx_data_buffer[0]; //Since the LSB gets updated for every baud_tick, the input comes out sequentially
            default: tx <= 1'b1;
        endcase
    end
endmodule
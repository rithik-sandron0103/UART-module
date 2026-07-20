module Top(input clk,
           input rst,
           input rxline,
           output txline,
           output [7:0] received_data,
           output packet_recieved);

    // Internal interconnect wires
    wire [7:0] producer_data;
    wire startwire;
    wire busywire;

    // Producer Instantiation
    // Continuously generates an incrementing stream of data bytes when the transmitter is idle
    Producer producer(
        .clk(clk),
        .rst(rst),
        .txbusy(busywire),
        .txstart(startwire),
        .data_out(producer_data)
    );

    // UART Transmitter (Tx) Instantiation
    // Serializes the parallel bytes received from the producer
    Tx transmitter(
        .clk(clk),
        .rst(rst),
        .txstart(startwire),
        .data_in(producer_data),
        .tx(txline),
        .txbusy(busywire)
    );

    // UART Receiver (Rx) Instantiation
    // Samples the incoming serial line (rxline) and converts the bitstream back into a parallel bytes
    Rx receiver(
        .clk(clk),
        .rst(rst),
        .rx(rxline),
        .data_out(received_data),
        .rx_done(packet_recieved)
    );
    
endmodule
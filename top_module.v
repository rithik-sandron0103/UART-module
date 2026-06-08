module Top(input clk,
           input rst,
           input rxline,
           output txline,
           output [7:0] received_data,
           output packet_recieved);

    wire [7:0] producer_data;
    wire startwire;
    wire busywire;

    //Instantiation
    Producer producer(
        .clk(clk),
        .rst(rst),
        .txbusy(busywire),
        .txstart(startwire),
        .data_out(producer_data)
    );

    Tx transmitter(
        .clk(clk),
        .rst(rst),
        .txstart(startwire),
        .data_in(producer_data),
        .tx(txline),
        .txbusy(busywire)
    );

    Rx receiver(
        .clk(clk),
        .rst(rst),
        .rx(rxline),
        .data_out(received_data),
        .rx_done(packet_recieved)
    );
    
endmodule
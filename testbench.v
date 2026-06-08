`timescale 1ns/1ps

module Top_tb();

    reg clk = 0;
    reg rst;

    wire txline;
    wire rxline;
    wire [7:0] received_data;
    wire packet_recieved;

    //Loopback connection
    assign rxline = txline;

    Top uut(
        .clk(clk),
        .rst(rst),
        .rxline(rxline),
        .txline(txline),
        .received_data(received_data),
        .packet_recieved(packet_recieved)
    );

    //Clock generation
    always #5 clk = ~clk;

    //Reset
    initial begin
        rst = 1;
        #100;
        rst = 0;
    end

    initial begin
        $dumpfile("top.vcd");
        $dumpvars(0, Top_tb);
    end

    always @(posedge packet_recieved) begin
        $display("Time=%0t | Received=%0d",
                $time, received_data);
    end

    initial begin
        #1000000000
        $finish;
    end

endmodule
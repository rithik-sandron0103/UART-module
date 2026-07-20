`timescale 1ns/1ps

module Top_tb();

    // Testbench Signals and Registers
    reg clk;    // System clock signal
    reg rst;    // Synchronous active-high reset

    wire txline;              // Serial transmission line from UUT
    wire rxline;              // Serial reception line (loopback connected to txline)
    wire [7:0] received_data; // Parallel data byte received by the UART receiver
    wire packet_recieved;     // Pulsed high when a full data byte has been received

    // Loopback connection
    assign rxline = txline;

    // Unit Under Test (UUT) Instantiation
    Top uut(
        .clk(clk),
        .rst(rst),
        .rxline(rxline),
        .txline(txline),
        .received_data(received_data),
        .packet_recieved(packet_recieved)
    );

    // Clock generation
    initial begin
        clk = 1'b0;
    end
    always #5 clk = ~clk;

    // Reset Control
    initial begin
        rst = 1;
        #100;
        rst = 0;
    end

    // Waveform Generation
    initial begin
        $dumpfile("top.vcd");
        $dumpvars(0, Top_tb); // Dump all hierarchical variables under the testbench scope
    end

    // Triggered whenever a packet is successfully received via loopback
    always @(posedge packet_recieved) begin
        $display("Time=%0t | Received=%0d",
                $time, received_data);
    end

    // Termination
    initial begin
        #1000000000 // Run simulation for 1 ms of simulated time
        $finish;
    end

endmodule
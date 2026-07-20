module Producer(input clk,
                input rst,
                input txbusy,       // Transmitter busy signal from the Tx module
                output reg txstart,
                output reg [7:0] data_out // Parallel data byte to be sent to the transmitter
                );

    reg txbusy_delayed;

    // Registering tx_busy for falling-edge detection
    always @(posedge clk) begin
        if (rst) txbusy_delayed <= 1;
        else txbusy_delayed <= txbusy;     
    end

    always @(posedge clk) begin
        if (rst) begin
            txstart <= 1'b0;
            data_out <= 8'd0;
        end
        else begin
            // Detecting falling edge of tx_busy
            if (txbusy_delayed && !txbusy) txstart <= 1;
            else txstart <= 0; 

            // Increment data payload right when transmission starts
            if (txstart) begin
                if (data_out == 8'd255) data_out <= 8'd0;
                else data_out <= data_out+1;
            end
        end
    end
endmodule
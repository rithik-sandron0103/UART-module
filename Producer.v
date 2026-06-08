module Producer(input clk,
                input rst,
                input txbusy,
                output reg txstart,
                output reg [7:0] data_out);

    reg txbusy_delayed;
    always @(posedge clk) begin
        if (rst) txbusy_delayed <= 1;
        else txbusy_delayed <= txbusy;     
    end

    always @(posedge clk) begin
        if (rst) begin
            txstart <= 0;
            data_out <= 8'd0;
        end
        else begin
            if (txbusy_delayed && !txbusy) txstart <= 1;
            else txstart <= 0; 
            if (txstart) begin
                if (data_out == 8'd255) data_out <= 8'd0;
                else data_out <= data_out+1;
            end
        end
    end
endmodule
module UART_TX(
    input clk, rst, load,
    input [7:0] data, 
    output reg tx
);
    
    localparam IDLE       = 2'b00, 
               START_BIT  = 2'b01, 
               DATA_BITS  = 2'b10, 
               STOP_BIT   = 2'b11;
               
    parameter CLKS_PER_BIT = 217;
    
    reg [$clog2(CLKS_PER_BIT)-1:0] clk_count;
    reg [1:0] state; 
    reg [2:0] bit_index;
    reg [7:0] tx_data;
    
    always @(posedge clk or negedge rst) 
    begin
        if (!rst) 
        begin
            state     <= IDLE;
            tx        <= 1'b1; 
            clk_count <= 0;
            bit_index <= 0;
            tx_data   <= 8'b0;
        end
        else 
        begin
            case (state)
                IDLE : 
                begin
                    tx        <= 1'b1; 
                    clk_count <= 0;
                    bit_index <= 0;
                    
                    if (load) 
                    begin
                        tx_data <= data;      
                        state   <= START_BIT;
                    end
                end
                
                START_BIT : 
                begin
                    tx <= 1'b0; 
                    
                    if (clk_count < CLKS_PER_BIT - 1) 
                    begin
                        clk_count <= clk_count + 1;
                    end
                    else 
                    begin
                        clk_count <= 0;
                        state     <= DATA_BITS;
                    end
                end
                
                DATA_BITS : 
                begin
                    tx <= tx_data[bit_index]; 
                    
                    if (clk_count < CLKS_PER_BIT - 1) 
                    begin
                        clk_count <= clk_count + 1;
                    end
                    else 
                    begin
                        clk_count <= 0;
                        
                        if (bit_index < 7) 
                        begin
                            bit_index <= bit_index + 1;
                        end
                        else 
                        begin
                            bit_index <= 0;
                            state     <= STOP_BIT;
                        end
                    end
                end
                
                STOP_BIT : 
                begin
                    tx <= 1'b1; 
                    
                    if (clk_count < CLKS_PER_BIT - 1) 
                    begin
                        clk_count <= clk_count + 1;
                    end
                    else 
                    begin
                        clk_count <= 0;
                        state     <= IDLE;
                    end
                end
                
                default : state <= IDLE;
            endcase
        end
    end
    
endmodule

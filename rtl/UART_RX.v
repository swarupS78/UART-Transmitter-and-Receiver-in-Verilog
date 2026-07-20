module UART_RX(
    input clk, rst, rx,
    output reg [7:0] data
);
   
    localparam IDLE       = 2'b00,
               START_BIT  = 2'b01,
               DATA_BITS  = 2'b10,
               STOP_BIT   = 2'b11;
  
    parameter CLKS_PER_BIT = 217;
  
    reg [$clog2(CLKS_PER_BIT)-1:0] clk_count;
    reg [1:0] state;
    reg [2:0] bit_index;
  
    always @(posedge clk or negedge rst)
    begin
        if (!rst)
        begin
            state     <= IDLE;
            clk_count <= 0;
            bit_index <= 0;
            data      <= 8'b0;
        end
        else
        begin
            case (state)
                IDLE :
                begin
                    clk_count <= 0;
                    bit_index <= 0;
          
                    if (rx == 1'b0)
                        state <= START_BIT;
                    else
                        state <= IDLE;
                end
      
                START_BIT :
                begin
                    if (clk_count == (CLKS_PER_BIT - 1) / 2)
                    begin
                        if (rx == 1'b0)
                        begin
                            clk_count <= 0;
                            state     <= DATA_BITS;
                        end
                        else
                            state     <= IDLE;
                    end
                    else
                    begin
                        clk_count <= clk_count + 1;
                        state     <= START_BIT;
                    end
                end
      
                DATA_BITS :
                begin
                    if (clk_count < CLKS_PER_BIT - 1)
                    begin
                        clk_count <= clk_count + 1;
                        state     <= DATA_BITS;
                    end
                    else
                    begin
                        clk_count       <= 0;
                        data[bit_index] <= rx;
            
                        if (bit_index < 7)
                        begin
                            bit_index <= bit_index + 1;
                            state     <= DATA_BITS;
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
                    if (clk_count < CLKS_PER_BIT - 1)
                    begin
                        clk_count <= clk_count + 1;
                        state     <= STOP_BIT;
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

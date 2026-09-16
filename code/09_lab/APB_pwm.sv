
`define DUTY_CYCLE 7'h08
`define FREQ 7'h04
`define CONF 7'h00 // Configuration Register, config[0]: enable, config[1]: clear

module APB_pwm #(
    // Configurable Parameters
    parameter DW = 32 ,  // Data width
    parameter AW = 32   // Address width
) (
    input logic pCLK,
    input logic pRESETn,

    // APB signals
    input logic [AW-1:0] pADDR,
    input logic  pSEL, // for each peripheral
    input logic  pENABLE,
    input logic  pWRITE,
    input logic [DW-1:0] pWDATA,
    output logic [DW-1:0] pRDATA,
    output logic  pREADY,
    output logic  pSLVERR,
    // External signals
    output logic pwm_out
);

    // registers for switches and leds
    logic [31:0] config_reg;

    // instantiate prescaler with freqency of 10KHz
    logic clock_enable;
    logic [9:0] limit_reg;

    assign limit_reg = 10'd999; // for 10KHz with 100MHz clock
    prescaler #(10) prescaler_inst (
        .clock(pCLK),
        .reset(!pRESETn),
        .limit(limit_reg),
        .clock_enable(clock_enable)
    );

    // instantiate counter
    logic [63:0] count_reg;
    logic [31:0] freq_reg;
    logic [31:0] duty_cycle_reg;
    
    always_ff @( posedge(pCLK) ) begin : PWM_generation_block
        if(!pRESETn) begin
            count_reg <= 64'b0;
        end else begin
            if (config_reg[0]) begin // if enabled
                if (clock_enable) begin
                    count_reg <= count_reg + 1;
                    if(count_reg == freq_reg - 1) begin
                        count_reg <= 64'b0;
                    end
                end
            end
        end
    end

    // PWM output logic
    assign pwm_out = count_reg < duty_cycle_reg;
  

    // define register for config device to enable/clear timer
    logic wr_en;
    // decoding logic 
    assign wr_en = pSEL & pWRITE & pREADY & pENABLE ; 
                               
    // write data into config register when selected 
    always_ff @( posedge pCLK ) begin : write_logic
        if (!pRESETn) begin
            config_reg <= 0;
        end else begin
            if (wr_en) begin
                case (pADDR[6:0])
                    `CONF: config_reg <= pWDATA;
                    `FREQ: freq_reg <= pWDATA;
                    `DUTY_CYCLE: duty_cycle_reg <= pWDATA;
                    default:  duty_cycle_reg <= 32'b0;
                endcase
            end
        end
    end

    // Reading data counters

    // define register
    assign pRDATA = 0;
    
    //assign pRDATA = read_data;

    // Ready state logic
    assign pREADY = 1'b1;
    
    
    // APB Slave Error Response
    // write fail, occurs when we write to an invalid address
    logic write_fail;
    assign write_fail = (wr_en && pADDR[6:0] != `CONF && pADDR[6:0] != `FREQ && pADDR[6:0] != `DUTY_CYCLE) ? 1'b1 : 1'b0;

    // read fail, occurs when we read an invalid address
    logic read_fail;
    assign read_fail = 1'b0;

    always_ff @(posedge pCLK) begin
        if (!pRESETn) begin
            pSLVERR <= 1'b0;
        end else begin
            pSLVERR <= write_fail | read_fail;
        end
    end

endmodule


module prescaler
    #(parameter PRESCALER_WIDTH = 8)
    (
        input logic clock,
        input logic reset,
        input logic [PRESCALER_WIDTH-1:0] limit,
        output logic clock_enable
    );

    logic [PRESCALER_WIDTH-1:0] count;

    always_ff @( posedge clock) begin 
        if (reset) begin
            count <= 0;
            clock_enable <= 0;
        end
        else begin
            if (count == limit-1) begin
                count <= 0;
                clock_enable <= ~clock_enable;
            end
            else begin
                clock_enable <= 0;
                count <= count + 1;
            end
        end
    end

endmodule
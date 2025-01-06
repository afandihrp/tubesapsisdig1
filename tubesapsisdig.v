module tubesapsisdig (
    input wire clk,          // Clock input
    input wire reset,        // Reset signal (active high)
    input wire vcc,          // Power supply (logic high)
    input wire gnd,          // Ground (logic low)
    output reg [2:0] light_main,  // Main road traffic light (R-Y-G)
    output reg [2:0] light_side   // Side road traffic light (R-Y-G)
);

    // State encoding
    localparam MAIN_GREEN   = 2'b00;  // Main road green, side road red
    localparam MAIN_YELLOW  = 2'b01;  // Main road yellow, side road red
    localparam SIDE_GREEN   = 2'b10;  // Side road green, main road red
    localparam SIDE_YELLOW  = 2'b11;  // Side road yellow, main road red

    reg [1:0] state;         // Current state
    reg [1:0] next_state;    // Next state

    // Timer
    localparam CLOCK_FREQ = 50000000; // Assuming 50 MHz clock
    localparam TIMER_COUNT = 60;
    reg [31:0] timer;        // Timer register

    // State transition logic (sequential)
    always @(posedge clk or posedge reset) begin
        if (reset == vcc) begin
            state <= MAIN_GREEN;
            timer <= 0;
        end else begin
            if (timer < (CLOCK_FREQ * TIMER_COUNT)) begin
                timer <= timer + 1;
            end else begin
                timer <= 0;          // Reset timer
                state <= next_state; // Transition to next state
            end
        end
    end

    // Next state logic (combinational)
    always @(*) begin
        case (state)
            MAIN_GREEN:   next_state = MAIN_YELLOW;
            MAIN_YELLOW:  next_state = SIDE_GREEN;
            SIDE_GREEN:   next_state = SIDE_YELLOW;
            SIDE_YELLOW:  next_state = MAIN_GREEN;
            default:      next_state = MAIN_GREEN;
        endcase
    end

    // Output logic (combinational)
    always @(*) begin
        case (state)
            MAIN_GREEN: begin
                light_main = 3'b001;  // Green
                light_side = 3'b100;  // Red
            end
            MAIN_YELLOW: begin
                light_main = 3'b010;  // Yellow
                light_side = 3'b100;  // Red
            end
            SIDE_GREEN: begin
                light_main = 3'b100;  // Red
                light_side = 3'b001;  // Green
            end
            SIDE_YELLOW: begin
                light_main = 3'b100;  // Red
                light_side = 3'b010;  // Yellow
            end
            default: begin
                light_main = 3'b100;  // Default to red
                light_side = 3'b100;  // Default to red
            end
        endcase
    end
endmodule

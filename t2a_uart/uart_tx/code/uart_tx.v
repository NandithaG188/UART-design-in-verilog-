// EcoMender Bot : Task 2A - UART Transmitter
/*
Instructions
-------------------
Students are not allowed to make any changes in the Module declaration.

This file is used to generate UART Tx data packet to transmit the messages based on the input data.

Recommended Quartus Version : 20.1
The submitted project file must be 20.1 compatible as the evaluation will be done on Quartus Prime Lite 20.1.

Warning: The error due to compatibility will not be entertained.
-------------------
*/

/*
Module UART Transmitter

Input:  clk_3125 - 3125 KHz clock
        parity_type - even(0)/odd(1) parity type
        tx_start - signal to start the communication.
        data    - 8-bit data line to transmit

Output: tx      - UART Transmission Line
        tx_done - message transmitted flag
*/

//// module declaration
//module uart_tx(
//    input clk_3125,
//    input parity_type,tx_start,
//    input [7:0] data,
//    output reg tx, tx_done
//);
//
////////////////////DO NOT MAKE ANY CHANGES ABOVE THIS LINE//////////////////
//
//
//// Add your code here...
//
//// State encoding
//localparam IDLE = 3'b000,
//           START = 3'b001,
//           DATA = 3'b010,
//           PARITY = 3'b011,
//           STOP = 3'b100;
//
//reg [2:0] state,nextstate;
//
//// Parameters
//localparam integer BAUD_COUNT = 13;  // Number of clock cycles for 230400 baud at 3.125 MHz
//
//// Registers
//reg [3:0] bit_counter;        // Counts up to 14 for bit timing
//reg [2:0] data_bit_index;     // Counts through each data bit (0 to 7)
//reg flag;
////reg parity_bit;               // Stores calculated parity bit
//
//// Initialization
//initial begin
//    tx = 1;
//    tx_done = 0;
//    state = IDLE;
//	 bit_counter = 0;
//    data_bit_index = 0;
//	 flag=0;
//	 
//end
//
//
//
//always @(posedge clk_3125, posedge tx_start) begin
//if(tx_start) state=START;
//else begin 
//if (bit_counter == BAUD_COUNT) begin
//                    bit_counter = 0;
//						  flag=1;
//                end else
//                    bit_counter = bit_counter + 1'b1;
//						  flag=0;
//						  state=nextstate;
//						  
//            end
//end
//
//
//// FSM and counter logic
//always @(*) begin
//
//        case (state)
//            IDLE: begin
//                tx = 1;
//                tx_done = 0;
//                
//            end
//
//            START: begin
//                tx = 0; // Start bit
//					 nextstate=START;
//                if (flag == 1) nextstate = DATA;
//					 end
//
//            DATA: begin
//                tx = data[7 - data_bit_index]; // Big-endian transmission, MSB first
//					 nextstate=DATA;
//                if (flag == 1) begin
//                    
//                    if (data_bit_index == 7)
//                        nextstate = PARITY;
//                    else
//                        data_bit_index = data_bit_index + 1'b1;
//                end 
//					 end
//
//            PARITY: begin
//                //tx <= parity_bit;
//					 tx= (parity_type == 1'b0) ? ^data : ~(^data);
//					 nextstate=PARITY;
//                if (flag == 1) begin
//                    nextstate = STOP;
//                end 
//            end
//
//            STOP: begin
//                tx = 1; // Stop bit
//					 nextstate=STOP;
//                if (flag == 1) begin
//                    tx_done = 1;
//                    nextstate = IDLE;
//                end 
//            end
//        endcase
//		  end
//
//
////////////////////DO NOT MAKE ANY CHANGES BELOW THIS LINE//////////////////
//
//endmodule

module uart_tx(
    input clk_3125,
    input parity_type, tx_start,
    input [7:0] data,
    output reg tx, tx_done
);

//////////////////DO NOT MAKE ANY CHANGES ABOVE THIS LINE//////////////////

// State encoding
localparam IDLE = 3'b000,
           START = 3'b001,
           DATA = 3'b010,
           PARITY = 3'b011,
           STOP = 3'b100;

// Parameters
localparam integer BAUD_COUNT = 13;  // Number of clock cycles for 230400 baud at 3.125 MHz

// Registers
reg [2:0] state, nextstate;
reg [3:0] bit_counter;        // Counts up to 14 for bit timing
reg [2:0] data_bit_index;     // Counts through each data bit (0 to 7)

// Initialization
initial begin
    tx = 1;
    tx_done = 0;
    state = IDLE;
    bit_counter = 0;
    data_bit_index = 0;
end

// State and counter update logic
always @(posedge clk_3125) begin
    if (tx_start && state == IDLE) begin
        // Start the transmission if tx_start is high in IDLE state
        state = START;
        bit_counter = 0;
        
        
    end else if (bit_counter == BAUD_COUNT) begin
        // When the counter reaches BAUD_COUNT, reset it and update the state
        bit_counter = 0;
        state = nextstate;
    end else begin
        bit_counter = bit_counter + 1;
    end
end

// FSM Logic for UART Transmission
always @(*) begin
    case (state)
        IDLE: begin
            tx = 1;                   // Idle line high
            tx_done = 0;
            nextstate = IDLE;
        end

        START: begin
            tx = 0;                   // Start bit
            nextstate = (bit_counter == BAUD_COUNT) ? DATA : START;
        end

        DATA: begin
            tx = data[7 - data_bit_index]; // Send each data bit
            if (bit_counter == BAUD_COUNT) begin
                if (data_bit_index == 7) begin
                    nextstate = PARITY;
						  data_bit_index = 0;
						  end
                else begin
                    nextstate = DATA;
                    data_bit_index = data_bit_index + 1;
                end
            end else begin
                nextstate = DATA;
            end
        end

        PARITY: begin
            tx = (parity_type == 1'b0) ? ^data : ~(^data);  // Parity bit based on parity_type
            nextstate = (bit_counter == BAUD_COUNT) ? STOP : PARITY;
        end

        STOP: begin
            tx = 1;                   // Stop bit
            if (bit_counter == BAUD_COUNT) begin
                tx_done = 1;
                nextstate = IDLE;
            end else begin
                nextstate = STOP;
            end
        end
    endcase
end

//////////////////DO NOT MAKE ANY CHANGES BELOW THIS LINE//////////////////

endmodule



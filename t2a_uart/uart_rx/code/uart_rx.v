//// EcoMender Bot : Task 2A - UART Receiver
///*
//Instructions
//-------------------
//Students are not allowed to make any changes in the Module declaration.
//
//This file is used to receive UART Rx data packet from receiver line and then update the rx_msg and rx_complete data lines.
//
//Recommended Quartus Version : 20.1
//The submitted project file must be 20.1 compatible as the evaluation will be done on Quartus Prime Lite 20.1.
//
//Warning: The error due to compatibility will not be entertained.
//-------------------
//*/
//
///*
//Module UART Receiver
//
//Baudrate: 230400 
//
//Input:  clk_3125 - 3125 KHz clock
//        rx      - UART Receiver
//
//Output: rx_msg - received input message of 8-bit width
//        rx_parity - received parity bit
//        rx_complete - successful uart packet processed signal
//*/
//
//// module declaration
//module uart_rx(
//    input clk_3125,
//    input rx,
//    output reg [7:0] rx_msg,
//    output reg rx_parity,
//    output reg rx_complete
//    );
//
////////////////////DO NOT MAKE ANY CHANGES ABOVE THIS LINE//////////////////
//
//// Add your code here....
//// State encoding
//localparam IDLE = 3'b000,
//           START = 3'b001,
//           DATA = 3'b010,
//           PARITY = 3'b011,
//           STOP = 3'b100;
//			  
//// Parameters
//localparam integer BAUD_COUNT = 13;  // Number of clock cycles for 230400 baud at 3.125 MHz
//
//// Registers
//reg [2:0] state, nextstate;
//reg [3:0] bit_counter;        // Counts up to 14 for bit timing
//reg [2:0] data_bit_index;     // Counts through each data bit (0 to 7)
//reg [7:0] rx_msgs;
//
//initial begin
//    rx_msg = 0;
//	 rx_msgs = 0;
//	 rx_parity = 0;
//    rx_complete = 0;
//	 state = IDLE;
//    nextstate = IDLE;
//    bit_counter = 0;
//    data_bit_index = 0;
//end
//
//// State and counter update logic
//always @(posedge clk_3125) begin
//
//
//    if (!rx && (state==IDLE)) begin
//        // Start the transmission if tx_start is high in IDLE state
//        state <= START;
//        bit_counter <= 0;
//        
//        
//    end else if (bit_counter == BAUD_COUNT) begin
//        // When the counter reaches BAUD_COUNT, reset it and update the state
//		 if(state==START) begin rx_complete<=1; end
//       bit_counter <= 1;
//       state <= nextstate;
//		 
//    end 
//	 
//	 else begin
//	     rx_complete<=0;
//        bit_counter <= bit_counter + 1;
//		  
//    end
//end
//
//// FSM Logic for UART Transmission
//always @(*) begin
//    case (state)
//        IDLE: begin
//            nextstate = IDLE;
//				
//        end
//
//        START: begin
//		  if (bit_counter == BAUD_COUNT) begin
//		  nextstate=DATA;
//        end
//		  
//		  else nextstate=START;
//        end
//
//        DATA: begin
//		  rx_msgs[7 - data_bit_index] = rx; // Send each data bit
//		  		
//            if (bit_counter == BAUD_COUNT) begin
//
//                if (data_bit_index == 7) begin
//                    nextstate = PARITY;
//						  data_bit_index = 0;
//						  end
//                else begin
//
//                    nextstate = DATA;
//                    data_bit_index = data_bit_index + 1;
//                end
//            end else begin
//                nextstate = DATA;
//            end
//        end
//
//        PARITY: begin
//		  rx_parity=rx;
//		  if (bit_counter == BAUD_COUNT) begin
//		  nextstate=STOP;
//		  end
//		  
//		  else nextstate=PARITY;
//            
//        end
//
//        STOP: begin
//		  
//            if (bit_counter == BAUD_COUNT ) begin 
//				    rx_msg=rx_msgs;
//                nextstate=IDLE;
//            end else begin
//                nextstate = STOP;
//            end
//        end
//    endcase
//end
////////////////////DO NOT MAKE ANY CHANGES BELOW THIS LINE//////////////////
//
//
//endmodule


module uart_rx(
    input clk_3125,
    input rx,
    output reg [7:0] rx_msg,
    output reg rx_parity,
    output reg rx_complete
    );

// State encoding
localparam IDLE = 3'b000,
           START = 3'b001,
           DATA = 3'b010,
           PARITY = 3'b011,
           STOP = 3'b100;
           
localparam integer BAUD_COUNT = 13;

reg [2:0] state, nextstate;
reg [3:0] bit_counter;
reg [2:0] data_bit_index;
reg [7:0] rx_msgs;

initial begin
    rx_msg = 0;
    rx_msgs = 0;
    rx_parity = 0;
    rx_complete = 0;
    state = IDLE;
    nextstate = IDLE;
    bit_counter = 0;
    data_bit_index = 0;
end

// State and counter update logic
always @(posedge clk_3125) begin
    if (!rx && (state==IDLE)) begin
        state <= START;
        bit_counter <= 0;
        rx_complete <= 0;  // Clear rx_complete at start of new transmission
    end else if (bit_counter == BAUD_COUNT) begin
        bit_counter <= 0;  // Reset to 0 instead of 1
        state <= nextstate;
        // Only set rx_complete in STOP state when valid data is received
        if (state == STOP && rx == 1) begin  // Check for valid stop bit
            rx_complete <= 1;
        end else begin
            rx_complete <= 0;
        end
    end else begin
        bit_counter <= bit_counter + 1;
        if (state != IDLE) begin
            rx_complete <= 0;
        end
    end
end

// FSM Logic
always @(*) begin
    case (state)
        IDLE: begin
            nextstate = IDLE;
        end
        
        START: begin
            if (bit_counter == BAUD_COUNT) begin
                nextstate = DATA;
            end else begin
                nextstate = START;
            end
        end
        
        DATA: begin
            if (bit_counter == BAUD_COUNT/2) begin  // Sample in middle of bit
                rx_msgs[7-data_bit_index] = rx;  // Store bits from LSB to MSB
            end
            
            if (bit_counter == BAUD_COUNT) begin
                if (data_bit_index == 7) begin
                    nextstate = PARITY;
                    data_bit_index = 0;
                end else begin
                    nextstate = DATA;
                    data_bit_index = data_bit_index + 1;
                end
            end else begin
                nextstate = DATA;
            end
        end
        
        PARITY: begin
            if (bit_counter == BAUD_COUNT/2) begin  // Sample parity in middle of bit
                rx_parity = rx;
            end
            if (bit_counter == BAUD_COUNT) begin
                nextstate = STOP;
            end else begin
                nextstate = PARITY;
            end
        end
        
        STOP: begin
            if (bit_counter == BAUD_COUNT) begin
                rx_msg = rx_msgs;  // Update output message
                nextstate = IDLE;
            end else begin
                nextstate = STOP;
            end
        end
        
        default: begin
            nextstate = IDLE;
        end
    endcase
end

endmodule




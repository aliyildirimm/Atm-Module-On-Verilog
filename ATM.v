`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date:    18:36:02 12/11/2019 
// Design Name: 
// Module Name:    ATM 
// Project Name: 
// Target Devices: 
// Tool versions: 
// Description: 
//
// Dependencies: 
//
// Revision: 
// Revision 0.01 - File Created
// Additional Comments: 
//
//////////////////////////////////////////////////////////////////////////////////
module ATM (input clk,
            input rst,
				input BTN3, BTN2, BTN1,
				input [3:0] SW,
				output reg [7:0] LED,                                     // LED[7] is the left most-LED
				output reg [6:0] digit4, digit3, digit2, digit1  // digit4 is the left-most SSD
);
  
	 reg [3:0] 	password;
	 reg [15:0]	balance; 
	 reg [7:0] 	current_state;
	 reg [7:0] 	next_state;	
	 reg [8:0]	lock;
	 reg [8:0]	warning;
	 reg [6:0] 	A, B, C, D;
	 // additional registers
	 
	parameter   IDLE 			= 8'b00000000;
	parameter	PASS_ENT3	= 8'b00000001;
	parameter	PASS_ENT2	= 8'b00000010;
	parameter	PASS_ENT1	= 8'b00000011;
	parameter	LOCK			= 8'b00000100;
	parameter	ATM_MENU		= 8'b00000101;
	parameter	MONEY			= 8'b00000110;
	parameter	WARNING		= 8'b00000111;
	parameter	PASS_CHG_3	= 8'b00001000;
	parameter	PASS_CHG_2 	= 8'b00001001;
	parameter	PASS_CHG_1 	= 8'b00001010;
	parameter	PASS_NEW 	= 8'b00001011;
	
		
	// sequential part – state transitions
	always @ (posedge clk or posedge rst)
	begin
		if(rst)
			current_state <= IDLE; 
		else
			current_state <= next_state; 
	end

	// combinational part – next state definitions
	always @ (*)
	begin
		case(current_state)
			IDLE:
			begin
				if(BTN3) next_state = PASS_ENT3; 
				else next_state = IDLE;
			end
			
			PASS_ENT3:
			begin
				if(BTN1) next_state = IDLE;
				else if(BTN3 && (password == SW)) next_state = ATM_MENU; 
				else if(BTN3 && (password != SW)) next_state = PASS_ENT2;
				else next_state = PASS_ENT3;
			end
			
			PASS_ENT2:
			begin
				if(BTN1) next_state = IDLE; 
				else if(BTN3 && (password == SW)) next_state = ATM_MENU; 
				else if(BTN3 && (password != SW)) next_state = PASS_ENT1; 
				else next_state = PASS_ENT2;
			end
			
			PASS_ENT1:
			begin
				if(BTN1) next_state = IDLE; 
				else if(BTN3 & (password == SW)) next_state = ATM_MENU; 
				else if(BTN3 & (password != SW)) next_state = LOCK; 
				else next_state = PASS_ENT1;
			end
			
			LOCK:
			begin
				if(lock ==100) next_state = IDLE;
				else next_state = LOCK;
			end
			
			ATM_MENU:
			begin
				if(BTN1) next_state = IDLE; 
				else if(BTN2) next_state = PASS_CHG_3; 
				else if(BTN3) next_state = MONEY ;
				else next_state = ATM_MENU; 
			end
			
			PASS_CHG_3:
			begin
				if(BTN1) next_state = ATM_MENU; 
				else if(BTN3 & (password == SW)) next_state = PASS_NEW; 
				else if(BTN3 & (password != SW)) next_state = PASS_CHG_2;
				else next_state = PASS_CHG_3; 
			end
			
			PASS_CHG_2:
			begin
				if(BTN1) next_state = ATM_MENU; 
				else if(BTN3 & (password == SW)) next_state = PASS_NEW; 
				else if(BTN3 & (password != SW)) next_state = PASS_CHG_1;
				else next_state = PASS_CHG_2; 
			end
			
			PASS_CHG_1:
			begin
				if(BTN1) next_state = ATM_MENU; 
				else if(BTN3 & (password == SW)) next_state = PASS_NEW; 
				else if(BTN3 & (password != SW)) next_state = LOCK;
				else next_state = PASS_CHG_1; 
			end
			
			PASS_NEW:
			begin
				if(BTN3) next_state = ATM_MENU;
				else next_state = PASS_NEW;
			end
			
			MONEY:
			begin
				if(BTN1) next_state = ATM_MENU; 
				else if(BTN3) next_state = MONEY;
				else if(BTN2) 
				begin
					if(balance < SW)
						next_state = WARNING;
					else
						next_state =MONEY;
				end
			end
			
			WARNING:
			begin
				if(warning == 0)next_state = MONEY;
				else next_state = WARNING;
			end	
		endcase
	end
	 	

	// sequential part – outputs
	always @ (posedge clk or posedge rst)
	begin
		if(rst)
			begin
				password <= 0;
				balance <= 0;
			end
		else
			begin
				case(current_state)
			//	IDLE:
				
			//	PASS_ENT_3:

			//	PASS_ENT_2:
				
				PASS_ENT1:
					if(BTN3==1 & (SW!= password)) lock <= 100;
					
				LOCK:
					lock <= lock - 1;

			//	ATM_MENU:
					
			//	PASS_CHG_3:

			//	PASS_CHG_2:
				
				PASS_CHG_1:
					if(BTN3==1 & SW!= password) lock <= 100;

				PASS_NEW:
				begin
					if(BTN3) password <=SW;
				end

				MONEY:
				begin
					if(BTN2 & (balance < SW))	warning <= 50;
					else if (BTN2 & (balance> SW)) balance <= balance-SW;
					else if (BTN3) balance <= balance + SW;
				end

				WARNING:
					warning <= warning -1;
				endcase
			end
	end
	
	always @ (*)
   begin
		// your code goes here	
		case (current_state)
			IDLE:
			begin
				A = 49; B = 8; C = 59; D = 66;
				digit4 = A;
				digit3 = B;
				digit2 = C;
				digit1 = D;
				LED = 8'b00000001;
			end
			
			PASS_ENT3:
			begin
				A = 24; B = 48; C = 126; D = 6;
				digit4 = A;
				digit3 = B;
				digit2 = C;
				digit1 = D;
				LED = 8'b10000000;
			end	
			
			PASS_ENT2:
			begin
			A = 24; B = 48; C = 126; D = 18;
				digit4 = A;
				digit3 = B;
				digit2 = C;
				digit1 = D;
				LED = 8'b11000000;
			end
			
			PASS_ENT1:
			begin
			A = 24; B = 48; C = 126; D = 79;
				digit4 = A;
				digit3 = B;
				digit2 = C;
				digit1 = D;
				LED = 8'b11100000;
			end
			
			LOCK:
			begin
			A = 56; B = 8; C = 121; D = 113;
				digit4 = A;
				digit3 = B;
				digit2 = C;
				digit1 = D;
				LED = 8'b11111111;
			end
			
			ATM_MENU:
			begin
			A = 1; B = 24; C = 48; D = 9;
				digit4 = A;
				digit3 = B;
				digit2 = C;
				digit1 = D;
				LED = 8'b00010000;
			end
			
			PASS_CHG_3:
			begin
			A = 24; B = 49; C = 126; D = 6;
				digit4 = A;
				digit3 = B;
				digit2 = C;
				digit1 = D;
				LED = 8'b00000100;
			end
			
			PASS_CHG_2:
			begin
			A = 24; B = 49; C = 126; D = 18;
				digit4 = A;
				digit3 = B;
				digit2 = C;
				digit1 = D;
				LED = 8'b00000110;
			end
			
			PASS_CHG_1:
			begin
				A = 24; B = 49; C = 126; D = 79;
				digit4 = A;
				digit3 = B;
				digit2 = C;
				digit1 = D;	
				LED = 8'b00000111;
			end
			
			PASS_NEW:
			begin
				A = 24; B = 8; C = 36; D = 36;
				digit4 = A;
				digit3 = B;
				digit2 = C;
				digit1 = D;
				LED = 8'b00000001;
			end
			
			MONEY:
			begin
				A = balance[3:0]; B= balance[7:4] ; C= balance[11:8] ; D = balance[15:12] ; 
				digit4 = D ;
				digit3 = C ;
				digit2 = B ;
				digit1 = A ;
				LED = 8'b00000010;
			end
			
			WARNING:
			begin 
				A = 126; B = 9; C = 8; D = 126;
				digit4 = A;
				digit3 = B;
				digit2 = C;
				digit1 = D;
				LED = 8'b11111111;
			end
		endcase
	end
endmodule


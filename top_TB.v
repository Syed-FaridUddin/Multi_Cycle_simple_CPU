// MACRO DEFINATIONS:
///////////////// Fields of IR
`define oper_type IR[31:27]
`define rdst	  IR[26:22]
`define rsrc1	  IR[21:17]
`define imm_mode  IR[16]
`define rsrc2	  IR[15:11]
`define isrc	  IR[15:0]

////////////////// Ariethmatic operations
`define movsgpr		5'b00000
`define mov			5'b00001
`define add			5'b00010
`define sub			5'b00011
`define mul			5'b00100

////////////////// Logical operations
`define orl			5'b00101
`define andl		5'b00110
`define xorl		5'b00111
`define xnorl		5'b01000
`define nandl		5'b01001
`define norl		5'b01010
`define notl		5'b01011

////////////////// Storage operations
`define storereg	5'b01101		// [reg] to data_mem
`define storedin	5'b01101		// [Ex. data bus] to data_mem
`define senddout	5'b01101		// [data_mem] to Ex. data bus
`define sendreg		5'b01101		// [data_mem] to reg



module top_TB();

	reg clk = 0;
	reg sys_rest;
	reg [15:0]din;
	wire [15:0]dout;
	
	top	UUT(clk, sys_rest, din, dout);
	
	// initial begin
		// clk 		= 0;
	// end
	
	always 	
		#5 clk = ~clk;
		
	initial begin
		sys_rest 	= 0;
		#6 sys_rest = 1;
		repeat(5) 
			@ (posedge clk);  // after 5 posedge of clk is over, then sys_rest is reset.
		sys_rest = 0;
		#2000;
		$stop;		
	end
	
	
endmodule



























// This TB is when there was no clock
/////////////////////////////////////////////////////////////////////////
// module top_TB();
	
	// top UUT(); ////// module instantiation
	
	// integer i; ////////// a variable should be declared outside the initaial block.
	// initial begin		
		// ////////////// writing/initializing all GPRs
		// for (i=0; i<32; i = i+1) begin
			// UUT.GPR[i] = 33;	
		// end
	// end
	
	// // we can have multiple initial blocks
	// initial begin
		// ///////////// ADD immd
		// $display("-------------------------------------------------");		
		// UUT.IR = 0;
		// UUT.`imm_mode = 1;
		// UUT.`oper_type = 2; // or use "`add"
		// UUT.`rsrc1 = 2;
		// UUT.`rdst = 0;
		// UUT.`isrc = 4; ////// decimal value = 4
		// #10
		// $display("OP:ADI Rsrc1:%0d  Rsrc2:%0d Rdst:%0d",UUT.GPR[2], UUT.`isrc, UUT.GPR[0]);
		
		// ///////////// ADD reg
		// $display("-------------------------------------------------");		
		// UUT.IR = 0;
		// UUT.`imm_mode = 0;
		// UUT.`oper_type = 2; // or use "`add"
		// UUT.`rsrc1 = 4;
		// UUT.`rsrc2 = 5;		
		// UUT.`rdst = 0;
		// #10
		// $display("OP:ADD Rsrc1:%0d  Rsrc2:%0d Rdst:%0d",UUT.GPR[4], UUT.GPR[5], UUT.GPR[0] );
		
		// ///////////// Immd mov
		// $display("-------------------------------------------------");	
		// UUT.IR = 0;
		// UUT.`imm_mode = 1;
		// UUT.`oper_type = 1; // or use "`mov"
		// UUT.`rdst = 4;
		// UUT.`isrc = 55; /////////// value = 7
		// #10
		// $display("OP:MOVI Rdst:%0d  imm_data:%0d",UUT.GPR[4],UUT.`isrc  );
		
		// ///////////// reg mov
		// $display("-------------------------------------------------");	
		// UUT.IR = 0;
		// UUT.`imm_mode = 0;
		// UUT.`oper_type = 1;
		// UUT.`rdst = 4;
		// UUT.`rsrc1 = 7; ////////////GPR[7]
		// #10
		// $display("OP: MOV Rdst: %0d  Rsrc1:%0d", UUT.GPR[4], UUT.GPR[7]);	
		
		// ///////////// reg mul
		// $display("-------------------------------------------------");
		// UUT.IR = 0;
		// UUT.`imm_mode = 1;
		// UUT.`oper_type = 4;
		// UUT.`rdst = 0;
		// UUT.`rsrc1 = 1; ///////// address
		// UUT.`isrc = 15; /////// Value
		// //This #10 is very esstial. without it, two "$displays" are executed together. 
		// #10 
		// $display("OP: MULi (LSB)Rdst:%0d  Rsrc1:%0d  Isrc:%0d " , UUT.GPR[0], UUT.GPR[1], UUT.`isrc);
		
		// $display("-------------------------------------------------");
		// UUT.IR = 0;
		// UUT.`imm_mode = 0;
		// UUT.`oper_type = 4;		
		// UUT.`rsrc1 = 0; ///////// address
		// UUT.`rsrc2 = 1; ///////// address
		// UUT.`rdst = 2;
		// #10
		// $display("OP: MUL (LSB)Rdst:%0d  Rsrc1:%0d  Rsrc2:%0d " , UUT.GPR[2], UUT.GPR[1], UUT.GPR[0]);

		// /****  MOVSGPR is always follow up with MUL ***/
		// UUT.IR = 0;
		// UUT.`oper_type = `movsgpr;
		// UUT.`rdst = 3;		
		// #10
		// $display("OP: MOVSGPR (MSB)Rdst:%0d  (LSB)Rdst:%0d " , UUT.GPR[3], UUT.GPR[2]);
		
		
		// ////////////////////// Logical operations
		// ///// Logical bitwise and
		// $display("-------------------------------------------------");
		// UUT.IR = 0;
		// UUT.`imm_mode = 1;
		// UUT.`oper_type = `andl;		
		// UUT.`rsrc1 = 8; ///////// address
		// UUT.`isrc = 15; ///////// address
		// UUT.`rdst = 9;
		// #10
		// $display("OP: ANDi Rdst:%3b  Rsrc1:%b  isrc:%16b " , UUT.GPR[9], UUT.GPR[8], UUT.`isrc);
							// // Note: %b = %16b here. %b is for binary display and %xb shows only x LSBs bits on display.
							// // "UUT.GPT[x] x should always be a number and not a "defined entity"
		
		// ///// Logical bitwise xor
		// $display("-------------------------------------------------");
		// UUT.IR = 0;
		// UUT.`imm_mode = 0;
		// UUT.`oper_type = `xorl;		
		// UUT.`rsrc1 = 9; ///////// address
		// UUT.`rsrc2 = 15; ///////// address
		// UUT.`rdst = 8;
		// #10
		// $display("OP: xor Rdst:%8b  Rsrc1:%8b  rsrc2:%8b " , UUT.GPR[8], UUT.GPR[9], UUT.GPR[15]);
		
		
		// ////////////////////////// Flag set
		// // zero Flag
		// $display("-------------------------------------------------");
		// UUT.IR = 0;
		// UUT.`oper_type = `add;
		// UUT.GPR[0] = 0;
		// UUT.`rsrc1 = 0;
		// UUT.GPR[1] = 0;
		// UUT.`rsrc2 = 1;
		// UUT.`imm_mode = 0;
		// UUT.`rdst = 2;
		// #10
		// $display("OP = ZeroFlag 	rdst =%0d 	zero = %1b", UUT.GPR[2], UUT.zero);
		
		// //sign Flag
		// $display("-------------------------------------------------");
		// UUT.IR = 0;
		// UUT.`oper_type = `add;
		// UUT.GPR[0] = 16'h8000;		
		// UUT.`rsrc1 = 0;
		// UUT.GPR[1] = 0;
		// UUT.`rsrc2 = 1;
		// UUT.`imm_mode = 0;
		// UUT.`rdst = 3;
		// #10
		// $display("OP = signFlag 	rdst =%0h 	sign = %1b", UUT.GPR[3], UUT.sign);
		
		// //carry and overflow Flag
		// $display("-------------------------------------------------");
		// UUT.IR = 0;
		// UUT.`oper_type = `add;
		// UUT.GPR[0] = 16'h8003; // 1000 0000 0000 0011  <0
		// UUT.`rsrc1 = 0;
		// UUT.GPR[1] = 16'h8005;//  1000 0000 0000 0101  <0	 
		// UUT.`rsrc2 = 1;
		// UUT.`imm_mode = 0;
		// UUT.`rdst = 4; // 		  0000 0000 0000 1000  >0
		// #10
		// $display("OP = CY&OVFlag 	rdst =%0h 	carry=%1b 	overflow=%1b", UUT.GPR[4], UUT.carry, UUT.overflow);
		
		
	// end

// endmodule
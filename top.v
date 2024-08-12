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

/*////////////////////////

Note:
(1) `rsrc1 is an address, GPR[`rsrc1] is the value.
(2) [VVI] We cannot break macro definitions.
	i.e; using `isrc[15] is not possible. instead use IR[15].

////////////////////////*/

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
`define storedin	5'b01110		// [Ex. data bus] to data_mem
`define senddout	5'b01111		// [data_mem] to Ex. data bus
`define sendreg		5'b10001		// [data_mem] to reg


////////////////// Jump operations
`define JMP 		5'b10010		// unconditional jump
`define JC	 		5'b10011		// Jump when Carry flag = 1
`define JNC 		5'b10100
`define JS	 		5'b10101
`define JNS 		5'b10110
`define JZ	 		5'b10111
`define JNZ	 		5'b11000
`define JOF	 		5'b11001
`define JNOF 		5'b11010
`define JZ	 		5'b11011

////////////////// Stop operations
`define Halt		5'b11100		// Stops processor from performing any task. Useful as we finish the program.

// 27 instructions.







module top(clk, sys_rest, din, dout);
	
	input clk;
	input sys_rest;
	input [15:0]din;	// immediate data entered by the user
	output reg [15:0]dout;


	
	reg [31:0]IR; 
	
			
	
	reg [15:0]GPR[31:0]; //////// 32 GPR of size 16b each.
								// Immd. value is of size 16b, hence the register size. 
								//  No sign extender used here.
						 
						 
						 
	reg [15:0]SGPR;		///////// Captures First 16 MSBs of the result of MUL operation.
	
	
	
	reg [31:0]mul_res; ////////// temp reg to store the result of mul op.
								// ALU is a combinational ckt. Has no reg to store output.
								// To trasnfer result in the two registers, we require a temporary 32b reg.
								// **Store of Overflow bits** 
								
								
	reg [31:0]inst_mem[15:0];  // 16x32b instruction memory unit 
	
	reg [15:0]data_mem[15:0];  //16x16b data memory unit. // size of immediate data = 16b
	
	
	// JUMP FLAGS.
	/*
		There are many jump instruction. jmp_flag is a common way of showing that yes jump is going to take place
		i,e; PC = `isrc instead of PC = PC+1  but the reason to jump is goverened by different jump-inst.
	*/	
	reg jmp_flag 	= 0;
	reg stop 	= 0;
	
	
	// FLAGS
	reg sign=0;
	reg zero=0;
	reg overflow=0;
	reg carry=0;
	
	
//	always @(*) begin		// Multiple Always block, make the design complex. 
							//   If there is a repeated job to perform under "always" block
							 //  utilize "task" (~ functions in C) */
	task decodeinst();
		begin
		// initilizing the flags everytime this task is called.
		jmp_flag 	= 0;
		stop 	= 0;
		
		
			case(`oper_type) //////// case has no begin-end. It hs case-endcase	
			
			// ** Arith. Opr ** //
				`movsgpr: begin
								GPR[`rdst] = SGPR;		
						  end
				`mov	: begin
								if (`imm_mode)
									GPR[`rdst] = `isrc;
								else
									GPR[`rdst] = GPR[`rsrc1];
						  end
				`add	: begin
								if (`imm_mode)
									GPR[`rdst] = GPR[`rsrc1] + `isrc;
								else
									GPR[`rdst] = GPR[`rsrc1] + GPR[`rsrc2];
						  end
				`sub	: begin
								if (`imm_mode)
									GPR[`rdst] = GPR[`rsrc1] - `isrc;
								else
									GPR[`rdst] = GPR[`rsrc1] - GPR[`rsrc2];
						  end
				`mul	: begin
								if (`imm_mode) begin
									mul_res = GPR[`rsrc1] * `isrc;
								end
								else begin
									mul_res = GPR[`rsrc1] * GPR[`rsrc2];
								end
								
								SGPR  = mul_res[31:16];
								GPR[`rdst] = mul_res[15:0];
								
						  end
						  
				// ** Logical. Opr ** //
				
				`orl	: begin
								if (`imm_mode)
									GPR[`rdst] = GPR[`rsrc1] | `isrc;
								else
									GPR[`rdst] = GPR[`rsrc1] | GPR[`rsrc2];						
						 end
				`andl	: begin
								if (`imm_mode)
									GPR[`rdst] = GPR[`rsrc1] & `isrc;
								else
									GPR[`rdst] = GPR[`rsrc1] & GPR[`rsrc2];						
						 end
				`xorl	: begin
								if (`imm_mode)
									GPR[`rdst] = GPR[`rsrc1] ^ `isrc;
								else
									GPR[`rdst] = GPR[`rsrc1] ^ GPR[`rsrc2];						
						 end
				`xnorl	: begin
								if (`imm_mode)
									GPR[`rdst] = GPR[`rsrc1] ~^ `isrc;
								else
									GPR[`rdst] = GPR[`rsrc1] ~^ GPR[`rsrc2];						
						 end
				`nandl	: begin
								if (`imm_mode)
									GPR[`rdst] = ~(GPR[`rsrc1] & `isrc);
								else
									GPR[`rdst] = ~(GPR[`rsrc1] & GPR[`rsrc2]);						
						 end
				`norl	: begin
								if (`imm_mode)
									GPR[`rdst] = ~(GPR[`rsrc1] | `isrc);
								else
									GPR[`rdst] = ~(GPR[`rsrc1] | GPR[`rsrc2]);						
						 end
				`notl	: begin
								if (`imm_mode)
									GPR[`rdst] = ~(`isrc);
								else
									GPR[`rdst] = ~(GPR[`rsrc1]) ;						
						 end
						 
							// ** Storage. Opr ** //
							
							
							
							
				/* `isrc is used as an address for data_mem unit.
				   As `isrc is of 16b size, therefore at max data_mem can be of size (2^16)x16b.
				   => Keytake away: `isrc is used as an address now and its size limits data_mem size
			   */
				`storereg : 	data_mem[`isrc] = GPR[`rsrc1];	// reg to data_mem
				
				`storedin : 	data_mem[`isrc] = din;			// din to data_mem
				
				`senddout : 	dout =  data_mem[`isrc];		// data_mem to dout
				
				`sendreg  :		GPR[`rsrc1] = data_mem[`isrc];  // data_mem to reg
				
				
				

				// ** Jump Opr ** //
				
				
				// For the jump instructions we only try to modify jmp_flag when the right condition is met.
				`JMP	:	jmp_flag = 1;
				
				`JC		: 	begin
								if (carry == 1)
									jmp_flag = 1;
								else
									jmp_flag = 0;
							end
							
				`JNC	: 	begin
								if (carry == 0)
									jmp_flag = 1;
								else
									jmp_flag = 0;
							end

				`JS		: 	begin
								if (sign == 1)
									jmp_flag = 1;
								else
									jmp_flag = 0;
							end	

				`JNS	: 	begin
								if (sign == 0)
									jmp_flag = 1;
								else
									jmp_flag = 0;
							end	

				`JZ		: 	begin
								if (zero == 1)
									jmp_flag = 1;
								else
									jmp_flag = 0;
							end	

				`JNZ	: 	begin
								if (zero == 0)
									jmp_flag = 1;
								else
									jmp_flag = 0;
							end	

				`JOF	: 	begin
								if (overflow == 1)
									jmp_flag = 1;
								else
									jmp_flag = 0;
							end	
							
				`JNOF	: 	begin
								if (overflow == 0)
									jmp_flag = 1;
								else
									jmp_flag = 0;
							end				
							
							
			// ** Stop. Opr ** //
				
				
				`Halt	: 	stop = 1;
							
			endcase	
		end // end of begin
	endtask
	
	///////////////////// Logic for condition flags
	
	
	
	reg [16:0]temp_sum;
	
//	always @ (*) begin  	// Same reason as above
	task decodeconditionFlag(); 
		begin
			// Sign flag
			if (`oper_type == `mul)
				sign = SGPR[15];
			else
				sign = GPR[`rdst][15]; // GPR[`rdst] is a word. GPR[`rdst][15] represents the MSB of the 16b word.
			
			
			// Carry flag
			if (`oper_type == `add) begin
				if (`imm_mode == 1)
					temp_sum = GPR[`rsrc1] + `isrc;
				else 
					temp_sum = GPR[`rsrc1] + GPR[`rsrc2];
				
				carry = temp_sum[16];		
			end
			else
				carry = 1'b0;
			
			// zero flag
			if (`oper_type == `mul)
				zero = ~((|mul_res) | (|GPR[`rdst]));
			else
				zero = ~(|GPR[`rdst]);
				
			
			// Overflow flag
			if (`oper_type == `add) begin
				if (`imm_mode)
					overflow = ( ~GPR[`rsrc1][15] & ~IR[15] & GPR[`rdst]) | (GPR[`rsrc1][15] & IR[15] & GPR[`rdst]);
				else
					overflow = ( ~GPR[`rsrc1][15] & ~GPR[`rsrc2][15] & GPR[`rdst]) | (GPR[`rsrc1][15] & GPR[`rsrc2][15] & ~GPR[`rdst]);
			end
			else if (`oper_type == `sub) begin
				if (`imm_mode)
					overflow = ( ~GPR[`rsrc1][15] & IR[15] & GPR[`rdst]) | (GPR[`rsrc1][15] & ~IR[15] & ~GPR[`rdst]);
				else
					overflow = ( ~GPR[`rsrc1][15] & GPR[`rsrc2][15] & GPR[`rdst]) | (GPR[`rsrc1][15] & ~GPR[`rsrc2][15] & ~GPR[`rdst]);
			end
			else
				overflow = 1'b0;
		end  // end of begin
	endtask
	
	initial begin
		// program to multiply two numbers through repetative addition.
		inst_mem [0] = 32'b00001000000000010000000000000101;
		inst_mem [1] = 32'b00001000010000010000000000000110;
		inst_mem [2] = 32'b00001000100000010000000000000000;
		inst_mem [3] = 32'b00001000110000010000000000000110;
		inst_mem [4] = 32'b00010000100001000000000000000000;
		inst_mem [5] = 32'b00011000110001110000000000000001;
		inst_mem [6] = 32'b11000000000000000000000000000100;
		inst_mem [7] = 32'b00001001000001000000000000000000;
		inst_mem [8] = 32'b11011000000000000000000000000000;
	end
	
	///////////// Program counter and reading from memory
	///////////////////////////////////////////// old program to test data mem and GPR 
	/*initial begin
	
	//** FInd out why $readmemb is not working later...
		// $readmemb("C:/LOCALDISK/IITB/PDUdemy/inst_data.mem", inst_mem); // bring contents of instdata into inst_mem register.
				// $readmemb reads binary data.
				// $readmemh reads hex data.
				
				
		// MOV R0,2	=> R0 = 2
		inst_mem[0] 	= 32'b00001000000000010000000000000010;
		// MOV R1,3 => R1 = 3
		inst_mem[1]		= 32'b00001000010000010000000000000011;
		
		
		// ADD R2, R0, R1 => R2 = 5
		inst_mem[2]		= 32'b00010000100000000000100000000000;
		// MUL R3, R0, R1 => R3 = 6
		inst_mem[3]		= 32'b00100000110000000000100000000000;


		// ROR R4, R0, R1 => R4 = 3
		inst_mem[4]		= 32'b00101001000000000000100000000000;
		// RNANAD R5, R0, R1 => R5 = FFFD
		inst_mem[5]		= 32'b01001001010000000000100000000000;


		// STOREREG 0,R2 -- DATA MEMORY WRITE OPERATION @ [0] => data_mem[0] = 5
		inst_mem[6]		= 32'b01101000000001000000000000000000;
		// STOREREG 1,R3 -- DATA MEMORY WRITE OPERATION @ [1] => data_mem[1] = 6
		inst_mem[7]		= 32'b01101000000001100000000000000001;
		// STOREREG 2,R4 -- DATA MEMORY WRITE OPERATION @ [2] => data_mem[2] = 3
		inst_mem[8]		= 32'b01101000000010000000000000000010;
		// STOREREG 3,R5 -- DATA MEMORY WRITE OPERATION @ [3] => data_mem[3] = FFFD
		inst_mem[9]		= 32'b01101000000010100000000000000011;


		// SENDREG R6,0 -- DATA MEMORY READ OPERATION @ [0] => R6 = 5
		inst_mem[11]	= 32'b10001000000011000000000000000000;			// definition can be changed from rsrc1 to rdst by updating in the task "decode_instruction"
		// SENDREG R7,1 -- DATA MEMORY READ OPERATION @ [1] => R7 = 6
		inst_mem[12]	= 32'b10001000000011100000000000000001;
		
	end*/
	
	
	reg [2:0]count;		// between fetching of two instruction we wish to have a 4 clock cycle delay
	integer PC = 0;

	/*always @ (posedge clk) begin
		if (sys_rest == 1) begin
			PC 	  <= 0;
			count <= 0;
		end
		else begin
			if (count < 4) 			 // We are expecting all types of instructions should finish within 4 clock cycles
				count <= count + 1;
			else begin
					count <= 0;
					PC	  <= PC + 1; // PC works as a pointer. Points to next instruction.
			end
		end
	end
	
	
	/////////////////// Reading and instruction
	
	always @ (*) begin // when PC changes, contents inside changes.
		if (sys_rest == 1) 
			IR = 0; 	// Blocking assignment. This generates combinational ckt.
		else begin
			IR = inst_mem[PC];
			
			// After fetching an inst, we need to decode it and check for flags.
			
			decodeinst();
			decodeconditionFlag();
		end			
	end*/
	// Line 310 - 340 is useful if we remove all the jump instructions.
	// New jump instructions require jump-Flag modification and they update PC accordingly. 
	// So we have developed a new FSM according to it.
	
	
	//***************************************************//
	/* This part contains the FSM(moore m/c) need to run a program on the processor.
		Two always block implementation:
		1. The FF to allot NS to PS.
		2. Handles op. logic and NS logic
		
	*/
	
	
	parameter ideal				= 0,
			  fetch_inst 		= 1,
			  dec_exec_inst 	= 2,
			  next_inst			= 3,
			  sense_halt		= 4,
			  delay_next_ins 	= 5;
    /*idle 			: check reset state
	 fetch_inst	 	: load instrcution from Program memory
	 dec_exec_inst 	: execute instruction + update condition flag
	 next_inst		: next instruction to be fetched
	*/
	
	
	// 3b can encode 6 stages.
	reg [2:0]PS = ideal;
	reg	[2:0]NS = ideal; 
	
	
	// PS <= NS logic (FF)
	always @ (posedge clk) begin
		if (sys_rest == 1)
			PS <= ideal;
		else 
			PS <= NS;		
	end
	
	
	
	
	// Op. logic and NS logic
	always @ (*) begin
		case (PS)
			ideal		: 	begin	// PS = 0
								IR = 32'b0;
								PC = 0;
								
								NS = fetch_inst;
							end
							
			fetch_inst	:	begin   // PS = 1
								IR = inst_mem[PC];
								
								NS = dec_exec_inst;
							end
							
			dec_exec_inst:	begin	// PS = 2
								decodeinst();
								decodeconditionFlag();
							
								NS = delay_next_ins;
							end
			
			delay_next_ins:	begin	// PS = 5
								if (count < 4)
									NS = delay_next_ins;
								else 
									NS = next_inst;
							end
							
			next_inst	:	begin	// PS = 3
								if ( jmp_flag == 1)		
									PC = `isrc;
								else	
									PC = PC + 1;
								
								NS = sense_halt;
							end
			
			sense_halt	:	begin	// PS = 4								
								if (stop == 0 && sys_rest == 0)
									NS = fetch_inst;
								else if (stop == 0 && sys_rest == 1)
									NS = ideal;
								else if(stop == 1 & sys_rest == 0) 				
									NS = sense_halt;
								else 				// {stop, sys_rest} =  {1,1} => higher priority to sys_rest
									NS = ideal;
							end
							
			default 	:	NS = ideal;
		endcase
	end
	
	/////////////////////////////////////////
	/*
		We cannot update count in a combinational block bc it requires an edge triggered signal (clk)
		Therefore, we are goin to define a seperate always block which will set "count" for each state of the FSM.
	*/
	
	always @ (posedge clk) begin
		case (PS) 
			ideal			: count <= 0;
			
			fetch_inst		: count <= 0;
			
			dec_exec_inst 	: count <= 0;
			
			delay_next_ins	: count <= count + 1;	// when count = 4, "next_inst" sets count to 0 again.
							
			next_inst		: count <= 0;
			
			sense_halt		: count <= 0;
			
			default			: count <= 0;			
		endcase
	end
		
	
endmodule
Properties:

* Implemented ISA of 27 instructions on 16-bit multi-cycle processor for fundamental operations.
* Added 16 bit Special GPR to store (overflow) 16 MSB bits for multiplication operation.
* Used task for decoding operations and flags and FSM for stage traversal.
* RTL description in Verilog HDL, complied and Simulated on Modelsim.

Note:
"inst_data.mem" is used by the TB to read coded instructions from.

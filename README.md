# DualBoardOpcodeSystem
Opcode system between Basys 3 and Zedboard utilizing SPI and UART

Zed to Basys: opcode = [8 bits] = [operation][destination]

Basys to Zed: Z input = [12 bits] = [result][dest]
	                                  8 bits   4 bits

operations:
0000:none
0001:display(1 operand)
0010:add
0011:sub
0100:mult
0101:division by 2
0110:modulo by 2
0111:xor
1000:or
1001:and
1010:not(1 operand)
1011: None
1100: None
1101: None
1110:flash
1111:easter egg

Destination:
dest = [Send Method Bit][board bit][display selection bits]

UART:
0000:none(hide operands)
0001:leds
0010:SSD
0011:Both
0100:Z Special
0101:Z leds
0110:Z SSD
0111:Z both

SPI:
1000:none(hide operands)
1001:leds
1010:SSD
1011:Both
1100:Z Special
1101:Z leds
1110:Z SSD
1111:Z both

Center Button starts send from Zed to Basys

module vliw_top_tb();
reg clock, reset;
reg [191:0] data;
reg [63:0] word;
wire [63:0] readdatapipe1, readdatapipe2, readdatapipe3;
wire jump;
parameter halfperiod = 5;
parameter twocycle = 20;
parameter delay = 100;
// include the file that declares the parameter declaration for register
// names and also instruction operations
`include “/project/VLIW/64bit/simulation/regname.v”
// clock generation

initial
begin
clock = 0;
forever #halfperiod clock = ~clock;
end
// pump in stimulus for vliw processor
initial
begin
// do a reset
    data = 0;
    setreserved;
    setreset;
    // word [58:55]opcode [53:50]src1 [48:45]src2 [43:40]dest op1
    // word [38:35]opcode [33:30]src1 [28:25]src2 [23:20]dest op2
    // word [18:15]opcode [13:10]src1 [8:5]src2 [3:0]dest op3
    // load all necessary values into r0 to r8
    // load #123456789abcdef0, reg0 -> op1
    word [58:55] = 4’b0100; // load inst op1
    word [53:50] = reg0; // src1 default to reg0 cause not used
    word [48:45] = reg0; // src2 default to reg0 cause not used
    word [43:40] = reg0;
    data [191:128] = 64’h123456789abcdef0; // data for op1
    // load #1000000000000001, reg1 -> op2
    word [38:35] = 4’b0100; // load inst op2
    word [33:30] = reg0; // src1 default to reg0 cause not used
    word [28:25] = reg0; // src2 default to reg0 cause not used
    word [23:20] = reg1;
    data [127:64] = 64’h1000000000000001; // data for op2
    // load #0111111111111110, reg2 -> op3
    word [18:15] = 4’b0100; // load inst op3
    word [13:10] = reg0; // src1 default to reg0 cause not used
    word [8:5] = reg0; // src2 default to reg0 cause not used
    word [3:0] = reg2;
    data [63:0] = 64’h0111111111111110;
    // one clock delay
    #halfperiod;
    #halfperiod;
    // load #abababababababab, reg3 -> op1
    word [58:55] = 4’b0100; // load inst op1
    word [53:50] = reg0; // src1 default to reg0 cause not used
    word [48:45] = reg0; // src2 default to reg0 cause not used
    word [43:40] = reg3;
    data [191:128] = 64’habababababababab; // data for op1
    // load #100000aaa19a8654, reg4 -> op2
    word [38:35] = 4’b0100; // load inst op2
    word [33:30] = reg0; // src1 default to reg0 cause not used
    word [28:25] = reg0; // src2 default to reg0 cause not used
    word [23:20] = reg4;
    data [127:64] = 64’h100000aaa19a8654; // data for op2
    // load #01111111abc739ab, reg5 -> op3
    word [18:15] = 4’b0100; // load inst op3
    word [13:10] = reg0; // src1 default to reg0 cause not used
    word [8:5] = reg0; // src2 default to reg0 cause not used
    word [3:0] = reg5;
    data [63:0] = 64’h01111111abc739ab;
    // one clock delay
    #halfperiod;
    #halfperiod;
    // load #2121212123232323, reg6 -> op1
    word [58:55] = 4’b0100; // load inst op1
    word [53:50] = reg0; // src1 default to reg0 cause not used
    word [48:45] = reg0; // src2 default to reg0 cause not used
    word [43:40] = reg6;
    data [191:128] = 64’h2121212123232323; // data for op1
    // load #5a5a5a5aa5a5a5a5, reg7 -> op2
    word [38:35] = 4’b0100; // load inst op2
    word [33:30] = reg0; // src1 default to reg0 cause not used
    word [28:25] = reg0; // src2 default to reg0 cause not used
    word [23:20] = reg7;
    data [127:64] = 64’h5a5a5a5aa5a5a5a5; // data for op2
    // load #9236104576530978, reg8 -> op3
    word [18:15] = 4’b0100; // load inst op3
    word [13:10] = reg0; // src1 default to reg0 cause not used
    word [8:5] = reg0; // src2 default to reg0 cause not used
    word [3:0] = reg8;
    data [63:0] = 64’h9236104576530978;
    // one clock delay
    #halfperiod;
    #halfperiod;
    // read r0 -> op1
    word [58:55] = 4’b0110; // read inst op1
    word [53:50] = reg0; // src1 is reg0
    word [48:45] = reg0; // src2 default to reg0 cause not used
    word [43:40] = reg0; // dest default to reg0 cause not used
    data [191:128] = 0; // not used
    // read r1 -> op2
    word [38:35] = 4’b0110; // read inst op2
    word [33:30] = reg1; // src1 is reg1
    word [28:25] = reg0; // src2 default to reg0 cause not used
    word [23:20] = reg0; // dest default to reg0 cause not used
    data [127:64] = 0; // not used
    // read reg2 -> op3
    word [18:15] = 4’b0110; // read inst op3
    word [13:10] = reg2; // src1 is reg2
    word [8:5] = reg0; // src2 default to reg0 cause not used
    word [3:0] = reg0; // dest default to reg0 cause not used
    data [63:0] = 0; // not used
    // one clock delay
    #halfperiod;
    #halfperiod;
    // add r4, r5, r10 -> op1
    word [58:55] = 4’b0001; // add inst op1
    word [53:50] = reg4; // src1 is reg4
    word [48:45] = reg5; // src2 is reg5
    word [43:40] = reg10; // destination is reg10
    data [191:128] = 0; // data is not used
    // sub r3, r3, r11 -> op2
    word [38:35] = 4’b0010; // sub inst op2
    word [33:30] = reg3; // src1 is reg3
    word [28:25] = reg3; // src2 is reg3
    word [23:20] = reg11; // destination is reg11
    data [127:64] = 0; // data is not used
    // mul r2, r1, r12 -> op3
    word [18:15] = 4’b0011; // mul inst op3
    word [13:10] = reg2; // src1 is reg2
    word [8:5] = reg1; // src2 is reg1
    word [3:0] = reg12; // destination is reg12
    data [63:0] = 0; // data is not used
    // one clock delay
    #halfperiod;
    #halfperiod;
    // read r3 -> op1
    word [58:55] = 4’b0110; // read inst op1
    word [53:50] = reg3; // src1 is reg3
    word [48:45] = reg0; // src2 default to reg0 cause not used
    word [43:40] = reg0; // dest default to reg0 cause not used
    data [191:128] = 0; // not used
    // read r4 -> op2
    word [38:35] = 4’b0110; // read inst op2
    word [33:30] = reg4; // src1 is reg4
    word [28:25] = reg0; // src2 default to reg0 cause not used
    word [23:20] = reg0; // dest default to reg0 cause not used
    data [127:64] = 0; // not used
    // read reg5 -> op3
    word [18:15] = 4’b0110; // read inst op3
    word [13:10] = reg5; // src1 is reg5
    word [8:5] = reg0; // src2 default to reg0 cause not used
    word [3:0] = reg0; // dest default to reg0 cause not used
    data [63:0] = 0; // not used
    // one clock delay
    #halfperiod;
    #halfperiod;
    // read r10 -> op1
    word [58:55] = 4’b0110; // read inst op1
    word [53:50] = reg10; // src1 is reg10
    word [48:45] = reg0; // src2 default to reg0 cause not used
    word [43:40] = reg0; // dest default to reg0 cause not used
    data [191:128] = 0; // not used
    // read r11 -> op2
    word [38:35] = 4’b0110; // read inst op2
    word [33:30] = reg11; // src1 is reg11
    word [28:25] = reg0; // src2 default to reg0 cause not used
    word [23:20] = reg0; // dest default to reg0 cause not used
    data [127:64] = 0; // not used
    // read reg12 -> op3
    word [18:15] = 4’b0110; // read inst op3
    word [13:10] = reg12; // src1 is reg12
    word [8:5] = reg0; // src2 default to reg0 cause not used
    word [3:0] = reg0; // dest default to reg0 cause not used
    data [63:0] = 0; // not used
    // one clock delay
    #halfperiod;
    #halfperiod;
    // nop -> op1
    word [58:55] = 4’b0000; // nop inst op1
    word [53:50] = reg0; // src1 default to reg0 cause not used
    word [48:45] = reg0; // src2 default to reg0 cause not used
    word [43:40] = reg0; // dest default to reg0 cause not used
    data [191:128] = 0; // not used
    // nop -> op2
    word [38:35] = 4’b0000; // nop inst op2
    word [33:30] = reg0; // src1 default to reg0 cause not used
    word [28:25] = reg0; // src2 default to reg0 cause not used
    word [23:20] = reg0; // dest default to reg0 cause not used
    data [127:64] = 0; // not used
    // nop -> op3
    word [18:15] = 4’b0000; // nop inst op3
    word [13:10] = reg0; // src1 default to reg0 cause not used
    word [8:5] = reg0; // src2 default to reg0 cause not used
    word [3:0] = reg0; // dest default to reg0 cause not used
    data [63:0] = 0; // not used
    // one clock delay
    #halfperiod;
    #halfperiod;
    #1000 $stop;
end

task setreserved;
begin
// all these bits in the vliw word are reserved and therefore not
used.
// they are meant for future expansion
    word [63:60] = 4’bxxxx;
    word [59] = 1’bx;
    word [54] = 1’bx;
    word [49] = 1’bx;
    word [44] = 1’bx;
    word [39] = 1’bx;
    word [34] = 1’bx;
    word [29] = 1’bx;
    word [24] = 1’bx;
    word [19] = 1’bx;
    word [14] = 1’bx;
    word [9] = 1’bx;
    word [4] = 1’bx;
end
endtask

task setreset;
begin
// do a reset
    reset = 0;
    #twocycle;
    reset = 1;
    #twocycle;
    reset = 0;
    #twocycle;
end
endtask
vliw_top vliw_top_inst (clock, reset, word, data, readdatapipe1,
readdatapipe2, readdatapipe3, readdatavalid, jump);
endmodule
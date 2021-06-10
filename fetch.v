module fetch( word, data, clock, reset, flush, f2d_data, f2d_destpipe1, f2d_despipe2, f2d_pipe3, 
f2d_instpipe1, f2d_instpipe2, f2d_instpipe3,
f2d_src1pipe1, f2d_src1pipe2, f2d_src1pipe3,
f2d_src2pipe1, f2d_src2pipe2, f2d_src2pipe3);

input clock;
input reset;
input flush;
input [63:0] word;
input [191:0] data;
output [3:0] f2dr_instpipe1, f2dr_instpipe2, f2dr_instpipe3;
output [3:0] f2d_destpipe1, f2d_destpipe2, f2d_destpipe3;
output [3:0] f2r_src1pipe1, f2r_src1pipe2, f2r_src1pipe3;
output [3:0] f2r_src2pipe2, f2r_src2pipe2, f2r_src2pipe3;
output [191:0] f2d_data;

`include "regname.v"

reg [3:0] f2dr_instpipe1, f2dr_instpipe2, f2dr_instpipe3;
reg [3:0] f2r_src1pipe1, f2r_src1pipe2, f2r_src1pipe3;
reg [3:0] f2r_src2pipe1, f2r_src2pipe2, f2r_src2pipe3;
reg [3:0] f2r_destpipe1, f2r_destpipe2, f2r_destpipe3;
reg [191:0] f2d_data;

always @ (posedge clock or posedge reset)
begin
    if (reset)
    begin
        f2dr_instpipe1 <= nop;
        f2dr_instpipe2 <= nop;
        f2dr_instpipe3 <= nop;
        f2r_src1pipe1 <= reg0;
        f2r_src1pipe2 <= reg0;
        f2r_src1pipe3 <= reg0;
        f2r_src2pipe1 <= reg0;
        f2r_src2pipe2 <= reg0;
        f2r_src2pipe3 <= reg0;
        f2r_destpipe1 <= reg0;
        f2r_destpipe2 <= reg0;
        f2r_destpipe3 <= reg0;
        f2d_data <= 0;
    end
    else
    begin
        if (~flush)
        begin
            // pipe1
            case (word[58:55])
                4'b0000: f2dr_instpipe1 <= nop;
                4'b0001: f2dr_instpipe1 <= add;
                4'b0010: f2dr_instpipe1 <= sub;
                4'b0011: f2dr_instpipe1 <= mul;
                4'b0100: f2dr_instpipe1 <= load;
                4'b0101: f2dr_instpipe1 <= move;
                4'b0110: f2dr_instpipe1 <= read;
                4'b0111: f2dr_instpipe1 <= compare;
                4'b1000: f2dr_instpipe1 <= xorinst;
                4'b1001: f2dr_instpipe1 <= nandinst;
                4'b1010: f2dr_instpipe1 <= norinst;
                4'b1011: f2dr_instpipe1 <= notinst;
                4'b1100: f2dr_instpipe1 <= shiftleft;
                4'b1101: f2dr_instpipe1 <= shiftright;
                4'b1110: f2dr_instpipe1 <= bshiftleft;
                4'b1111: f2dr_instpipe1 <= bshiftright;
                default: f2dr_instpipe1 <= nop;
            endcase

            case (word[53:50])
                4'b0000: f2r_src1pipe1 <= reg0;
                4'b0001: f2r_src1pipe1 <= reg1;
                4'b0010: f2r_src1pipe1 <= reg2;
                4'b0011: f2r_src1pipe1 <= reg3;
                4'b0100: f2r_src1pipe1 <= reg4;
                4'b0101: f2r_src1pipe1 <= reg5;
                4'b0110: f2r_src1pipe1 <= reg6;
                4'b0111: f2r_src1pipe1 <= reg7;
                4'b1000: f2r_src1pipe1 <= reg8;
                4'b1001: f2r_src1pipe1 <= reg9;
                4'b1010: f2r_src1pipe1 <= reg10;
                4'b1011: f2r_src1pipe1 <= reg11;
                4'b1100: f2r_src1pipe1 <= reg12;
                4'b1101: f2r_src1pipe1 <= reg13;
                4'b1110: f2r_src1pipe1 <= reg14;
                4'b1111: f2r_src1pipe1 <= reg15;
                default: f2r_src1pipe1 <= reg0;
            endcase

            case (word[48:45])
                4'b0000: f2r_src2pipe1 <= reg0;
                4'b0001: f2r_src2pipe1 <= reg1;
                4'b0010: f2r_src2pipe1 <= reg2;
                4'b0011: f2r_src2pipe1 <= reg3;
                4'b0100: f2r_src2pipe1 <= reg4;
                4'b0101: f2r_src2pipe1 <= reg5;
                4'b0110: f2r_src2pipe1 <= reg6;
                4'b0111: f2r_src2pipe1 <= reg7;
                4'b1000: f2r_src2pipe1 <= reg8;
                4'b1001: f2r_src2pipe1 <= reg9;
                4'b1010: f2r_src2pipe1 <= reg10;
                4'b1011: f2r_src2pipe1 <= reg11;
                4'b1100: f2r_src2pipe1 <= reg12;
                4'b1101: f2r_src2pipe1 <= reg13;
                4'b1110: f2r_src2pipe1 <= reg14;
                4'b1111: f2r_src2pipe1 <= reg15;
                default: f2r_src2pipe1 <= reg0;
            endcase

            case (word[43:40])
                4'b0000: f2d_destpipe1 <= reg0;
                4'b0001: f2d_destpipe1 <= reg1;
                4'b0010: f2d_destpipe1 <= reg2;
                4'b0011: f2d_destpipe1 <= reg3;
                4'b0100: f2d_destpipe1 <= reg4;
                4'b0101: f2d_destpipe1 <= reg5;
                4'b0110: f2d_destpipe1 <= reg6;
                4'b0111: f2d_destpipe1 <= reg7;
                4'b1000: f2d_destpipe1 <= reg8;
                4'b1001: f2d_destpipe1 <= reg9;
                4'b1010: f2d_destpipe1 <= reg10;
                4'b1011: f2d_destpipe1 <= reg11;
                4'b1100: f2d_destpipe1 <= reg12;
                4'b1101: f2d_destpipe1 <= reg13;
                4'b1110: f2d_destpipe1 <= reg14;
                4'b1111: f2d_destpipe1 <= reg15;
                default: f2d_destpipe1 <= reg0;
            endcase

            //pipe2
            case (word[38:35])
                4'b0000: f2dr_instpipe2 <= nop;
                4'b0001: f2dr_instpipe2 <= add;
                4'b0010: f2dr_instpipe2 <= sub;
                4'b0011: f2dr_instpipe2 <= mul;
                4'b0100: f2dr_instpipe2 <= load;
                4'b0101: f2dr_instpipe2 <= move;
                4'b0110: f2dr_instpipe2 <= read;
                4'b0111: f2dr_instpipe2 <= compare;
                4'b1000: f2dr_instpipe2 <= xorinst;
                4'b1001: f2dr_instpipe2 <= nandinst;
                4'b1010: f2dr_instpipe2 <= norinst;
                4'b1011: f2dr_instpipe2 <= notinst;
                4'b1100: f2dr_instpipe2 <= shiftleft;
                4'b1101: f2dr_instpipe2 <= shiftright;
                4'b1110: f2dr_instpipe2 <= bshiftleft;
                4'b1111: f2dr_instpipe2 <= bshiftright;
                default: f2dr_instpipe2 <= nop;
            endcase

            case (word[33:30])
                4'b0000: f2r_src1pipe2 <= reg0;
                4'b0001: f2r_src1pipe2 <= reg1;
                4'b0010: f2r_src1pipe2 <= reg2;
                4'b0011: f2r_src1pipe2 <= reg3;
                4'b0100: f2r_src1pipe2 <= reg4;
                4'b0101: f2r_src1pipe2 <= reg5;
                4'b0110: f2r_src1pipe2 <= reg6;
                4'b0111: f2r_src1pipe2 <= reg7;
                4'b1000: f2r_src1pipe2 <= reg8;
                4'b1001: f2r_src1pipe2 <= reg9;
                4'b1010: f2r_src1pipe2 <= reg10;
                4'b1011: f2r_src1pipe2 <= reg11;
                4'b1100: f2r_src1pipe2 <= reg12;
                4'b1101: f2r_src1pipe2 <= reg13;
                4'b1110: f2r_src1pipe2 <= reg14;
                4'b1111: f2r_src1pipe2 <= reg15;
                default: f2r_src1pipe2 <= reg0;
            endcase

            case (word[28:25])
                4'b0000: f2r_src2pipe2 <= reg0;
                4'b0001: f2r_src2pipe2 <= reg1;
                4'b0010: f2r_src2pipe2 <= reg2;
                4'b0011: f2r_src2pipe2 <= reg3;
                4'b0100: f2r_src2pipe2 <= reg4;
                4'b0101: f2r_src2pipe2 <= reg5;
                4'b0110: f2r_src2pipe2 <= reg6;
                4'b0111: f2r_src2pipe2 <= reg7;
                4'b1000: f2r_src2pipe2 <= reg8;
                4'b1001: f2r_src2pipe2 <= reg9;
                4'b1010: f2r_src2pipe2 <= reg10;
                4'b1011: f2r_src2pipe2 <= reg11;
                4'b1100: f2r_src2pipe2 <= reg12;
                4'b1101: f2r_src2pipe2 <= reg13;
                4'b1110: f2r_src2pipe2 <= reg14;
                4'b1111: f2r_src2pipe2 <= reg15;
                default: f2r_src2pipe2 <= reg0;
            endcase

            case (word[23:20])
                4'b0000: f2d_destpipe2 <= reg0;
                4'b0001: f2d_destpipe2 <= reg1;
                4'b0010: f2d_destpipe2 <= reg2;
                4'b0011: f2d_destpipe2 <= reg3;
                4'b0100: f2d_destpipe2 <= reg4;
                4'b0101: f2d_destpipe2 <= reg5;
                4'b0110: f2d_destpipe2 <= reg6;
                4'b0111: f2d_destpipe2 <= reg7;
                4'b1000: f2d_destpipe2 <= reg8;
                4'b1001: f2d_destpipe2 <= reg9;
                4'b1010: f2d_destpipe2 <= reg10;
                4'b1011: f2d_destpipe2 <= reg11;
                4'b1100: f2d_destpipe2 <= reg12;
                4'b1101: f2d_destpipe2 <= reg13;
                4'b1110: f2d_destpipe2 <= reg14;
                4'b1111: f2d_destpipe2 <= reg15;
                default: f2d_destpipe2 <= reg0;
            endcase
            
            //pipe3
            case (word[18:15])
                4'b0000: f2dr_instpipe3 <= nop;
                4'b0001: f2dr_instpipe3 <= add;
                4'b0010: f2dr_instpipe3 <= sub;
                4'b0011: f2dr_instpipe3 <= mul;
                4'b0100: f2dr_instpipe3 <= load;
                4'b0101: f2dr_instpipe3 <= move;
                4'b0110: f2dr_instpipe3 <= read;
                4'b0111: f2dr_instpipe3 <= compare;
                4'b1000: f2dr_instpipe3 <= xorinst;
                4'b1001: f2dr_instpipe3 <= nandinst;
                4'b1010: f2dr_instpipe3 <= norinst;
                4'b1011: f2dr_instpipe3 <= notinst;
                4'b1100: f2dr_instpipe3 <= shiftleft;
                4'b1101: f2dr_instpipe3 <= shiftright;
                4'b1110: f2dr_instpipe3 <= bshiftleft;
                4'b1111: f2dr_instpipe3 <= bshiftright;
                default: f2dr_instpipe3 <= nop;
            endcase

            case (word[13:10])
                4'b0000: f2r_src1pipe3 <= reg0;
                4'b0001: f2r_src1pipe3 <= reg1;
                4'b0010: f2r_src1pipe3 <= reg2;
                4'b0011: f2r_src1pipe3 <= reg3;
                4'b0100: f2r_src1pipe3 <= reg4;
                4'b0101: f2r_src1pipe3 <= reg5;
                4'b0110: f2r_src1pipe3 <= reg6;
                4'b0111: f2r_src1pipe3 <= reg7;
                4'b1000: f2r_src1pipe3 <= reg8;
                4'b1001: f2r_src1pipe3 <= reg9;
                4'b1010: f2r_src1pipe3 <= reg10;
                4'b1011: f2r_src1pipe3 <= reg11;
                4'b1100: f2r_src1pipe3 <= reg12;
                4'b1101: f2r_src1pipe3 <= reg13;
                4'b1110: f2r_src1pipe3 <= reg14;
                4'b1111: f2r_src1pipe3 <= reg15;
                default: f2r_src1pipe3 <= reg0;
            endcase

            case (word[8:5])
                4'b0000: f2r_src2pipe3 <= reg0;
                4'b0001: f2r_src2pipe3 <= reg1;
                4'b0010: f2r_src2pipe3 <= reg2;
                4'b0011: f2r_src2pipe3 <= reg3;
                4'b0100: f2r_src2pipe3 <= reg4;
                4'b0101: f2r_src2pipe3 <= reg5;
                4'b0110: f2r_src2pipe3 <= reg6;
                4'b0111: f2r_src2pipe3 <= reg7;
                4'b1000: f2r_src2pipe3 <= reg8;
                4'b1001: f2r_src2pipe3 <= reg9;
                4'b1010: f2r_src2pipe3 <= reg10;
                4'b1011: f2r_src2pipe3 <= reg11;
                4'b1100: f2r_src2pipe3 <= reg12;
                4'b1101: f2r_src2pipe3 <= reg13;
                4'b1110: f2r_src2pipe3 <= reg14;
                4'b1111: f2r_src2pipe3 <= reg15;
                default: f2r_src2pipe3 <= reg0;
            endcase

            case (word[23:20])
                4'b0000: f2d_destpipe3 <= reg0;
                4'b0001: f2d_destpipe3 <= reg1;
                4'b0010: f2d_destpipe3 <= reg2;
                4'b0011: f2d_destpipe3 <= reg3;
                4'b0100: f2d_destpipe3 <= reg4;
                4'b0101: f2d_destpipe3 <= reg5;
                4'b0110: f2d_destpipe3 <= reg6;
                4'b0111: f2d_destpipe3 <= reg7;
                4'b1000: f2d_destpipe3 <= reg8;
                4'b1001: f2d_destpipe3 <= reg9;
                4'b1010: f2d_destpipe3 <= reg10;
                4'b1011: f2d_destpipe3 <= reg11;
                4'b1100: f2d_destpipe3 <= reg12;
                4'b1101: f2d_destpipe3 <= reg13;
                4'b1110: f2d_destpipe3 <= reg14;
                4'b1111: f2d_destpipe3 <= reg15;
                default: f2d_destpipe3 <= reg0;
            endcase
        
            if ((word[58:55]=='b0100) | (word[38:35] == 4'b01000) | (word[18:15]) == 'b01000))
                f2d_data <= data;
            else
                f2d_data <= 0;
            end
        else
        begin
            f2dr_instpipe1 <= nop;
            f2dr_instpipe2 <= nop;
            f2dr_instpipe3 <= nop;
            f2r_src1pipe1 <= reg0;
            f2r_src1pipe2 <= reg0;
            f2r_src1pipe3 <= reg0;
            f2r_src2pipe1 <= reg0;
            f2r_src2pipe2 <= reg0;
            f2r_src2pipe3 <= reg0;
            f2r_destpipe1 <= reg0;
            f2r_destpipe2 <= reg0;
            f2r_destpipe3 <= reg0;
            f2d_data <= 0;
        end
    end 
end
endmodule
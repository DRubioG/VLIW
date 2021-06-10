module registerfile (
    cloock, flush,, reset,
    f2r_src1pipe1, f2r_src1pipe2, f2r_src1pipe3,
    f2r_src2pipe1, f2r_src2pipe2, f2r_src2pipe3,
    f2dr_instpipe1, f2dr_instpipe2, f2dr_instpipe3,
    w2re_datapipe1, w2re_datapipe2, w2rre_datapipe3,
    w2r_wrpipe1, w2r_wrpipe2, w2r_wrpipe3,
    w2re_destpipe1, w2re_destpipe2, w2re_destpipe3,
    r2e_src1datapipe1, r2e_src1datapipe2, r2e_src1datapipe3,
    r2e_src2datapipe1, r2e_src2datapipe2, r2e_src2datapipe3,
    r2e_src1pipe1, r2e_src1pipe2, r2e_src1pipe3,
    r2e_src2pipe1, r2e_src2pipe2, r2e_src2pipe3
);

input [3:0] f2r_src1pipe1, f2r_src1pipe2, f2r_src1pipe3;
input [3:0] f2r_src2pipe1, f2r_src2pipe2, f2r_src2pipe3;
input [3:0] f2dr_instpipe1, f2dr_instpipe2, f2dr_instpipe3;
input clock, flush, reset;
input [63:0] w2re_datapipe1, w2re_datapipe2, w2re_datapipe3;
input w2r_wrpipe1, w2r_wrpipe2, w2r_wrpipe3;
input [3:0] w2re_destpipe1, w2re_destpipe2, w2re_destpipe3;

output [63:0] r2e_src1datapipe1, r2e_src1datapipe2, r2e_src1datapipe3;
output [63:0] r2e_src2datapipe1, r2e_src2datapipe2, r2e_src2datapipe3;
output [3:0] r2e_src1pipe1, r2e_src1pipe2, r2e_src1pipe2;
output [3:0] r2e_src2pipe1, r2e_src2pipe2, r2e_src2pipe3;

reg [63:0] r2e_src1datapipe1, r2e_src1datapipe2, r2e_src1datapipe3;
reg [63:0] r2e_src2datapipe1, r2e_src2datapipe2, r2e_src2datapipe3;
reg [63:0] memoryarray [0:15];
reg [3:0] r2e_src1pipe1, r2e_src1pipe2, r2e_src1pipe3;
reg [3:0] r2e_src2pipe1, r2e_src2pipe2, r2e_src2pipe3;

integer i;

always @ (posedge clock or posedge reset)
begin
    if (reset)
    begin
        for (i=0; i<16; i=i+1)
            memoryarray[i] <= 0;
        r2e_src1datapipe1 <= 0;
        r2e_src1datapipe2 <= 0;
        r2e_src1datapipe3 <= 0;
        r2e_src2datapipe1 <= 0;
        r2e_src2datapipe1 <= 0;
        r2e_src2datapipe1 <= 0;
        r2e_src1pipe1 <= 0;
        r2e_src1pipe2 <= 0;
        r2e_src1pipe3 <= 0;
        r2e_src2pipe1 <= 0;
        r2e_src2pipe2 <= 0;
        r2e_src2pipe3 <= 0;
    end
    else
    begin
        if (~flush)
        begin
            // pipe 1
            case (f2dr_instpipe1)
                4'b0000: 
                begin
                    r2e_src1datapipe1 <= 0;
                    r2e_src2datapipe1 <=0;
                end
                4'b0001://add
                begin
                    r2e_src1datapipe1 <= memoryarray[f2r_src1pipe1];
                    r2e_src2datapipe1 <= memoryarray[f2r_src2pipe1];
                end;
                4'b0010://sub
                begin
                    r2e_src1datapipe1 <= memoryarray[f2r_src1pipe1];
                    r2e_src2datapipe1 <= memoryarray[f2r_src2pipe1];
                end;
                4'b0011: //mul
                begin
                    r2e_src1datapipe1 <= 64'h00000000ffffffff & memoryarray[f2r_src1pipe1];
                    r2e_src2datapipe1 <= 64'h00000000ffffffff & memoryarray[f2r_src2pipe1];
                end;
                4'b0100: //load
                begin
                    r2e_src1datapipe1 <= 0;
                    r2e_src2datapipe1 <= 0;
                end;
                4'b0101:    //move
                begin
                    r2e_src1datapipe1 <= memoryarray[f2r_src1pipe1];
                    r2e_src2datapipe1 <= 0;
                end;
                4'b0110:    //read
                begin
                    r2e_src1datapipe1 <= memoryarray[f2r_src1pipe1];
                    r2e_src2datapipe1 <= 0;
                end;
                4'b0111:    //compare
                begin
                    r2e_src1datapipe1 <= memoryarray[f2r_src1pipe1];
                    r2e_src2datapipe1 <= memoryarray[f2r_src2pipe1];
                end;
                4'b1000:    //xor
                begin
                    r2e_src1datapipe1 <= memoryarray[f2r_src1pipe1];
                    r2e_src2datapipe1 <= memoryarray[f2r_src2pipe1];
                end;
                4'b1001:    //nand
                begin
                    r2e_src1datapipe1 <= memoryarray[f2r_src1pipe1];
                    r2e_src2datapipe1 <= memoryarray[f2r_src2pipe1];
                end;
                4'b1010:    //nor
                begin
                    r2e_src1datapipe1 <= memoryarray[f2r_src1pipe1];
                    r2e_src2datapipe1 <= memoryarray[f2r_src2pipe1];
                end;
                4'b1011:    //not
                begin
                    r2e_src1datapipe1 <= memoryarray[f2r_src1pipe1];
                    r2e_src2datapipe1 <= 0;
                end;
                4'b1100:    //shift left
                begin
                    r2e_src1datapipe1 <= memoryarray[f2r_src1pipe1];
                    r2e_src2datapipe1 <= 64'h000000000000000f & memoryarray[f2r_src2pipe1];
                end;
                4'b1101:    //shift right
                begin
                    r2e_src1datapipe1 <= memoryarray[f2r_src1pipe1];
                    r2e_src2datapipe1 <= 64'h000000000000000f & memoryarray[f2r_src2pipe1];
                end;
                4'b1110:    //barrel shift left
                begin
                    r2e_src1datapipe1 <= memoryarray[f2r_src1pipe1];
                    r2e_src2datapipe1 <= 64'h000000000000000f & memoryarray[f2r_src2pipe1];
                end;
                4'b0001:
                begin
                    r2e_src1datapipe1 <= memoryarray[f2r_src1pipe1];
                    r2e_src2datapipe1 <= 64'h000000000000000f & memoryarray[f2r_src2pipe1];
                end;
                default:
                begin
                    r2e_src1datapipe1 <= 0;
                    r2e_src2datapipe1 <= 0;
                end;
            endcase
            // pipe 2
            case (f2dr_instpipe2)
                4'b0000: 
                begin
                    r2e_src1datapipe2 <= 0;
                    r2e_src2datapipe2 <=0;
                end
                4'b0001://add
                begin
                    r2e_src1datapipe2 <= memoryarray[f2r_src1pipe2];
                    r2e_src2datapipe2 <= memoryarray[f2r_src2pipe2];
                end;
                4'b0010://sub
                begin
                    r2e_src1datapipe2 <= memoryarray[f2r_src1pipe2];
                    r2e_src2datapipe2 <= memoryarray[f2r_src2pipe2];
                end;
                4'b0011: //mul
                begin
                    r2e_src1datapipe2 <= 64'h00000000ffffffff & memoryarray[f2r_src1pipe2];
                    r2e_src2datapipe2 <= 64'h00000000ffffffff & memoryarray[f2r_src2pipe2];
                end;
                4'b0100: //load
                begin
                    r2e_src1datapipe2 <= 0;
                    r2e_src2datapipe2 <= 0;
                end;
                4'b0101:    //move
                begin
                    r2e_src1datapipe2 <= memoryarray[f2r_src1pipe2];
                    r2e_src2datapipe2 <= 0;
                end;
                4'b0110:    //read
                begin
                    r2e_src1datapipe2 <= memoryarray[f2r_src1pipe2];
                    r2e_src2datapipe2 <= 0;
                end;
                4'b0111:    //compare
                begin
                    r2e_src1datapipe2 <= memoryarray[f2r_src1pipe2];
                    r2e_src2datapipe2 <= memoryarray[f2r_src2pipe2];
                end;
                4'b1000:    //xor
                begin
                    r2e_src1datapipe2 <= memoryarray[f2r_src1pipe2];
                    r2e_src2datapipe2 <= memoryarray[f2r_src2pipe2];
                end;
                4'b1001:    //nand
                begin
                    r2e_src1datapipe2 <= memoryarray[f2r_src1pipe2];
                    r2e_src2datapipe2 <= memoryarray[f2r_src2pipe2];
                end;
                4'b1010:    //nor
                begin
                    r2e_src1datapipe2 <= memoryarray[f2r_src1pipe2];
                    r2e_src2datapipe2 <= memoryarray[f2r_src2pipe2];
                end;
                4'b1011:    //not
                begin
                    r2e_src1datapipe2 <= memoryarray[f2r_src1pipe2];
                    r2e_src2datapipe2 <= 0;
                end;
                4'b1100:    //shift left
                begin
                    r2e_src1datapipe2 <= memoryarray[f2r_src1pipe2];
                    r2e_src2datapipe2 <= 64'h000000000000000f & memoryarray[f2r_src2pipe2];
                end;
                4'b1101:    //shift right
                begin
                    r2e_src1datapipe2 <= memoryarray[f2r_src1pipe2];
                    r2e_src2datapipe2 <= 64'h000000000000000f & memoryarray[f2r_src2pipe2];
                end;
                4'b1110:    //barrel shift left
                begin
                    r2e_src1datapipe2 <= memoryarray[f2r_src1pipe2];
                    r2e_src2datapipe2 <= 64'h000000000000000f & memoryarray[f2r_src2pipe2];
                end;
                4'b0001:
                begin
                    r2e_src1datapipe2 <= memoryarray[f2r_src1pipe2];
                    r2e_src2datapipe2 <= 64'h000000000000000f & memoryarray[f2r_src2pipe2];
                end;
                default:
                begin
                    r2e_src1datapipe2 <= 0;
                    r2e_src2datapipe2 <= 0;
                end;
            endcase

            // pipe 3
            case (f2dr_instpipe3)
                4'b0000: 
                begin
                    r2e_src1datapipe3 <= 0;
                    r2e_src2datapipe3 <=0;
                end
                4'b0001://add
                begin
                    r2e_src1datapipe3 <= memoryarray[f2r_src1pipe3];
                    r2e_src2datapipe3 <= memoryarray[f2r_src2pipe3];
                end;
                4'b0010://sub
                begin
                    r2e_src1datapipe3 <= memoryarray[f2r_src1pipe3];
                    r2e_src2datapipe3 <= memoryarray[f2r_src2pipe3];
                end;
                4'b0011: //mul
                begin
                    r2e_src1datapipe3 <= 64'h00000000ffffffff & memoryarray[f2r_src1pipe3];
                    r2e_src2datapipe3 <= 64'h00000000ffffffff & memoryarray[f2r_src2pipe3];
                end;
                4'b0100: //load
                begin
                    r2e_src1datapipe3 <= 0;
                    r2e_src2datapipe3 <= 0;
                end;
                4'b0101:    //move
                begin
                    r2e_src1datapipe3 <= memoryarray[f2r_src1pipe3];
                    r2e_src2datapipe3 <= 0;
                end;
                4'b0110:    //read
                begin
                    r2e_src1datapipe3 <= memoryarray[f2r_src1pipe3];
                    r2e_src2datapipe3 <= 0;
                end;
                4'b0111:    //compare
                begin
                    r2e_src1datapipe3 <= memoryarray[f2r_src1pipe3];
                    r2e_src2datapipe3 <= memoryarray[f2r_src2pipe3];
                end;
                4'b1000:    //xor
                begin
                    r2e_src1datapipe3 <= memoryarray[f2r_src1pipe3];
                    r2e_src2datapipe3 <= memoryarray[f2r_src2pipe3];
                end;
                4'b1001:    //nand
                begin
                    r2e_src1datapipe3 <= memoryarray[f2r_src1pipe3];
                    r2e_src2datapipe3 <= memoryarray[f2r_src2pipe3];
                end;
                4'b1010:    //nor
                begin
                    r2e_src1datapipe3 <= memoryarray[f2r_src1pipe3];
                    r2e_src2datapipe3 <= memoryarray[f2r_src2pipe3];
                end;
                4'b1011:    //not
                begin
                    r2e_src1datapipe3 <= memoryarray[f2r_src1pipe3];
                    r2e_src2datapipe3 <= 0;
                end;
                4'b1100:    //shift left
                begin
                    r2e_src1datapipe3 <= memoryarray[f2r_src1pipe3];
                    r2e_src2datapipe3 <= 64'h000000000000000f & memoryarray[f2r_src2pipe3];
                end;
                4'b1101:    //shift right
                begin
                    r2e_src1datapipe3 <= memoryarray[f2r_src1pipe3];
                    r2e_src2datapipe3 <= 64'h000000000000000f & memoryarray[f2r_src2pipe3];
                end;
                4'b1110:    //barrel shift left
                begin
                    r2e_src1datapipe3 <= memoryarray[f2r_src1pipe3];
                    r2e_src2datapipe3 <= 64'h000000000000000f & memoryarray[f2r_src2pipe3];
                end;
                4'b0001:
                begin
                    r2e_src1datapipe3 <= memoryarray[f2r_src1pipe3];
                    r2e_src2datapipe3 <= 64'h000000000000000f & memoryarray[f2r_src2pipe3];
                end;
                default:
                begin
                    r2e_src1datapipe3 <= 0;
                    r2e_src2datapipe3 <= 0;
                end;
            endcase
            r2e_src1pipe1 <= f2r_src1pipe1;
            r2e_src1pipe2 <= f2r_src1pipe2;
            r2e_src1pipe3 <= f2r_src1pipe3;
            r2e_src2pipe1 <= f2r_src2pipe1;
            r2e_src2pipe2 <= f2r_src2pipe2;
            r2e_src2pipe3 <= f2r_src2pipe3;
        end
        else
        begin
            r2e_src1datapipe1 <= 0;
            r2e_src1datapipe2 <= 0;
            r2e_src1datapipe3 <= 0;
            r2e_src2datapipe1 <= 0;
            r2e_src2datapipe2 <= 0;
            r2e_src2datapipe3 <= 0;
            r2e_src1pipe1 <= 0;
            r2e_src1pipe2 <= 0;
            r2e_src1pipe3 <= 0;
            r2e_src2pipe1 <= 0;
            r2e_src2pipe2 <= 0;
            r2e_src2pipe3 <= 0;
        end

        if (w2r_wrpipe1)
            memoryarray[w2re_destpipe1] <= w2re_datapipe1;
        
        if (w2r_wrpipe2)
            memoryarray[w2re_destpipe2] <= w2re_datapipe2;

        if (w2re_wrpipe3)
            memoryarray[w2re_destpipe3] <= w2re_datapipe3;
    end
end
endmodule
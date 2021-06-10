module execute (clock, reset
d2e_instpipe1, d2e_instpipe2, d2e_instpipe3,
d2e_destpipe1, d2e_destpipe2, d2e_destpipe3,
d2e_datapipe1, d2e_datapipe2, d2e_datapipe3,
r2e_src1datapipe1, r2e_src1datapipe2, r2e_src1datapipe3,
r2e_src2datapipe1, r2e_src2datapipe2, r2e_src2datapipe3,
r2e_src1pipe1, r2e_src1pipe2, r2e_src1pipe3,
r2e_src2pipe1, r2e_src2pipe2, r2e_src2pipe3,
w2re_destpipe1, w2re_destpipe2, w2re_destpipe3,
w2re_datapipe1, w2re_datapipe2, w2re_datapipe3,
e2w_destpipe1, e2w_destpipe2, e2w_destpipe3,
e2w_datapipe1, e2w_datapipe2, e2w_datapipe3,
e2w_wrpipe1, e2w_wrpipe2, e2w_wrpipe3,
e2w_readpipe1, e2w_readpipe2, e2w_readpipe3,
flush, jump);

input clock, reset;
input [3:0] d2e_destpipe1, d2e_destpipe2, d2e_destpipe3;
input [3:0] d2e_instpipe1, d2e_instpipe2, d2e_instpipe3;
input [63:0] d2e_datapipe1, d2e_datapipe2, d2e_datapipe3;
input [63:0] r2e_src1datapipe1, r2e_src1datapipe2, r2e_src1datapipe3;
input [63:0] r2e_src2datapipe1, r2e_src2datapipe2, r2e_src2datapipe3;

input [3:0] r2e_src1pipe1, r2e_src1pipe2, r2e_src1pipe3;
input [3:0] r2e_src2pipe1, r2e_src2pipe2, r2e_src2pipe3;
input [3:0] w2re_destpipe1, w2re_destpipe2, w2re_destpipe3;
input [63:0] w2re_datapipe1, w2re_datapipe2, w2re_datapipe3;

output [3:0] e2w_destpipe1, e2w_destpipe2, e2w_destpipe3;
output [63:0] e2w_datapipe1, e2w_datapipe2, e2w_datapipe3;
output e2w_wrpipe1, e2w_wrpipe2, e2w_wrpipe3;
output e2w_readpipe1, e2w_readpipe2, e2w_readpipe3;
output flush, jump;

reg [3:0] e2w_destpipe1, e2w_destpipe2, e2w_destpipe3;
reg [63:0] e2w_datapipe1, e2w_datapipe2, e2w_datapipe3;
reg e2w_wrpipe1, e2w_wrpipe2, e2w_wrpipe3;
reg e2w_readpipe1, e2w_readpipe2, e2w_readpipe3;
reg flush, jump;
reg preflush;

reg [63:0] int_src1datapipe1, int_src1datapipe2, int_src1datapipe3;
reg [63:0] int_src2datapipe1, int_src2datapipe2, int_src2datapipe3;

reg [3:0] postw2re_destpipe1, postw2re_destpipe2, postw2re_destpipe3;
reg [63:0] postw2re_datapipe1, postw2re_datapipe2, postw2re_datapipe3;

`include "regname.v"

always @ (posedge clock or posedge reset)
begin
    if(reset)
    begin
        postw2re_datapipe1 <= reg0;
        postw2re_datapipe2 <= reg0;
        postw2re_datapipe3 <= reg0;
        postw2re_destpipe1 <= 0;
        postw2re_destpipe2 <= 0;
        postw2re_destpipe3 <= 0;
    end 
    else
    begin
        postw2re_datapipe1 <= w2re_datapipe1;
        postw2re_datapipe2 <= w2re_datapipe2;
        postw2re_datapipe3 <= w2re_datapipe3;
        postw2re_destpipe1 <= w2re_destpipe1;
        postw2re_destpipe2 <= w2re_destpipe2;
        postw2re_destpipe3 <= w2re_destpipe3;    
    end
    wire comp_w2re_dest = (w2re_destpipe1 == w2re_destpipe1)
        & (w2re_destpipe2 == w2re_destpipe3);
    wire comp_postw2re_dest = (postw2re_destpipe1 == postw2re_destpipe2)
        & (postw2re_destpipe2 == postw2re_destpipe3);

    always @ (d2e_instpipe1 or postw2re_destpipe1 or r2e_src1pipe1 or 
        r2e_src2pipe1 or r2e_src1datapipe1 or r2e_src2datapipe1 or
        postw2re-datapipe11 or w2re_destpipe1 or w2re_datapipe1 or
        e2w_wrpipe1 or postw2re_destpipe2 or postw2re_datapipe2 or
        postw2re_destpipe3 or postw2re_datapipe3 or comp_w2re_dest or
        comp_postw2re_dest)
    begin
        if ((d2e_instpipe1 == load) | (d2e_instpipe1 == nop))
        begin
            int_src1datapipe1 = r2e_src1datapipe1;
            int_src2datapipe1 = r2e_src2datapipe1;
        end
    end
    else
    begin
        if ((w2re_destpipe1 == r2e_src1pipe1)& ~comp_w2re_dest)
        begin
            int_src1datapipe1 = w2re_datapipe1;
            int_src2datapipe1 = r2e_src2datapipe1;
        end
        else if (((w2re_destpipe1 == r2e_src2pipe1)
            & ~((w2re_destpipe1 == reg0)
            &(r2e_src2pipe1==reg0)&(d2e_instpipe1
            ==read)) &~comp_w2re_dest)
        begin
            int_src1datapipe1 = r2e_src1datapipe1;
            int_src2datapipe1 = w2re_datapipe1;
        end
        // for cross operation register bypass between
        // operation3 and operation1 for src2 AND
        // between operation2 and operation1 for src1.
        else if ((postw2re_destpipe2 == r2e_src1pipe1) & (postw2re_destpipe3 == r2e_src2pipe1))
        begin
            case (d2e_instpipe1)
                4’b0011: // mul
                begin
                    int_src1datapipe1 = 64’h00000000ffffffff & postw2re_datapipe2;
                    int_src2datapipe1 = 64’h00000000ffffffff & postw2re_datapipe3;
                end
                4’b1100:
                // shift left inst.
                begin
                    int_src1datapipe1 = postw2re_datapipe2;
                    int_src2datapipe1 =64’h000000000000000f & postw2re_datapipe3;
                end
                4’b1101:
                // shift right inst.
                begin
                    int_src1datapipe1 = postw2re_datapipe2;
                    int_src2datapipe1 =64’h000000000000000f & postw2re_datapipe3;
                end
                4’b1110:
                // barrel shift left inst.
                begin
                    int_src1datapipe1 = postw2re_datapipe2;
                    int_src2datapipe1= 64’h000000000000000f & postw2re_datapipe3;
                end
                4’b1111:
                // barrel shift right inst.
                begin
                    int_src1datapipe1 = postw2re_datapipe2;
                    int_src2datapipe1 =64’h000000000000000f & postw2re_datapipe3;
                end
                default:
                begin
                    int_src1datapipe1 = postw2re_datapipe2;
                    int_src2datapipe1 = postw2re_datapipe3;
                end
            endcase
        end
            // for cross operation register bypass between
            // operation3 and operation1 for src1 AND
            // between operation2 and operation1 for src2.
        else if ((postw2re_destpipe2 == r2e_src2pipe1) &
            (postw2re_destpipe3 == r2e_src1pipe1))
        begin
            case (d2e_instpipe1)
                4’b0011: // mul
                begin
                    int_src1datapipe1 = 64’h00000000ffffffff & postw2re_datapipe3;
                    int_src2datapipe1 = 64’h00000000ffffffff & postw2re_datapipe2;
                end
                4’b1100: // shift left inst.
                begin
                    int_src1datapipe1 = postw2re_datapipe3;
                    int_src2datapipe1 =64’h000000000000000f & postw2re_datapipe2;
                end
                4’b1101: // shift right inst.
                begin
                    int_src1datapipe1 = postw2re_datapipe3;
                    int_src2datapipe1 =64’h000000000000000f & postw2re_datapipe2;
                end
                4’b1110: // barrel shift left inst.
                begin
                    int_src1datapipe1 = postw2re_datapipe3;
                    int_src2datapipe1 =64’h000000000000000f & postw2re_datapipe2;
                end
                4’b1111: // barrel shift right inst.
                begin
                    int_src1datapipe1 = postw2re_datapipe3;
                    int_src2datapipe1 =64’h000000000000000f & postw2re_datapipe2;
                end
                default:
                begin
                    int_src1datapipe1 = postw2re_datapipe3;
                    int_src2datapipe1 = postw2re_datapipe2;
                end
            endcase
        end
// for cross operation register bypass between
// operation1 and operation1 for src2 AND
// between operation3 and operation1 for src1.
        else if ((postw2re_destpipe1 == r2e_src2pipe1) & (postw2re_destpipe3 == r2e_src1pipe1))
        begin
            case (d2e_instpipe1)
                4’b0011: // mul
                begin
                    int_src1datapipe1 =64’h00000000ffffffff & postw2re_datapipe3;
                    int_src2datapipe1 =64’h00000000ffffffff & postw2re_datapipe1;
                end
                4’b1100: // shift left inst.
                begin
                    int_src1datapipe1 = postw2re_datapipe3;
                    int_src2datapipe1 =64’h000000000000000f & postw2re_datapipe1;
                end
                4’b1101: // shift right inst.
                begin
                    int_src1datapipe1 = postw2re_datapipe3;
                    int_src2datapipe1 =64’h000000000000000f & postw2re_datapipe1;
                end
                4’b1110: // barrel shift left inst.
                begin
                    int_src1datapipe1 = postw2re_datapipe3;
                    int_src2datapipe1 =64’h000000000000000f & postw2re_datapipe1;
                end
                4’b1111: // barrel shift right inst.
                begin
                    int_src1datapipe1 = postw2re_datapipe3;
                    int_src2datapipe1 =64’h000000000000000f & postw2re_datapipe1;
                end
                default:
                begin
                    int_src1datapipe1 = postw2re_datapipe3;
                    int_src2datapipe1 = postw2re_datapipe1;
                end
            endcase
        end
// for cross operation register bypass between
// operation1 and operation1 for src1 AND
// between operation3 and operation1 for src2.
        else if ((postw2re_destpipe1 == r2e_src1pipe1) & (postw2re_destpipe3 == r2e_src2pipe1))
        begin
            case (d2e_instpipe1)
                4’b0011: // mul
                begin
                    int_src1datapipe1 =64’h00000000ffffffff & postw2re_datapipe1;
                    int_src2datapipe1 =64’h00000000ffffffff & postw2re_datapipe3;
                end
                4’b1100: // shift left inst.
                begin
                    int_src1datapipe1 = postw2re_datapipe1;
                    int_src2datapipe1 =64’h000000000000000f & postw2re_datapipe3;
                end
                4’b1101: // shift right inst
                begin
                    int_src1datapipe1 = postw2re_datapipe1;
                    int_src2datapipe1 =64’h000000000000000f & postw2re_datapipe3;
                end
                4’b1110: // barrel shift left inst
                begin
                    int_src1datapipe1 = postw2re_datapipe1;
                    int_src2datapipe1 =64’h000000000000000f & postw2re_datapipe3;
                end
                4’b1111: // barrel shift right inst
                begin
                    int_src1datapipe1 = postw2re_datapipe1;
                    int_src2datapipe1 =64’h000000000000000f & postw2re_datapipe3;
                end
                default:
                begin
                    int_src1datapipe1 = postw2re_datapipe1;
                    int_src2datapipe1 = postw2re_datapipe3;
                end
            endcase
        end
// for cross operation register bypass between
// operation1 and operation1 for src1 AND
// between operation1 and operation1 for src2.
        else if ((postw2re_destpipe1 == r2e_src1pipe1) & (postw2re_destpipe1 == r2e_src2pipe1))
        begin
            case (d2e_instpipe1)
                4’b0011: // mul
                begin
                    int_src1datapipe1 =64’h00000000ffffffff & postw2re_datapipe1;
                    int_src2datapipe1 =64’h00000000ffffffff & postw2re_datapipe1;
                end
                4’b1100: // shift left inst
                begin
                    int_src1datapipe1 = postw2re_datapipe1;
                    int_src2datapipe1 =64’h000000000000000f & postw2re_datapipe1;
                end
                4’b1101: // shift right inst
                begin
                    int_src1datapipe1 = postw2re_datapipe1;
                    int_src2datapipe1 =64’h000000000000000f & postw2re_datapipe1;
                end
                4’b1110: // barrel shift left inst
                begin
                    int_src1datapipe1 = postw2re_datapipe1;
                    int_src2datapipe1 =64’h000000000000000f & postw2re_datapipe1;
                end
                4’b1111: // barrel shift right inst
                begin
                    int_src1datapipe1 = postw2re_datapipe1;
                    int_src2datapipe1 =64’h000000000000000f & postw2re_datapipe1;
                end
                default:
                begin
                    int_src1datapipe1 = postw2re_datapipe1;
                    int_src2datapipe1 = postw2re_datapipe1;
                end
            endcase
        end
// for cross operation register bypass between
// operation2 and operation1 for src1 AND
// between operation2 and operation1 for src2.
        else if ((postw2re_destpipe2 == r2e_src2pipe1) & (postw2re_destpipe2 == r2e_src1pipe1))
        begin
            case (d2e_instpipe1)
                4’b0011: // mul
                begin
                    int_src1datapipe1 =64’h00000000ffffffff & postw2re_datapipe2;
                    int_src2datapipe1 =64’h00000000ffffffff & postw2re_datapipe2;
                end
                4’b1100: // shift left inst
                begin
                    int_src1datapipe1 = postw2re_datapipe2;
                    int_src2datapipe1 =64’h000000000000000f & postw2re_datapipe2;
                end
                4’b1101: // shift right inst
                begin
                    int_src1datapipe1 = postw2re_datapipe2;
                    int_src2datapipe1 =64’h000000000000000f & postw2re_datapipe2;
                end
                4’b1110: // barrel shift left inst
                begin
                    int_src1datapipe1 = postw2re_datapipe2;
                    int_src2datapipe1 =64’h000000000000000f & postw2re_datapipe2;
                end
                4’b1111: // barrel shift right inst
                begin
                    int_src1datapipe1 = postw2re_datapipe2;
                    int_src2datapipe1 =64’h000000000000000f & postw2re_datapipe2;
                end
                default:
                begin
                    int_src1datapipe1 = postw2re_datapipe2;
                    int_src2datapipe1 = postw2re_datapipe2;
                end
            endcase
        end
// for cross operation register bypass between
// operation3 and operation1 for src1 AND
// between operation3 and operation1 for src2.
        else if ((postw2re_destpipe3 == r2e_src1pipe1) & (postw2re_destpipe3 == r2e_src2pipe1))
        begin
            case (d2e_instpipe1)
                4’b0011: // mul
                begin
                    int_src1datapipe1 =64’h00000000ffffffff & postw2re_datapipe3;
                    int_src2datapipe1 =64’h00000000ffffffff & postw2re_datapipe3;
                end
                4’b1100: // shift left inst
                begin
                    int_src1datapipe1 = postw2re_datapipe3;
                    int_src2datapipe1 =64’h000000000000000f & postw2re_datapipe3;
                end
                4’b1101: // shift right inst
                begin
                    int_src1datapipe1 = postw2re_datapipe3;
                    int_src2datapipe1 =64’h000000000000000f & postw2re_datapipe3;
                end
                4’b1110: // barrel shift left inst
                begin
                    int_src1datapipe1 = postw2re_datapipe3;
                    int_src2datapipe1 =64’h000000000000000f & postw2re_datapipe3;
                end
                4’b1111: // barrel shift right inst
                begin
                    int_src1datapipe1 = postw2re_datapipe3;
                    int_src2datapipe1 =64’h000000000000000f & postw2re_datapipe3;
                end
                default:
                begin
                    int_src1datapipe1 = postw2re_datapipe3;
                    int_src2datapipe1 = postw2re_datapipe3;
                end
            endcase
        end
// for cross operation register bypass between
// operation1 and operation1 for src1 AND
// between operation2 and operation1 for src2.
        else if ((postw2re_destpipe2 == r2e_src2pipe1) & (postw2re_destpipe1 == r2e_src1pipe1))
        begin
            case (d2e_instpipe1)
                4’b0011: // mul
                begin
                    int_src1datapipe1 =64’h00000000ffffffff & postw2re_datapipe1;
                    int_src2datapipe1 =64’h00000000ffffffff & postw2re_datapipe2;
                end
                4’b1100: // shift left inst
                begin
                    int_src1datapipe1 = postw2re_datapipe1;
                    int_src2datapipe1 =64’h000000000000000f & postw2re_datapipe2;
                end
                4’b1101: // shift right inst
                begin
                    int_src1datapipe1 = postw2re_datapipe1;
                    int_src2datapipe1 =64’h000000000000000f & postw2re_datapipe2;
                end
                4’b1110: // barrel shift left inst
                begin
                    int_src1datapipe1 = postw2re_datapipe1;
                    int_src2datapipe1 =64’h000000000000000f & postw2re_datapipe2;
                end
                4’b1111: // barrel shift right inst
                begin
                    int_src1datapipe1 = postw2re_datapipe1;
                    int_src2datapipe1 =64’h000000000000000f & postw2re_datapipe2;
                end
                default:
                begin
                    int_src1datapipe1 = postw2re_datapipe1;
                    int_src2datapipe1 = postw2re_datapipe2;
                end
            endcase
        end
// for cross operation register bypass between
// operation2 and operation1 for src1 AND
// between operation1 and operation1 for src2.
        else if ((postw2re_destpipe1 == r2e_src2pipe1) & (postw2re_destpipe2 == r2e_src1pipe1))
        begin
            case (d2e_instpipe1)
                4’b0011: // mul
                begin
                    int_src1datapipe1 =64’h00000000ffffffff & postw2re_datapipe2;
                    int_src2datapipe1 =64’h00000000ffffffff & postw2re_datapipe1;
                end
                4’b1100: // shift left inst
                begin
                    int_src1datapipe1 = postw2re_datapipe2;
                    int_src2datapipe1 =64’h000000000000000f & postw2re_datapipe1;
                end
                4’b1101: // shift right inst
                begin
                    int_src1datapipe1 = postw2re_datapipe2;
                    int_src2datapipe1 =64’h000000000000000f & postw2re_datapipe1;
                end
                4’b1110: // barrel shift left inst
                begin
                    int_src1datapipe1 = postw2re_datapipe2;
                    int_src2datapipe1 =64’h000000000000000f & postw2re_datapipe1;
                end
                4’b1111: // barrel shift right inst
                begin
                    int_src1datapipe1 = postw2re_datapipe2;
                    int_src2datapipe1 =64’h000000000000000f & postw2re_datapipe1;
                end
                default:
                begin
                    int_src1datapipe1 = postw2re_datapipe2;
                    int_src2datapipe1 = postw2re_datapipe1;
                end
            endcase
        end
// for register bypass between operation1 and
// operation1 for src2
        else if ((postw2re_destpipe1 == r2e_src2pipe1) & ~comp_postw2re_dest)
        begin
            int_src1datapipe1 = r2e_src1datapipe1;
            case (d2e_instpipe1)
                4’b0011: // mul
                    int_src2datapipe1 =64’h00000000ffffffff & postw2re_datapipe1;
                4’b1100: // shift left inst
                    int_src2datapipe1 =64’h000000000000000f & postw2re_datapipe1;
                4’b1101: // shift right inst
                    int_src2datapipe1 =64’h000000000000000f & postw2re_datapipe1;
                4’b1110: // barrel shift left inst
                    int_src2datapipe1 =64’h000000000000000f & postw2re_datapipe1;
                4’b1111: // barrel shift right inst
                    int_src2datapipe1 =64’h000000000000000f & postw2re_datapipe1;
                default:
                    int_src2datapipe1 = postw2re_datapipe1;
            endcase
        end
// for register bypass between operation1 and
// operation1 for src1
        else if ((postw2re_destpipe1 == r2e_src1pipe1) & ~comp_postw2re_dest)
        begin
            int_src2datapipe1 = r2e_src2datapipe1;
            case (d2e_instpipe1)
                4’b0011: // mul
                    int_src1datapipe1 =64’h00000000ffffffff & postw2re_datapipe1;
                4’b1100: // shift left inst
                    int_src1datapipe1 = postw2re_datapipe1;
                4’b1101: // shift right inst
                    int_src1datapipe1 = postw2re_datapipe1;
                4’b1110: // barrel shift left inst
                    int_src1datapipe1 = postw2re_datapipe1;
                4’b1111: // barrel shift right inst
                    int_src1datapipe1 = postw2re_datapipe1;
                default:
                    int_src1datapipe1 = postw2re_datapipe1;
            endcase
        end
        // for cross operation register bypass between
        // operation2 and operation1 for src1
        else if ((postw2re_destpipe2 == r2e_src1pipe1)& ~comp_postw2re_dest)
        begin
            int_src2datapipe1 = r2e_src2datapipe1;
            case (d2e_instpipe1)
                4’b0011: // mul
                    int_src1datapipe1 =64’h00000000ffffffff & postw2re_datapipe2;
                4’b1100: // shift left inst
                    int_src1datapipe1 = postw2re_datapipe2;
                4’b1101: // shift right inst
                    int_src1datapipe1 = postw2re_datapipe2;
                4’b1110: // barrel shift left inst
                    int_src1datapipe1 = postw2re_datapipe2;
                4’b1111: // barrel shift right inst
                    int_src1datapipe1 = postw2re_datapipe2;
                default:
                    int_src1datapipe1 = postw2re_datapipe2;
            endcase
        end
// for cross operation register bypass between
// operation2 and operation1 for src2
        else if ((postw2re_destpipe2 == r2e_src2pipe1) & ~comp_postw2re_dest)
        begin
            int_src1datapipe1 = r2e_src1datapipe1;
            case (d2e_instpipe1)
                4’b0011: // mul
                    int_src2datapipe1 =64’h00000000ffffffff & postw2re_datapipe2;
                4’b1100: // shift left inst
                    int_src2datapipe1 =64’h000000000000000f & postw2re_datapipe2;
                4’b1101: // shift right inst
                    int_src2datapipe1 =64’h000000000000000f & postw2re_datapipe2;
                4’b1110: // barrel shift left inst
                    int_src2datapipe1 =64’h000000000000000f & postw2re_datapipe2;
                4’b1111: // barrel shift right inst
                    int_src2datapipe1 =64’h000000000000000f & postw2re_datapipe2;
                default:
                    int_src2datapipe1 = postw2re_datapipe2;
            endcase 
        end
// for cross operation register bypass between
// operation3 and operation1 for src1
        else if ((postw2re_destpipe3 == r2e_src1pipe1)
        & ~comp_postw2re_dest)
        begin
            int_src2datapipe1 = r2e_src2datapipe1;
            case (d2e_instpipe1)
                4’b0011: // mul
                    int_src1datapipe1 =64’h00000000ffffffff & postw2re_datapipe3;
                4’b1100: // shift left inst
                    int_src1datapipe1 = postw2re_datapipe3;
                4’b1101: // shift right inst
                    int_src1datapipe1 = postw2re_datapipe3;
                4’b1110: // barrel shift left inst
                    int_src1datapipe1 = postw2re_datapipe3;
                4’b1111: // barrel shift right inst
                    int_src1datapipe1 = postw2re_datapipe3;
                default:
                    int_src1datapipe1 = postw2re_datapipe3;
            endcase
        end
// for cross operation register bypass between
// operation3 and operation1 for src2
        else if ((postw2re_destpipe3 == r2e_src2pipe1)
        & ~comp_postw2re_dest)
        begin
            int_src1datapipe1 = r2e_src1datapipe1;
            case (d2e_instpipe1)
                4’b0011: // mul
                    int_src2datapipe1 =64’h00000000ffffffff & postw2re_datapipe3;
                4’b1100: // shift left inst
                    int_src2datapipe1 =64’h000000000000000f & postw2re_datapipe3;
                4’b1101: // shift right inst
                    int_src2datapipe1 =64’h000000000000000f & postw2re_datapipe3;
                4’b1110: // barrel shift left inst
                    int_src2datapipe1 =64’h000000000000000f & postw2re_datapipe3;
                4’b1111: // barrel shift right inst
                    int_src2datapipe1 =64’h000000000000000f & postw2re_datapipe3;
                default:
                    int_src2datapipe1 = postw2re_datapipe3;
            endcase
        end
        else
        begin
            int_src1datapipe1 = r2e_src1datapipe1;
            int_src2datapipe1 = r2e_src2datapipe1;
        end
    end
end


// for register bypass on operation2
always @ (d2e_instpipe2 or postw2re_destpipe2 or r2e_src1pipe2 or
    r2e_src2pipe2 or r2e_src1datapipe2 or r2e_src2datapipe2 or
    postw2re_datapipe2 or w2re_destpipe2 or w2re_datapipe2 or
    postw2re_datapipe1 or postw2re_destpipe1 or e2w_wrpipe2 or
    postw2re_destpipe3 or postw2re_datapipe3) or comp_w2re_dest or
    comp_postw2re_dest
begin
    if ((d2e_instpipe2 == load) | (d2e_instpipe2 == nop))
    begin
        int_src1datapipe2 = r2e_src1datapipe2;
        int_src2datapipe2 = r2e_src2datapipe2;
    end
/* else if (e2w_wrpipe2) // for debug only
begin
if (postw2re_destpipe2 == r2e_src1pipe2)
begin
int_src1datapipe2 = postw2re_datapipe2;
int_src2datapipe2 = r2e_src2datapipe2;
end
else if (postw2re_destpipe2 == r2e_src2pipe2)
begin
int_src1datapipe2 = r2e_src1datapipe2;
int_src2datapipe2 = postw2re_datapipe2;
end
else
begin
int_src1datapipe2 = r2e_src1datapipe2;
int_src2datapipe2 = r2e_src2datapipe2;
end
end */
    else
    begin
        if ((w2re_destpipe2 == r2e_src1pipe2) & ~comp_w2re_dest)
        begin
            int_src1datapipe2 = w2re_datapipe2;
            int_src2datapipe2 = r2e_src2datapipe2;
        end
        else if ((w2re_destpipe2 == r2e_src2pipe2)
            & ~((w2re_destpipe2== reg0)&(r2e_src2pipe2==reg0)
            &(d2e_instpipe2==read)) &~comp_w2re_dest)
        begin
            int_src1datapipe2 = r2e_src1datapipe2;
            int_src2datapipe2 = w2re_datapipe2;
        end
// for cross operation register bypass between
// operation2 and operation2 for src2 AND
// between operation1 and operation2 for src1.
        else if ((postw2re_destpipe2 == r2e_src2pipe2)
            & (postw2re_destpipe1 == r2e_src1pipe2))
        begin
            case (d2e_instpipe2)
                4’b0011: // mul
                begin
                    int_src1datapipe2 =64’h00000000ffffffff & postw2re_datapipe1;
                    int_src2datapipe2 =64’h00000000ffffffff & postw2re_datapipe2;
                end
                4’b1100: // shift left inst
                begin
                    int_src1datapipe2 = postw2re_datapipe1;
                    int_src2datapipe2 =64’h000000000000000f & postw2re_datapipe2;
                end
                4’b1101: // shift right inst
                begin
                    int_src1datapipe2 = postw2re_datapipe1;
                    int_src2datapipe2 =64’h000000000000000f & postw2re_datapipe2;
                end
                4’b1110: // barrel shift left inst
                begin
                    int_src1datapipe2 = postw2re_datapipe1;
                    int_src2datapipe2 =64’h000000000000000f & postw2re_datapipe2;
                end
                4’b1111: // barrel shift right inst
                begin
                    int_src1datapipe2 = postw2re_datapipe1;
                    int_src2datapipe2 =64’h000000000000000f & postw2re_datapipe2;
                end
                default:
                begin
                    int_src1datapipe2 = postw2re_datapipe1;
                    int_src2datapipe2 = postw2re_datapipe2;
                end
            endcase
        end
// for cross operation register bypass between
// operation2 and operation2 for src2 AND
// between operation3 and operation2 for src1.
        else if ((postw2re_destpipe2 == r2e_src2pipe2) &
            (postw2re_destpipe3 == r2e_src1pipe2))
        begin
            case (d2e_instpipe2)
                4’b0011: // mul
                begin
                    int_src1datapipe2 =64’h00000000ffffffff & postw2re_datapipe3;
                    int_src2datapipe2 =64’h00000000ffffffff & postw2re_datapipe2;
                end
                4’b1100: // shift left inst
                begin
                    int_src1datapipe2 = postw2re_datapipe3;
                    int_src2datapipe2 =64’h000000000000000f & postw2re_datapipe2;
                end
                4’b1101: // shift right inst
                begin
                    int_src1datapipe2 = postw2re_datapipe3;
                    int_src2datapipe2 =64’h000000000000000f & postw2re_datapipe2;
                end
                4’b1110: // barrel shift left inst
                begin
                    int_src1datapipe2 = postw2re_datapipe3;
                    int_src2datapipe2 =64’h000000000000000f & postw2re_datapipe2;
                end
                4’b1111: // barrel shift right inst
                begin
                    int_src1datapipe2 = postw2re_datapipe3;
                    int_src2datapipe2 =64’h000000000000000f & postw2re_datapipe2;
                end
                default:
                begin
                    int_src1datapipe2 = postw2re_datapipe3;
                    int_src2datapipe2 = postw2re_datapipe2;
                end
            endcase
        end
// for cross operation register bypass between
// operation2 and operation2 for src1 AND
// between operation1 and operation2 for src2.
        else if ((postw2re_destpipe2 == r2e_src1pipe2) &
            (postw2re_destpipe1 == r2e_src2pipe2))
        begin
            case (d2e_instpipe2)
                4’b0011: // mul
                begin
                    int_src1datapipe2 =64’h00000000ffffffff & postw2re_datapipe2;
                    int_src2datapipe2 =64’h00000000ffffffff & postw2re_datapipe1;
                end
                4’b1100: // shift left inst
                begin
                    int_src1datapipe2 = postw2re_datapipe2;
                    int_src2datapipe2 =64’h000000000000000f & postw2re_datapipe1;
                end
                4’b1101: // shift right inst
                begin
                    int_src1datapipe2 = postw2re_datapipe2;
                    int_src2datapipe2 =64’h000000000000000f & postw2re_datapipe1;
                end
                4’b1110: // barrel shift left inst
                begin
                    int_src1datapipe2 = postw2re_datapipe2;
                    int_src2datapipe2 =64’h000000000000000f & postw2re_datapipe1;
                end
                4’b1111: // barrel shift right inst
                begin
                    int_src1datapipe2 = postw2re_datapipe2;
                    int_src2datapipe2 =64’h000000000000000f & postw2re_datapipe1;
                end
                default:
                begin
                    int_src1datapipe2 = postw2re_datapipe2;
                    int_src2datapipe2 = postw2re_datapipe1;
                end
            endcase
        end
// for cross operation register bypass between
// operation2 and operation2 for src1 AND
// between operation3 and operation2 for src2.
        else if ((postw2re_destpipe2 == r2e_src1pipe2) &
            (postw2re_destpipe3 == r2e_src2pipe2))
        begin
            case (d2e_instpipe2)
                4’b0011: // mul
                begin
                    int_src1datapipe2 =64’h00000000ffffffff & postw2re_datapipe2;
                    int_src2datapipe2 =64’h00000000ffffffff & postw2re_datapipe3;
                end
                4’b1100: // shift left inst
                begin
                    int_src1datapipe2 = postw2re_datapipe2;
                    int_src2datapipe2 =64’h000000000000000f & postw2re_datapipe3;
                end
                4’b1101: // shift right inst
                begin
                    int_src1datapipe2 = postw2re_datapipe2;
                    int_src2datapipe2 =64’h000000000000000f & postw2re_datapipe3;
                end
                4’b1110: // barrel shift left inst
                begin
                    int_src1datapipe2 = postw2re_datapipe2;
                    int_src2datapipe2 =64’h000000000000000f & postw2re_datapipe3;
                end
                4’b1111: // barrel shift right inst
                begin
                    int_src1datapipe2 = postw2re_datapipe2;
                    int_src2datapipe2 =64’h000000000000000f & postw2re_datapipe3;
                end
                default:
                begin
                    int_src1datapipe2 = postw2re_datapipe2;
                    int_src2datapipe2 = postw2re_datapipe3;
                end
            endcase
        end
// for cross operation register bypass between
// operation2 and operation2 for src1 AND
// between operation2 and operation2 for src2.
        else if ((postw2re_destpipe2 == r2e_src1pipe2) &
            (postw2re_destpipe2 == r2e_src2pipe2))
        begin
            case (d2e_instpipe2)
                4’b0011: // mul
                begin
                    int_src1datapipe2 =64’h00000000ffffffff & postw2re_datapipe2;
                    int_src2datapipe2 =64’h00000000ffffffff & postw2re_datapipe2;
                end
                4’b1100: // shift left inst
                begin
                    int_src1datapipe2 = postw2re_datapipe2;
                    int_src2datapipe2 =64’h000000000000000f & postw2re_datapipe2;
                end
                4’b1101: // shift right inst
                begin
                    int_src1datapipe2 = postw2re_datapipe2;
                    int_src2datapipe2 =64’h000000000000000f & postw2re_datapipe2;
                end
                4’b1110: // barrel shift left inst
                begin
                    int_src1datapipe2 = postw2re_datapipe2;
                    int_src2datapipe2 =64’h000000000000000f & postw2re_datapipe2;
                end
                4’b1111: // barrel shift right inst
                begin
                    int_src1datapipe2 = postw2re_datapipe2;
                    int_src2datapipe2 =64’h000000000000000f & postw2re_datapipe2;
                end
                default:
                begin
                    int_src1datapipe2 = postw2re_datapipe2;
                    int_src2datapipe2 = postw2re_datapipe2;
                end
            endcase
        end
// for cross operation register bypass between
// operation1 and operation2 for src1 AND
// between operation1 and operation2 for src2.
        else if ((postw2re_destpipe1 == r2e_src2pipe2) &
            (postw2re_destpipe1 == r2e_src1pipe2))
        begin
            case (d2e_instpipe2)
                4’b0011: // mul
                begin
                    int_src1datapipe2 =64’h00000000ffffffff & postw2re_datapipe1;
                    int_src2datapipe2 =64’h00000000ffffffff & postw2re_datapipe1;
                end
                4’b1100: // shift left inst
                begin
                    int_src1datapipe2 = postw2re_datapipe1;
                    int_src2datapipe2 =64’h000000000000000f & postw2re_datapipe1;
                end
                4’b1101: // shift right inst
                begin
                    int_src1datapipe2 = postw2re_datapipe1;
                    int_src2datapipe2 =64’h000000000000000f & postw2re_datapipe1;
                end
                4’b1110: // barrel shift left inst
                begin
                    int_src1datapipe2 = postw2re_datapipe1;
                    int_src2datapipe2 =64’h000000000000000f & postw2re_datapipe1;
                end
                4’b1111: // barrel shift right inst
                begin
                    int_src1datapipe2 = postw2re_datapipe1;
                    int_src2datapipe2 =64’h000000000000000f & postw2re_datapipe1;
                end
                default:
                begin
                    int_src1datapipe2 = postw2re_datapipe1;
                    int_src2datapipe2 = postw2re_datapipe1;
                end
            endcase
        end
// for cross operation register bypass between
// operation3 and operation2 for src1 AND
// between operation3 and operation2 for src2.
        else if ((postw2re_destpipe3 == r2e_src2pipe2) &
            (postw2re_destpipe3 == r2e_src1pipe2))
        begin
            case (d2e_instpipe2)
                4’b0011: // mul
                begin
                    int_src1datapipe2 =64’h00000000ffffffff & postw2re_datapipe3;
                    int_src2datapipe2 =64’h00000000ffffffff & postw2re_datapipe3;
                end
                4’b1100: // shift left inst
                begin
                    int_src1datapipe2 = postw2re_datapipe3;
                    int_src2datapipe2 =64’h000000000000000f & postw2re_datapipe3;
                end
                4’b1101: // shift right inst
                begin
                    int_src1datapipe2 = postw2re_datapipe3;
                    int_src2datapipe2 =64’h000000000000000f & postw2re_datapipe3;
                end
                4’b1110: // barrel shift left inst
                begin
                    int_src1datapipe2 = postw2re_datapipe3;
                    int_src2datapipe2 =64’h000000000000000f & postw2re_datapipe3;
                end
                4’b1111: // barrel shift right inst
                begin
                    int_src1datapipe2 = postw2re_datapipe3;
                    int_src2datapipe2 =64’h000000000000000f & postw2re_datapipe3;
                end
                default:
                begin
                    int_src1datapipe2 = postw2re_datapipe3;
                    int_src2datapipe2 = postw2re_datapipe3;
                end
            endcase
        end
// for cross operation register bypass between
// operation3 and operation2 for src2 AND
// between operation1 and operation2 for src1.
        else if ((postw2re_destpipe3 == r2e_src2pipe2) &
            (postw2re_destpipe1 == r2e_src1pipe2))
        begin
            case (d2e_instpipe2)
                4’b0011: // mul
                begin
                    int_src1datapipe2 =64’h00000000ffffffff & postw2re_datapipe1;
                    int_src2datapipe2 =64’h00000000ffffffff & postw2re_datapipe3;
                end
                4’b1100: // shift left inst
                begin
                    int_src1datapipe2 = postw2re_datapipe1;
                    int_src2datapipe2 =64’h000000000000000f & postw2re_datapipe3;
                end
                4’b1101: // shift right inst
                begin
                    int_src1datapipe2 = postw2re_datapipe1;
                    int_src2datapipe2 =64’h000000000000000f & postw2re_datapipe3;
                end
                4’b1110: // barrel shift left inst
                begin
                    int_src1datapipe2 = postw2re_datapipe1;
                    int_src2datapipe2 =64’h000000000000000f & postw2re_datapipe3;
                end
                4’b1111: // barrel shift right inst
                begin
                    int_src1datapipe2 = postw2re_datapipe1;
                    int_src2datapipe2 =64’h000000000000000f & postw2re_datapipe3;
                end
                default:
                begin
                    int_src1datapipe2 = postw2re_datapipe1;
                    int_src2datapipe2 = postw2re_datapipe3;
                end
            endcase
        end
// for cross operation register bypass between
// operation1 and operation2 for src2 AND
// between operation3 and operation2 for src1.
        else if ((postw2re_destpipe1 == r2e_src2pipe2) &
            (postw2re_destpipe3 == r2e_src1pipe2))
        begin
            case (d2e_instpipe2)
                4’b0011: // mul
                begin
                    int_src1datapipe2 =64’h00000000ffffffff & postw2re_datapipe3;
                    int_src2datapipe2 =64’h00000000ffffffff & postw2re_datapipe1;
                end
                4’b1100: // shift left inst
                begin
                    int_src1datapipe2 = postw2re_datapipe3;
                    int_src2datapipe2 =64’h000000000000000f & postw2re_datapipe1;
                end
                4’b1101: // shift right inst
                begin
                    int_src1datapipe2 = postw2re_datapipe3;
                    int_src2datapipe2 =64’h000000000000000f & postw2re_datapipe1;
                end
                4’b1110: // barrel shift left inst
                begin
                    int_src1datapipe2 = postw2re_datapipe3;
                    int_src2datapipe2 =64’h000000000000000f & postw2re_datapipe1;
                end
                4’b1111: // barrel shift right inst
                begin
                    int_src1datapipe2 = postw2re_datapipe3;
                    int_src2datapipe2 =64’h000000000000000f & postw2re_datapipe1;
                end
                default:
                begin
                    int_src1datapipe2 = postw2re_datapipe3;
                    int_src2datapipe2 = postw2re_datapipe1;
                end
            endcase
        end
// for cross operation register bypass between
// operation1 and operation2 for src2
        else if ((postw2re_destpipe1 == r2e_src2pipe2)
            & ~comp_postw2re_dest)
        begin
            int_src1datapipe2 = r2e_src1datapipe2;
            case (d2e_instpipe2)
                4’b0011: // mul
                    int_src2datapipe2 = 64’h00000000ffffffff & postw2re_datapipe1;
                4’b1100: // shift left inst
                    int_src2datapipe2 = 64’h000000000000000f &postw2re_datapipe1;
                4’b1101: // shift right inst
                    int_src2datapipe2 = 64’h000000000000000f & postw2re_datapipe1;
                4’b1110: // barrel shift left inst
                    int_src2datapipe2 = 64’h000000000000000f & postw2re_datapipe1;
                4’b1111: // barrel shift right inst
                    int_src2datapipe2 = 64’h000000000000000f & postw2re_datapipe1;
                default:
                    int_src2datapipe2 = postw2re_datapipe1;
            endcase
        end
// for cross operation register bypass between
// operation1 and operation2 for src1
        else if ((postw2re_destpipe1 == r2e_src1pipe2)
            & ~comp_postw2re_dest)
        begin
            int_src2datapipe2 = r2e_src2datapipe2;
            case (d2e_instpipe2)
                4’b0011: // mul
                    int_src1datapipe2 = 64’h00000000ffffffff &
                    postw2re_datapipe1;
                4’b1100: // shift left inst
                    int_src1datapipe2 = postw2re_datapipe1;
                4’b1101: // shift right inst
                    int_src1datapipe2 = postw2re_datapipe1;
                4’b1110: // barrel shift left inst
                    int_src1datapipe2 = postw2re_datapipe1;
                4’b1111: // barrel shift right inst
                    int_src1datapipe2 = postw2re_datapipe1;
                default:
                    int_src1datapipe2 = postw2re_datapipe1;
            endcase
        end
// for register bypass between operation2 and
// operation2 for src2
        else if ((postw2re_destpipe2 == r2e_src2pipe2)
            & ~comp_postw2re_dest)
        begin
            int_src1datapipe2 = r2e_src1datapipe2;
            case (d2e_instpipe2)
                4’b0011: // mul
                    int_src2datapipe2 = 64’h00000000ffffffff & postw2re_datapipe2;
                4’b1100: // shift left inst
                    int_src2datapipe2 = 64’h000000000000000f & postw2re_datapipe2;
                4’b1101: // shift right inst
                    int_src2datapipe2 = 64’h000000000000000f & postw2re_datapipe2;
                4’b1110: // barrel shift left inst
                    int_src2datapipe2 = 64’h000000000000000f & postw2re_datapipe2;
                4’b1111: // barrel shift right inst
                    int_src2datapipe2 = 64’h000000000000000f & postw2re_datapipe2;
                default:
                    int_src2datapipe2 = postw2re_datapipe2;
            endcase
        end
// for register bypass between operation2 and
// operation2 for src1
        else if ((postw2re_destpipe2 == r2e_src1pipe2)
            & ~comp_postw2re_dest)
        begin
            int_src2datapipe2 = r2e_src2datapipe2;
            case (d2e_instpipe2)
                4’b0011: // mul
                    int_src1datapipe2 = 64’h00000000ffffffff & postw2re_datapipe2;
                4’b1100: // shift left inst
                    int_src1datapipe2 = postw2re_datapipe2;
                4’b1101: // shift right inst
                    int_src1datapipe2 = postw2re_datapipe2;
                4’b1110: // barrel shift left inst
                    int_src1datapipe2 = postw2re_datapipe2;
                4’b1111: // barrel shift right inst
                    int_src1datapipe2 = postw2re_datapipe2;
                default:
                    int_src1datapipe2 = postw2re_datapipe2;
            endcase
        end
// for cross operation register bypass between
// operation3 and operation2 for src1
        else if ((postw2re_destpipe3 == r2e_src1pipe2)
            & ~comp_postw2re_dest)
        begin
            int_src2datapipe2 = r2e_src2datapipe2;
            case (d2e_instpipe2)
                4’b0011: // mul
                    int_src1datapipe2 = 64’h00000000ffffffff & postw2re_datapipe3;
                4’b1100: // shift left inst
                    int_src1datapipe2 = postw2re_datapipe3;
                4’b1101: // shift right inst
                    int_src1datapipe2 = postw2re_datapipe3;
                4’b1110: // barrel shift left inst
                    int_src1datapipe2 = postw2re_datapipe3;
                4’b1111: // barrel shift right inst
                    int_src1datapipe2 = postw2re_datapipe3;
                default:
                    int_src1datapipe2 = postw2re_datapipe3;
            endcase
        end
// for cross operation register bypass between
// operation3 and operation2 for src2
        else if ((postw2re_destpipe3 == r2e_src2pipe2)
            & ~comp_postw2re_dest)
        begin
            int_src1datapipe2 = r2e_src1datapipe2;
            case (d2e_instpipe2)
                4’b0011: // mul
                    int_src2datapipe2 = 64’h00000000ffffffff & postw2re_datapipe3;
                4’b1100: // shift left inst
                    int_src2datapipe2 = 64’h000000000000000f & postw2re_datapipe3;
                4’b1101: // shift right inst
                    int_src2datapipe2 = 64’h000000000000000f & postw2re_datapipe3;
                4’b1110: // barrel shift left inst
                    int_src2datapipe2 = 64’h000000000000000f & postw2re_datapipe3;
                4’b1111: // barrel shift right inst
                    int_src2datapipe2 = 64’h000000000000000f & postw2re_datapipe3;
                default:
                    int_src2datapipe2 = postw2re_datapipe3;
            endcase
        end
        else
        begin
            int_src1datapipe2 = r2e_src1datapipe2;
            int_src2datapipe2 = r2e_src2datapipe2;
        end
    end
end


// for register bypass on operation3
always @ (d2e_instpipe3 or postw2re_destpipe3 or r2e_src1pipe3 or
    r2e_src2pipe3 or r2e_src1datapipe3 or r2e_src2datapipe3 or
    postw2re_datapipe3 or w2re_destpipe3 or w2re_datapipe3 or
    postw2re_datapipe1 or postw2re_destpipe1 or e2w_wrpipe3 or postw2re_
    destpipe2 or postw2re_datapipe2 or comp_w2re_dest or comp_postw2re_dest)
begin
    if ((d2e_instpipe3 == load) | (d2e_instpipe3 == nop))
    begin
        int_src1datapipe3 = r2e_src1datapipe3;
        int_src2datapipe3 = r2e_src2datapipe3;
    end
    /* else if (e2w_wrpipe3) // for debug only
    begin
    if (postw2re_destpipe3 == r2e_src1pipe3)
    begin
    int_src1datapipe3 = postw2re_datapipe3;
    int_src2datapipe3 = r2e_src2datapipe3;
    end
    else if (postw2re_destpipe3 == r2e_src2pipe3)
    begin
    int_src1datapipe3 = r2e_src1datapipe3;
    int_src2datapipe3 = postw2re_datapipe3;
    end
    else
    begin
    int_src1datapipe3 = r2e_src1datapipe3;
    int_src2datapipe3 = r2e_src2datapipe3;
    end
    end */
    else
    begin
        if ((w2re_destpipe3 == r2e_src1pipe3) & ~comp_w2re_dest)
        begin
            int_src1datapipe3 = w2re_datapipe3;
            int_src2datapipe3 = r2e_src2datapipe3;
        end
        else if ((w2re_destpipe3 == r2e_src2pipe3)
            & ~((w2re_destpipe3 == reg0)
            &(r2e_src2pipe3==reg0) &(d2e_instpipe3==read))
            & ~comp_w2re_dest)
        begin
            int_src1datapipe3 = r2e_src1datapipe3;
            int_src2datapipe3 = w2re_datapipe3;
        end
// for cross operation register bypass between
// operation3 and operation3 for src1 AND
// between operation2 and operation3 for src2.
        else if ((postw2re_destpipe3 == r2e_src1pipe3) &
            (postw2re_destpipe2 == r2e_src2pipe3))
        begin
            case (d2e_instpipe3)
                4’b0011: // mul
                begin
                    int_src1datapipe3 =64’h00000000ffffffff & postw2re_datapipe3;
                    int_src2datapipe3 =64’h00000000ffffffff & postw2re_datapipe2;
                end
                4’b1100: // shift left inst
                begin
                    int_src1datapipe3 = postw2re_datapipe3;
                    int_src2datapipe3 =64’h000000000000000f & postw2re_datapipe2;
                end
                4’b1101: // shift right inst
                begin
                    int_src1datapipe3 = postw2re_datapipe3;
                    int_src2datapipe3 =64’h000000000000000f & postw2re_datapipe2;
                end
                4’b1110: // barrel shift left inst
                begin
                    int_src1datapipe3 = postw2re_datapipe3;
                    int_src2datapipe3 =64’h000000000000000f & postw2re_datapipe2;
                end
                4’b1111: // barrel shift right inst
                begin
                    int_src1datapipe3 = postw2re_datapipe3;
                    int_src2datapipe3 =64’h000000000000000f & postw2re_datapipe2;
                end
                default:
                begin
                    int_src1datapipe3 = postw2re_datapipe3;
                    int_src2datapipe3 = postw2re_datapipe2;
                end
            endcase
        end
// for cross operation register bypass between
// operation3 and operation3 for src2 AND
// between operation2 and operation3 for src1.
        else if ((postw2re_destpipe3 == r2e_src2pipe3) &
            (postw2re_destpipe2 == r2e_src1pipe3))
        begin
            case (d2e_instpipe3)
                4’b0011: // mul
                begin
                    int_src1datapipe3 =64’h00000000ffffffff & postw2re_datapipe2;
                    int_src2datapipe3 =64’h00000000ffffffff & postw2re_datapipe3;
                end
                4’b1100: // shift left inst
                begin
                    int_src1datapipe3 = postw2re_datapipe2;
                    int_src2datapipe3 =64’h000000000000000f & postw2re_datapipe3;
                end
                4’b1101: // shift right inst
                begin
                    int_src1datapipe3 = postw2re_datapipe2;
                    int_src2datapipe3 =64’h000000000000000f & postw2re_datapipe3;
                end
                4’b1110: // barrel shift left inst
                begin
                    int_src1datapipe3 = postw2re_datapipe2;
                    int_src2datapipe3 =64’h000000000000000f & postw2re_datapipe3;
                end
                4’b1111: // barrel shift right inst
                begin
                    int_src1datapipe3 = postw2re_datapipe2;
                    int_src2datapipe3 =64’h000000000000000f & postw2re_datapipe3;
                end
                default:
                begin
                    int_src1datapipe3 = postw2re_datapipe2;
                    int_src2datapipe3 = postw2re_datapipe3;
                end
            endcase
        end
// for cross operation register bypass between
// operation3 and operation3 for src2 AND
// between operation1 and operation3 for src1.
        else if ((postw2re_destpipe3 == r2e_src2pipe3) &
            (postw2re_destpipe1 == r2e_src1pipe3))
        begin
            case (d2e_instpipe3)
                4’b0011: // mul
                begin
                    int_src1datapipe3 =64’h00000000ffffffff & postw2re_datapipe1;
                    int_src2datapipe3 =64’h00000000ffffffff & postw2re_datapipe3;
                end
                4’b1100: // shift left inst
                begin
                    int_src1datapipe3 = postw2re_datapipe1;
                    int_src2datapipe3 =64’h000000000000000f & postw2re_datapipe3;
                end
                4’b1101: // shift right inst
                begin
                    int_src1datapipe3 = postw2re_datapipe1;
                    int_src2datapipe3 =64’h000000000000000f & postw2re_datapipe3;
                end
                4’b1110: // barrel shift left inst
                begin
                    int_src1datapipe3 = postw2re_datapipe1;
                    int_src2datapipe3 =64’h000000000000000f & postw2re_datapipe3;
                end
                4’b1111: // barrel shift right inst
                begin
                    int_src1datapipe3 = postw2re_datapipe1;
                    int_src2datapipe3 =64’h000000000000000f & postw2re_datapipe3;
                end
                default:
                begin
                    int_src1datapipe3 = postw2re_datapipe1;
                    int_src2datapipe3 = postw2re_datapipe3;
                end
            endcase
        end
// for cross operation register bypass between
// operation3 and operation3 for src1 AND
// between operation1 and operation3 for src2.
        else if ((postw2re_destpipe3 == r2e_src1pipe3) &
            (postw2re_destpipe1 == r2e_src2pipe3))
        begin
            case (d2e_instpipe3)
                4’b0011: // mul
                begin
                    int_src1datapipe3 =64’h00000000ffffffff & postw2re_datapipe3;
                    int_src2datapipe3 =64’h00000000ffffffff & postw2re_datapipe1;
                end
                4’b1100: // shift left inst
                begin
                    int_src1datapipe3 = postw2re_datapipe3;
                    int_src2datapipe3 =64’h000000000000000f & postw2re_datapipe1;
                end
                4’b1101: // shift right inst
                begin
                    int_src1datapipe3 = postw2re_datapipe3;
                    int_src2datapipe3 =64’h000000000000000f  & postw2re_datapipe1;
                end
                4’b1110: // barrel shift left inst
                begin
                    int_src1datapipe3 = postw2re_datapipe3;
                    int_src2datapipe3 =64’h000000000000000f & postw2re_datapipe1;
                end
                4’b1111: // barrel shift right inst
                begin
                    int_src1datapipe3 = postw2re_datapipe3;
                    int_src2datapipe3 =64’h000000000000000f & postw2re_datapipe1;
                end
                default:
                begin
                    int_src1datapipe3 = postw2re_datapipe3;
                    int_src2datapipe3 = postw2re_datapipe1;
                end
            endcase
        end
// for cross operation register bypass between
// operation3 and operation3 for src1 AND
// between operation3 and operation3 for src2.
        else if ((postw2re_destpipe3 == r2e_src1pipe3) &
            (postw2re_destpipe3 == r2e_src2pipe3))
        begin
            case (d2e_instpipe3)
                4’b0011: // mul
                begin
                    int_src1datapipe3 =64’h00000000ffffffff & postw2re_datapipe3;
                    int_src2datapipe3 =64’h00000000ffffffff& postw2re_datapipe3;
                end
                4’b1100: // shift left inst
                begin
                    int_src1datapipe3 = postw2re_datapipe3;
                    int_src2datapipe3 =64’h000000000000000f & postw2re_datapipe3;
                end
                4’b1101: // shift right inst
                begin
                    int_src1datapipe3 = postw2re_datapipe3;
                    int_src2datapipe3 =64’h000000000000000f & postw2re_datapipe3;
                end
                4’b1110: // barrel shift left inst
                begin
                    int_src1datapipe3 = postw2re_datapipe3;
                    int_src2datapipe3 =64’h000000000000000f & postw2re_datapipe3;
                end
                4’b1111: // barrel shift right inst
                begin
                    int_src1datapipe3 = postw2re_datapipe3;
                    int_src2datapipe3 =64’h000000000000000f & postw2re_datapipe3;
                end
                default:
                begin
                    int_src1datapipe3 = postw2re_datapipe3;
                    int_src2datapipe3 = postw2re_datapipe3;
                end
            endcase
        end
// for cross operation register bypass between
// operation1 and operation3 for src1 AND
// between operation1 and operation3 for src2.
        else if ((postw2re_destpipe1 == r2e_src1pipe3) &
            (postw2re_destpipe1 == r2e_src2pipe3))
        begin
            case (d2e_instpipe3)
                4’b0011: // mul
                begin
                    int_src1datapipe3 =64’h00000000ffffffff & postw2re_datapipe1;
                    int_src2datapipe3 =64’h00000000ffffffff & postw2re_datapipe1;
                end
                4’b1100: // shift left inst
                begin
                    int_src1datapipe3 = postw2re_datapipe1;
                    int_src2datapipe3 =64’h000000000000000f & postw2re_datapipe1;
                end
                4’b1101: // shift right inst
                begin
                    int_src1datapipe3 = postw2re_datapipe1;
                    int_src2datapipe3 =64’h000000000000000f & postw2re_datapipe1;
                end
                4’b1110: // barrel shift left inst
                begin
                    int_src1datapipe3 = postw2re_datapipe1;
                    int_src2datapipe3 =64’h000000000000000f & postw2re_datapipe1;
                end
                4’b1111: // barrel shift right inst
                begin
                    int_src1datapipe3 = postw2re_datapipe1;
                    int_src2datapipe3 =64’h000000000000000f & postw2re_datapipe1;
                end
                default:
                begin
                    int_src1datapipe3 = postw2re_datapipe1;
                    int_src2datapipe3 = postw2re_datapipe1;
                end
            endcase
        end
// for cross operation register bypass between
// operation2 and operation3 for src1 AND
// between operation2 and operation3 for src2.
        else if ((postw2re_destpipe2 == r2e_src1pipe3) &
            (postw2re_destpipe2 == r2e_src2pipe3))
        begin
            case (d2e_instpipe3)
                4’b0011: // mul
                begin
                    int_src1datapipe3 =64’h00000000ffffffff & postw2re_datapipe2;
                    int_src2datapipe3 =64’h00000000ffffffff & postw2re_datapipe2;
                end
                4’b1100: // shift left inst
                begin
                    int_src1datapipe3 = postw2re_datapipe2;
                    int_src2datapipe3 =64’h000000000000000f & postw2re_datapipe2;
                end
                4’b1101: // shift right inst
                begin
                    int_src1datapipe3 = postw2re_datapipe2;
                    int_src2datapipe3 =64’h000000000000000f & postw2re_datapipe2;
                end
                4’b1110: // barrel shift left inst
                begin
                    int_src1datapipe3 = postw2re_datapipe2;
                    int_src2datapipe3 =64’h000000000000000f & postw2re_datapipe2;
                end
                4’b1111: // barrel shift right inst
                begin
                    int_src1datapipe3 = postw2re_datapipe2;
                    int_src2datapipe3 =64’h000000000000000f & postw2re_datapipe2;
                end
                default:
                begin
                    int_src1datapipe3 = postw2re_datapipe2;
                    int_src2datapipe3 = postw2re_datapipe2;
                end
            endcase
        end
// for cross operation register bypass between
// operation1 and operation3 for src1 AND
// between operation2 and operation3 for src2.
        else if ((postw2re_destpipe1 == r2e_src1pipe3) &
            (postw2re_destpipe2 == r2e_src2pipe3))
        begin
            case (d2e_instpipe3)
                4’b0011: // mul
                begin
                    int_src1datapipe3 =64’h00000000ffffffff & postw2re_datapipe1;
                    int_src2datapipe3 =64’h00000000ffffffff & postw2re_datapipe2;
                end
                4’b1100: // shift left inst
                begin
                    int_src1datapipe3 = postw2re_datapipe1;
                    int_src2datapipe3 =64’h000000000000000f & postw2re_datapipe2;
                end
                4’b1101: // shift right inst
                begin
                    int_src1datapipe3 = postw2re_datapipe1;
                    int_src2datapipe3 =64’h000000000000000f & postw2re_datapipe2;
                end
                4’b1110: // barrel shift left inst
                begin
                    int_src1datapipe3 = postw2re_datapipe1;
                    int_src2datapipe3 =64’h000000000000000f & postw2re_datapipe2;
                end
                4’b1111: // barrel shift right inst
                begin
                    int_src1datapipe3 = postw2re_datapipe1;
                    int_src2datapipe3 =64’h000000000000000f & postw2re_datapipe2;
                end
                default:
                begin
                    int_src1datapipe3 = postw2re_datapipe1;
                    int_src2datapipe3 = postw2re_datapipe2;
                end
            endcase
        end
// for cross operation register bypass between
// operation2 and operation3 for src1 AND
// between operation1 and operation3 for src2.
        else if ((postw2re_destpipe2 == r2e_src1pipe3) &
            (postw2re_destpipe1 == r2e_src2pipe3))
        begin
            case (d2e_instpipe3)
                4’b0011: // mul
                begin
                    int_src1datapipe3 =64’h00000000ffffffff & postw2re_datapipe2;
                    int_src2datapipe3 =64’h00000000ffffffff & postw2re_datapipe1;
                end
                4’b1100: // shift left inst
                begin
                    int_src1datapipe3 = postw2re_datapipe2;
                    int_src2datapipe3 =64’h000000000000000f & postw2re_datapipe1;
                end
                4’b1101: // shift right inst
                begin
                    int_src1datapipe3 = postw2re_datapipe2;
                    int_src2datapipe3 =64’h000000000000000f & postw2re_datapipe1;
                end
                4’b1110: // barrel shift left inst
                begin
                    int_src1datapipe3 = postw2re_datapipe2;
                    int_src2datapipe3 =64’h000000000000000f & postw2re_datapipe1;
                end
                4’b1111: // barrel shift right inst
                begin
                    int_src1datapipe3 = postw2re_datapipe2;
                    int_src2datapipe3 =64’h000000000000000f & postw2re_datapipe1;
                end
                default:
                begin
                    int_src1datapipe3 = postw2re_datapipe2;
                    int_src2datapipe3 = postw2re_datapipe1;
                end
            endcase
        end
// for cross operation register bypass between
// operation1 and operation3 for src1
        else if ((postw2re_destpipe1 == r2e_src1pipe3)
            & ~comp_postw2re_dest)
        begin
            int_src2datapipe3 = r2e_src2datapipe3;
            case (d2e_instpipe3)
                4’b0011: // mul
                    int_src1datapipe3 = 64’h00000000ffffffff & postw2re_datapipe1;
                4’b1100: // shift left inst
                    int_src1datapipe3 = postw2re_datapipe1;
                4’b1101: // shift right inst
                    int_src1datapipe3 = postw2re_datapipe1;
                4’b1110: // barrel shift left inst
                    int_src1datapipe3 = postw2re_datapipe1;
                4’b1111: // barrel shift right inst
                    int_src1datapipe3 = postw2re_datapipe1;
                default:
                    int_src1datapipe3 = postw2re_datapipe1;
            endcase
        end
// for cross operation register bypass between
// operation1 and operation3 for src2
        else if ((postw2re_destpipe1 == r2e_src2pipe3)
            & ~comp_postw2re_dest)
        begin
            int_src1datapipe3 = r2e_src1datapipe3;
            case (d2e_instpipe3)
                4’b0011: // mul
                    int_src2datapipe3 = 64’h00000000ffffffff & postw2re_datapipe1;
                4’b1100: // shift left inst
                    int_src2datapipe3 = 64’h000000000000000f & postw2re_datapipe1;
                4’b1101: // shift right inst
                    int_src2datapipe3 = 64’h000000000000000f & postw2re_datapipe1;
                4’b1110: // barrel shift left inst
                    int_src2datapipe3 = 64’h000000000000000f & postw2re_datapipe1;
                4’b1111: // barrel shift right inst
                    int_src2datapipe3 = 64’h000000000000000f & postw2re_datapipe1;
                default:
                    int_src2datapipe3 = postw2re_datapipe1;
            endcase
        end
// for cross operation register bypass between
// operation2 and operation3 for src1
        else if ((postw2re_destpipe2 == r2e_src1pipe3)
            & ~comp_postw2re_dest)
        begin
            int_src2datapipe3 = r2e_src2datapipe3;
            case (d2e_instpipe3)
                4’b0011: // mul
                    int_src1datapipe3 = 64’h00000000ffffffff & postw2re_datapipe2;
                4’b1100: // shift left inst
                    int_src1datapipe3 = postw2re_datapipe2;
                4’b1101: // shift right inst
                    int_src1datapipe3 = postw2re_datapipe2;
                4’b1110: // barrel shift left inst
                    int_src1datapipe3 = postw2re_datapipe2;
                4’b1111: // barrel shift right inst
                    int_src1datapipe3 = postw2re_datapipe2;
                default:
                    int_src1datapipe3 = postw2re_datapipe2;
            endcase
        end
// for cross operation register bypass between
// operation2 and operation3 for src2
        else if ((postw2re_destpipe2 == r2e_src2pipe3)
            & ~comp_postw2re_dest)
        begin
            int_src1datapipe3 = r2e_src1datapipe3;
            case (d2e_instpipe3)
                4’b0011: // mul
                    int_src2datapipe3 = 64’h00000000ffffffff & postw2re_datapipe2;
                4’b1100: // shift left inst
                    int_src2datapipe3 = 64’h000000000000000f & postw2re_datapipe2;
                4’b1101: // shift right inst
                    int_src2datapipe3 = 64’h000000000000000f & postw2re_datapipe2;
                4’b1110: // barrel shift left inst
                    int_src2datapipe3 = 64’h000000000000000f & postw2re_datapipe2;
                4’b1111: // barrel shift right inst
                    int_src2datapipe3 = 64’h000000000000000f & postw2re_datapipe2;
                default:
                    int_src2datapipe3 = postw2re_datapipe2;
            endcase
        end
// for register bypass between operation3 and
// operation3 for src1
        else if ((postw2re_destpipe3 == r2e_src1pipe3)
            & ~comp_postw2re_dest)
        begin
            int_src2datapipe3 = r2e_src2datapipe3;
            case (d2e_instpipe3)
                4’b0011: // mul
                    int_src1datapipe3 = 64’h00000000ffffffff & postw2re_datapipe3;
                4’b1100: // shift left inst
                    int_src1datapipe3 = postw2re_datapipe3;
                4’b1101: // shift right inst
                    int_src1datapipe3 = postw2re_datapipe3;
                4’b1110: // barrel shift left inst
                    int_src1datapipe3 = postw2re_datapipe3;
                4’b1111: // barrel shift right inst
                    int_src1datapipe3 = postw2re_datapipe3;
                default:
                    int_src1datapipe3 = postw2re_datapipe3;
            endcase
        end
// for register bypass between operation3 and
// operation3 for src2
        else if ((postw2re_destpipe3 == r2e_src2pipe3)
            & ~comp_postw2re_dest)
        begin
            int_src1datapipe3 = r2e_src1datapipe3;
            case (d2e_instpipe3)
                4’b0011: // mul
                    int_src2datapipe3 = 64’h00000000ffffffff & postw2re_datapipe3;
                4’b1100: // shift left inst
                    int_src2datapipe3 = 64’h000000000000000f & postw2re_datapipe3;
                4’b1101: // shift right inst
                    int_src2datapipe3 = 64’h000000000000000f & postw2re_datapipe3;
                4’b1110: // barrel shift left inst
                    int_src2datapipe3 = 64’h000000000000000f & postw2re_datapipe3;
                4’b1111: // barrel shift right inst
                    int_src2datapipe3 = 64’h000000000000000f & postw2re_datapipe3;
                default:
                    int_src2datapipe3 = postw2re_datapipe3;
            endcase
        end
        else
        begin
            int_src1datapipe3 = r2e_src1datapipe3;
            int_src2datapipe3 = r2e_src2datapipe3;
        end
    end
end


always @ (posedge clock or posedge reset)
begin
    if (reset)
    begin
        e2w_destpipe1 <= reg0;
        e2w_destpipe2 <= reg0;
        e2w_destpipe3 <= reg0;
        e2w_datapipe1 <= 0;
        e2w_datapipe2 <= 0;
        e2w_datapipe3 <= 0;
        e2w_wrpipe1 <= 0;
        e2w_wrpipe2 <= 0;
        e2w_wrpipe3 <= 0;
        e2w_readpipe1 <= 0;
        e2w_readpipe2 <= 0;
        e2w_readpipe3 <= 0;
        preflush <= 0;
        jump <= 0;
    end
    else // positive edge of clock detected
    begin
    // execute for operation 1 pipe1
        case (d2e_instpipe1)
            nop:
            begin
            // in noop, all default to zero
                e2w_destpipe1 <= reg0;
                e2w_datapipe1 <= 0;
                e2w_wrpipe1 <= 0;
                e2w_readpipe1 <= 0;
            end
            add:
            begin
            // src1 + src2 -> dest
                e2w_destpipe1 <= d2e_destpipe1;
                e2w_datapipe1 <= int_src1datapipe1 + int_src2datapipe1;
                e2w_wrpipe1 <= 1;
                e2w_readpipe1 <= 0;
            end
            sub:
            begin
            // src1 - src2 -> dest
                e2w_destpipe1 <= d2e_destpipe1;
                e2w_datapipe1 <= int_src1datapipe1 - int_src2datapipe1;
                e2w_wrpipe1 <= 1;
                e2w_readpipe1 <= 0;
            end
            mul:
            begin
            // src1 x src2 -> dest
            // only 32 bits considered
                e2w_destpipe1 <= d2e_destpipe1;
                e2w_datapipe1 <= int_src1datapipe1 * int_src2datapipe1;
                e2w_wrpipe1 <= 1;
                e2w_readpipe1 <= 0;
            end
            load:
            begin
            // load data from data bus to dest
                e2w_destpipe1 <= d2e_destpipe1;
                e2w_datapipe1 <= d2e_datapipe1;
                e2w_wrpipe1 <= 1;
                e2w_readpipe1 <= 0;
            end
            move:
            begin
            // move contents from src1 to dest
                e2w_destpipe1 <= d2e_destpipe1;
                e2w_datapipe1 <= int_src1datapipe1;
                e2w_wrpipe1 <= 1;
                e2w_readpipe1 <= 0;
            end
            read:
            begin
            // read data src1 to output
                e2w_destpipe1 <= reg0;
                e2w_datapipe1 <= int_src1datapipe1;
                e2w_wrpipe1 <= 0;
                e2w_readpipe1 <= 1;
            end
            compare:
            begin
            // compare src1, src2, dest
            // results stored in dest
                if (int_src1datapipe1 > int_src2datapipe1)
                    e2w_datapipe1[1] <= 1;
                else
                    e2w_datapipe1[1] <= 0;

                if (int_src1datapipe1 < int_src2datapipe1)
                    e2w_datapipe1[2] <= 1;
                else
                    e2w_datapipe1[2] <= 0;

                if (int_src1datapipe1 <=int_src2datapipe1)
                    e2w_datapipe1[3] <= 1;
                else
                    e2w_datapipe1[3] <= 0;

                if (int_src1datapipe1 >= int_src2datapipe1)
                    e2w_datapipe1[4] <= 1;
                else
                    e2w_datapipe1[4] <= 0;

                    e2w_datapipe1[63:5] <= 0;
                    e2w_datapipe1[0] <= 0;
                    e2w_destpipe1 <= d2e_destpipe1;
                    e2w_wrpipe1 <= 1;
                    e2w_readpipe1 <= 0;
            end
            xorinst:
            begin
            // xorinst src1, src2, dest
                e2w_destpipe1 <= d2e_destpipe1;
                e2w_datapipe1 <= int_src1datapipe ^ int_src2datapipe1;
                e2w_wrpipe1 <= 1;
                e2w_readpipe1 <= 0;
            end
            nandinst:
            begin
            // nandinst src1, src2, dest
                e2w_destpipe1 <= d2e_destpipe1;
                e2w_datapipe1 <=~(int_src1datapipe1 & int_src2datapipe1);
                e2w_wrpipe1 <= 1;
                e2w_readpipe1 <= 0;
            end
            norinst:
            begin
            // norinst src1, src2, dest
                e2w_destpipe1 <= d2e_destpipe1;
                e2w_datapipe1 <=~(int_src1datapipe1 | int_src2datapipe1);
                e2w_wrpipe1 <= 1;
                e2w_readpipe1 <= 0;
            end
            notinst:
            begin
            // notinst src1, dest
                e2w_destpipe1 <= d2e_destpipe1;
                e2w_datapipe1 <=~int_src1datapipe1;
                e2w_wrpipe1 <= 1;
                e2w_readpipe1 <= 0;
            end
            shiftleft:
            begin
            // shiftleft src1, src2, dest
                e2w_destpipe1 <= d2e_destpipe1;
                case (int_src2datapipe1[3:0])
                    4’b0000:
                        e2w_datapipe1 <= int_src1datapipe1;
                    4’b0001:
                        e2w_datapipe1<=(int_src1datapipe1 << 1);
                    4’b0010:
                        e2w_datapipe1<=(int_src1datapipe1 << 2);
                    4’b0011:
                        e2w_datapipe1<=(int_src1datapipe1 << 3);
                    4’b0100:
                        e2w_datapipe1<=(int_src1datapipe1 << 4);
                    4’b0101:
                        e2w_datapipe1<=(int_src1datapipe1 << 5);
                    4’b0110:
                        e2w_datapipe1<=(int_src1datapipe1 << 6);
                    4’b0111:
                        e2w_datapipe1<=(int_src1datapipe1 << 7);
                    4’b1000:
                        e2w_datapipe1<=(int_src1datapipe1 << 8);
                    4’b1001:
                        e2w_datapipe1<=(int_src1datapipe1 << 9);
                    4’b1010:
                        e2w_datapipe1<=(int_src1datapipe1 << 10);
                    4’b1011:
                        e2w_datapipe1<=(int_src1datapipe1 << 11);
                    4’b1100:
                        e2w_datapipe1<=(int_src1datapipe1 << 12);
                    4’b1101:
                        e2w_datapipe1<=(int_src1datapipe1 << 13);
                    4’b1110:
                        e2w_datapipe1<=(int_src1datapipe1 << 14);
                    4’b1111:
                        e2w_datapipe1<=(int_src1datapipe1 << 15);
                    default:
                        e2w_datapipe1<=int_src1datapipe1;
                endcase
                e2w_wrpipe1 <= 1;
                e2w_readpipe1 <= 0;
            end
        shiftright:
        begin
        // shiftright src1, src2, dest
            e2w_destpipe1 <= d2e_destpipe1;
            case (int_src2datapipe1[3:0])
                4’b0000:
                    e2w_datapipe1 <= int_src1datapipe1;
                4’b0001:
                    e2w_datapipe1<=(int_src1datapipe1 >> 1);
                4’b0010:
                    e2w_datapipe1<=(int_src1datapipe1 >> 2);
                4’b0011:
                    e2w_datapipe1<=(int_src1datapipe1 >> 3);
                4’b0100:
                    e2w_datapipe1<=(int_src1datapipe1 >> 4);
                4’b0101:
                    e2w_datapipe1<=(int_src1datapipe1 >> 5);
                4’b0110:
                    e2w_datapipe1<=(int_src1datapipe1 >> 6);
                4’b0111:
                    e2w_datapipe1<=(int_src1datapipe1 >> 7);
                4’b1000:
                    e2w_datapipe1<=(int_src1datapipe1 >> 8);
                4’b1001:
                    e2w_datapipe1<=(int_src1datapipe1 >> 9);
                4’b1010:
                    e2w_datapipe1<=(int_src1datapipe1 >> 10);
                4’b1011:
                    e2w_datapipe1<=(int_src1datapipe1 >> 11);
                4’b1100:
                    e2w_datapipe1<=(int_src1datapipe1 >> 12);
                4’b1101:
                    e2w_datapipe1<=(int_src1datapipe1 >> 13);
                4’b1110:
                    e2w_datapipe1<=(int_src1datapipe1 >> 14);
                4’b1111:
                    e2w_datapipe1<=(int_src1datapipe1 >> 15);
                default:
                    e2w_datapipe1 <= int_src1datapipe1;
            endcase
            e2w_wrpipe1 <= 1;
            e2w_readpipe1 <= 0;
        end
        bshiftleft:
        begin
        // bshiftleft left src1, src2, dest
            e2w_destpipe1 <= d2e_destpipe1;
            case (int_src2datapipe1[3:0])
                4’b0000:
                    e2w_datapipe1 <= int_src1datapipe1;
                4’b0001:
                    e2w_datapipe1<={int_src1datapipe1[62:0],int_src1datapipe1[63]};
                4’b0010:
                    e2w_datapipe1<={int_src1datapipe1[61:0],int_src1datapipe1[63:62]};
                4’b0011:
                    e2w_datapipe1<={int_src1datapipe1[60:0],int_src1datapipe1[63:61]};
                4’b0100:
                    e2w_datapipe1<={int_src1datapipe1[59:0],int_src1datapipe1[63:60]};
                4’b0101:
                    e2w_datapipe1<={int_src1datapipe1[58:0],int_src1datapipe1[63:59]};
                4’b0110:
                    e2w_datapipe1<={int_src1datapipe1[57:0],int_src1datapipe1[63:58]};
                4’b0111:
                    e2w_datapipe1<={int_src1datapipe1[56:0],int_src1datapipe1[63:57]};
                4’b1000:
                    e2w_datapipe1<={int_src1datapipe1[55:0],int_src1datapipe1[63:56]};
                4’b1001:
                    e2w_datapipe1<={int_src1datapipe1[54:0],int_src1datapipe1[63:55]};
                4’b1010:
                    e2w_datapipe1<={int_src1datapipe1[53:0],int_src1datapipe1[63:54]};
                4’b1011:
                    e2w_datapipe1<={int_src1datapipe1[52:0],int_src1datapipe1[63:53]};
                4’b1100:
                    e2w_datapipe1<={int_src1datapipe1[51:0],int_src1datapipe1[63:52]};
                4’b1101:
                    e2w_datapipe1<={int_src1datapipe1[50:0],int_src1datapipe1[63:51]};
                4’b1110:
                    e2w_datapipe1<={int_src1datapipe1[49:0],int_src1datapipe1[63:50]};
                4’b1111:
                    e2w_datapipe1<={int_src1datapipe1[48:0],int_src1datapipe1[63:49]};
                default:
                    e2w_datapipe1 <= int_src1datapipe1;
            endcase
            e2w_wrpipe1 <= 1;
            e2w_readpipe1 <= 0;
        end
        bshiftright:
        begin
        // bshiftright src1, src2, dest
            e2w_destpipe1 <= d2e_destpipe1;
            case (int_src2datapipe1[3:0])
                4’b0000:
                    e2w_datapipe1 <= int_src1datapipe1;
                4’b0001:
                    e2w_datapipe1<={int_src1datapipe1[0],int_src1datapipe1[63:1]};
                4’b0010:
                    e2w_datapipe1 <= {int_src1datapipe1[1:0],int_src1datapipe1[63:2]};
                4’b0011:
                    e2w_datapipe1 <= {int_src1datapipe1[2:0],int_src1datapipe1[63:3]};
                4’b0100:
                    e2w_datapipe1 <= {int_src1datapipe1[3:0],int_src1datapipe1[63:4]};
                4’b0101:
                    e2w_datapipe1 <= {int_src1datapipe1[4:0],int_src1datapipe1[63:5]};
                4’b0110:
                    e2w_datapipe1 <= {int_src1datapipe1[5:0],int_src1datapipe1[63:6]};
                4’b0111:
                    e2w_datapipe1 <= {int_src1datapipe1[6:0],int_src1datapipe1[63:7]};
                4’b1000:
                    e2w_datapipe1 <= {int_src1datapipe1[7:0],int_src1datapipe1[63:8]};
                4’b1001:
                    e2w_datapipe1 <= {int_src1datapipe1[8:0],int_src1datapipe1[63:9]};
                4’b1010:
                    e2w_datapipe1 <= {int_src1datapipe1[9:0],int_src1datapipe1[63:10]};
                4’b1011:
                    e2w_datapipe1 <= {int_src1datapipe1[10:0],int_src1datapipe1[63:11]};
                4’b1100:
                    e2w_datapipe1 <= {int_src1datapipe1[11:0],int_src1datapipe1[63:12]};
                4’b1101:
                    e2w_datapipe1 <= {int_src1datapipe1[12:0],int_src1datapipe1[63:13]};
                4’b1110:
                    e2w_datapipe1 <= {int_src1datapipe1[13:0],int_src1datapipe1[63:14]};
                4’b1111:
                    e2w_datapipe1 <= {int_src1datapipe1[14:0],int_src1datapipe1[63:15]};
                default:
                    e2w_datapipe1 <= int_src1datapipe1;
            endcase
            e2w_wrpipe1 <= 1;
            e2w_readpipe1 <= 0;
        end
        default:
        begin
        // default
            e2w_destpipe1 <= reg0;
            e2w_datapipe1 <= 0;
            e2w_wrpipe1 <= 0;
            e2w_readpipe1 <= 0;
        end
    endcase

    // execute for operation 2 pipe2
    case (d2e_instpipe2)
        nop:
        begin
        // in noop, all default to zero
            e2w_destpipe2 <= reg0;
            e2w_datapipe2 <= 0;
            e2w_wrpipe2 <= 0;
            e2w_readpipe2 <= 0;
        end
        add:
        begin
        // src1 + src2 -> dest
            e2w_destpipe2 <= d2e_destpipe2;
            e2w_datapipe2 <= int_src1datapipe2 + int_src2datapipe2;
            e2w_wrpipe2 <= 1;
            e2w_readpipe2 <= 0;
        end
        sub:
        begin
        // src1 - src2 -> dest
            e2w_destpipe2 <= d2e_destpipe2;
            e2w_datapipe2 <= int_src1datapipe2 - int_src2datapipe2;
            e2w_wrpipe2 <= 1;
            e2w_readpipe2 <= 0;
        end
        mul:
        begin
        // src1 x src2 -> dest
        // only 32 bits considered
            e2w_destpipe2 <= d2e_destpipe2;
            e2w_datapipe2 <= int_src1datapipe2
            * int_src2datapipe2;
            e2w_wrpipe2 <= 1;
            e2w_readpipe2 <= 0;
        end
        load:
        begin
        // load data from data bus to dest
            e2w_destpipe2 <= d2e_destpipe2;
            e2w_datapipe2 <= d2e_datapipe2;
            e2w_wrpipe2 <= 1;
            e2w_readpipe2 <= 0;
        end
        move:
        begin
        // move contents from src1 to dest
            e2w_destpipe2 <= d2e_destpipe2;
            e2w_datapipe2 <= int_src1datapipe2;
            e2w_wrpipe2 <= 1;
            e2w_readpipe2 <= 0;
        end
        read:
        begin
        // read data src1 to output
            e2w_destpipe2 <= reg0;
            e2w_datapipe2 <= int_src1datapipe2;
            e2w_wrpipe2 <= 0;
            e2w_readpipe2 <= 1;
        end
        compare:
        begin
        // compare src1, src2, dest
        // results stored in dest
            if (int_src1datapipe2 > int_src2datapipe2)
                e2w_datapipe2[1] <= 1;
            else
                e2w_datapipe2[1] <= 0;

            if (int_src1datapipe2 < int_src2datapipe2)
                e2w_datapipe2[2] <= 1;
            else
                e2w_datapipe2[2] <= 0;

            if (int_src1datapipe2 <= int_src2datapipe2)
                e2w_datapipe2[3] <= 1;
            else
                e2w_datapipe2[3] <= 0;
            if (int_src1datapipe2 >= int_src2datapipe2)
                e2w_datapipe2[4] <= 1;
            else
                e2w_datapipe2[4] <= 0;
                e2w_datapipe2[63:5] <= 0;
                e2w_datapipe2[0] <= 0;
                e2w_destpipe2 <= d2e_destpipe2;
                e2w_wrpipe2 <= 1;
                e2w_readpipe2 <= 0;
        end
        xorinst:
        begin
        // xorinst src1, src2, dest
            e2w_destpipe2 <= d2e_destpipe2;
            e2w_datapipe2 <= int_src1datapipe2 ^ int_src2datapipe2;
            e2w_wrpipe2 <= 1;
            e2w_readpipe2 <= 0;
        end
        nandinst:
        begin
        // nandinst src1, src2, dest
            e2w_destpipe2 <= d2e_destpipe2;
            e2w_datapipe2 <=~(int_src1datapipe2 & int_src2datapipe2);
            e2w_wrpipe2 <= 1;
            e2w_readpipe2 <= 0;
        end
        norinst:
        begin
        // norinst src1, src2, dest
            e2w_destpipe2 <= d2e_destpipe2;
            e2w_datapipe2 <=~(int_src1datapipe2 | int_src2datapipe2);
            e2w_wrpipe2 <= 1;
            e2w_readpipe2 <= 0;
        end
        notinst:
        begin
        // notinst src1, dest
            e2w_destpipe2 <= d2e_destpipe2;
            e2w_datapipe2 <=~int_src1datapipe2;
            e2w_wrpipe2 <= 1;
            e2w_readpipe2 <= 0;
        end
        shiftleft:
        begin
        // shiftleft src1, src2, dest
            e2w_destpipe2 <= d2e_destpipe2;
            case (int_src2datapipe2[3:0])
                4’b0000:
                    e2w_datapipe2<=int_src1datapipe2;
                4’b0001:
                    e2w_datapipe2<=(int_src1datapipe2 << 1);
                4’b0010:
                    e2w_datapipe2<=(int_src1datapipe2 << 2);
                4’b0011:
                    e2w_datapipe2<=(int_src1datapipe2 << 3);
                4’b0100:
                    e2w_datapipe2<=(int_src1datapipe2 << 4);
                4’b0101:
                    e2w_datapipe2<=(int_src1datapipe2 << 5);
                4’b0110:
                    e2w_datapipe2<=(int_src1datapipe2 << 6);
                4’b0111:
                    e2w_datapipe2<=(int_src1datapipe2 << 7);
                4’b1000:
                    e2w_datapipe2<=(int_src1datapipe2 << 8);
                4’b1001:
                    e2w_datapipe2<=(int_src1datapipe2 << 9);
                4’b1010:
                    e2w_datapipe2<=(int_src1datapipe2 << 10);
                4’b1011:
                    e2w_datapipe2<=(int_src1datapipe2 << 11);
                4’b1100:
                    e2w_datapipe2<=(int_src1datapipe2 << 12);
                4’b1101:
                    e2w_datapipe2<=(int_src1datapipe2 << 13);
                4’b1110:
                    e2w_datapipe2<=(int_src1datapipe2 << 14);
                4’b1111:
                    e2w_datapipe2<=(int_src1datapipe2 << 15);
                default:
                    e2w_datapipe2 <= int_src1datapipe2;
            endcase
            e2w_wrpipe2 <= 1;
            e2w_readpipe2 <= 0;
        end
        shiftright:
        begin
        // shiftright src1, src2, dest
            e2w_destpipe2 <= d2e_destpipe2;
            case (int_src2datapipe2[3:0])
                4’b0000:
                    e2w_datapipe2 <= int_src1datapipe2;
                4’b0001:
                    e2w_datapipe2<=(int_src1datapipe2 >> 1);
                4’b0010:
                    e2w_datapipe2<=(int_src1datapipe2 >> 2);
                4’b0011:
                    e2w_datapipe2<=(int_src1datapipe2 >> 3);
                4’b0100:
                    e2w_datapipe2<=(int_src1datapipe2 >> 4);
                4’b0101:
                    e2w_datapipe2<=(int_src1datapipe2 >> 5);
                4’b0110:
                    e2w_datapipe2<=(int_src1datapipe2 >> 6);
                4’b0111:
                    e2w_datapipe2<=(int_src1datapipe2 >> 7);
                4’b1000:
                    e2w_datapipe2<=(int_src1datapipe2 >> 8);
                4’b1001:
                    e2w_datapipe2<=(int_src1datapipe2 >> 9);
                4’b1010:
                    e2w_datapipe2<=(int_src1datapipe2 >> 10);
                4’b1011:
                    e2w_datapipe2<=(int_src1datapipe2 >> 11);
                4’b1100:
                    e2w_datapipe2<=(int_src1datapipe2 >> 12);
                4’b1101:
                    e2w_datapipe2<=(int_src1datapipe2 >> 13);
                4’b1110:
                    e2w_datapipe2<=(int_src1datapipe2 >> 14);
                4’b1111:
                    e2w_datapipe2<=(int_src1datapipe2 >> 15);
                default:
                    e2w_datapipe2 <= int_src1datapipe2;
            endcase
            e2w_wrpipe2 <= 1;
            e2w_readpipe2 <= 0;
        end
        bshiftleft:
        begin
        // bshiftleft left src1, src2, dest
            e2w_destpipe2 <= d2e_destpipe2;
            case (int_src2datapipe2[3:0])
                4’b0000:
                    e2w_datapipe2 <= int_src1datapipe2;
                4’b0001:
                    e2w_datapipe2 <= {int_src1datapipe2[62:0],int_src1datapipe2[63]};
                4’b0010:
                    e2w_datapipe2 <= {int_src1datapipe2[61:0],int_src1datapipe2[63:62]};
                4’b0011:
                    e2w_datapipe2 <= {int_src1datapipe2[60:0],int_src1datapipe2[63:61]};
                4’b0100:
                    e2w_datapipe2 <= {int_src1datapipe2[59:0],int_src1datapipe2[63:60]};
                4’b0101:
                    e2w_datapipe2 <= {int_src1datapipe2[58:0],int_src1datapipe2[63:59]};
                4’b0110:
                    e2w_datapipe2 <= {int_src1datapipe2[57:0],int_src1datapipe2[63:58]};
                4’b0111:
                    e2w_datapipe2 <= {int_src1datapipe2[56:0],int_src1datapipe2[63:57]};
                4’b1000:
                    e2w_datapipe2 <= {int_src1datapipe2[55:0],int_src1datapipe2[63:56]};
                4’b1001:
                    e2w_datapipe2 <= {int_src1datapipe2[54:0],int_src1datapipe2[63:55]};
                4’b1010:
                    e2w_datapipe2 <= {int_src1datapipe2[53:0],int_src1datapipe2[63:54]};
                4’b1011:
                    e2w_datapipe2 <= {int_src1datapipe2[52:0],int_src1datapipe2[63:53]};
                4’b1100:
                    e2w_datapipe2 <= {int_src1datapipe2[51:0],int_src1datapipe2[63:52]};
                4’b1101:
                    e2w_datapipe2 <= {int_src1datapipe2[50:0],int_src1datapipe2[63:51]};
                4’b1110:
                    e2w_datapipe2 <= {int_src1datapipe2[49:0],int_src1datapipe2[63:50]};
                4’b1111:
                    e2w_datapipe2 <= {int_src1datapipe2[48:0],int_src1datapipe2[63:49]};
                default:
                    e2w_datapipe2 <= int_src1datapipe2;
            endcase
            e2w_wrpipe2 <= 1;
            e2w_readpipe2 <= 0;
        end
        bshiftright:
        begin
        // bshiftright src1, src2, dest
            e2w_destpipe2 <= d2e_destpipe2;
            case (int_src2datapipe2[3:0])
                4’b0000:
                    e2w_datapipe2 <= int_src1datapipe2;
                4’b0001:
                    e2w_datapipe2 <= {int_src1datapipe2[0],int_src1datapipe2[63:1]};
                4’b0010:
                    e2w_datapipe2 <= {int_src1datapipe2[1:0],int_src1datapipe2[63:2]};
                4’b0011:
                    e2w_datapipe2 <= {int_src1datapipe2[2:0],int_src1datapipe2[63:3]};
                4’b0100:
                    e2w_datapipe2 <= {int_src1datapipe2[3:0],int_src1datapipe2[63:4]};
                4’b0101:
                    e2w_datapipe2 <= {int_src1datapipe2[4:0],int_src1datapipe2[63:5]};
                4’b0110:
                    e2w_datapipe2 <= {int_src1datapipe2[5:0],int_src1datapipe2[63:6]};
                4’b0111:
                    e2w_datapipe2 <= {int_src1datapipe2[6:0],int_src1datapipe2[63:7]};
                4’b1000:
                    e2w_datapipe2 <= {int_src1datapipe2[7:0],int_src1datapipe2[63:8]};
                4’b1001:
                    e2w_datapipe2 <= {int_src1datapipe2[8:0],int_src1datapipe2[63:9]};
                4’b1010:
                    e2w_datapipe2 <= {int_src1datapipe2[9:0],int_src1datapipe2[63:10]};
                4’b1011:
                    e2w_datapipe2 <= {int_src1datapipe2[10:0],int_src1datapipe2[63:11]};
                4’b1100:
                    e2w_datapipe2 <= {int_src1datapipe2[11:0],int_src1datapipe2[63:12]};
                4’b1101:
                    e2w_datapipe2 <= {int_src1datapipe2[12:0],int_src1datapipe2[63:13]};
                4’b1110:
                    e2w_datapipe2 <= {int_src1datapipe2[13:0],int_src1datapipe2[63:14]};
                4’b1111:
                    e2w_datapipe2 <= {int_src1datapipe2[14:0],int_src1datapipe2[63:15]};
                default:
                    e2w_datapipe2 <= int_src1datapipe2;
            endcase
            e2w_wrpipe2 <= 1;
            e2w_readpipe2 <= 0;
        end
        default:
        begin
        // default
            e2w_destpipe2 <= reg0;
            e2w_datapipe2 <= 0;
            e2w_wrpipe2 <= 0;
            e2w_readpipe2 <= 0;
        end
    endcase


    // execute for operation 3 pipe3
    case (d2e_instpipe3)
        nop:
        begin
        // in noop, all default to zero
            e2w_destpipe3 <= reg0;
            e2w_datapipe3 <= 0;
            e2w_wrpipe3 <= 0;
            e2w_readpipe3 <= 0;
        end
        add:
        begin
        // src1 + src2 -> dest
            e2w_destpipe3 <= d2e_destpipe3;
            e2w_datapipe3 <= int_src1datapipe3 + int_src2datapipe3;
            e2w_wrpipe3 <= 1;
            e2w_readpipe3 <= 0;
        end
        sub:
        begin
        // src1 - src2 -> dest
        // if borrow occurs, it is ignored
            e2w_destpipe3 <= d2e_destpipe3;
            e2w_datapipe3 <= int_src1datapipe3 - int_src2datapipe3;
            e2w_wrpipe3 <= 1;
            e2w_readpipe3 <= 0;
        end
        mul:
        begin
        // src1 x src2 -> dest
        // only 32 bits considered
            e2w_destpipe3 <= d2e_destpipe3;
            e2w_datapipe3 <= int_src1datapipe3 * int_src2datapipe3;
            e2w_wrpipe3 <= 1;
            e2w_readpipe3 <= 0;
        end
        load:
        begin
        // load data from data bus to dest
            e2w_destpipe3 <= d2e_destpipe3;
            e2w_datapipe3 <= d2e_datapipe3;
            e2w_wrpipe3 <= 1;
            e2w_readpipe3 <= 0;
        end
        move:
        begin
        // move contents from src1 to dest
            e2w_destpipe3 <= d2e_destpipe3;
            e2w_datapipe3 <= int_src1datapipe3;
            e2w_wrpipe3 <= 1;
            e2w_readpipe3 <= 0;
        end
        read:
        begin
        // read data src1 to output
            e2w_destpipe3 <= reg0;
            e2w_datapipe3 <= int_src1datapipe3;
            e2w_wrpipe3 <= 0;
            e2w_readpipe3 <= 1;
        end
        compare:
        begin
        // compare src1, src2, dest
        // results stored in dest
            if (int_src1datapipe3 > int_src2datapipe3)
                e2w_datapipe3[1] <= 1;
            else
                e2w_datapipe3[1] <= 0;

            if (int_src1datapipe3 < int_src2datapipe3)
                e2w_datapipe3[2] <= 1;
            else
                e2w_datapipe3[2] <= 0;

            if (int_src1datapipe3 <= int_src2datapipe3)
                e2w_datapipe3[3] <= 1;
            else
                e2w_datapipe3[3] <= 0;

            if (int_src1datapipe3 >= int_src2datapipe3)
                e2w_datapipe3[4] <= 1;
            else
                e2w_datapipe3[4] <= 0;
                e2w_datapipe3[63:5] <= 0;
                e2w_datapipe3[0] <= 0;
                e2w_destpipe3 <= d2e_destpipe3;
                e2w_wrpipe3 <= 1;
                e2w_readpipe3 <= 0;
        end
        xorinst:
        begin
        // xorinst src1, src2, dest
            e2w_destpipe3 <= d2e_destpipe3;
            e2w_datapipe3 <= int_src1datapipe3 ^ int_src2datapipe3;
            e2w_wrpipe3 <= 1;
            e2w_readpipe3 <= 0;
        end
        nandinst:
        begin
        // nandinst src1, src2, dest
            e2w_destpipe3 <= d2e_destpipe3;
            e2w_datapipe3 <=~(int_src1datapipe3 & int_src2datapipe3);
            e2w_wrpipe3 <= 1;
            e2w_readpipe3 <= 0;
        end
        norinst:
        begin
        // norinst src1, src2, dest
            e2w_destpipe3 <= d2e_destpipe3;
            e2w_datapipe3 <=~(int_src1datapipe3 | int_src2datapipe3);
            e2w_wrpipe3 <= 1;
            e2w_readpipe3 <= 0;
        end
        notinst:
        begin
        // notinst src1, dest
            e2w_destpipe3 <= d2e_destpipe3;
            e2w_datapipe3 <=~int_src1datapipe3;
            e2w_wrpipe3 <= 1;
            e2w_readpipe3 <= 0;
        end
        shiftleft:
        begin
        // shiftleft src1, src2, dest
            e2w_destpipe3 <= d2e_destpipe3;
            case (int_src2datapipe3[3:0])
                4’b0000:
                    e2w_datapipe3 <= int_src1datapipe3;
                4’b0001:
                    e2w_datapipe3 <=(int_src1datapipe3 << 1);
                4’b0010:
                    e2w_datapipe3 <=(int_src1datapipe3 << 2);
                4’b0011:
                    e2w_datapipe3 <=(int_src1datapipe3 << 3);
                4’b0100:
                    e2w_datapipe3 <=(int_src1datapipe3 << 4);
                4’b0101:
                    e2w_datapipe3 <=(int_src1datapipe3 << 5);
                4’b0110:
                    e2w_datapipe3 <=(int_src1datapipe3 << 6);
                4’b0111:
                    e2w_datapipe3 <=(int_src1datapipe3 << 7);
                4’b1000:
                    e2w_datapipe3 <=(int_src1datapipe3 << 8);
                4’b1001:
                    e2w_datapipe3 <=(int_src1datapipe3 << 9);
                4’b1010:
                    e2w_datapipe3<=(int_src1datapipe3 << 10);
                4’b1011:
                    e2w_datapipe3<=(int_src1datapipe3 << 11);
                4’b1100:
                    e2w_datapipe3<=(int_src1datapipe3 << 12);
                4’b1101:
                    e2w_datapipe3<=(int_src1datapipe3 << 13);
                4’b1110:
                    e2w_datapipe3<=(int_src1datapipe3 << 14);
                4’b1111:
                    e2w_datapipe3<=(int_src1datapipe3 << 15);
                default:
                    e2w_datapipe3 <= int_src1datapipe3;
            endcase
            e2w_wrpipe3 <= 1;
            e2w_readpipe3 <= 0;
        end
        shiftright:
        begin
        // shiftright src1, src2, dest
            e2w_destpipe3 <= d2e_destpipe3;
            case (int_src2datapipe3[3:0])
                4’b0000:
                    e2w_datapipe3 <= int_src1datapipe3;
                4’b0001:
                    e2w_datapipe3 <=(int_src1datapipe3 >> 1);
                4’b0010:
                    e2w_datapipe3 <=(int_src1datapipe3 >> 2);
                4’b0011:
                    e2w_datapipe3 <=(int_src1datapipe3 >> 3);
                4’b0100:
                    e2w_datapipe3 <=(int_src1datapipe3 >> 4);
                4’b0101:
                    e2w_datapipe3 <=(int_src1datapipe3 >> 5);
                4’b0110:
                    e2w_datapipe3 <=(int_src1datapipe3 >> 6);
                4’b0111:
                    e2w_datapipe3 <=(int_src1datapipe3 >> 7);
                4’b1000:
                    e2w_datapipe3 <=(int_src1datapipe3 >> 8);
                4’b1001:
                    e2w_datapipe3 <=(int_src1datapipe3 >> 9);
                4’b1010:
                    e2w_datapipe3<=(int_src1datapipe3 >> 10);
                4’b1011:
                    e2w_datapipe3<=(int_src1datapipe3 >> 11);
                4’b1100:
                    e2w_datapipe3<=(int_src1datapipe3 >> 12);
                4’b1101:
                    e2w_datapipe3<=(int_src1datapipe3 >> 13);
                4’b1110:
                    e2w_datapipe3<=(int_src1datapipe3 >> 14);
                4’b1111:
                    e2w_datapipe3<=(int_src1datapipe3 >> 15);
                default:
                    e2w_datapipe3 <= int_src1datapipe3;
            endcase
            e2w_wrpipe3 <= 1;
            e2w_readpipe3 <= 0;
        end
        bshiftleft:
        begin
        // bshiftleft left src1, src2, dest
            e2w_destpipe3 <= d2e_destpipe3;
            case (int_src2datapipe3[3:0])
                4’b0000:
                    e2w_datapipe3 <= int_src1datapipe3;
                4’b0001:
                    e2w_datapipe3 <= {int_src1datapipe3[62:0],int_src1datapipe3[63]};
                4’b0010:
                    e2w_datapipe3 <= {int_src1datapipe3[61:0],int_src1datapipe3[63:62]};
                4’b0011:
                    e2w_datapipe3 <= {int_src1datapipe3[60:0],int_src1datapipe3[63:61]};
                4’b0100:
                    e2w_datapipe3 <= {int_src1datapipe3[59:0],int_src1datapipe3[63:60]};
                4’b0101:
                    e2w_datapipe3 <= {int_src1datapipe3[58:0],int_src1datapipe3[63:59]};
                4’b0110:
                    e2w_datapipe3 <= {int_src1datapipe3[57:0],int_src1datapipe3[63:58]};
                4’b0111:
                    e2w_datapipe3 <= {int_src1datapipe3[56:0],int_src1datapipe3[63:57]};
                4’b1000:
                    e2w_datapipe3 <= {int_src1datapipe3[55:0],int_src1datapipe3[63:56]};
                4’b1001:
                    e2w_datapipe3 <= {int_src1datapipe3[54:0],int_src1datapipe3[63:55]};
                4’b1010:
                    e2w_datapipe3 <= {int_src1datapipe3[53:0],int_src1datapipe3[63:54]};
                4’b1011:
                    e2w_datapipe3 <= {int_src1datapipe3[52:0],int_src1datapipe3[63:53]};
                4’b1100:
                    e2w_datapipe3 <= {int_src1datapipe3[51:0],int_src1datapipe3[63:52]};
                4’b1101:
                    e2w_datapipe3 <= {int_src1datapipe3[50:0],int_src1datapipe3[63:51]};
                4’b1110:
                    e2w_datapipe3 <= {int_src1datapipe3[49:0],int_src1datapipe3[63:50]};
                4’b1111:
                    e2w_datapipe3 <= {int_src1datapipe3[48:0],int_src1datapipe3[63:49]};
                default:
                    e2w_datapipe3 <= int_src1datapipe3;
            endcase
            e2w_wrpipe3 <= 1;
            e2w_readpipe3 <= 0;
        end
        bshiftright:
        begin
        // bshiftright src1, src2, dest
            e2w_destpipe3 <= d2e_destpipe3;
            case (int_src2datapipe3[3:0])
                4’b0000:
                    e2w_datapipe3 <= int_src1datapipe3;
                4’b0001:
                    e2w_datapipe3 <= {int_src1datapipe3[0],int_src1datapipe3[63:1]};
                4’b0010:
                    e2w_datapipe3 <= {int_src1datapipe3[1:0],int_src1datapipe3[63:2]};
                4’b0011:
                    e2w_datapipe3 <= {int_src1datapipe3[2:0],int_src1datapipe3[63:3]};
                4’b0100:
                    e2w_datapipe3 <= {int_src1datapipe3[3:0],int_src1datapipe3[63:4]};
                4’b0101:
                    e2w_datapipe3 <= {int_src1datapipe3[4:0],int_src1datapipe3[63:5]};
                4’b0110:
                    e2w_datapipe3 <= {int_src1datapipe3[5:0],int_src1datapipe3[63:6]};
                4’b0111:
                    e2w_datapipe3 <= {int_src1datapipe3[6:0],int_src1datapipe3[63:7]};
                4’b1000:
                    e2w_datapipe3 <= {int_src1datapipe3[7:0],int_src1datapipe3[63:8]};
                4’b1001:
                    e2w_datapipe3 <= {int_src1datapipe3[8:0],int_src1datapipe3[63:9]};
                4’b1010:
                    e2w_datapipe3 <= {int_src1datapipe3[9:0],int_src1datapipe3[63:10]};
                4’b1011:
                    e2w_datapipe3 <= {int_src1datapipe3[10:0],int_src1datapipe3[63:11]};
                4’b1100:
                    e2w_datapipe3 <= {int_src1datapipe3[11:0],int_src1datapipe3[63:12]};
                4’b1101:
                    e2w_datapipe3 <= {int_src1datapipe3[12:0],int_src1datapipe3[63:13]};
                4’b1110:
                    e2w_datapipe3 <= {int_src1datapipe3 [13:0],int_src1datapipe3[63:14]};
                4’b1111:
                    e2w_datapipe3 <= {int_src1datapipe3[14:0],int_src1datapipe3[63:15]};
                default:
                    e2w_datapipe3 <= int_src1datapipe3;
            endcase
            e2w_wrpipe3 <= 1;
            e2w_readpipe3 <= 0;
        end
        default:
        begin
        // default
            e2w_destpipe3 <= reg0;
            e2w_datapipe3 <= 0;
            e2w_wrpipe3 <= 0;
            e2w_readpipe3 <= 0;
        end
    endcase


    if (((d2e_instpipe3 == compare) & (int_src1datapipe3
        == int_src2datapipe3)) | ((d2e_instpipe2 == compare)
        & (int_src1datapipe2 == int_src2datapipe2)) |
        ((d2e_instpipe1 == compare) & (int_src1datapipe1 ==
        int_src2datapipe1)))
    begin
        preflush <= 1;
        jump <= 1;
    end
    else
    begin
        preflush <= 0;
        jump <= 0;
    end
    end
end
// flush needs to be delayed 1 clock cycle to ensure adequate time for
// writeback to write the necessary data into registers in register file
always @ (posedge clock or posedge reset)
begin
    if (reset)
    begin
        flush <= 0;
    end
    else
    begin
        flush <= preflush;
    end
end
endmodule
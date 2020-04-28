`define MLOFS 6'o00

module conv_top
(
  input                      clk  ,
  input  [dataWidth - 1 : 0] dataI,
  output [          511 : 0] dataO
)
#(
  parameter
    dataWidth = 1024
 );

  genvar idx;
  generate
    for (idx = 0; idx < 1024 / 32; idx = idx + 1)
    begin splitter
      accum acc(.clk(clk), .a(dataI[64 * idx + 31 : 64 * idx]), .b(dataI[64 * idx + 63 : 64 * idx + 32]), .o(dataO[32 * idx + 31 : 32 * idx]));
    end
  endgenerate

endmodule

module accum
(
  input               clk,
  input      [31 : 0] a  ,
                      b  ,
  output reg [31 : 0] o
);

  wire          negligible, underflow, overflow;
  wire [ 4 : 0] eorAbs0, eorAbs, zpc;
  wire [ 7 : 0] ea, eb, eo, er, eoInv;
  wire [ 8 : 0] er0, eorDiff;
  wire [23 : 0] mo, mr, shiftmo, shiftmr;
  wire [25 : 0] shiftmo0, shiftmr0, signmo, signmr, mor0;
  wire [24 : 0] mor;
  wire [ 8 : 0] eoFin;
  wire [47 : 0] r;

  assign
    ea         = a[30 : 23]                       ,
    eb         = b[30 : 23]                       ,
    eo         = o[30 : 23]                       ,
    er0        = a + b                            ,
    underflow  = ea[7] ^ eb[7]                    ,
    overflow   = ~er0[8] & er0[7] & ~underflow    ,
    er         = ~er0[7] & er0[8] & ~underflow
               ? 8'h00
               : er0[7 : 0]                       ,
    eoInv      = ~eo + 1'b1                       ,
    eorDiff    = eoInv + er                       ,
    negligible = eorDiff[8]
               ? &eorDiff[7 : 5] & |eorDiff[4 : 3]
               : |eorDiff[7 : 5] | &eorDiff[4 : 3],
    mo         = {1'b1, o[22 : 0]}                ,
    mr         = {1'b1, r[22 : 0]}                ,
    shiftmo    = eorDiff[8]
               ? mo
               : mo >> eorAbs0                    ,
    shiftmr    = eorDiff[8]
               ? mr >> eorAbs
               : mr                               ,
    shiftmo0   = {2'b00, shiftmo}                 ,
    shiftmr0   = {2'b00, shiftmr}                 ,
    signmo     = o[31]
               ? ~shiftmo0 + 1'b1
               : shiftmo0                         ,
    signmr     = r[31]
               ? ~shiftmr0 + 1'b1
               : shiftmr0                         ,
    mor0       = signmo + signmr                  ,
    mor        = mor0[25]
               ? ~mor0 + 1'b1
               : mor0                             ,
    eoFin      = mor[24]
               ? er0 - 1'b1
               : er0 + zpc /*zpc[4].cnt[24]*/     ;

/*
//  1st variant     :
  wire [24 : 0] morZeros;

  genvar idx, idx1, idx2;
  generate
    for (idx = 0; idx < 23; idx = idx + 1)
    begin : zpc
      if (idx)
        assign morZeros[idx] = morZeros[idx - 1] & ~mor[23 - idx];
      else
        assign morZeros[idx] = ~mor[23 - idx];
    end

    for (idx1 = 0; idx1 < 5; idx1 = idx1 + 1)
    begin : zpc_1
      if (idx1 < 4)
        wire [(1 << idx1) - 1 : 0] cnt [(1 << idx1 + 1) - (1 << idx1)];
      else
        wire [(1 << idx1) - 1 : 0] cnt [24 - (1 << idx1)];
      if (idx1)
        for (idx2 = 1 << idx1; (idx2 < (1 << idx1 + 1)) | (idx2 < 24); idx2 = idx2 + 1)
        begin : zpc_2  //  can i skip this, if there are no any definition inside?
          if (idx2 > 1 << idx1)
            assign zpc_1[idx1].cnt[idx2 - (1 << idx1)] = morZeros[idx2] + zpc_1[idx1].cnt[idx2 - 1];
          else
            assign zpc_1[idx1].cnt[idx2 - (1 << idx1)] = morZeros[idx2] + zpc_1[idx1 -1].cnt[(1 << idx1 + 1) - (1 << idx1) - 1];
        end
      else
      assign zpc_1[idx1].cnt[0] = morZeros[idx1];
    end
  endgenerate
//  1st variant end ^
*/

//  2nd variant
  genvar idxA, idxB;
  generate
    for (idxA = 0; idxA < 25; idxA = idxA + 1)
    begin : zpc_lc
      for (idxB = 1 << idxA; idxB < 1 << idxA + 1; idxB = idxB + 1)
      begin : zpc_lut
        if (mor < idxB)
          assign zpc = 24 - idxA;
      end
    end
  endgenerate
//  2nd variand end ^

  mult multInst ({1'b1, a[22 : 0]}, {1'b1, b[22 : 0]}, r);

  always @(posedge clk)
  begin
    o[22 : 0]  <= mor[24]
                ? mor[24 : 1]
                : mor[22 : 0] << zpc,
    o[30 : 23] <= eoFin,
    o[31]      <= mor0[25];
  end

endmodule

module mult
(
  input  [23 : 0] a,
                  b,
  output [47 : 0] o
);

  wire [71 : 0] r;

  assign o = r[59 : 12];

  lpm_mult LPMmult
  (
    .result (r)                ,
    .dataa  ({MLOFS, a, MLOFS}),
    .datab  ({MLOFS, b, MLOFS})
  )
  #(
    .lpm_widtha         (36)        ,
    .lpm_widthb         (36)        ,
    .lpm_widthp         (72)        ,
    .lpm_widths         (72)        ,
    .lpm_representation ("UNSIGNED"),
    .lpm_pipeline       ( 0)        ,
    .lpm_hint
    ("\
      INPUT_A_IS_CONSTANT                           = NO        ,\
      INPUT_B_IS_CONSTANT                           = NO        ,\
      USE_EAB                                       = NO        ,\
      MAXIMIZE_SPEED                                = 10        ,\
      DEDICATED_MULTIPLIER_CIRCUITRY                = YES       ,\
      DSP_BLOCK_BALANCING                           = DSP BLOCKS,\
      LOGIC_ELEMENTS                                = OFF       ,\
      DEDICATED_MULTIPLIER_MIN_INPUT_WIDTH_FOR_AUTO = 24         \
    ")
   );

endmodule

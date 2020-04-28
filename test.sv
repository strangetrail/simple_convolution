`define readWaitMode  2'b00
`define readMode      2'b01
`define writeWaitMode 2'b10
`define writeMode     2'b11

module test
(
  input                 clk,
                        reset_n,
                        read_n_in,
                        write_n_in,
//                      byteenable_in,
                        address_in,
                        waitrequest_n,
  input      [  31 : 0] writedata_in,
  input      [1023 : 0] readdata_in,
  output reg            read_n_out,
                        write_n_out,
  output reg [  31 : 0] address_out,
  output reg [1023 : 0] writedata_out,
  output reg [  31 : 0] readdata_out
);

  wire            reset                     = ~reset_n                                               ,
                  clkHB                     = |ioaddr[0] & |ioaddr[1] & ~&ioaddr[0] & ~&ioaddr[1]    ,
                  complexReset              = dataOffset[1] & ~dataOffset[0] & clkHB & &mode | reset ;
  wire [  31 : 0] resetArray        [0 : 1]                                                          ,
                  resetArray_n      [0 : 1]                                                          ;
  reg  [   1 : 0] dataOffset                                                                         ;
  reg  [   2 : 0] mode                                                                               ;
  reg  [  31 : 0] ioaddr            [0 : 1]                                                          ;
  reg  [  31 : 0] currentCell                                                                        ;
  reg  [1023 : 0] data              [0 : 3]                                                          ;

/*
  wire [ 511 : 0] dataO;
  wire [1023 : 0] dataI;
  conv_top convolution(.clk(clk), .dataI(dataI), .dataO(dataO));
*/

  genvar idx;
  generate
    for (idx = 0; idx < 2; idx = idx + 1)
    begin : reset_array
      assign resetArray[idx] = {4{8'h00}};
      assign resetArray_n[idx] = {4{8'hff}};
    end
  endgenerate

  initial
  begin
    read_n_out <= 1'b1;
    write_n_out <= 1'b1;
    ioaddr <= resetArray;
    currentCell <= 32'h0;
    dataOffset <= 2'b00;
    mode <= 2'b00;
  end

  always @(posedge clk or posedge complexReset)
  begin
    if (complexReset)
      ioaddr <= resetArray;
    else
      if (~write_n_in)
        ioaddr[address_in] <= writedata_in;
      else
        if (~read_n_in)
          readdata_out <= ioaddr[address_in];
  end

/*
  clkHB    __---__---__---__---__---__---__
  clkHBd   __-----_____-----_____-----_____
*/

  always @(posedge clk)
  begin
    if (clkHB)
    begin
      if (~|currentCell)
        currentCell <= ioaddr[0];
      case (mode)
      2'b00:
      begin
        address_out <= currentCell;
        read_n_out <= 1'b0;
        mode <= 2'b01;
      end
      2'b01:
      begin
        if (waitrequest_n)
        begin
          data[dataOffset] <= readdata_in;
/*
          dataI <= readdata_in;
*/
          dataOffset = dataOffset + 1;
          if (~|dataOffset)
          begin
            currentCell <= 32'h0;
            mode <= 2'b10;
          end
          else
          begin
            currentCell <= currentCell + 1024;
            mode <= 2'b00;
          end
          read_n_out <= 1'b1;
        end
      end
      2'b10:
      begin
        address_out <= currentCell;
        write_n_out <= 1'b0;
        mode <= 2'b11;
      end
      2'b11:
      begin
        if (waitrequest_n)
        begin
          writedata_out <= data[dataOffset] & {32{32'h96969696}};
/*
          writedata_out <= {128{4'h0}, dataO};
*/
          dataOffset = dataOffset + 1;
          if (~|dataOffset)
          begin
            currentCell <= 32'h0;
            mode <= 2'b00;
          end
          else
          begin
            currentCell <= currentCell + 1024;
            mode <= 2'b10;
          end
          write_n_out <= 1'b1;
        end
      end
      endcase
    end
  end

endmodule

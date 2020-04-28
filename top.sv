module top
(
  input           clock_source,
  input           global_reset_n,
  inout  [15 : 0] mem_dq,
  inout  [ 1 : 0] mem_dqs,
  inout  [ 0 : 0] mem_clk,
                  mem_clk_n,
  output [12 : 0] mem_addr,
  output [ 1 : 0] mem_ba,
                  mem_dm,
  output [ 0 : 0] mem_cas_n,
                  mem_cke,
                  mem_cs_n,
                  mem_ras_n,
                  mem_we_n
/*
  input         clock_source,
                reset_n,
  inout  [ 1:0] ddr_dqs,
  inout  [15:0] ddr_dq,
  output        ddr_ras_n,
                ddr_cas_n,
                ddr_we_n,
  output [ 0:0] clk_to_sdram,
                clk_to_sdram_n,
                ddr_cs_n,
                ddr_cke,
  output [ 1:0] ddr_ba,
                ddr_dm,
  output [12:0] ddr_a
*/
);

/*
  wire       stratix_dll_control,
             dqsupdate,
             write_clk,
             dedicated_resynch_or_capture_clk,
             dedicated_postamble_clk,
             pll_reset,
             pll_locked,
             clk_source;
  wire [5:0] dqs_delay_ctrl;
  reg        soft_reset_reg_n,
             soft_reset_reg2_n;

  assign pll_reset = !reset_n;
*/

  testSystemQSYS tsInst0
  (
/*
    .clk_0                                                      (clk_source),
    .clk_to_sdram_from_the_ddr_sdram_component_classic_0        (clk_to_sdram[0]),
    .clk_to_sdram_n_from_the_ddr_sdram_component_classic_0      (clk_to_sdram_n[0]),
    .ddr_a_from_the_ddr_sdram_component_classic_0               (ddr_a),
    .ddr_ba_from_the_ddr_sdram_component_classic_0              (ddr_ba),
    .ddr_cas_n_from_the_ddr_sdram_component_classic_0           (ddr_cas_n),
    .ddr_cke_from_the_ddr_sdram_component_classic_0             (ddr_cke[0]),
    .ddr_cs_n_from_the_ddr_sdram_component_classic_0            (ddr_cs_n[0]),
    .ddr_dm_from_the_ddr_sdram_component_classic_0              (ddr_dm),
    .ddr_dq_to_and_from_the_ddr_sdram_component_classic_0       (ddr_dq),
    .ddr_dqs_to_and_from_the_ddr_sdram_component_classic_0      (ddr_dqs),
    .ddr_ras_n_from_the_ddr_sdram_component_classic_0           (ddr_ras_n),
    .ddr_we_n_from_the_ddr_sdram_component_classic_0            (ddr_we_n),
    .reset_n                                                    (soft_reset_reg2_n),
    .dqsupdate_to_the_ddr_sdram_component_classic_0             (dqsupdate),
    .dqs_delay_ctrl_to_the_ddr_sdram_component_classic_0        (dqs_delay_ctrl),
    .stratix_dll_control_from_the_ddr_sdram_component_classic_0 (stratix_dll_control),
    .write_clk_to_the_ddr_sdram_component_classic_0             (write_clk)
*/
    .clk_clk       (clock_source),
    .reset_reset_n (global_reset_n),
    .altmemddr_0_soft_reset_n_reset_n (1'b1),
    .altmemddr_0_memory_mem_clk (mem_clk),
    .altmemddr_0_memory_mem_clk_n (mem_clk_n),
    .altmemddr_0_memory_mem_cs_n (mem_cs_n),
    .altmemddr_0_memory_mem_cke (mem_cke),
    .altmemddr_0_memory_mem_addr (mem_addr),
    .altmemddr_0_memory_mem_ba (mem_ba),
    .altmemddr_0_memory_mem_ras_n (mem_ras_n),
    .altmemddr_0_memory_mem_cas_n (mem_cas_n),
    .altmemddr_0_memory_mem_we_n (mem_we_n),
    .altmemddr_0_memory_mem_dq (mem_dq),
    .altmemddr_0_memory_mem_dqs (mem_dqs),
    .altmemddr_0_memory_mem_dm (mem_dm)
  );

/*
  ddr_pll_stratixii stratixII_PLL
  (
    .areset (pll_reset),
    .c0     (clk_source),
    .c1     (write_clk),
    .c2     (dedicated_resynch_or_capture_clk),
    .c3     (dedicated_postamble_clk),
    .inclk0 (clock_source),
    .locked (pll_locked)
  );

  ddr_sdram_component_classic_0_auk_ddr_dll auk_DLL
  (
    .addnsub (1'b0),
    .offset (6'b000000),
    .reset_n(soft_reset_reg2_n),
    .clk(clk_source),
    .delayctrlout(dqs_delay_ctrl),
    .dqsupdate(dqsupdate),
    .stratix_dll_control(stratix_dll_control)
  );

  always @(posedge clk_source or negedge pll_locked)
  begin
    if (~pll_locked)
    begin
      soft_reset_reg_n  <= 1'b0;
      soft_reset_reg2_n <= 1'b0;
    end
    else
    begin
      soft_reset_reg_n  <= 1'b1;
      soft_reset_reg2_n <= soft_reset_reg_n;
    end
  end
*/

endmodule

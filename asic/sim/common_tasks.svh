// =============================================================================
// Common Test Tasks for RISC-V CPU Testbench
// =============================================================================

task automatic display_pass();
begin
    $display("\n");
    $display("PPPP   AAA  SSSS  SSSS");
    $display("P   P A   A S     S   ");
    $display("PPPP  AAAAA  SSS   SSS");
    $display("P     A   A     S     S");
    $display("P     A   A SSSS  SSSS");
    $display("\n===================== TEST PASSED =====================\n");
end
endtask

task automatic display_fail();
begin
    $display("\n");
    $display("FFFF   AAA  III  L     ");
    $display("F     A   A  I   L     ");
    $display("FFFF  AAAAA  I   L     ");
    $display("F     A   A  I   L     ");
    $display("F     A   A III  LLLLL ");
    $display("\n===================== TEST FAILED ====================\n");
end
endtask



read_file -type verilog {flist.v}
set_option top alu
current_goal Design_Read -top alu
current_goal lint/lint_rtl -top alu
run_goal
capture ./spyglass-1/alu/lint/lint_rtl/spyglass_reports/spyglass_violations.rpt {write_report spyglass_violations}
current_goal lint/lint_rtl_enhanced -top alu
set_goal_option ignorerule W164b
run_goal
capture ./spyglass-1/alu/lint/lint_rtl_enhanced/spyglass_reports/spyglass_violations.rpt {write_report spyglass_violations}

exit -force
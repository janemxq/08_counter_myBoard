onerror {resume}
quietly WaveActivateNextPane {} 0
add wave -noupdate -height 30 /tb_functionGenerate/sys_rst_n
add wave -noupdate -height 30 /tb_functionGenerate/uart_flag
add wave -noupdate -height 30 -radix decimal /tb_functionGenerate/pulse_width1
add wave -noupdate -height 30 -radix decimal /tb_functionGenerate/pulse_width2
add wave -noupdate -height 30 -radix decimal /tb_functionGenerate/pulse_gap
add wave -noupdate -height 30 -radix decimal /tb_functionGenerate/cnt
add wave -noupdate -height 30 /tb_functionGenerate/pulse_flag
add wave -noupdate -height 30 /tb_functionGenerate/po_flag_dly1
add wave -noupdate -height 30 /tb_functionGenerate/po_flag_dly2
add wave -noupdate -height 30 /tb_functionGenerate/pulse_en
add wave -noupdate -height 30 /tb_functionGenerate/locked
add wave -noupdate -height 30 /tb_functionGenerate/pulse_out1
add wave -noupdate -height 30 /tb_functionGenerate/pulse_out2
add wave -noupdate /tb_functionGenerate/my_clk
TreeUpdate [SetDefaultTree]
WaveRestoreCursors {{Cursor 1} {150000 ps} 0}
quietly wave cursor active 1
configure wave -namecolwidth 150
configure wave -valuecolwidth 100
configure wave -justifyvalue left
configure wave -signalnamewidth 1
configure wave -snapdistance 10
configure wave -datasetprefix 0
configure wave -rowmargin 4
configure wave -childrowmargin 2
configure wave -gridoffset 0
configure wave -gridperiod 1
configure wave -griddelta 40
configure wave -timeline 0
configure wave -timelineunits us
update
WaveRestoreZoom {0 ps} {315 ns}

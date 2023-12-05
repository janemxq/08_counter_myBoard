onerror {resume}
quietly WaveActivateNextPane {} 0
add wave -noupdate /tb_uart_rx/sys_rst_n
add wave -noupdate /tb_uart_rx/rx
add wave -noupdate /tb_uart_rx/rec_byte_cnt
add wave -noupdate /tb_uart_rx/po_data
add wave -noupdate /tb_uart_rx/po_flag
add wave -noupdate /tb_uart_rx/rx_data
TreeUpdate [SetDefaultTree]
WaveRestoreCursors {{Cursor 1} {10999999459 ps} 0}
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
WaveRestoreZoom {10999999050 ps} {11000000050 ps}

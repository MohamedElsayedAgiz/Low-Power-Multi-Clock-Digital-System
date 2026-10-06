onerror {resume}
quietly WaveActivateNextPane {} 0
add wave -noupdate -expand -group {System_Interface
} /tb_SYS_TOP/DUT/REF_CLK
add wave -noupdate -expand -group {System_Interface
} /tb_SYS_TOP/DUT/UART_CLK
add wave -noupdate -expand -group {System_Interface
} /tb_SYS_TOP/DUT/RST_N
add wave -noupdate -expand -group {System_Interface
} /tb_SYS_TOP/DUT/UART_RX_IN
add wave -noupdate -expand -group {System_Interface
} -color Magenta -itemcolor Black /tb_SYS_TOP/DUT/UART_TX_O_V
add wave -noupdate -expand -group {System_Interface
} -color Magenta -itemcolor Black /tb_SYS_TOP/DUT/UART_TX_O
add wave -noupdate -expand -group {System_Interface
} /tb_SYS_TOP/DUT/framing_error
add wave -noupdate -expand -group {System_Interface
} /tb_SYS_TOP/DUT/parity_error
add wave -noupdate -expand -group {SYS_CTRL
} -color Blue -itemcolor Blue /tb_SYS_TOP/DUT/U0_SYS_CTRL/current_state
add wave -noupdate -expand -group {SYS_CTRL
} /tb_SYS_TOP/DUT/U0_SYS_CTRL/RX_D_VLD
add wave -noupdate -expand -group {SYS_CTRL
} -color Cyan -itemcolor Cyan /tb_SYS_TOP/DUT/U0_SYS_CTRL/RX_P_DATA
add wave -noupdate -expand -group {SYS_CTRL
} /tb_SYS_TOP/DUT/U0_SYS_CTRL/WrEn
add wave -noupdate -expand -group {SYS_CTRL
} /tb_SYS_TOP/DUT/U0_SYS_CTRL/RdEn
add wave -noupdate -expand -group {SYS_CTRL
} /tb_SYS_TOP/DUT/U0_SYS_CTRL/WrData
add wave -noupdate -expand -group {SYS_CTRL
} /tb_SYS_TOP/DUT/U0_SYS_CTRL/RdData_Valid
add wave -noupdate -expand -group {SYS_CTRL
} /tb_SYS_TOP/DUT/U0_SYS_CTRL/RdData
add wave -noupdate -expand -group {SYS_CTRL
} /tb_SYS_TOP/DUT/U0_SYS_CTRL/TX_D_VLD
add wave -noupdate -expand -group {SYS_CTRL
} /tb_SYS_TOP/DUT/U0_SYS_CTRL/TX_P_DATA
add wave -noupdate -expand -group {SYS_CTRL
} /tb_SYS_TOP/DUT/U0_SYS_CTRL/OUT_Valid
add wave -noupdate -expand -group {SYS_CTRL
} /tb_SYS_TOP/DUT/U0_SYS_CTRL/EN
add wave -noupdate -expand -group {SYS_CTRL
} /tb_SYS_TOP/DUT/U0_SYS_CTRL/CLK_EN
add wave -noupdate -expand -group {SYS_CTRL
} /tb_SYS_TOP/DUT/U0_SYS_CTRL/Address
add wave -noupdate -expand -group {SYS_CTRL
} /tb_SYS_TOP/DUT/U0_SYS_CTRL/ALU_FUN
add wave -noupdate -expand -group {SYS_CTRL
} /tb_SYS_TOP/DUT/U0_SYS_CTRL/FIFO_FULL
add wave -noupdate -expand -group {UART
} /tb_SYS_TOP/DUT/UO_UART/parity_type
add wave -noupdate -expand -group {UART
} /tb_SYS_TOP/DUT/UO_UART/parity_enable
add wave -noupdate -expand -group {UART
} /tb_SYS_TOP/DUT/UO_UART/Prescale
TreeUpdate [SetDefaultTree]
WaveRestoreCursors {{Cursor 1} {2515061262 ps} 0}
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
configure wave -timelineunits ns
update
WaveRestoreZoom {674695305 ps} {3316895026 ps}

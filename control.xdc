set_property -dict { PACKAGE_PIN M20   IOSTANDARD LVCMOS33 } [get_ports { NCLR }]; #IO_L7N_T1_AD2N_35 Sch=sw[0]
set_property -dict { PACKAGE_PIN L15   IOSTANDARD LVCMOS33 } [get_ports { SERIAL_OUT }]; #IO_L22N_T3_AD7N_35 Sch=led4_b

set_property -dict { PACKAGE_PIN H16   IOSTANDARD LVCMOS33 } [get_ports { CLK }]; #IO_L13P_T2_MRCC_35 Sch=sysclk

set_property -dict { PACKAGE_PIN R14   IOSTANDARD LVCMOS33 } [get_ports { out_led[0] }]; #IO_L22N_T3_AD7N_35 Sch=led4_b
set_property -dict { PACKAGE_PIN P14   IOSTANDARD LVCMOS33 } [get_ports { out_led[1] }]; #IO_L22N_T3_AD7N_35 Sch=led4_b
set_property -dict { PACKAGE_PIN N16   IOSTANDARD LVCMOS33 } [get_ports { out_led[2] }]; #IO_L22N_T3_AD7N_35 Sch=led4_b
set_property -dict { PACKAGE_PIN M14   IOSTANDARD LVCMOS33 } [get_ports { out_led[3] }]; #IO_L22N_T3_AD7N_35 Sch=led4_b

set_property -dict { PACKAGE_PIN T14   IOSTANDARD LVCMOS33 } [get_ports { out[0] }]; #IO_L5P_T0_34 Sch=ar[0]
set_property -dict { PACKAGE_PIN U12   IOSTANDARD LVCMOS33 } [get_ports { out[1] }]; #IO_L2N_T0_34 Sch=ar[1]
set_property -dict { PACKAGE_PIN U13   IOSTANDARD LVCMOS33 } [get_ports { out[2] }]; #IO_L3P_T0_DQS_PUDC_B_34 Sch=ar[2]
set_property -dict { PACKAGE_PIN V13   IOSTANDARD LVCMOS33 } [get_ports { out[3] }]; #IO_L3N_T0_DQS_34 Sch=ar[3]
set_property -dict { PACKAGE_PIN V15   IOSTANDARD LVCMOS33 } [get_ports { out[4] }]; #IO_L10P_T1_34 Sch=ar[4]
set_property -dict { PACKAGE_PIN T15   IOSTANDARD LVCMOS33 } [get_ports { out[5] }]; #IO_L5N_T0_34 Sch=ar[5]
set_property -dict { PACKAGE_PIN R16   IOSTANDARD LVCMOS33 } [get_ports { out[6] }]; #IO_L19P_T3_34 Sch=ar[6]

set_property -dict { PACKAGE_PIN V17   IOSTANDARD LVCMOS33 } [get_ports { disp1 }]; #IO_L21P_T3_DQS_34 Sch=ar[8]
set_property -dict { PACKAGE_PIN V18   IOSTANDARD LVCMOS33 } [get_ports { disp2 }]; #IO_L21N_T3_DQS_34 Sch=ar[9]
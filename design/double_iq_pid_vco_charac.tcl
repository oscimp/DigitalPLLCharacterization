# change to upper
set up_board [string toupper $board_name]
if {$up_board == "REDPITAYA"} {
    set ADC_SIZE 14
} else {
    if {$up_board == "REDPITAYA16"} {
        set ADC_SIZE 16
    }
}

#the characterization loop is made for $AFTER_FIR_SIZE = 14
set AFTER_FIR_SIZE 14

#perturbation NCO size
set PERTURBATION_SIZE 19 

# Create ip for performance measurements : PERTURBATION_NCO, ADD_PERTURBATION, SWITCH_PERTURBATION, D2R_PERTURBATION, and C2R_PERTURBATION, EXP_dynsh, EXP_PERTURBATION, DUPPL_PIDin and DUPPL_PERTURBATION

add_ip_and_conf nco_counter PERTURBATION_NCO {COUNTER_SIZE {32} LUT_SIZE {12} DATA_SIZE {$PERTURBATION_SIZE} }
connect_proc PERTURBATION_NCO s00_axi 0xC0000

add_ip_and_conf adder_substracter_real ADD_PERTURBATION {opp {add} DATA_SIZE {39} }

add_ip_and_conf switchReal SWITCH_PERTURBATION {DEFAULT_INPUT {0} DATA_SIZE {40} }
connect_proc SWITCH_PERTURBATION s00_axi 0xE0000 

add_ip_and_conf dataReal_to_ram D2R_PERTURBATION {NB_INPUT {6} DATA_SIZE {15} NB_SAMPLE {12500} }
connect_proc D2R_PERTURBATION s00_axi 0xF0000

add_ip_and_conf dupplReal duppl_D2R1 {NB_OUTPUT {3} DATA_SIZE {15} }
add_ip_and_conf dupplReal duppl_D2R2 {NB_OUTPUT {3} DATA_SIZE {15} }
add_ip_and_conf dupplReal duppl_pre_switch {NB_OUTPUT {2} DATA_SIZE {39} }
add_ip_and_conf dupplReal DUPPL_PERTURBATION {NB_OUTPUT {2} DATA_SIZE {$PERTURBATION_SIZE} }
add_ip_and_conf convertComplexToReal C2R_PERTURBATION {DATA_SIZE {$PERTURBATION_SIZE} }
add_ip_and_conf expanderReal EXP_paral_switch {DATA_IN_SIZE {39} DATA_OUT_SIZE {40} }
add_ip_and_conf expanderReal EXP_PERTURBATION {DATA_IN_SIZE {$PERTURBATION_SIZE} DATA_OUT_SIZE {39} }
add_ip_and_conf shifterReal shifter_perturbation {DATA_IN_SIZE {$PERTURBATION_SIZE} DATA_OUT_SIZE {15} }

# Create instance: redpitaya_converters_0, and set properties
add_ip_and_conf redpitaya_converters redpitaya_converters_0 {
	CLOCK_DUTY_CYCLE_STABILIZER_EN {false} \
	ADC_SIZE $ADC_SIZE }
connect_to_fpga_pins redpitaya_converters_0 phys_interface phys_interface_0
connect_intf redpitaya_converters_0 rst_o PERTURBATION_NCO ref_rst_i
connect_intf redpitaya_converters_0 clk_o PERTURBATION_NCO ref_clk_i

# Create instance: adc1_offset, and set properties
add_ip_and_conf add_constReal adc1_offset {
	DATA_IN_SIZE $ADC_SIZE \
	DATA_OUT_SIZE $ADC_SIZE }
connect_proc adc1_offset s00_axi 0x50000

if {$up_board == "REDPITAYA16"} {
  # Create instance: adc2_offset, and set properties
  add_ip_and_conf add_constReal adc2_offset {
	DATA_IN_SIZE $ADC_SIZE \
	DATA_OUT_SIZE $ADC_SIZE }
  connect_proc adc2_offset s00_axi 0x40000

  # Create instance: mixer_sin_1, and set properties
  add_ip_and_conf mixer_sin mixer_sin_1 {
	DATA_IN_SIZE $ADC_SIZE \
	DATA_OUT_SIZE $ADC_SIZE \
	NCO_SIZE {16} }

  # Create instance: convertComplexToReal_5, and set properties
  add_ip_and_conf convertComplexToReal convertComplexToReal_5 {
	DATA_SIZE {14} }

  # Create instance: convertComplexToReal_1, and set properties
  add_ip_and_conf convertComplexToReal convertComplexToReal_1 {
	DATA_SIZE $ADC_SIZE }

  # Create instance: expanderReal_3, and set properties
  add_ip_and_conf expanderReal expanderReal_3 {
	DATA_IN_SIZE {14} \
	DATA_OUT_SIZE {21} }

  # Create instance: dds2_nco, and set properties
  add_ip_and_conf nco_counter dds2_nco {
	COUNTER_SIZE {40} \
	DATA_SIZE {16} \
	LUT_SIZE {12} }
  connect_intf redpitaya_converters_0 clk_o dds2_nco ref_clk_i
  connect_intf redpitaya_converters_0 rst_o dds2_nco ref_rst_i
  connect_proc dds2_nco s00_axi 0x1D0000

  # Create instance: dds2_f0, and set properties
  add_ip_and_conf add_constReal dds2_f0 {
	DATA_IN_SIZE {40} \
	DATA_OUT_SIZE {40} \
	format {unsigned} }
  connect_proc dds2_f0 s00_axi 0x1B0000
 
  # Create instance: mixer_sin_5, and set properties
  add_ip_and_conf mixer_sin mixer_sin_5 {
	DATA_IN_SIZE {14} \
	DATA_OUT_SIZE {14} \
	NCO_SIZE {16} }

  # Create instance: demod2_nco, and set properties
  add_ip_and_conf nco_counter demod2_nco {
	COUNTER_SIZE {40} \
	DATA_SIZE {16} \
	LUT_SIZE {12} }
  connect_intf redpitaya_converters_0 clk_o demod2_nco ref_clk_i
  connect_intf redpitaya_converters_0 rst_o demod2_nco ref_rst_i
  connect_proc demod2_nco s00_axi 0x70000

  # Create instance: dds_range, and set properties
  add_ip_and_conf axi_to_dac dds_range {
	DATA_SIZE {14} \
	SYNCHRONIZE_CHAN {false} }
  connect_intf redpitaya_converters_0 clk_o dds_range ref_clk_i
  connect_intf redpitaya_converters_0 rst_o dds_range ref_rst_i
  connect_proc dds_range s00_axi 0x120000

  # Create instance: mixer_sin_3, and set properties
  add_ip_and_conf multiplierReal mixer_sin_3 {
	DATA1_IN_SIZE {14} \
	DATA_OUT_SIZE {14} \
	DATA2_IN_SIZE {14} }
  
  # Create instance: dds2_offset, and set properties
  add_ip_and_conf add_constReal dds2_offset {
	DATA_IN_SIZE {14} \
	DATA_OUT_SIZE {14} \
	format {signed} }
  connect_proc dds2_offset s00_axi 0x210000

  # Create instance: pidv3_axi_1, and set properties
  add_ip_and_conf pidv3_axi pidv3_axi_1 {
	DSR {1} \
	ISR {19} \
	I_SIZE {18} \
	PSR {13} }
  connect_proc pidv3_axi_1 s00_axi 0x140000

  # Create instance: shifterReal_2, and set properties
  add_ip_and_conf shifterReal shifterReal_2 {
	DATA_IN_SIZE {21} \
	DATA_OUT_SIZE {40} }

  # Create instance: firReal_1, and set properties
  add_ip_and_conf firReal firReal_1 {
	DATA_IN_SIZE $ADC_SIZE \
	DATA_OUT_SIZE {32} \
	DECIMATE_FACTOR {1} \
	NB_COEFF {25} }
  connect_proc firReal_1 s00_axi 0x90000

  # Create instance: shifterReal_dyn_1, and set properties
  add_ip_and_conf shifterReal_dyn shifterReal_dyn_1 {
	DATA_IN_SIZE 32 \
	DATA_OUT_SIZE $AFTER_FIR_SIZE }
  connect_proc shifterReal_dyn_1 s00_axi 0xA0000
}

# Create instance: mixer_sin_0, and set properties
add_ip_and_conf mixer_sin mixer_sin_0 {
	DATA_IN_SIZE $ADC_SIZE \
	DATA_OUT_SIZE $ADC_SIZE \
	NCO_SIZE {16} }

# Create instance: convertComplexToReal_0, and set properties
add_ip_and_conf convertComplexToReal convertComplexToReal_0 {
	DATA_SIZE $ADC_SIZE }

# Create instance: firReal_0, and set properties
add_ip_and_conf firReal firReal_0 {
	DATA_IN_SIZE $ADC_SIZE \
	DATA_OUT_SIZE {32} \
	DECIMATE_FACTOR {1} \
	NB_COEFF {25} }
connect_proc firReal_0 s00_axi 0x80000

# Create instance: shifterReal_dyn_0, and set properties
add_ip_and_conf shifterReal_dyn shifterReal_dyn_0 {
	DATA_IN_SIZE 32 \
	DATA_OUT_SIZE $AFTER_FIR_SIZE }
connect_proc shifterReal_dyn_0 s00_axi 0x20000

# Create instance: pidv3_axi_0, and set properties
# MD 01/09/21: changed ISR from 19 to 13 and PSR from 13 to 1
add_ip_and_conf pidv3_axi pidv3_axi_0 {
	DSR {1} \
	ISR {13} \
	I_SIZE {18} \
	PSR {1} \
	DATA_OUT_SIZE {30} \
	DATA_IN_SIZE {14} }
connect_proc pidv3_axi_0 s00_axi 0x30000

# Create instance: dupplReal_1_to_3_1, and set properties
add_ip_and_conf dupplReal dupplReal_1_to_3_1 {
	DATA_SIZE $AFTER_FIR_SIZE \
	NB_OUTPUT 3 }

# Create instance: dupplReal_1_to_2_4, and set properties
add_ip_and_conf dupplReal_1_to_2 dupplReal_1_to_2_4 {
	DATA_SIZE $AFTER_FIR_SIZE }

# Create instance: dupplReal_1_to_2_3, and set properties
add_ip_and_conf dupplReal_1_to_2 dupplReal_1_to_2_3 {
	DATA_SIZE $AFTER_FIR_SIZE }

#Create instance: dupplReal_PIDout, and set properties
add_ip_and_conf dupplReal_1_to_2 dupplReal_PIDout {
	DATA_SIZE {30} }

# Create instance: convertComplexToReal_4, and set properties
add_ip_and_conf convertComplexToReal convertComplexToReal_4 {
	DATA_SIZE {14} }

# Create instance: dataReal_to_ram_fast, and set properties
add_ip_and_conf dataReal_to_ram dataReal_to_ram_fast {
	DATA_SIZE {16} \
	NB_INPUT {2} \
	NB_SAMPLE {1024} }
connect_proc dataReal_to_ram_fast s00_axi 0x00000

# Create instance: dataReal_to_ram_slow, and set properties
add_ip_and_conf dataReal_to_ram dataReal_to_ram_slow {
	DATA_SIZE {16} \
	NB_INPUT {2} \
	NB_SAMPLE {2048} }
connect_proc dataReal_to_ram_slow s00_axi 0xB0000

# Create instance: dds1_f0, and set properties
add_ip_and_conf add_constReal dds1_f0 {
	DATA_IN_SIZE {39} \
	DATA_OUT_SIZE {39} \
	format {unsigned} }
connect_proc dds1_f0 s00_axi 0x190000

# Create instance: dds1_nco, and set properties
add_ip_and_conf nco_counter dds1_nco {
	COUNTER_SIZE {40} \
	DATA_SIZE {16} \
	LUT_SIZE {12} }
connect_intf redpitaya_converters_0 clk_o dds1_nco ref_clk_i
connect_intf redpitaya_converters_0 rst_o dds1_nco ref_rst_i
connect_proc dds1_nco s00_axi 0x1A0000

# Create instance: dds1_offset, and set properties
add_ip_and_conf add_constReal dds1_offset {
	DATA_IN_SIZE {14} \
	DATA_OUT_SIZE {14} \
	format {signed} }
connect_proc dds1_offset s00_axi 0x200000

# Create instance: dds_ampl, and set properties
add_ip_and_conf axi_to_dac dds_ampl {
	DATA_SIZE {14} \
	SYNCHRONIZE_CHAN {false} }
connect_intf redpitaya_converters_0 clk_o dds_ampl ref_clk_i
connect_intf redpitaya_converters_0 rst_o dds_ampl ref_rst_i
connect_proc dds_ampl s00_axi 0x130000

# Create instance: demod1_nco, and set properties
add_ip_and_conf nco_counter demod1_nco {
	COUNTER_SIZE {40} \
	DATA_SIZE {16} \
	LUT_SIZE {12} }
connect_intf redpitaya_converters_0 clk_o demod1_nco ref_clk_i
connect_intf redpitaya_converters_0 rst_o demod1_nco ref_rst_i
connect_proc demod1_nco s00_axi 0x60000

# Create instance: meanReal_D2R1, and set properties
add_ip_and_conf meanReal meanReal_D2R1 {
	DATA_IN_SIZE {15} \
	DATA_OUT_SIZE {15} \
	NB_ACCUM {128} \
	SHIFT {7} }

# Create instance: meanReal_D2R5, and set properties  #averaging for the channel D2R#5
add_ip_and_conf meanReal meanReal_D2R5 {
	DATA_IN_SIZE {15} \
	DATA_OUT_SIZE {15} \
	NB_ACCUM {8} \
	SHIFT {3} }

# Create instance: meanReal_D2R6, and set properties  #averaging for the channel D2R#6
add_ip_and_conf meanReal meanReal_D2R6 {
	DATA_IN_SIZE {15} \
	DATA_OUT_SIZE {15} \
	NB_ACCUM {8} \
	SHIFT {3} }

	
# Create instance: meanReal_D2R2, and set properties
add_ip_and_conf meanReal meanReal_D2R2 {
	DATA_IN_SIZE {15} \
	DATA_OUT_SIZE {15} \
	NB_ACCUM {128} \
	SHIFT {7} }

# Create instance: meanReal_0, and set properties
add_ip_and_conf meanReal meanReal_0 {
	DATA_IN_SIZE {14} \
	DATA_OUT_SIZE {16} \
	NB_ACCUM {128} \
	SHIFT {7} }

# Create instance: meanReal_1, and set properties
add_ip_and_conf meanReal meanReal_1 {
	DATA_IN_SIZE {14} \
	DATA_OUT_SIZE {16} \
	NB_ACCUM {128} \
	SHIFT {7} }

# Create instance: meanReal_2, and set properties
add_ip_and_conf meanReal meanReal_2 {
	DATA_IN_SIZE {14} \
	DATA_OUT_SIZE {16} \
	NB_ACCUM {8192} \
	SHIFT {13} }

# Create instance: meanReal_3, and set properties
add_ip_and_conf meanReal meanReal_3 {
	DATA_IN_SIZE {14} \
	DATA_OUT_SIZE {16} \
	NB_ACCUM {8192} \
	SHIFT {13} }

# Create instance: mixer_sin_4, and set properties
add_ip_and_conf mixer_sin mixer_sin_4 {
	DATA_IN_SIZE {14} \
	DATA_OUT_SIZE {14} \
	NCO_SIZE {16} }

# Create instance: shifterReal_3, and set properties
add_ip_and_conf shifterReal shifterReal_3 {
	DATA_IN_SIZE {30} \
	DATA_OUT_SIZE {39} }

# expander to fit D2R_PERTURBATION in
add_ip_and_conf expanderReal D2R_PERT_DAT1 {
	DATA_IN_SIZE {14} \
	DATA_OUT_SIZE {15} }
# Create instance: expanderReal_D2R, and set properties
add_ip_and_conf expanderReal expanderReal_D2R {
	DATA_IN_SIZE {30} \
	DATA_OUT_SIZE {14} }

# Create interface connections
connect_proc_rst redpitaya_converters_0 adc_rst_i

#connect_intf dds_range dataB_rst_o mixer_sin_3 nco_rst_i
connect_intf adc1_offset data_out mixer_sin_0 data_in
connect_intf convertComplexToReal_0 dataI_out firReal_0 data_in

connect_intf convertComplexToReal_4 dataI_out dds1_offset data_in
connect_intf dds1_nco sine_out mixer_sin_4 nco_in
connect_intf dds1_offset data_out redpitaya_converters_0 dataA_in
connect_intf dds_ampl dataA_out mixer_sin_4 data_in

#CHARATERIZATION STAGE
#way without perturbation
#connect_intf dupplReal_1_to_4_1 data1_out EXP_dynsh data_in
connect_intf EXP_paral_switch data_out SWITCH_PERTURBATION data1_in
#way with perturbation
connect_intf dupplReal_1_to_3_1 data1_out pidv3_axi_0 data_in
connect_intf PERTURBATION_NCO sine_out C2R_PERTURBATION data_in
connect_intf C2R_PERTURBATION dataI_out DUPPL_PERTURBATION data_in
connect_intf DUPPL_PERTURBATION data2_out EXP_PERTURBATION data_in
connect_intf EXP_PERTURBATION data_out ADD_PERTURBATION data2_in
connect_intf ADD_PERTURBATION data_out SWITCH_PERTURBATION data2_in
connect_intf SWITCH_PERTURBATION data_out dds1_nco pinc_in

#data to ram connections
connect_intf dupplReal_1_to_3_1 data2_out D2R_PERT_DAT1 data_in
connect_intf D2R_PERT_DAT1 data_out duppl_D2R1 data_in
connect_intf duppl_D2R1 data1_out D2R_PERTURBATION data1_in
connect_intf duppl_D2R1 data3_out meanReal_D2R5 data_in  
connect_intf duppl_D2R1 data2_out meanReal_D2R1 data_in
connect_intf meanReal_D2R1 data_out D2R_PERTURBATION data3_in
connect_intf meanReal_D2R5 data_out D2R_PERTURBATION data5_in
connect_intf DUPPL_PERTURBATION data1_out shifter_perturbation data_in
connect_intf shifter_perturbation data_out duppl_D2R2 data_in
connect_intf duppl_D2R2 data1_out D2R_PERTURBATION data2_in
connect_intf duppl_D2R2 data2_out meanReal_D2R2 data_in
connect_intf duppl_D2R2 data3_out meanReal_D2R6 data_in
connect_intf meanReal_D2R2 data_out D2R_PERTURBATION data4_in
connect_intf meanReal_D2R6 data_out D2R_PERTURBATION data6_in
#end of CHARATERIZATION STAGE

connect_intf dupplReal_1_to_3_1 data3_out dupplReal_1_to_2_3 data_in
connect_intf dupplReal_1_to_2_3 data1_out meanReal_1 data_in
connect_intf dupplReal_1_to_2_3 data2_out meanReal_3 data_in
connect_intf dupplReal_1_to_2_4 data1_out meanReal_0 data_in
connect_intf dupplReal_1_to_2_4 data2_out meanReal_2 data_in
connect_intf firReal_0 data_out shifterReal_dyn_0 data_in
connect_intf dataReal_to_ram_fast data1_in meanReal_0 data_out
connect_intf dataReal_to_ram_fast data2_in meanReal_1 data_out
connect_intf dataReal_to_ram_slow data1_in meanReal_2 data_out
connect_intf dataReal_to_ram_slow data2_in meanReal_3 data_out
connect_intf convertComplexToReal_0 data_in mixer_sin_0 data_out
connect_intf convertComplexToReal_4 data_in mixer_sin_4 data_out
connect_intf demod1_nco sine_out mixer_sin_0 nco_in
connect_intf adc1_offset data_in redpitaya_converters_0 dataA_out
if {$up_board == "REDPITAYA16"} {
  connect_intf dds_range dataB_out mixer_sin_3 data2_in
  connect_intf adc2_offset data_in redpitaya_converters_0 dataB_out
  connect_intf adc2_offset data_out mixer_sin_1 data_in
  connect_intf demod2_nco sine_out mixer_sin_1 nco_in
  connect_intf convertComplexToReal_1 data_in mixer_sin_1 data_out
  connect_intf convertComplexToReal_1 dataI_out firReal_1 data_in
  connect_intf firReal_1 data_out shifterReal_dyn_1 data_in
  connect_intf shifterReal_dyn_1 data_out pidv3_axi_1 data_in
  connect_intf mixer_sin_3 data1_in pidv3_axi_1 data_out
  connect_intf mixer_sin_3 data_out expanderReal_3 data_in
  connect_intf expanderReal_3 data_out shifterReal_2 data_in
  connect_intf dds2_f0 data_in shifterReal_2 data_out
  connect_intf dds2_nco pinc_in dds2_f0 data_out
  connect_intf dds2_nco sine_out mixer_sin_5 nco_in
  connect_intf dds_ampl dataB_out mixer_sin_5 data_in
  connect_intf convertComplexToReal_5 data_in mixer_sin_5 data_out
  connect_intf convertComplexToReal_5 dataI_out dds2_offset data_in
  connect_intf dds2_offset data_out redpitaya_converters_0 dataB_in
}
connect_intf duppl_pre_switch data_in dds1_f0 data_out
connect_intf duppl_pre_switch data1_out ADD_PERTURBATION data1_in
connect_intf duppl_pre_switch data2_out EXP_paral_switch data_in
connect_intf dds1_f0 data_in shifterReal_3 data_out
connect_intf dupplReal_1_to_3_1 data_in shifterReal_dyn_0 data_out
connect_intf dupplReal_PIDout data_in pidv3_axi_0 data_out
connect_intf shifterReal_3 data_in dupplReal_PIDout data1_out
connect_intf expanderReal_D2R data_in dupplReal_PIDout data2_out
connect_intf expanderReal_D2R data_out dupplReal_1_to_2_4 data_in

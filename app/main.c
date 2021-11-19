#include <stdio.h>
#include <stdlib.h>
#include <stdint.h>
#include <fcntl.h>
#include <unistd.h>
#include <unistd.h>  // for sleep()
#include "nco_conf.h"
#include "switch_conf.h"
#include "pidv3_axi_conf.h"
#include "utils_conf.h"
#include "fir_conf.h"// library for communicating with the FIR
#include "add_const_conf.h" 
#include "axi_to_dac_conf.h" 

#define size 12500
#define channels 6
#define fs 125000000 // 125 MHz for 14-bit Redpitaya, 122.88 MHz for 16-bit
#define f  21370600  // 21.4 MHz for https://www.digikey.fr/product-detail/fr/ecs-inc/ECS-96SMF21A30/X717CT-ND/1693789
#define foffset 0x2BD3C36113 // dec2hex(floor(21.4e6/125e6*2^40))                           

void run_measurement(long freq_pert, int kpval, int kival, int dynval)
{
 char filename[256];
 short c[size*channels];
 int fi,fo;
 // file name
 sprintf(filename, "/tmp/data_%08ld.bin", freq_pert);
 printf("freq = %ld", freq_pert);
 printf("%s",filename);

 // configure
 shifter_set("/dev/shifterReal_dyn_0", dynval);   /* set dyn shifter to dynval */
 pidv3_axi_set_kchan("/dev/pidv3_axi_0", KP, kpval); /* set Kp to 1 */
 pidv3_axi_set_kchan("/dev/pidv3_axi_0", KI, kival); /* set Ki to 0 */
 nco_counter_send_conf("/dev/PERTURBATION_NCO", fs, freq_pert, 32, 0,   1,   1);
                      // /dev                   fs    fo      acc offs pinc poff
 
 // collect data
 fi=open("/dev/D2R_PERTURBATION",O_RDWR);
 fo=open(filename,O_WRONLY|O_CREAT,0666);
 switch_send_conf("/dev/SWITCH_PERTURBATION", 1); /* 1=PERTURBATION ON ; 0=PERTURBATION OFF */
 usleep(100000);
 read(fi,c,size*channels*sizeof(short));
 write(fo,c,size*channels*sizeof(short));
 close(fi);
 close(fo);
}

int main(int argc,char **argv)
{long freq_pert;
 int kpval = 10;
 int kival = 40;
 int dynval = 13;
 if (argc>1) {kpval=atoi(argv[1]);printf("Kp=%d\n",kpval);}
 if (argc>2) {kival=atoi(argv[2]);printf("Ki=%d\n",kival);}
 if (argc>3) {dynval=atoi(argv[3]);printf("Dyn=%d\n",dynval);}

// pinc, poff: 1 = AXI control, 0 = interface (other IP)  v    v
 nco_counter_send_conf("/dev/demod1_nco", fs, f, 40, 0,   1,   1);  // nco_counter /dev/demod1_nco
 nco_counter_send_conf("/dev/dds1_nco",   fs, f, 40, 0,   0,   0);  // nco_counter /dev/dds1_nco
 fir_send_confSigned("/dev/firReal_0","fir_lp_4000000_12000000_40dB.dat",25);
 // ./fir_loader.py /dev/firReal_0 fir_lp_4000000_12000000_40dB.dat  # configure FIR coefficients
 add_const_set_offset("/dev/dds1_offset",0);                        // add_constReal /dev/dds1_offset
 add_const_set_offset("/dev/dds1_f0",foffset);                      // add_constReal /dev/dds1_f0
 add_const_set_offset("/dev/adc1_offset",0);                        // add_constReal /dev/adc1_offset
 axi_to_dac_full_conf("/dev/dds_ampl",2047,2047,BOTH_ALWAYS_HIGH,0);// axi_to_dac /dev/dds_ampl

 for (freq_pert=(long)round(8*120);freq_pert<=(long)round(828*120);freq_pert+=(long)round(10*120)) /* from 0.960 kHz to 99.360 kHz,-- 120 Hz is the fft bin size for the slow signal using the first 8000 points */
     run_measurement(freq_pert,kpval,kival,dynval);

 for (freq_pert=(long)round(52*1920);freq_pert<=(long)round(522*1920);freq_pert+=(long)round(10*1920)) /* from 99.840 kHz kHz to 1.002240 MHz -- 1920 Hz is the fft bin size for mid signal using the first 8000 points*/
     run_measurement(freq_pert,kpval,kival,dynval);

 for (freq_pert=(long)round(66*15360);freq_pert<=(long)round(656*15360);freq_pert+=(long)round(10*15360)) /* from 1.013760 MHz kHz to 10.076160 MHz  -- 15360 Hz is the fft bin size for fast signal using hte first 8000 points*/
     run_measurement(freq_pert,kpval,kival,dynval);
}

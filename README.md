# DigitalPLLCharacterization

On the host PC where OscimpDigital is installed:
```
cd /somewhere/oscimpDigital                      # goto OscimpDigital repository
source settings.sh                               # set environment variables
source /opt/Xilinx/Vivado/2020.1/settings64.sh   # load Vivado environment variables 
cd /somewhere/DigitalPLLCharacterization/design  # go to this design
make                                             # Vivado synthesis ... very long
make xml                                         # get resources from Vivado project
cd ..                                            # vvv generate app/ bash script
${OSCIMP_DIGITAL_APP}/tools/module_generator/ *.xml
${OSCIMP_DIGITAL_APP}/tools/webserver_generator/webserver_generator.py *.xml
cd app
make                                             # compile application
```

The Redpitaya Buildroot install is expected to support Python3 and the Oscimp libraries: copy from OscimpDigital/lib
liboscimp_fpga.so to the Redpitaya's /usr/lib and liboscimp_fpga.py to the Redpitaya's /usr/lib/python3.9/

On the Redpitaya
```
cd app
./double_iq_pid_vco_charac_us.sh                                 # load bitstream and kernel modules
./fir_loader.py /dev/firReal_0 fir_lp_4000000_12000000_40dB.dat  # configure FIR coefficients
./double_iq_pid_vco_charac_us                                    # execute the PLL characterization program, filling /tmp with *.bin
```

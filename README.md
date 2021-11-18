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

On the Redpitaya
```
cd app
./double_iq_pid_vco_charac_us.sh
./fir_loader.py fir_lp_4000000_12000000_40dB.dat
./double_iq_pid_vco_charac_us
```

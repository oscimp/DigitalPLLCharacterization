# DigitalPLLCharacterization

```
cd /somewhere/oscimpDigital                      # goto OscimpDigital repository
source settings.sh                               # set environment variables
source /opt/Xilinx/Vivado/2020.1/settings64.sh   # load Vivado environment variables 
cd /somewhere/DigitalPLLCharacterization/design  # go to this design
make                                             # Vivado synthesis ... very long
make xml                                         # get resources from Vivado project
cd ..                                            # vvv generate app/ bash script
${OSCIMP_DIGITAL_APP}/tools/module_generator/ *.xml
cd app
make                                             # compile application
```

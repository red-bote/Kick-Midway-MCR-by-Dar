copy /B 1200a-v2.b3 + 1300b-v2.b4 + 1400c-v2.b5 + 1500d-v2.d4 + 1600e-v2.d5 + 1700f-v2.d6 kick_cpu.bin
make_vhdl_prom kick_cpu.bin kick_cpu.vhd

copy /B 4200-a.a7 + 4300-b.a8 + 4400-c.a9 + 4500-d.a10 kick_sound_cpu.bin
make_vhdl_prom kick_sound_cpu.bin kick_sound_cpu.vhd

make_vhdl_prom 1800g-v2.g4 kick_bg_bits_1.vhd
make_vhdl_prom 1900h-v2.g5 kick_bg_bits_2.vhd 

copy /B 2600a-v2.1e + 2700b-v2.1d + 2800c-v2.1b + 2900d-v2.1a kick_sp_bits.bin
make_vhdl_prom kick_sp_bits.bin kick_sp_bits.vhd

make_vhdl_prom midssio_82s123.12d midssio_82s123.vhd

rem 1200a-v2.b3 CRC 65924917
rem 1300b-v2.b4 CRC 27929f52
rem 1400c-v2.b5 CRC 69107ce6
rem 1500d-v2.d4 CRC 04a23aa1
rem 1600e-v2.d5 CRC 1d2834c0
rem 1700f-v2.d6 CRC ddf84ce1

rem 4200-a.a7  CRC 9e35c02e
rem 4300-b.a8  CRC ca2b7c28
rem 4400-c.a9  CRC d1901551
rem 4500-d.a10 CRC d36ddcdc

rem 1800g-v2.g4 CRC b4d120f3
rem 1900h-v2.g5 CRC c3ba4893

rem 2600a-v2.1e CRC 2c5d6b55
rem 2700b-v2.1d CRC 565ea97d
rem 2800c-v2.1b CRC f3be56a1
rem 2900d-v2.1a CRC 77da795e

rem midssio_82s123.12d CRC e1281ee9
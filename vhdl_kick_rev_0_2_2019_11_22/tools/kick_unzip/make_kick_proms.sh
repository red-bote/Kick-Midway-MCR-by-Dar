#!/bin/bash
# Port of make_kick_proms.bat for the Basys3 build. Run from this
# directory (the unzipped kick.zip) by contrib/tools/roms.sh, which sets:
#   MAKE_VHDL_PROM  path of the compiled make_vhdl_prom
#   PROM_DIR        output directory for the PROM VHDL
# make_vhdl_prom names the entity after its output argument, so it runs inside
# PROM_DIR with bare output file names. The SSIO color PROM is read under its
# MAME name 82s123.12d (the .bat: midssio_82s123.12d, same CRC e1281ee9).

set -euo pipefail

: "${MAKE_VHDL_PROM:?}" "${PROM_DIR:?}"
roms="$(pwd)"
tmp="$(mktemp -d)"
trap 'rm -rf "$tmp"' EXIT

cat 1200a-v2.b3 1300b-v2.b4 1400c-v2.b5 1500d-v2.d4 1600e-v2.d5 1700f-v2.d6 > "$tmp/kick_cpu.bin"
cat 4200-a.a7 4300-b.a8 4400-c.a9 4500-d.a10 > "$tmp/kick_sound_cpu.bin"
cat 2600a-v2.1e 2700b-v2.1d 2800c-v2.1b 2900d-v2.1a > "$tmp/kick_sp_bits.bin"

cd "$PROM_DIR"
"$MAKE_VHDL_PROM" "$tmp/kick_cpu.bin"       kick_cpu.vhd
"$MAKE_VHDL_PROM" "$tmp/kick_sound_cpu.bin" kick_sound_cpu.vhd
"$MAKE_VHDL_PROM" "$roms/1800g-v2.g4"       kick_bg_bits_1.vhd
"$MAKE_VHDL_PROM" "$roms/1900h-v2.g5"       kick_bg_bits_2.vhd
"$MAKE_VHDL_PROM" "$tmp/kick_sp_bits.bin"   kick_sp_bits.vhd
"$MAKE_VHDL_PROM" "$roms/82s123.12d"        midssio_82s123.vhd

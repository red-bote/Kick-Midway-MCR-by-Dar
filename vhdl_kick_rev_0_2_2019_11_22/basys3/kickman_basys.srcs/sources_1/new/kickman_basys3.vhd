----------------------------------------------------------------------------------
-- Company: Red~Bote
-- Engineer: Glenn Neidermeier
-- 
-- Create Date: 12/02/2024 07:34:15 PM
-- Design Name: 
-- Module Name: kickman_basys3 - struct
-- Project Name: 
-- Target Devices: Basys 3 Artix-7 FPGA Trainer Board 
-- Tool Versions: Vivado v2020.2
-- Description: 
-- 
-- Dependencies: 
--   vhdl_kick_rev_0_2_2019_11_22
-- Revision:
-- Revision 0.01 - File Created
-- Additional Comments:
-- 
----------------------------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_unsigned.all;
use ieee.numeric_std.all;

entity kickman_basys3 is
    port (
        clk : in std_logic;

        O_PMODAMP2_AIN : out std_logic;
        O_PMODAMP2_GAIN : out std_logic;
        O_PMODAMP2_SHUTD : out std_logic;

        vga_r : out std_logic_vector (3 downto 0);
        vga_g : out std_logic_vector (3 downto 0);
        vga_b : out std_logic_vector (3 downto 0);
        vga_hs : out std_logic;
        vga_vs : out std_logic;

        ps2_clk : in std_logic;
        ps2_dat : in std_logic;

        sw : in std_logic_vector (15 downto 0));
end kickman_basys3;

architecture struct of kickman_basys3 is

    signal clock_40 : std_logic;
    signal clock_kbd : std_logic;
    signal reset : std_logic;

    signal clock_div : std_logic_vector(3 downto 0);

    signal r : std_logic_vector(3 downto 0);
    signal g : std_logic_vector(3 downto 0);
    signal b : std_logic_vector(3 downto 0);
    signal hsync : std_logic;
    signal vsync : std_logic;
    signal csync : std_logic;
    signal blankn : std_logic;
    signal tv15Khz_mode : std_logic;

    signal audio_l : std_logic_vector(15 downto 0);
    signal audio_r : std_logic_vector(15 downto 0);
    signal pwm_accumulator_l : std_logic_vector(17 downto 0);
    signal pwm_accumulator_r : std_logic_vector(17 downto 0);

    signal kbd_intr : std_logic;
    signal kbd_scancode : std_logic_vector(7 downto 0);
    signal joy_BBBBFRLDU : std_logic_vector(8 downto 0);
    signal fn_pulse : std_logic_vector(7 downto 0);
    signal fn_toggle : std_logic_vector(7 downto 0);
    -- signal keys_HUA      : std_logic_vector(2 downto 0);

    signal ctc_zc_to_2 : std_logic; -- every ~100 scanlines from kick core
    signal ctc_zc_to_2_r : std_logic;
    signal spin_count : std_logic_vector(9 downto 0);

    signal dbg_cpu_addr : std_logic_vector(15 downto 0);

    component clk_wiz_0
        port (
            clk_out1 : out std_logic;
            locked : out std_logic;
            clk_in1 : in std_logic
        );
    end component;

begin

    -- Clock 40MHz for Video and CPU board
    clocks : clk_wiz_0
    port map(
        -- Clock out ports  
        clk_out1 => clock_40,
        -- Status and control signals
        locked => open, -- pll_locked,
        -- Clock in ports
        clk_in1 => clk
    );

    -- Kick
    kick : entity work.kick
        port map(
            clock_40 => clock_40,
            reset => reset,

            tv15Khz_mode => tv15Khz_mode,
            video_r => r,
            video_g => g,
            video_b => b,
            video_csync => csync,
            video_blankn => blankn,
            video_hs => hsync,
            video_vs => vsync,

            separate_audio => fn_toggle(4), -- F5
            audio_out_l => audio_l,
            audio_out_r => audio_r,

            coin1 => fn_pulse(0), -- F1
            coin2 => '0',
            start1 => fn_pulse(1), -- F2
            start2 => fn_pulse(2), -- F3
            kick => joy_BBBBFRLDU(0), -- up 
            service => fn_toggle(6), -- F7 (allow machine settings access)

            ctc_zc_to_2 => ctc_zc_to_2,
            spin_angle => spin_count(9 downto 6),

            dbg_cpu_addr => dbg_cpu_addr
        );

    -- spin angle decoder simulation
    process (clock_40)
    begin
        if rising_edge(clock_40) then
            ctc_zc_to_2_r <= ctc_zc_to_2;

            if ctc_zc_to_2_r = '0' and ctc_zc_to_2 = '1' then
                if joy_BBBBFRLDU(4) = '0' then -- space -- speed up
                    if joy_BBBBFRLDU(2) = '1' then
                        spin_count <= spin_count - 40;
                    end if; -- left
                    if joy_BBBBFRLDU(3) = '1' then
                        spin_count <= spin_count + 40;
                    end if; -- right						
                else
                    if joy_BBBBFRLDU(2) = '1' then
                        spin_count <= spin_count - 55;
                    end if;
                    if joy_BBBBFRLDU(3) = '1' then
                        spin_count <= spin_count + 55;
                    end if;
                end if;
            end if;

        end if;
    end process;

    -- adapt video to 4bits/color only and blank
    vga_r <= r when blankn = '1' else "0000";
    vga_g <= g when blankn = '1' else "0000";
    vga_b <= b when blankn = '1' else "0000";

    -- synchro composite/ synchro horizontale
    -- vga_hs <= csync;
    -- vga_hs <= hsync;
    vga_hs <= csync when tv15Khz_mode = '1' else hsync;
    -- commutation rapide / synchro verticale
    -- vga_vs <= '1';
    -- vga_vs <= vsync;
    vga_vs <= '1' when tv15Khz_mode = '1' else vsync;

    --sound_string <= "00" & audio & "000" & "00" & audio & "000";

    -- get scancode from keyboard
    process (reset, clock_40)
    begin
        if reset = '1' then
            clock_div <= (others => '0');
            clock_kbd <= '0';
        else
            if rising_edge(clock_40) then
                if clock_div = "1001" then
                    clock_div <= (others => '0');
                    clock_kbd <= not clock_kbd;
                else
                    clock_div <= clock_div + '1';
                end if;
            end if;
        end if;
    end process;

    keyboard : entity work.io_ps2_keyboard
        port map(
            clk => clock_kbd, -- synchrounous clock with core
            kbd_clk => ps2_clk,
            kbd_dat => ps2_dat,
            interrupt => kbd_intr,
            scancode => kbd_scancode
        );

    -- translate scancode to joystick
    joystick : entity work.kbd_joystick
        port map(
            clk => clock_kbd, -- synchrounous clock with core
            kbdint => kbd_intr,
            kbdscancode => std_logic_vector(kbd_scancode),
            joy_BBBBFRLDU => joy_BBBBFRLDU,
            fn_pulse => fn_pulse,
            fn_toggle => fn_toggle
        );

    -- pwm sound output
    process (clock_40) -- use same clock as kick_sound_board
    begin
        if rising_edge(clock_40) then

            if clock_div = "0000" then
                pwm_accumulator_l <= ('0' & pwm_accumulator_l(16 downto 0)) + ('0' & audio_l & '0');
                pwm_accumulator_r <= ('0' & pwm_accumulator_r(16 downto 0)) + ('0' & audio_r & '0');
            end if;

        end if;
    end process;

    --pwm_audio_out_l <= pwm_accumulator(17);
    --pwm_audio_out_r <= pwm_accumulator(17);

    -- active-low shutdown pin
    O_PMODAMP2_SHUTD <= sw(14);
    -- gain pin is driven high there is a 6 dB gain, low is a 12 dB gain 
    O_PMODAMP2_GAIN <= sw(15);

    O_PMODAMP2_AIN <= pwm_accumulator_l(17);

end struct;

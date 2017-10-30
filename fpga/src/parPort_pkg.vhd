library ieee;
use ieee.std_logic_1164.all;

package parPort_pkg is
    constant ADDR_REGDIR    : std_logic_vector(2 downto 0)  := "000";
    constant ADDR_REGPIN    : std_logic_vector(2 downto 0)  := "001";
    constant ADDR_REGPORT   : std_logic_vector(2 downto 0)  := "010";
    constant ADDR_REGSET    : std_logic_vector(2 downto 0)  := "011";
    constant ADDR_REGCLR    : std_logic_vector(2 downto 0)  := "100";
end parPort_pkg;

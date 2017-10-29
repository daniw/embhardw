library ieee;
use ieee.std_logic_1164.all;

entity parPort is
    port(
    -- Avalon interface signals
    Clk_CI          : in    std_logic
    ;
    Reset_RLI       : in    std_logic
    ;
    Address_DI      : in    std_logic_vector(2 downto 0)
    ;
    Read_SI         : in    std_logic
    ;
    ReadData_DO     : out   std_logic_vector(7 downto 0)
    ;
    Write_SI        : in    std_logic
    ;
    WriteData_DI    : in    std_logic_vector(7 downto 0)
    ;
    -- Parallel Port external interface
    ParPort_DIO     : inout std_logic_vector(7 downto 0)
    );
end entity parPort;

architecture noWait of parPort is
    signal RegDir_D     : std_logic_vector(7 downto 0);
    signal RegPort_D    : std_logic_vector(7 downto 0);
    signal RegPin_D     : std_logic_vector(7 downto 0);

begin

pRegWr  : process(Clk_CI, Reset_RLI)
begin
    if (Reset_RLI = '0') then
        -- Input by default
        RegDir_D    <= (others => '0');
        RegPort_D   <= (others => '0');
    elsif rising_edge(Clk_CI) then
        if Write_SI = '1' then
            -- Write cycle
            case Address_DI(2 downto 0) is
                when "000"  => RegDir_D     <= WriteData_DI;
                when "010"  => RegPort_D    <= WriteData_DI;
                when "011"  => RegPort_D    <= RegPort_D or WriteData_DI;
                when "100"  => RegPort_D    <= RegPort_D and not WriteData_DI;
                when others => null
            end case;
        end if;
    end if;
end process pRegWr;

---- Read from registers without buffer and without delay
--ReadData_DO <=  RegDir_D    when Address_DI = "000" else
--                RegPin_D    when Address_DI = "001" else
--                RegPort_D   when Address_DI = "010" else
--                (others => '0');

-- Read Process from registers with wait 1
pRegRd  : process(Clk_CI, Reset_RLI)
begin
    if Reset_RLI = '0' then
        ReadData_DO <= (others => '0');
    elsif rising_edge(Clk_CI) then 
        case Address_DI(2 downto 0) is
            when "000"  => ReadData_DO <= RegDir_D;
            when "000"  => ReadData_DO <= RegPin_D;
            when "000"  => ReadData_DO <= RegPort_D;
            when others => null;
    end if;
end process pRegRd;

end architecture noWait;

library ieee;
use ieee.std_logic_1164.all;
use work.parPort_pkg.all;

entity parPort is
    generic(
        PORT_WIDTH  : integer   := 8    -- Port width in number of bits
        ;
        ADDR_WIDTH  : integer   := 3    -- Address width in number of bits
    );
    port(
    -- Avalon interface signals
    Clk_CI          : in    std_logic
    ;
    Reset_RLI       : in    std_logic
    ;
    Address_DI      : in    std_logic_vector(ADDR_WIDTH-1 downto 0)
    ;
    Read_SI         : in    std_logic
    ;
    ReadData_DO     : out   std_logic_vector(PORT_WIDTH-1 downto 0)
    ;
    Write_SI        : in    std_logic
    ;
    WriteData_DI    : in    std_logic_vector(PORT_WIDTH-1 downto 0)
    ;
    -- Parallel Port external interface
    ParPort_DIO     : inout std_logic_vector(PORT_WIDTH-1 downto 0)
    );
end entity parPort;

architecture arch_parPort of parPort is
    -- Registers
    signal RegDir_D     : std_logic_vector(PORT_WIDTH-1 downto 0);
    signal RegPort_D    : std_logic_vector(PORT_WIDTH-1 downto 0);
    signal RegPin_D     : std_logic_vector(PORT_WIDTH-1 downto 0);
    signal ParPortSync0 : std_logic_vector(PORT_WIDTH-1 downto 0);
    signal ParPortSync1 : std_logic_vector(PORT_WIDTH-1 downto 0);

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
            case Address_DI(ADDR_WIDTH-1 downto 0) is
                when ADDR_REGDIR  => RegDir_D     <= WriteData_DI;
                when ADDR_REGPORT => RegPort_D    <= WriteData_DI;
                when ADDR_REGSET  => RegPort_D    <= RegPort_D or WriteData_DI;
                when ADDR_REGCLR  => RegPort_D    <= RegPort_D and not WriteData_DI;
                when others => null;
            end case;
        end if;
    end if;
end process pRegWr;

-- Synchronization of inputs to prevent metastability
pPortSync : process(Clk_CI, Reset_RLI)
begin
    if Reset_RLI = '0' then
        ParPortSync0 <= (others => '0');
        ParPortSync1 <= (others => '0');
        RegPin_D     <= (others => '0');
    elsif rising_edge(Clk_CI) then
        ParPortSync0 <= ParPort_DIO;
        ParPortSync1 <= ParPortSync0;
        RegPin_D     <= ParPortSync1;
    end if;
end process pPortSync;

---- Process to assign output data
--pPortOut : process(RegDir_D, RegPort_D)
--begin
--    for i in PORT_WIDTH-1 downto 0 loop
--        if RegDir_D(i) = '1' then
--            ParPort_DIO(i) <= RegPort_D(i);
--        else
--            ParPort_DIO(i) <= 'Z';
--        end if;
--    end loop;
--end process pPortOut;
ParPort_DIO <= "01010101";

-- Read Process from registers with wait 1
pRegRd  : process(Clk_CI, Reset_RLI)
begin
    if Reset_RLI = '0' then
        ReadData_DO <= (others => '0');
    elsif rising_edge(Clk_CI) then 
        case Address_DI(ADDR_WIDTH-1 downto 0) is
            when ADDR_REGDIR  => ReadData_DO <= RegDir_D;
            when ADDR_REGPIN  => ReadData_DO <= RegPin_D;
            when ADDR_REGPORT => ReadData_DO <= RegPort_D;
            when others => null;
        end case;
    end if;
end process pRegRd;

end architecture arch_parPort;

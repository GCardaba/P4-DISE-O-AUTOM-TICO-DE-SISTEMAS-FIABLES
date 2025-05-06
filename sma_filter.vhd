
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

use IEEE.NUMERIC_STD.ALL;
entity sma_filter is
generic (
        N     : integer := 4;
        WIDTH : integer := 8);
   port (
        clk  : in  std_logic;
        rst  : in  std_logic;
        din  : in  std_logic_vector(WIDTH-1 downto 0);
        load : in  std_logic;
        dout : out std_logic_vector(WIDTH-1 downto 0));
end sma_filter;
architecture Beh of sma_filter is
    type array_model is array(0 to N-1) of unsigned(WIDTH-1 downto 0); --array que almacena 4 arrays de 8 elementos
    signal muestras : array_model := (others => (others => '0'));   --variable donde se almacenan los datos a procesar
    signal avg : unsigned(WIDTH-1 downto 0) := (others => '0');
begin
    process(clk, rst)
    variable temp_sum : unsigned(WIDTH+1 downto 0);  -- 2 bits extras para evitar overflow | variable para que se actualice (dentro de los bucles for) al instante y no al terminar el process
    begin
        if rst = '1' then
            muestras<= (others => (others =>'0'));
            avg <= (others => '0');
        elsif rising_edge(clk) then
            if load = '1' then
                -- Reorden de muestras
                for i in N-1 downto 1 loop
                    muestras(i) <= muestras(i-1);
                end loop;
                muestras(0) <= unsigned(din);
            end if;

            -- Calcular promedio con los valores actuales de muestras
            temp_sum := (others => '0');
            for i in 0 to N-1 loop
                temp_sum := temp_sum + muestras(i);
            end loop;
            avg <= temp_sum(temp_sum'high downto 2);  -- División por 4 (eliminas los 2 bits menos significativos) es mas eficiente que la operación división 
        end if;
    end process;

    dout <= std_logic_vector(avg);
end Beh;
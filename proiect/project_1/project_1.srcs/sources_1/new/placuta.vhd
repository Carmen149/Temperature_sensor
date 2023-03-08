----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 12/05/2021 04:32:31 PM
-- Design Name: 
-- Module Name: placuta - Behavioral
-- Project Name: 
-- Target Devices: 
-- Tool Versions: 
-- Description: 
-- 
-- Dependencies: 
-- 
-- Revision:
-- Revision 0.01 - File Created
-- Additional Comments:
-- 
----------------------------------------------------------------------------------


library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
--use IEEE.STD_LOGIC_UNSIGNED.ALL;
--use IEEE.STD_LOGIC_ARITH.ALL;
use IEEE.numeric_std.ALL;
-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
--use IEEE.NUMERIC_STD.ALL;

-- Uncomment the following library declaration if instantiating
-- any Xilinx leaf cells in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

entity placuta is
Port
 (
 signal clk:in std_logic;
 signal btn:in std_logic_vector(4 downto 0);
 signal sw:in std_logic_vector(15 downto 0);
 signal TMP_INT:in std_logic; -- over-temperature and under temp indicator
 signal TMP_CT:in std_logic; -- critical over-temperature indicator
 signal cat:out std_logic_vector(7 downto 0);
 signal an:out std_logic_vector(7 downto 0);
 signal led:out std_logic_vector(15 downto 0);
 signal TMP_SCL:inout std_logic;
 signal TMP_SDA:inout std_logic;
 signal RX:in std_logic;
 signal TX:out std_logic
  );
end placuta;

architecture Behavioral of placuta is

signal TSR:std_logic_vector(23 downto 0):=(others=>'0');
signal btn_reset:std_logic;
signal btn_start:std_logic;
signal semnal_read:std_logic;
signal counter:INTEGER:=0;
signal ena:std_logic:='0';
signal unitati : STD_LOGIC_VECTOR (3 downto 0);
signal zeci : STD_LOGIC_VECTOR (3 downto 0);
signal sute: STD_LOGIC_VECTOR (3 downto 0);
signal mii : STD_LOGIC_VECTOR (3 downto 0);
signal date:std_logic_vector(12 downto 0);
signal afisor:std_logic_vector(31 downto 0);
signal dateN : integer;
signal intVal : integer;
signal final : std_logic_vector(12 downto 0);
signal final_1 : std_logic_vector(15 downto 0);
signal start:std_logic;
signal activ:std_logic;
signal done:std_logic;
signal trimitere_mesaje:std_logic_vector(7 downto 0);
signal numarator:integer:=0;
signal rx_8:std_logic_vector(7 downto 0);
begin

sep: entity WORK.separator port map (
            numar => final(11 downto 0),
           unitati => unitati,
           zeci  => zeci,
           sute => sute,
           mii  => mii
);



buton_reset:entity WORK.mpg port map
(
btn=>btn(1),
clk=>clk,
en=>btn_reset
);

buton_start:entity WORK.mpg port map
(
btn=>btn(0),
clk=>clk,
en=>btn_start
);
senzor:entity WORK.senzorTemperatura port map
(
TMP_SCL=>TMP_SCL,
		TMP_SDA=>TMP_SDA,
--		TMP_INT : in STD_LOGIC; -- Interrupt line from the ADT7420, not used in this project
--		TMP_CT : in STD_LOGIC;  -- Critical Temperature interrupt line from ADT7420, not used in this project
		
		TEMP_O =>date, --12-bit two's complement temperature with sign bit
		RDY_O =>led(15),	--'1' when there is a valid temperature reading on TEMP_O
		ERR_O =>led(1), --'1' if communication error
		
		CLK_I=>clk,
		SRST_I=>btn_reset
);

dateN <=  625 * to_integer(unsigned (date)) /10000;
final<= date(12) & std_logic_vector(to_unsigned(dateN, 12));
final_1 <= "000" & final;
afisor<="0000000000000000000"& date(12) &sute & zeci &unitati;

ssd:entity WORK.displ7seg port map
    (
    Clk=>Clk,
           Rst=>btn_reset,
           Data=>afisor,   -- datele pentru 8 cifre (cifra 1 din stanga: biti 31..28)
           An=>an,    -- selectia anodului activ
           Seg=>cat
    );
    
--data de la telefon la placuta
bl_rx:entity WORK.uartRx
   generic map
    (
    g_CLKS_PER_BIT => 10416     -- Needs to be set correctly
    )
    port map
          (
        i_Clk=>clk,
        i_RX_Serial=>RX,
        o_RX_DV=>led(0),
        o_RX_Byte=>rx_8
          );
          
--data spre telefon     
--trimitere_mesaje <= zeci&unitati;  
bl_tx:entity WORK.uartTx
    generic map
    (
    g_CLKS_PER_BIT => 10416     -- Needs to be set correctly
    )
    port map
          (
        i_Clk=>Clk,
        i_TX_DV=>start,
        i_TX_Byte=>trimitere_mesaje,--x"41",
        o_TX_Active=>activ,
        o_TX_Serial=>TX,
        o_TX_Done=>done
          );
          
    unitate_cc:entity WORK.UCC
    port map
    (
    clk=>clk,
    rst=>btn_reset,
    btn_start=>btn_start,
    date_intrare=> final_1,
    activ=>activ,
    done=>done,
    date_iesire=>trimitere_mesaje,
    start=>start
    );      
    
end Behavioral;

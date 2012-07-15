library ieee;
use ieee.std_logic_1164.all;

package stdc_package is

component stdc is
	generic(
		CC_WIDTH: positive
	);
	port(
		sys_clk_i: in std_logic;
		sys_rst_i: in std_logic;
		
		serdes_clk_i: in std_logic;
		serdes_strobe_i: in std_logic;
		
		signal_i: in std_logic;
		
		detect_o: out std_logic;
		polarity_o: out std_logic;
		timestamp_cc_o: out std_logic_vector(CC_WIDTH-1 downto 0);
		timestamp_8th_o: out std_logic_vector(2 downto 0);
		
		cc_rst_i: in std_logic;
		cc_cy_o: out std_logic
	);
end component;

end package;
 

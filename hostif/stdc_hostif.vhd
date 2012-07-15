library ieee;
use ieee.std_logic_1164.all;

library work;
use work.stdc_package.all;
use work.stdc_hostif_package.all;

entity stdc_hostif is
	port(
		-- system signals
		sys_rst_i: in std_logic;
		sys_clk_i: in std_logic;
		
		-- SERDES
		serdes_clk_i: in std_logic;
		serdes_strobe_i: in std_logic;
		
		-- Wishbone
		wb_addr_i: in std_logic_vector(31 downto 0);
		wb_data_i: in std_logic_vector(31 downto 0);
		wb_data_o: out std_logic_vector(31 downto 0);
		wb_cyc_i: in std_logic;
		wb_sel_i: in std_logic_vector(3 downto 0);
		wb_stb_i: in std_logic;
		wb_we_i: in std_logic;
		wb_ack_o: out std_logic;
		irq_o: out std_logic;
		
		-- TDC input
		signal_i: in std_logic;
		
		-- coarse counter
		cc_rst_i: in std_logic;
		cc_cy_o: out std_logic
	);
end entity;

architecture rtl of stdc_hostif is
signal ack: std_logic;
signal cc_pending: std_logic;
signal event_pending: std_logic;

signal detect: std_logic;
signal polarity: std_logic;
signal timestamp_cc: std_logic_vector(28 downto 0);
signal timestamp_8th: std_logic_vector(2 downto 0);
signal cc_cy: std_logic;
begin
	process(sys_clk_i)
	begin
		if rising_edge(sys_clk_i) then
			if sys_rst_i = '1' then
				ack <= '0';
				wb_data_o <= (wb_data_o'range => '0');
				cc_pending <= '0';
				event_pending <= '0';
			else
				ack <= '0';
				if (wb_cyc_i = '1') and (wb_stb_i = '1') and (ack = '0') then
					ack <= '1';
					wb_data_o <= (wb_data_o'range => '0');
					case wb_addr_i(1 downto 0) is
						when "00" => wb_data_o(0) <= cc_pending;
						when "01" => wb_data_o(0) <= event_pending;
						when "10" => wb_data_o(0) <= polarity;
						when "11" => wb_data_o <= timestamp_cc & timestamp_8th;
						when others => null;
					end case;
					if (wb_we_i = '1') then
						case wb_addr_i(1 downto 0) is
							when "00" => cc_pending <= '0';
							when "01" => event_pending <= '0';
							when others => null;
						end case;
					end if;
				end if;
				if cc_cy = '1' then
					cc_pending <= '1';
				end if;
				if detect = '1' then
					event_pending <= '1';
				end if;
			end if;
		end if;
	end process;
	wb_ack_o <= ack;
	irq_o <= cc_pending or event_pending;

	cmp_stdc: stdc
		generic map(
			CC_WIDTH => 29
		)
		port map(
			sys_clk_i => sys_clk_i,
			sys_rst_i => sys_rst_i,
			
			serdes_clk_i => serdes_clk_i,
			serdes_strobe_i => serdes_strobe_i,
			
			signal_i => signal_i,
			
			detect_o => detect,
			polarity_o => polarity,
			timestamp_cc_o => timestamp_cc,
			timestamp_8th_o => timestamp_8th,
			
			cc_rst_i => cc_rst_i,
			cc_cy_o => cc_cy
		);
	cc_cy_o <= cc_cy;
	
end architecture;

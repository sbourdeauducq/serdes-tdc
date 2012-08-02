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
signal detect: std_logic;
signal polarity: std_logic;
signal timestamp_cc: std_logic_vector(28 downto 0);
signal timestamp_8th: std_logic_vector(2 downto 0);
signal cc_cy: std_logic;

signal filter: std_logic_vector(1 downto 0);

signal fifo_clear: std_logic;
signal fifo_full: std_logic;
signal fifo_we: std_logic;
signal fifo_di: std_logic_vector(32 downto 0);
signal fifo_empty: std_logic;
signal fifo_re: std_logic;
signal fifo_do: std_logic_vector(32 downto 0);

signal cc_pending: std_logic;
signal overflow_pending: std_logic;
signal ack: std_logic;
begin
	-- instantiate basic TDC core
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
	
	-- FIFO
	cmp_fifo: stdc_fifo
		generic map(
			D_DEPTH => 10,
			D_WIDTH => 33
		)
		port map(
			sys_clk_i => sys_clk_i,
			
			clear_i => fifo_clear,
			
			full_o => fifo_full,
			we_i => fifo_we,
			data_i => fifo_di,
			
			empty_o => fifo_empty,
			re_i => fifo_re,
			data_o => fifo_do
		);
	fifo_we <= detect and ((polarity and filter(0)) or (not polarity and filter(1)));
	fifo_di <= polarity & timestamp_cc & timestamp_8th;
	
	-- bus logic
	process(sys_clk_i)
	begin
		if rising_edge(sys_clk_i) then
			if sys_rst_i = '1' then
				ack <= '0';
				wb_data_o <= (wb_data_o'range => '0');
				fifo_re <= '0';
				fifo_clear <= '1';
				cc_pending <= '0';
				overflow_pending <= '0';
				filter <= "11";
			else
				ack <= '0';
				fifo_re <= '0';
				fifo_clear <= '0';
				if (wb_cyc_i = '1') and (wb_stb_i = '1') and (ack = '0') then
					ack <= '1';
					wb_data_o <= (wb_data_o'range => '0');
					case wb_addr_i(4 downto 2) is
						when "000" => wb_data_o(0) <= not fifo_empty;
						when "001" => wb_data_o(0) <= fifo_do(32);
						when "010" => wb_data_o <= fifo_do(31 downto 0);
						-- 011 is FIFO clear and is write-only
						when "100" => wb_data_o(0) <= cc_pending;
						when "101" => wb_data_o(0) <= overflow_pending;
						when "110" => wb_data_o(1 downto 0) <= filter;
						when others => null;
					end case;
					if wb_we_i = '1' then
						case wb_addr_i(4 downto 2) is
							when "000" => fifo_re <= '1';
							when "011" => fifo_clear <= '1';
							when "100" => cc_pending <= '0';
							when "101" => overflow_pending <= '0';
							when "110" => filter <= wb_data_i(1 downto 0);
							when others => null;
						end case;
					end if;
				end if;
				if cc_cy = '1' then
					cc_pending <= '1';
				end if;
				if fifo_we = '1' and fifo_full = '1' then
					overflow_pending <= '1';
				end if;
			end if;
		end if;
	end process;
	wb_ack_o <= ack;
	irq_o <= not fifo_empty or cc_pending or overflow_pending;
	
end architecture;

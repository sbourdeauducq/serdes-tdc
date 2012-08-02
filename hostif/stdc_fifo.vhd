library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

library work;
use work.stdc_package.all;
use work.stdc_hostif_package.all;

entity stdc_fifo is
	generic(
		D_DEPTH: positive;
		D_WIDTH: positive
	);
	port(
		sys_clk_i: in std_logic;
		
		clear_i: in std_logic;
		
		-- write
		full_o: out std_logic;
		we_i: in std_logic;
		data_i: in std_logic_vector(D_WIDTH-1 downto 0);
		
		-- read
		empty_o: out std_logic;
		re_i: in std_logic;
		data_o: out std_logic_vector(D_WIDTH-1 downto 0)
	);
end entity;

architecture rtl of stdc_fifo is
signal level: std_logic_vector(D_DEPTH downto 0);
signal produce: std_logic_vector(D_DEPTH-1 downto 0);
signal consume: std_logic_vector(D_DEPTH-1 downto 0);

signal do_write: std_logic;
signal do_read: std_logic;

signal full: std_logic;
signal empty: std_logic;

type storage_type is array(2**D_DEPTH-1 downto 0) of std_logic_vector(D_WIDTH-1 downto 0);
signal storage: storage_type;
signal storage_rda: std_logic_vector(D_DEPTH-1 downto 0);
begin
	do_write <= we_i and not full;
	do_read <= re_i and not empty;

	process(sys_clk_i)
	begin
		if rising_edge(sys_clk_i) then
			if clear_i = '1' then
				level <= (level'range => '0');
				produce <= (produce'range => '0');
				consume <= (consume'range => '0');
			else
				if do_write = '1' then
					produce <= std_logic_vector(unsigned(produce) + 1);
				end if;
				if do_read = '1' then
					consume <= std_logic_vector(unsigned(consume) + 1);
				end if;
				if do_write = '1' and do_read = '0' then
					level <= std_logic_vector(unsigned(level) + 1);
				end if;
				if do_write = '0' and do_read = '1' then
					level <= std_logic_vector(unsigned(level) - 1);
				end if;
			end if;
		end if;
	end process;
	
	full <= level(D_DEPTH);
	empty <= '1' when level = (level'range => '0') else '0';
	full_o <= full;
	empty_o <= empty;
	
	process(sys_clk_i)
	begin
		if rising_edge(sys_clk_i) then
			if do_write = '1' then
				storage(to_integer(unsigned(produce))) <= data_i;
			end if;
			storage_rda <= consume;
		end if;
	end process;
	data_o <= storage(to_integer(unsigned(storage_rda)));
	
end architecture;

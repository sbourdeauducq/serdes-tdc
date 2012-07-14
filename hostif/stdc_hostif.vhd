library ieee;
use ieee.std_logic_1164.all;

library work;
--use work.tdc_package.all;
use work.stdc_hostif_package.all;

entity stdc_hostif is
    port(
        sys_rst_i : in std_logic;
        wb_clk_i  : in std_logic;
        
        wb_addr_i : in std_logic_vector(31 downto 0);
        wb_data_i : in std_logic_vector(31 downto 0);
        wb_data_o : out std_logic_vector(31 downto 0);
        wb_cyc_i  : in std_logic;
        wb_sel_i  : in std_logic_vector(3 downto 0);
        wb_stb_i  : in std_logic;
        wb_we_i   : in std_logic;
        wb_ack_o  : out std_logic;
        wb_irq_o  : out std_logic;
        
        cc_rst_i  : in std_logic;
        cc_cy_o   : out std_logic;
        signal_i  : in std_logic
    );
end entity;

architecture rtl of stdc_hostif is
begin
	wb_data_o <= (others => '0');
	wb_ack_o <= '0';
	wb_irq_o <= '0';
	cc_cy_o <= '0';
end architecture;

--------------------------------------------------------------------------------
-- Gideon's Logic B.V. - Copyright 2023
--
-- Description: This block implements a simple DMA controller for reading a 
--              byte stream from memory. Note that there is no buffering, so
--              this is not super efficient. But it is intended to be used for
--              uart communication. Even at 6.67 Mbps, a byte takes 1.5 us,
--              so one memory transfer occurs every 6 us, and as long as the
--              latency is < 1.5us, no hickups are expected. 
--------------------------------------------------------------------------------
library ieee;
    use ieee.std_logic_1164.all;
    use ieee.numeric_std.all;
    
library work;
    use work.io_bus_pkg.all;
    use work.mem_bus_pkg.all;
        
entity tx_dma is
generic (
    g_mem_tag       : std_logic_vector(7 downto 0) := X"14" );
port (
    clock           : in  std_logic;
    reset           : in  std_logic;
        
    -- AXI stream with packet address information
    addr_data       : in  std_logic_vector(31 downto 0);
    addr_user       : in  std_logic_vector(15 downto 0); -- Length
    addr_valid      : in  std_logic;
    addr_ready      : out std_logic;

    -- interface to memory (read)
    mem_req         : out t_mem_req_32;
    mem_resp        : in  t_mem_resp_32;

    -- AXI byte stream coming from memory
    out_data        : out std_logic_vector(7 downto 0) := X"00";
    out_valid       : out std_logic;
    out_last        : out std_logic;
    out_ready       : in  std_logic
);
end entity;

architecture gideon of tx_dma is

    type t_state is (idle, wait_mem, copy);
    signal state    : t_state;

    signal mem_addr     : unsigned(25 downto 0) := (others => '0');
    signal mem_data     : std_logic_vector(31 downto 0);
    signal read_req     : std_logic;
    signal remain       : unsigned(15 downto 0);
    signal out_valid_i  : std_logic;
begin
    addr_ready <= '1' when state = idle else '0';
    out_valid <= out_valid_i;

    process(clock)
    begin
        if rising_edge(clock) then
            if out_ready = '1' then
                out_valid_i <= '0';
                out_last <= '0';
            end if;

            case state is
            when idle =>
                remain <= unsigned(addr_user);
                mem_addr <= unsigned(addr_data(mem_addr'range));
                read_req <= '0';
                if addr_valid = '1' then
                    read_req <= '1';
                    state <= wait_mem;
                end if;

            when wait_mem =>
                if mem_resp.rack = '1' and mem_resp.rack_tag = g_mem_tag then
                    read_req <= '0';
                end if;
                if mem_resp.dack_tag = g_mem_tag then
                    mem_data <= mem_resp.data;
                    state <= copy;
                end if;

            when copy =>
                if out_valid_i = '0' or out_ready = '1' then
                    for i in 0 to 3 loop
                        if mem_addr(1 downto 0) = i then
                            out_data <= mem_data(7+8*i downto 8*i);
                        end if;
                    end loop;
                    out_valid_i <= '1';
                    if remain = 1 then
                        out_last <= '1';
                        state <= idle;
                    else
                        remain <= remain - 1;
                        mem_addr <= mem_addr + 1;
                        if mem_addr(1 downto 0) = "11" then
                            read_req <= '1';
                            state <= wait_mem;
                        end if;
                    end if;
                end if;
            end case;             

            if reset = '1' then
                out_valid_i <= '0';
                out_last <= '0';
                read_req <= '0';
                state <= idle;
            end if;
        end if;
    end process;

    mem_req.request <= read_req;
    mem_req.data    <= X"00000000";
    mem_req.address <= mem_addr(mem_addr'high downto 2) & "00";
    mem_req.read_writen <= '1';
    mem_req.byte_en <= (others => '1');
    mem_req.tag     <= g_mem_tag;
    
end architecture;

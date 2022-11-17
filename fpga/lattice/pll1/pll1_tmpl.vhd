-- VHDL module instantiation generated by SCUBA Diamond (64-bit) 3.12.0.240.2
-- Module  Version: 5.7
-- Fri Sep  2 10:59:52 2022

-- parameterized module component declaration
component pll1
    port (CLKI: in  std_logic; 
        PHASESEL: in  std_logic_vector(1 downto 0); 
        PHASEDIR: in  std_logic; PHASESTEP: in  std_logic; 
        PHASELOADREG: in  std_logic; RST: in  std_logic; 
        ENCLKOS: in  std_logic; ENCLKOS2: in  std_logic; 
        ENCLKOS3: in  std_logic; CLKOP: out  std_logic; 
        CLKOS: out  std_logic; CLKOS2: out  std_logic; 
        CLKOS3: out  std_logic; LOCK: out  std_logic);
end component;

-- parameterized module component instance
__ : pll1
    port map (CLKI=>__, PHASESEL(1 downto 0)=>__, PHASEDIR=>__, 
        PHASESTEP=>__, PHASELOADREG=>__, RST=>__, ENCLKOS=>__, ENCLKOS2=>__, 
        ENCLKOS3=>__, CLKOP=>__, CLKOS=>__, CLKOS2=>__, CLKOS3=>__, LOCK=>__);

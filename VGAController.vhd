----------------------------------------------------------------------------------
-- Engineer: Pablo Cáceres
-- Project Name: Proyect PONG
-- Brief: The top module of the project, receives its input from the board, generates
--        the outputs using its submodules and sends them to the monitor from the board. 
----------------------------------------------------------------------------------

library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

entity VGAController is
  Port (clock, centerButton, upButton, leftButton, rightButton: in std_logic;
        difficultyControl: in std_logic_vector(1 downto 0);
        hSync, vSync: out std_logic;
        VGARed, VGAGreen, VGABlue: out std_logic_vector(3 downto 0);
        buzzer: out std_logic;  -- Agregar el buzzer como salida
        col_led: out std_logic; -- DEBUG
        game_led: out std_logic; -- DEBUG
        reset: in std_logic
        );
end VGAController;

architecture Behavioral of VGAController is
----------------------------------------------------------------------------------------------------------------------------------------
--Decleration of the components
component ClockDivider is
    Port (clockIn: in std_logic;
          clockOut: out std_logic);
end component;  
component Sync is
    Port (clock, left, right, start: in std_logic;
          difficultyControl: in std_logic_vector(1 downto 0);
          hSync, vSync: out std_logic; 
          r, g, b: out std_logic_vector(3 downto 0);
          collision: out std_logic;
          game_started: out std_logic
          );
end component;

component MelodyPlayer is
    Port (
        clk : in std_logic;         -- Reloj de 100 MHz
        reset : in std_logic;
        mode : in std_logic;        -- '0' para melodía, '1' para pitido corto
        button : in std_logic;      -- Botón para activar el pitido
        buzzer : out std_logic      -- Salida para el buzzer
    );
end component;

signal playing: std_logic := '0';  -- Señal intermedia para detectar si esta en partida
signal collision: std_logic := '0';  -- Señal intermedia para detectar colisiones
signal melody: std_logic := '0';  -- Señal intermedia para la melodia
signal button_signal: std_logic := '0';  -- Señal intermedia para asignar button

--Intermediate carrier signal   
signal VGAClock: std_logic;

----------------------------------------------------------------------------------------------------------------------------------------

begin
 
    button_signal <= collision when playing = '1' else centerButton;
    
    --port-mappings
    ----------------------------------------------------------------------------------------------------------------------------------------
    Component1: ClockDivider 
                    port map(clockIn => clock,
                             clockOut => VGAClock);
    Component2: Sync
                    port map(clock => VGAClock,
                             left => leftButton,
                             right => rightButton,
                             start => centerButton,
                             difficultyControl => difficultyControl,
                             hSync => hSync,
                             vSync => vSync,
                             r => VGARed,
                             g => VGAGreen,
                             b => VGABlue,
                             collision => collision,
                             game_started => playing
                             );
                             
    Component3 : MelodyPlayer
                    port map (
                        clk => clock,         -- Reloj de 100 MHz
                        reset => reset,
                        mode => playing,        -- '0' para melodía, '1' para pitido corto
                        button => button_signal,      -- Botón para activar el pitido
                        buzzer => buzzer      -- Salida para el buzzer
                    );
end Behavioral;

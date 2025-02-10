library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_ARITH.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;

entity MelodyPlayer is
    Port (
        clk : in std_logic;         -- Reloj de 100 MHz
        reset : in std_logic;
        mode : in std_logic;        -- '0' para melodía, '1' para pitido corto
        button : in std_logic;      -- Botón para activar el pitido
        buzzer : out std_logic      -- Salida para el buzzer
    );
end MelodyPlayer;

architecture Behavioral of MelodyPlayer is

    type state_type is (IDLE, BEEP, MELODY, DONE);
    signal state : state_type := IDLE;

    constant MAX_NOTE_INDEX : integer := 15;

    type melody_array is array (0 to MAX_NOTE_INDEX) of integer;
    --(262-Do, 294-Re, 330-Mi, 349-Fa, 392-Sol, 440-La, 494-Si, 523-);
    -- Notas en Hz (Melodía de acción)
    constant notes : melody_array := (196, 196, 262, 294, 330, 294, 262, 196, 
                                      220, 220, 294, 330, 349, 392, 440, 494);
    
    -- Duraciones en ms
    constant durations : melody_array := (600, 200, 200, 200, 400, 200, 200, 400,
                                          600, 200, 200, 200, 400, 200, 200, 800);

    
    signal note_index : integer range 0 to MAX_NOTE_INDEX := 0;
    signal duration_counter : integer := 0;
    signal toggle : std_logic := '0';
    signal pwm_clk_div : integer := 0;
    
    constant CLK_FREQ : integer := 100_000_000; -- 100 MHz
    signal period : integer := 0;
    signal half_period : integer := 0;
    
    constant BEEP_FREQ : integer := 440; -- 1 kHz para el pitido corto
    constant BEEP_DURATION : integer := 10_000_000; -- 500 ms
    signal beep_active : std_logic := '0';

begin

    process(clk, reset)
    begin
        if reset = '1' then
            state <= IDLE;
            note_index <= 0;
            duration_counter <= 0;
            pwm_clk_div <= 0;
            toggle <= '0';
            beep_active <= '0';
        elsif rising_edge(clk) then
            case state is
                when IDLE =>
                    if mode = '1' then
                        if button = '1' then
                            beep_active <= '1';
                            state <= BEEP;
                            duration_counter <= 0;
                        end if;
                    elsif mode = '0' then
                        if button = '1' then
                            state <= MELODY;
                            note_index <= 0;
                            duration_counter <= 0;
                        end if;
                    end if;
                when BEEP =>
                    if beep_active = '1' then
                        period <= CLK_FREQ / BEEP_FREQ;
                        half_period <= period / 2;
                        if pwm_clk_div >= half_period then
                            toggle <= not toggle;
                            pwm_clk_div <= 0;
                        else
                            pwm_clk_div <= pwm_clk_div + 1;
                        end if;
                        if duration_counter >= BEEP_DURATION then
                            state <= IDLE;
                            toggle <= '0';
                            beep_active <= '0';
                        else
                            duration_counter <= duration_counter + 1;
                        end if;
                    else
                        state <= IDLE;
                        beep_active <= '0';
                    end if;
                
                when MELODY =>
                    period <= CLK_FREQ / notes(note_index);
                    half_period <= period / 2;
                    if pwm_clk_div >= half_period then
                        toggle <= not toggle;
                        pwm_clk_div <= 0;
                    else
                        pwm_clk_div <= pwm_clk_div + 1;
                    end if;
                    if duration_counter >= (durations(note_index) * 100_000) then
                        duration_counter <= 0;
                        if note_index < MAX_NOTE_INDEX then
                            note_index <= note_index + 1;
                        else
                            state <= DONE;
                        end if;
                    else
                        duration_counter <= duration_counter + 1;
                    end if;
                
                when DONE =>
                    toggle <= '0';
                    state <= IDLE;
                
            end case;
        end if;
    end process;
    
    buzzer <= toggle;
    
end Behavioral;

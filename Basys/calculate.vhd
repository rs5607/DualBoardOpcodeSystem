library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity calculate is
    Port (
    sw: in STD_LOGIC_VECTOR(15 downto 0); --switches to get operands
    opcode: in STD_LOGIC_VECTOR(7 downto 0); --opcode recieved from Zed
    send: out STD_LOGIC; --signal to tell Basys to send opcode and result back to Zed
    result: out STD_LOGIC_VECTOR(15 downto 0):= (others => '0'); --result from operation
    send_data: out STD_LOGIC_VECTOR(11 downto 0):= (others => '0') --data to be sent to Zed
     );
end calculate;
architecture Behavioral of calculate is
    signal results_int: STD_LOGIC_VECTOR(15 downto 0):= (others => '0');
begin
    result <= results_int;
    process(opcode, sw) begin
        case opcode(7 downto 4) is
            when "0001" => --display input from switches
                results_int <= sw;
            when "0010" => --add first 8 and last 8 switches
                results_int <= STD_LOGIC_VECTOR(resize(unsigned(sw(15 downto 8)), 16) + resize(unsigned(sw(7 downto 0)), 16));
            when "0011" => --subtract first 8 switches from last 8 switches
                results_int <= STD_LOGIC_VECTOR(resize(unsigned(sw(15 downto 8)), 16) - resize(unsigned(sw(7 downto 0)), 16));
            when "0100" => --multiply first 8 and last 8 switches
                results_int <= STD_LOGIC_VECTOR(unsigned(sw(15 downto 8)) * unsigned(sw(7 downto 0)));
            when "0101" => --divide switches by 2
                results_int <= STD_LOGIC_VECTOR(unsigned(sw) / 2);
            when "0110" => --switches modulus 2
                results_int <= STD_LOGIC_VECTOR(unsigned(sw) mod 2);
            when "0111" => --xor first 8 and last 8 switches, result is only 8 bits, so set upper 8 bits to 0
                results_int(7 downto 0) <= sw(15 downto 8) xor sw(7 downto 0);
                results_int(15 downto 8) <= (others => '0');
            when "1000" =>--or first 8 and last 8 switches, result is only 8 bits, so set upper 8 bits to 0
                results_int(7 downto 0) <= sw(15 downto 8) or sw(7 downto 0);
                results_int(15 downto 8) <= (others => '0');
            when "1001" =>--and first 8 and last 8 switches, result is only 8 bits, so set upper 8 bits to 0
                results_int(7 downto 0) <= sw(15 downto 8) and sw(7 downto 0);
                results_int(15 downto 8) <= (others => '0');
            when "1010" => --compliment switches
                results_int <= not sw;
            when others => --default, set to 0
                results_int <= (others => '0');               
        end case;
            if opcode(7 downto 4) = "1110" then --set result for special functions flash and easter egg
                send_data(11 downto 4) <= (others => '0');
            elsif opcode(7 downto 4) = "1111" then
                send_data(11 downto 4) <= (others => '1');  
            else      
                send_data(11 downto 4) <= results_int(7 downto 0); --normal send data, result and destination
                send_data(3 downto 0) <= opcode(3 downto 0);
            end if;     
    end process;        
end Behavioral;



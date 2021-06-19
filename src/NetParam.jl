module NetParam

export NetParameterType
export NetworkData
export readTouchStone

@enum NetParameterType begin
    Scattering = 1
    Admittance = 2
    Impedance  = 3
    HybridH    = 4
    HybridG    = 5
end

struct NetworkData
    data::AbstractArray{ComplexF64,3}
    freq::AbstractArray{Float64,1}
    paramType::Int32 # NetParameterType
    refImp::Float64
end

greet() = print("Hello World!")

function NetworkData( data::AbstractArray{ComplexF64,3}, freq::AbstractArray{Float64,1}, paramType::Int32, refImp::Float64 )

end


function __init__()
    print( "test" )
    f = NetworkData( rand( 3, 3, 3 ), rand( 3 ), 2, 2.0 )
    print( f.data )
end

# GENERAL SYNTAX RULES
#  1. Touchstone files are case-insensitive
#  2. Only ASCII chars are allowed, specifically ANSI X3.4-1986 compliant
#     Anything greater than 0x07E or less than 0x20 is not allowed with the
#     Exception of tabs, carriage return, linefeed/cr combo.
#  3. Comments are preceded by '!', can appear on individual line or at end
#     of valid line. No multiline comments
#  4. File extension of '.snp', where 'n' is number of network ports.
#  5. Conventionally, angles are measured in degrees
#
#
#  2-port devices can contain noise parameter data (potentially meaningless on other
#   devices without clarification) -- don't parse for non-two-port devices
#
#  OPTION LINE - always starts with '#', always terminated with a newline
#  # <freq unit> <parameter> <format> R <n>
#  * '#' - marks beginning of option line
#  * frequency unit - unit of frequency, acceptable are (GHz, MHz, KHz, Hz)
#                     again, case insensitive - default is GHz
#  * parameter - type of network parameters
#                   S - scattering - default if otherwise unspecified
#                   Y - admittance
#                   Z - impedance
#                   H - hybrid-h
#                   G - hybrid-g
#  * format - specified format of network param pairs
#               DB - for dB-angle (dB = 20*log10|magnitude|)
#               MA - for magnitude-angle - default if otherwise unspecified
#               RI - for real-imaginary
#             Angles are always in degrees
#             Format does not apply to noise parameters
#  * R n - specifies the reference resistance in ohms, where n is a positive number
#          of ohms - defaults to 50
#
#  DATA LINES - contain network data, only one line for 1-port, 2-port,
#               multi line for all else.
#               Always follows the option line (no need to hunt for option)
#               No more than four pairs of network data per line
#               Individual entries always separated by whitespace
#               Always terminated by newline
#               Always increasing order of frequency
#               one-port - <freq> <N11>
#               two-port - <freq> <N11> <N21> <N12> <N22> in that order, no commas
#               three-port - <freq> <N11> <N12> <N13>
#                            <N21> <N22> <N23>
#                            <N31> <N32> <N33>
#               four-port - <freq> <N11> <N12> <N13> <N14>
#                           <N21> <N22> <N23> <N24>
#                           <N31> <N32> <N33> <N34>
#                           <N41> <N42> <N43> <N44>
#               five+ port - <freq> <N11> <N12> <N13> <N14> ! wrap to next line after four
#                            <N15> <N16>
#                            <N21> <N22> <N23> <N24>
#                            <N25> <N26>
#                            ... and so on
#  NOISE DATA - always follows the network parameter data
#               can be any frequency, as long as lowest noise param is lower than
#               highest network param, for parsing this only applies to two port networks
#               source reflection coefficient and effective noise resistance normalized
#               to same as for network parameters always has format of:
#               <x1> <x2> <x3> <x4> <x5>
#               <x1> - frequency in already specified units
#               <x2> - minimum noise figure in dB
#               <x3> - source reflection coefficient to realize minimimum noise figure (magnitude in MA pair)
#               <x4> - phase in degrees of reflection coefficient (angle in MA pair)
#               <x5> - normalized effective noise resistance
#

function read_touch_stone( path::String )::NetworkData

end



end # module

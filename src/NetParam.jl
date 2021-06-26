module NetParam

export NetParameterType
export NetworkData
export readTouchStone

"""
    NetParameterType

    enum serving as a type specifier for what the data in a NetworkData struct
    represents
"""
@enum NetParameterType begin
    Scattering = 1
    Admittance = 2
    Impedance  = 3
    HybridH    = 4
    HybridG    = 5
end

"""
    PairFormat

    enum serving as descriptive format specifier
"""
@enum PairFormat begin
    MA = 1
    DB = 2
    RI = 3
end

"""
    NetworkData

    Struct containing information describing a microwave network
"""
struct NetworkData
    data::AbstractArray{ComplexF64,3}
    freq::AbstractArray{Float64,1}
    paramType::Int32 # NetParameterType
    refImp::Float64
    noiseData::AbstractArray{Float64,2}
end

"""
    Options
"""
struct DataOptions
    freqmult::Int64
    paramtype::Int32
    format::Int32
    impedance::Float64
end

#  # <freq unit> <parameter> <format> R <n>

# function NetworkData( data::AbstractArray{ComplexF64,3},
#                       freq::AbstractArray{Float64,1},
#                       paramType::Int32,
#                       refImp::Float64,
#                       noiseData::AbstractArray{Float64,2} )
#
# end

function __init__()
    print( "test" )
    f = NetworkData( rand( 3, 3, 3 ), rand( 3 ), 2, 2.0, rand( 2, 2 ) )
    print( f.data )
end

# GENERAL TOUCHSTONE SYNTAX RULES
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

"""
    parse_options

    Parse out file format properties from the touchstone option line
"""
function parse_options( optionstr::String )::DataOptions

    freqmult = 1
    paramtype = Scattering
    format = MA
    ref_imp = 50

    options = split( optionstr )

    for option in options
        if "ghz" == prop
            freqmult = 1e9
        elseif "mhz" == prop
            freqmult = 1e6
        elseif "khz" == prop
            freqmult = 1e3
        elseif "hz" == prop
            freqmult = 1
        elseif "s" == prop
            paramtype = Scattering
        elseif "y" == prop
            paramtype = Admittance
        elseif "z" == prop
            paramtype = Impedance
        elseif "h" == prop
            paramtype = HybridH
        elseif "g" == prop
            paramtype = HybridG
        elseif "ma" == prop
            format = MA
        elseif "db" == prop
            format = DB
        elseif "ri" == prop
            format = RI
        elseif "r" == prop
            # do nothing
        elseif tryparse( Float64, prop ) !== nothing
            # is number, assume it's the reference impedance
            ref_imp = parse( Float64, prop )
        end
    end

    return DataOptions( freqmult, paramtype, format, ref_imp )
end

"""
    read_normal

    parse the data in lines from a normal touchstone file
"""
function read_normal( portcount::Int32, lines::Vector{String} )::NetworkData

    # Touchstone defaults
    freqmult = 1
    paramtype = Scattering
    format = MA
    ref_imp = 50

    for line in lines
        # eliminate comments
        line = lowercase( split( line, "!" )[begin] )

        if '#' in line
            opts = parse_options( line )
            freqmult = opts.freqmult
            paramtype = opts.paramtype
            format = opts.format
            ref_imp = opts.impedance
        else

        end
        contents = split( line )

        if '#' == contents[1]
            opts = parse_options( line )


    end

end

"""
    read_mixer

    parse data data in lines for touchstone mixer file
"""
function read_mixer( portcount::Int32, lines::Vector{String} )::NetworkData
    # TODO: implement this function

    # Touchstone defaults
    freqmult = 1
    paramtype = Scattering
    format = MA
    ref_imp = 50
    csvmode = false

    for line in lines

        if 'CSV' in line
            csvmode = true
        end

        if csvmode
        else
            contents = split( line )
        end


    end
end

"""
    read_touchstone( path::String )

    Open and parse a file conforming to the Touchstone file format and
    return a corresponding NetworkData object.

    TODO: Check ANSI character encoding compliance
          Error checking is for chumps
"""
function read_touchstone( path::String )::NetworkData
    touchstone_file = open( path, "r" )

    if isfile( touchstone_file )
        extension = split( path, '.' )[2]
        # Offset frequency / mixer touchstones files designated
        # by appended x typically: '.sNpx'
        ismixer = ( 'x' in ext )

        lines = readlines( touchstone_file )

        if ismixer
            portcount = parse( Int32, extension[2:end-2] )
            return read_mixer( portcount, lines )
        else
            portcount = parse( Int32, extension[2:end-1] )
            return read_normal( portcount, lines )
        end
    end
end


function write_touchstone( path::String, network_data::NetworkData )


end # module

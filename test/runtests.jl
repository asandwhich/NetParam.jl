using NetParam
using Test

@time @testset "NetParam Reading" begin
    touchstone_file_names = readdir( "data/touchstone" )

    # Threads.@threads
    for filename in touchstone_file_names
        filepath = string( "data/touchstone/", filename )

        # for excluding mixer files
        if !occursin( "px", lowercase( filename ) )
            # print( filename, '\n' )
            NetParam.read_touchstone( filepath )
        end
    end
end

@time @testset "mixertest" begin
    @test true
end

using NetParam
using Test

@time @testset "NetParam Reading" begin
    # Insert tests here
    print("test")

    touchstone_file_names = readdir( "data/touchstone" )

    # Threads.@threads
    Threads.@threads for filename in touchstone_file_names
        filepath = string( "data/touchstone/", filename )

        # for not exclude mixer files
        if !occursin( "px", lowercase( filename ) )
            print( filename, '\n' )
            passed = false
            try
                NetParam.read_touchstone( filepath )
                passed = true
            catch err
                passed = false
            end
            @test passed
        end
    end
end

@time @testset "mixertest" begin
    @test false
end

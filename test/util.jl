
@testset "test ac ml uc huristic" begin
    @testset "3-bus case" begin
        result = PowerModelsMLD.run_ac_mld_uc(case3_mld, ipopt_solver)

        #println(result["objective"])
        @test result["termination_status"] == PMs.LOCALLY_SOLVED
        @test isapprox(result["objective"], 1.0344; atol = 1e-2)
        #println("active power: $(active_power_served(result))")
        @test isapprox(active_power_served(result), 1.0344; atol = 1e-1)
        @test all_gens_on(result)
        @test all_voltages_on(result)
    end
    @testset "3-bus uc case" begin
        result = PowerModelsMLD.run_ac_mld_uc(case3_mld_uc, ipopt_solver)

        #println(result["objective"])
        @test result["termination_status"] == PMs.LOCALLY_SOLVED
        @test isapprox(result["objective"], 0.49999999; atol = 1e-2)
        #println("active power: $(active_power_served(result))")
        @test isapprox(active_power_served(result), 0.49999999; atol = 1e-1)
        @test isapprox(gen_status(result, "1"), 0.000000; atol = 1e-6)
        @test isapprox(gen_status(result, "2"), 1.000000; atol = 1e-6)
        @test all_voltages_on(result)
    end
    @testset "3-bus line charge case" begin
        result = PowerModelsMLD.run_ac_mld_uc(case3_mld_lc, ipopt_solver)

        #println(result["objective"])
        @test result["termination_status"] == PMs.LOCALLY_SOLVED
        @test isapprox(result["objective"], 210.641; atol = 1e-2)
        #println("active power: $(active_power_served(result))")
        @test isapprox(active_power_served(result), 0.34770; atol = 1e-3)
        #@test all_gens_on(result)
        #println([bus["status"] for (i,bus) in result["solution"]["bus"]])
        @test isapprox(bus_status(result, "1"), 0.0; atol = 1e-4)
        @test isapprox(bus_status(result, "2"), 0.0; atol = 1e-4)
        @test isapprox(bus_status(result, "3"), 0.0; atol = 1e-4)
    end
    @testset "24-bus rts case" begin
        result = PowerModelsMLD.run_ac_mld_uc(case24, ipopt_solver)

        #println(result["objective"])
        @test result["termination_status"] == PMs.LOCALLY_SOLVED
        @test isapprox(result["objective"], 31.83; atol = 1e-1)
        #println("active power: $(active_power_served(result))")
        @test isapprox(active_power_served(result), 28.5; atol = 1e-0)
        @test all_gens_on(result)
        @test all_voltages_on(result)
    end
end

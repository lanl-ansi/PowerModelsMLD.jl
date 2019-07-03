### Max Loading w/ Storage

@testset "test ac ml strg" begin
    @testset "5-bus strg case relaxed" begin
        result = run_mld_strg(case5_mld_strg, ACPPowerModel, juniper_solver)

        #println(result["objective"])
        @test result["termination_status"] == LOCALLY_SOLVED
        @test isapprox(result["objective"], 2286.541959570648; atol = 1e-2)
        #println("active power: $(active_power_served(result))")
        @test isapprox(active_power_served(result), 6.542045207786627; atol = 1e-1)
        @test all_gens_on(result)
        @test all_voltages_on(result)
    end
        @testset "5-bus strg case uc" begin
        result = run_mld_strg_uc(case5_mld_strg_uc, ACPPowerModel, juniper_solver)

        #println(result["objective"])
        @test result["termination_status"] == LOCALLY_SOLVED
        @test isapprox(result["objective"], 2247.51532146452; atol = 1e-2)
        #println("active power: $(active_power_served(result))")
        @test isapprox(active_power_served(result), 7.515735740137701; atol = 1e-1)
        @test isapprox(gen_status(result, "1"), 1.000000; atol = 1e-6)
        @test isapprox(gen_status(result, "2"), 1.000000; atol = 1e-6)
        @test isapprox(gen_status(result, "3"), 1.000000; atol = 1e-6)
        @test isapprox(gen_status(result, "4"), 1.000000; atol = 1e-6)
        @test isapprox(gen_status(result, "5"), 0.000000; atol = 1e-6)
        @test isapprox(storage_status(result, "1"), 1.000000; atol = 1e-6)
        @test isapprox(storage_status(result, "2"), 1.000000; atol = 1e-6)
        @test all_voltages_on(result)
    end
    @testset "5-bus strg only case uc" begin
        result = run_mld_strg_uc(case5_mld_strg_only, ACPPowerModel, juniper_solver)

        #println(result["objective"])
        @test result["termination_status"] == LOCALLY_SOLVED
        @test isapprox(result["objective"], 2081.8773730804032,; atol = 1e-2)
        #println("active power: $(active_power_served(result))")
        @test isapprox(active_power_served(result), 1.8774159199852325; atol = 1e-1)
        @test isapprox(gen_status(result, "1"), 0.000000; atol = 1e-6)
        @test isapprox(gen_status(result, "2"), 0.000000; atol = 1e-6)
        @test isapprox(gen_status(result, "3"), 0.000000; atol = 1e-6)
        @test isapprox(gen_status(result, "4"), 0.000000; atol = 1e-6)
        @test isapprox(gen_status(result, "5"), 0.000000; atol = 1e-6)
        @test isapprox(storage_status(result, "1"), 1.000000; atol = 1e-6)
        @test isapprox(storage_status(result, "2"), 1.000000; atol = 1e-6)
        @test all_voltages_on(result)
    end
end

# NLP solver required until alternate constraints are created for storage 
@testset "test dc ml strg" begin
    @testset "5-bus case" begin
        result = run_mld_strg(case5_mld_strg, DCPPowerModel, juniper_solver)

        #println(result["objective"])
        @test result["termination_status"] == LOCALLY_SOLVED
        @test isapprox(result["objective"], 286.39983018501727; atol = 1e-2)
        #println("active power: $(active_power_served(result))")
        @test isapprox(active_power_served(result), 6.3998903579828195; atol = 1e-1)
        @test all_gens_on(result)
        @test all_voltages_on(result)
    end
    @testset "5-bus strg case uc" begin
        result = run_mld_strg_uc(case5_mld_strg_uc, DCPPowerModel, juniper_solver)

        #println(result["objective"])
        @test result["termination_status"] == LOCALLY_SOLVED
        @test isapprox(result["objective"], 247.8998425256388; atol = 1e-2)
        #println("active power: $(active_power_served(result))")
        @test isapprox(active_power_served(result), 7.899899285192944; atol = 1e-1)
        @test isapprox(gen_status(result, "1"), 1.000000; atol = 1e-6)
        @test isapprox(gen_status(result, "2"), 1.000000; atol = 1e-6)
        @test isapprox(gen_status(result, "3"), 1.000000; atol = 1e-6)
        @test isapprox(gen_status(result, "4"), 1.000000; atol = 1e-6)
        @test isapprox(gen_status(result, "5"), 0.000000; atol = 1e-6)
        @test isapprox(storage_status(result, "1"), 1.000000; atol = 1e-6)
        @test isapprox(storage_status(result, "2"), 1.000000; atol = 1e-6)
        @test all_voltages_on(result)
    end
    @testset "5-bus strg only case uc" begin
        result = run_mld_strg_uc(case5_mld_strg_only, DCPPowerModel, juniper_solver)

        #println(result["objective"])
        @test result["termination_status"] == LOCALLY_SOLVED
        @test isapprox(result["objective"], 81.7777331457043; atol = 1e-2)
        #println("active power: $(active_power_served(result))")
        @test isapprox(active_power_served(result), 1.7777505275183447; atol = 1e-1)
        @test isapprox(gen_status(result, "1"), 0.000000; atol = 1e-6)
        @test isapprox(gen_status(result, "2"), 0.000000; atol = 1e-6)
        @test isapprox(gen_status(result, "3"), 0.000000; atol = 1e-6)
        @test isapprox(gen_status(result, "4"), 0.000000; atol = 1e-6)
        @test isapprox(gen_status(result, "5"), 0.000000; atol = 1e-6)
        @test isapprox(storage_status(result, "1"), 1.000000; atol = 1e-6)
        @test isapprox(storage_status(result, "2"), 1.000000; atol = 1e-6)
        @test all_voltages_on(result)
    end
end


# SOCWRPowerModel does not support storage yet
@testset "test soc ml strg" begin
    # @testset "5-bus case" begin
    #     result = run_mld_strg(case5_mld_strg, SOCWRPowerModel, juniper_solver)

    #     #println(result["objective"])
    #     @test result["termination_status"] == LOCALLY_SOLVED
    #     @test isapprox(result["objective"], 286.6276942310463; atol = 1e-2)
    #     #println("active power: $(active_power_served(result))")
    #     @test isapprox(active_power_served(result), 6.683425000630671; atol = 1e-1)
    #     @test all_gens_on(result)
    #     @test all_voltages_on(result)
    # end
end


### Max Loading Tests

@testset "test ac ml" begin
    @testset "3-bus case" begin
        result = run_mld(case3_mld, PMs.ACPPowerModel, ipopt_solver)

        #println(result["objective"])
        @test result["status"] == :LocalOptimal
        @test isapprox(result["objective"], 321.0343994279289; atol = 1e-2)
        #println("active power: $(active_power_served(result))")
        @test isapprox(active_power_served(result), 1.0343967674927383; atol = 1e-1)
        @test all_gens_on(result)
        @test all_voltages_on(result)
    end
    @testset "3-bus shunt case" begin
        result = run_mld(case3_mld_s, PMs.ACPPowerModel, ipopt_solver)

        #println(result["objective"])
        @test result["status"] == :LocalOptimal
        @test isapprox(result["objective"], 339.012705296994; atol = 1e-2)
        #println("active power: $(active_power_served(result))")
        @test isapprox(active_power_served(result), 0.795164947910047; atol = 1e-1)
        @test all_gens_on(result)
        @test all_voltages_on(result)
        #TODO add test where branch "2" is turned on
    end
    @testset "3-bus uc case" begin
        result = run_mld(case3_mld_uc, PMs.ACPPowerModel, ipopt_solver)

        #println(result["objective"])
        @test result["status"] == :LocalOptimal
        @test isapprox(result["objective"], 317.95051383124365; atol = 1e-2)
        #println("active power: $(active_power_served(result))")
        @test isapprox(active_power_served(result), 1.1343966796133428; atol = 1e-1)
        @test isapprox(gen_status(result, "1"), 0.681614; atol = 1e-4)
        @test isapprox(gen_status(result, "2"), 1.000000; atol = 1e-4)
        @test all_voltages_on(result)
    end
    @testset "3-bus line charge case" begin
        result = run_mld(case3_mld_lc, PMs.ACPPowerModel, ipopt_solver)

        #println(result["objective"])
        @test result["status"] == :LocalOptimal
        @test isapprox(result["objective"], 189.67617468355436; atol = 1e-2)
        #println("active power: $(active_power_served(result))")
        @test isapprox(active_power_served(result), 0.008694494772611786; atol = 1e-1)
        @test all_gens_on(result)
        #println([bus["status"] for (i,bus) in result["solution"]["bus"]])
        @test isapprox(bus_status(result, "1"), 1.0; atol = 1e-4)
        @test isapprox(bus_status(result, "2"), 0.796675; atol = 1e-2)
        @test isapprox(bus_status(result, "3"), 1.02784e-8; atol = 1e-2)
    end
    @testset "24-bus rts case" begin
        result = run_mld(case24, PMs.ACPPowerModel, ipopt_solver)

        #println(result["objective"])
        @test result["status"] == :LocalOptimal
        @test isapprox(result["objective"], 9152.70006919554; atol = 1e-2)
        #println("active power: $(active_power_served(result))")
        @test isapprox(active_power_served(result), 28.49999877675928; atol = 1e-0)
        @test all_gens_on(result)
        @test all_voltages_on(result)
    end
end

case3_mld_ub = run_mld(case3_mld, PMs.ACPPowerModel, ipopt_solver)["objective"]
case3_mld_s_ub = run_mld(case3_mld_s, PMs.ACPPowerModel, ipopt_solver)["objective"]
case3_mld_uc_ub = run_mld(case3_mld_uc, PMs.ACPPowerModel, ipopt_solver)["objective"]
case24_ub = run_mld(case24, PMs.ACPPowerModel, ipopt_solver)["objective"]


@testset "test dc ml" begin
    @testset "3-bus case" begin
        result = run_mld(case3_mld, PMs.DCPPowerModel, ipopt_solver)

        #println(result)
        #println(result["objective"])
        @test result["status"] == :LocalOptimal
        @test isapprox(result["objective"], 21.158217744648525; atol = 1e-2)
        #println("active power: $(active_power_served(result))")
        @test isapprox(active_power_served(result), 1.1582177246877814; atol = 1e-1)
        @test all_gens_on(result)
    end
    @testset "3-bus shunt case" begin
        result = run_mld(case3_mld_s, PMs.DCPPowerModel, ipopt_solver)

        #println(result["objective"])
        @test result["status"] == :LocalOptimal
        @test isapprox(result["objective"], 41.37051189714199; atol = 1e-2)
        #println("active power: $(active_power_served(result))")
        @test isapprox(active_power_served(result), 1.370511858660896; atol = 1e-1)
        @test all_gens_on(result)
        #TODO add test where branch "2" is turned on
    end
    @testset "3-bus uc case" begin
        result = run_mld(case3_mld_uc, PMs.DCPPowerModel, ipopt_solver)

        #println(result["objective"])
        @test result["status"] == :LocalOptimal
        @test isapprox(result["objective"], 19.239460676642224; atol = 1e-2)
        #println("active power: $(active_power_served(result))")
        @test isapprox(active_power_served(result), 1.2582176367462893; atol = 1e-1)
        @test isapprox(gen_status(result, "1"), 0.7981242774648455; atol = 1e-4)
        @test isapprox(gen_status(result, "2"), 1.000000; atol = 1e-4)
    end
    @testset "3-bus line charge case" begin
        result = run_mld(case3_mld_lc, PMs.DCPPowerModel, ipopt_solver)

        #println(result["objective"])
        @test result["status"] == :LocalOptimal
        @test isapprox(result["objective"], 10.58051212014409; atol = 1e-2)
        #println("active power: $(active_power_served(result))")
        @test isapprox(active_power_served(result), 0.5805121110548641; atol = 1e-1)
        @test all_gens_on(result)
    end
    @testset "24-bus rts case" begin
        result = run_mld(case24, PMs.DCPPowerModel, ipopt_solver)

        #println(result)
        #println(result["objective"])
        @test result["status"] == :LocalOptimal
        @test isapprox(result["objective"], 1160.65; atol = 1e-2)
        #println("active power: $(active_power_served(result))")
        @test isapprox(active_power_served(result), 28.453537816101903; atol = 1e-0)
        @test all_gens_on(result)
    end
end


@testset "test soc ml" begin
    @testset "3-bus case" begin
        result = run_mld(case3_mld, PMs.SOCWRPowerModel, ipopt_solver)

        #println(result["objective"])
        @test result["status"] == :LocalOptimal
        @test isapprox(result["objective"], 321.2196411074043; atol = 1e-2)
        #println("active power: $(active_power_served(result))")
        @test isapprox(active_power_served(result), 1.2196381783402782; atol = 1e-1)
        @test all_gens_on(result)
        @test all_voltages_on(result)
        @test result["objective"]/case3_mld_ub >= 1.0 - opt_gap_tol
    end
    @testset "3-bus shunt case" begin
        result = run_mld(case3_mld_s, PMs.SOCWRPowerModel, ipopt_solver)

        #println(result["objective"])
        @test result["status"] == :LocalOptimal
        @test isapprox(result["objective"], 339.60194869178946; atol = 1e-2)
        #println("active power: $(active_power_served(result))")
        @test isapprox(active_power_served(result), 0.7951648586134081; atol = 1e-1)
        @test all_gens_on(result)
        @test all_voltages_on(result)
        #TODO add test where branch "2" is turned on
        @test result["objective"]/case3_mld_s_ub >= 1.0 - opt_gap_tol
    end
    @testset "3-bus case uc" begin
        result = run_mld(case3_mld_uc, PMs.SOCWRPowerModel, ipopt_solver)

        #println(result["objective"])
        @test result["status"] == :LocalOptimal
        @test isapprox(result["objective"], 320.14956871083746; atol = 1e-2)
        #println("active power: $(active_power_served(result))")
        @test isapprox(active_power_served(result), 1.319638090638242; atol = 1e-1)
        @test isapprox(gen_status(result, "1"), 0.8830430937050369; atol = 1e-4)
        @test isapprox(gen_status(result, "2"), 1.000000; atol = 1e-4)
        @test all_voltages_on(result)
        @test result["objective"]/case3_mld_uc_ub >= 1.0 - opt_gap_tol
    end
    @testset "3-bus line charge case" begin
        result = run_mld(case3_mld_lc, PMs.SOCWRPowerModel, ipopt_solver)

        #println(result["objective"])
        @test result["status"] == :LocalOptimal
        @test isapprox(result["objective"], 210.64079640410367; atol = 1e-2)
        #println("active power: $(active_power_served(result))")
        @test isapprox(active_power_served(result), 0.347705761474513; atol = 1e-1)
        @test all_gens_on(result)
        #println([bus["status"] for (i,bus) in result["solution"]["bus"]])
        @test isapprox(bus_status(result, "1"), 0.881391; atol = 1e-2)
        @test isapprox(bus_status(result, "2"), 0.560770; atol = 1e-2)
        @test isapprox(bus_status(result, "3"), 0.560770; atol = 1e-2)
    end
    @testset "24-bus rts case" begin
        result = run_mld(case24, PMs.SOCWRPowerModel, ipopt_solver)

        #println(result["objective"])
        @test result["status"] == :LocalOptimal
        @test isapprox(result["objective"], 9152.700068450631; atol = 1e-2)
        #println("active power: $(active_power_served(result))")
        @test isapprox(active_power_served(result), 28.49999877675928; atol = 1e-0)
        @test all_gens_on(result)
        @test all_voltages_on(result)
        @test result["objective"]/case24_ub >= 1.0 - opt_gap_tol
    end
end

# stop supporting QC because bus voltage on/off is tedious to implement
#=
@testset "test qc ml" begin
    @testset "3-bus case" begin
        result = run_mld(case3_mld, PMs.QCWRPowerModel, ipopt_solver)

        println(result["objective"])
        @test result["status"] == :LocalOptimal
        #@test isapprox(result["objective"], 51.118520841468644; atol = 1e-2)
        #println("active power: $(active_power_served(result))")
        @test isapprox(active_power_served(result), 1.1185212567455372; atol = 1e-1)
        @test all_gens_on(result)
        @test all_voltages_on(result)
        @test result["objective"]/case3_mld_ub >= 1.0 - opt_gap_tol
    end
    @testset "3-bus shunt case" begin
        result = run_mld(case3_mld_s, PMs.QCWRPowerModel, ipopt_solver)

        println(result["objective"])
        @test result["status"] == :LocalOptimal
        #@test isapprox(result["objective"], 49.01270212392994; atol = 1e-2)
        #println("active power: $(active_power_served(result))")
        @test isapprox(active_power_served(result), 0.795164852069185; atol = 1e-1)
        @test all_gens_on(result)
        @test all_voltages_on(result)
        #TODO add test where branch "2" is turned on
        @test result["objective"]/case3_mld_s_ub >= 1.0 - opt_gap_tol
    end
    @testset "3-bus uc case" begin
        result = run_mld(case3_mld_uc, PMs.QCWRPowerModel, ipopt_solver)

        println(result["objective"])
        @test result["status"] == :LocalOptimal
        #@test isapprox(result["objective"], 48.96619870361255; atol = 1e-2)
        #println("active power: $(active_power_served(result))")
        @test isapprox(active_power_served(result), 1.2185210778391826; atol = 1e-1)
        @test isapprox(gen_status(result, "1"), 0.7747675203992428; atol = 1e-4)
        @test isapprox(gen_status(result, "2"), 1.000000; atol = 1e-4)
        @test all_voltages_on(result)
        @test result["objective"]/case3_mld_uc_ub >= 1.0 - opt_gap_tol
    end
    @testset "3-bus line charge case" begin
        result = run_mld(case3_mld_lc, PMs.QCWRPowerModel, ipopt_solver)

        println(result["objective"])
        @test result["status"] == :LocalOptimal
        #@test isapprox(result["objective"], 326.89562490859475; atol = 1e-2)
        println("active power: $(active_power_served(result))")
        #@test isapprox(active_power_served(result), 0.4128996074212094; atol = 1e-1)
        @test all_gens_on(result)
        println([bus["status"] for (i,bus) in result["solution"]["bus"]])
        #@test isapprox(bus_status(result, "1"), 1.0; atol = 1e-4)
        #@test isapprox(bus_status(result, "2"), 0.9305186423983485; atol = 1e-2)
        #@test isapprox(bus_status(result, "3"), 0.9343086026987113; atol = 1e-2)
    end
    @testset "24-bus rts case" begin
        result = run_mld(case24, PMs.QCWRPowerModel, ipopt_solver)

        println(result["objective"])
        @test result["status"] == :LocalOptimal
        #@test isapprox(result["objective"], 1926.6000112270171; atol = 1e-2)
        #println("active power: $(active_power_served(result))")
        @test isapprox(active_power_served(result), 28.499998760431113; atol = 1e-0)
        @test all_gens_on(result)
        @test all_voltages_on(result)
        @test result["objective"]/case24_ub >= 1.0 - opt_gap_tol
    end
end
=#

@testset "test sdp ml" begin
    @testset "3-bus case" begin
        result = run_mld(case3_mld, PMs.SDPWRMPowerModel, scs_solver)

        #println(result["objective"])
        @test result["status"] == :Optimal
        @test isapprox(result["objective"], 321.03573785052635; atol = 1e-1)
        #println("active power: $(active_power_served(result))")
        @test isapprox(active_power_served(result), 1.0356333562919656; atol = 1e-1)
        @test all_gens_on(result)
        @test all_voltages_on(result)
        @test result["objective"]/case3_mld_ub >= 1.0 - opt_gap_tol
    end
    @testset "3-bus shunt case" begin
        result = run_mld(case3_mld_s, PMs.SDPWRMPowerModel, scs_solver)

        #println(result["objective"])
        @test result["status"] == :Optimal
        @test isapprox(result["objective"], 339.608; atol = 1e-2)
        #println("active power: $(active_power_served(result))")
        @test isapprox(active_power_served(result), 0.7951417073393225; atol = 1e-1)
        @test all_gens_on(result)
        @test all_voltages_on(result)
        #TODO add test where branch "2" is turned on
        @test result["objective"]/case3_mld_s_ub >= 1.0 - opt_gap_tol
    end
    @testset "3-bus uc case" begin
        result = run_mld(case3_mld_uc, PMs.SDPWRMPowerModel, scs_solver)

        #println(result["objective"])
        @test result["status"] == :Optimal
        # UnknownError is seems to occur on Linux
        #@test result["status"] == :Infeasible || result["status"] == :UnknownError
        @test isapprox(result["objective"], 317.95315458497123; atol = 1e-2)
        #println("active power: $(active_power_served(result))")
        @test isapprox(active_power_served(result), 1.1352542434823208; atol = 1e-1)
        @test isapprox(gen_status(result, "1"), 0.681722; atol = 2e-4)
        @test isapprox(gen_status(result, "2"), 1.000000; atol = 1e-4)
        @test all_voltages_on(result)
        @test result["objective"]/case3_mld_uc_ub >= 1.0 - opt_gap_tol
    end
    @testset "3-bus line charge case" begin
        result = run_mld(case3_mld_lc, PMs.SDPWRMPowerModel, scs_solver)

        #println(result["objective"])
        @test result["status"] == :Optimal
        @test isapprox(result["objective"], 210.64571064033981; atol = 1e-2)
        #println("active power: $(active_power_served(result))")
        @test isapprox(active_power_served(result), 0.3477251597699522; atol = 1e-1)
        @test all_gens_on(result)
        #println([bus["status"] for (i,bus) in result["solution"]["bus"]])
        @test isapprox(bus_status(result, "1"), 0.881014; atol = 1e-2)
        @test isapprox(bus_status(result, "2"), 0.560613; atol = 1e-2)
        @test isapprox(bus_status(result, "3"), 0.560626; atol = 1e-2)
    end
    # TODO replace this with smaller case, way too slow for unit testing
    #@testset "24-bus rts case" begin
    #    result = run_mld(case24, PMs.SDPWRMPowerModel, scs_solver)
    #    PowerModels.make_mixed_units(result["solution"])

    #    @test result["status"] == :Optimal
    #    @test isapprox(result["objective"], 34.29; atol = 1e-2)
    #end
end


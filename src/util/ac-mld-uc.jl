
"implements a scalable huristic solution to the AC-MLD problem"
function run_ac_mld_uc(case::Dict{String,<:Any}, solver; modifications::Dict{String,<:Any}=Dict{String,Any}("per_unit" => case["per_unit"]), setting::Dict{String,<:Any}=Dict{String,Any}(), int_tol::Real=1e-6)
    case = deepcopy(case)
    PMs.update_data(case, modifications)

    PMs.propagate_topology_status(case)
    PMs.select_largest_component(case)
    #PMs.check_refrence_buses(case)

    if length(setting) != 0
        Memento.info(LOGGER, "settings: $(setting)")
    end


    soc_result = run_mld(case, PMs.SOCWRPowerModel, solver; setting=setting)

    @assert (soc_result["status"] == :LocalOptimal)
    soc_sol = soc_result["solution"]

    soc_active_delivered = sum([if (case["load"][i]["status"] != 0) load["pd"] else 0.0 end for (i,load) in soc_sol["load"]])
    soc_active_output = sum([if (isequal(gen["pg"], NaN) || gen["gen_status"] == 0) 0.0 else gen["pg"] end for (i,gen) in soc_sol["gen"]])
    Memento.info(LOGGER, "soc active gen:    $(soc_active_output)")
    Memento.info(LOGGER, "soc active demand: $(soc_active_delivered)")


    for (i,bus) in soc_sol["bus"]
        if !isequal(bus["status"], NaN) && case["bus"][i]["bus_type"] != 4 && bus["status"] <= 1-int_tol
            case["bus"][i]["bus_type"] = 4
            Memento.info(LOGGER, "removing bus $i, $(bus["status"])")
        end
    end

    for (i,gen) in soc_sol["gen"]
        if !isequal(gen["gen_status"], NaN) && case["gen"][i]["gen_status"] != 0 && gen["gen_status"] <= 1-int_tol
            case["gen"][i]["gen_status"] = 0
            Memento.info(LOGGER, "removing gen $i, $(gen["gen_status"])")
        end
    end

    PMs.propagate_topology_status(case)

    bus_count = sum([if (case["bus"][i]["bus_type"] != 4) 1 else 0 end for (i,bus) in case["bus"]])

    if bus_count <= 0
        result = soc_result
    else
        PMs.select_largest_component(case)

        ac_result = run_mld_smpl(case, PMs.ACPPowerModel, solver; setting=setting)
        ac_result["solve_time"] = ac_result["solve_time"] + soc_result["solve_time"]

        # update solution with status values
        ac_sol = ac_result["solution"]

        result = ac_result
    end


    sol = result["solution"]
    for (i,bus) in case["bus"]
        if bus["bus_type"] != 4
            sol["bus"][i]["status"] = 1
        else
            sol["bus"][i]["status"] = 0
        end

        if !haskey(sol["bus"][i], "va")
            sol["bus"][i]["va"] = 0.0
        end
    end

    for (i,gen) in case["gen"]
        sol["gen"][i]["gen_status"] = gen["gen_status"]
    end

    if haskey(sol, "branch")
        for (i,branch) in case["branch"]
            sol["branch"][i]["br_status"] = branch["br_status"]

            # fairly hacky.  Can probably be removed once PTI is supported directly.
            sol["branch"][i]["f_bus"] = branch["f_bus"]
            sol["branch"][i]["t_bus"] = branch["t_bus"]
            sol["branch"][i]["transformer"] = branch["transformer"]
        end
    end

    active_delivered = sum([if (case["load"][i]["status"] != 0) load["pd"] else 0.0 end for (i,load) in sol["load"]])
    active_output = sum([if (isequal(gen["pg"], NaN) || gen["gen_status"] == 0) 0.0 else gen["pg"] end for (i,gen) in sol["gen"]])
    Memento.info(LOGGER, "ac active gen:    $active_output")
    Memento.info(LOGGER, "ac active demand: $active_delivered")


    return result
end
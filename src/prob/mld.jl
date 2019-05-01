# Formulations of Various Maximum Loadability Problems
export run_mld, run_mld_smpl, run_mld_uc

# Maximum loadability with generator and bus participation relaxed
function run_mld(file, model_constructor, solver; kwargs...)
    return PMs.run_generic_model(file, model_constructor, solver, post_mld; solution_builder = get_mld_solution, kwargs...)
end

function post_mld(pm::PMs.GenericPowerModel)
    variable_bus_voltage_indicator(pm, relax=true)
    variable_bus_voltage_on_off(pm)

    variable_generation_indicator(pm, relax=true)
    variable_generation_on_off(pm)

    PMs.variable_branch_flow(pm)
    PMs.variable_dcline_flow(pm)

    variable_demand_factor(pm)
    variable_shunt_factor(pm)


    objective_max_loadability(pm)


    for i in PMs.ids(pm, :ref_buses)
        PMs.constraint_theta_ref(pm, i)
    end
    constraint_bus_voltage_on_off(pm)

    for i in PMs.ids(pm, :gen)
        constraint_generation_on_off(pm, i)
    end

    for i in PMs.ids(pm, :bus)
        constraint_kcl_shunt_shed(pm, i)
    end

    for i in PMs.ids(pm, :branch)
        PMs.constraint_ohms_yt_from(pm, i)
        PMs.constraint_ohms_yt_to(pm, i)

        PMs.constraint_voltage_angle_difference(pm, i)

        PMs.constraint_thermal_limit_from(pm, i)
        PMs.constraint_thermal_limit_to(pm, i)
    end

    for i in PMs.ids(pm, :dcline)
        PMs.constraint_dcline(pm, i)
    end
end


# this is the same as above, but variable_generation_indicator constraints are *not* relaxed

# Maximum loadability with flexible generator participation fixed
function run_mld_uc(file, model_constructor, solver; kwargs...)
    return PMs.run_generic_model(file, model_constructor, solver, post_mld_uc; solution_builder = get_mld_solution, kwargs...)
end

function post_mld_uc(pm::PMs.GenericPowerModel)
    variable_bus_voltage_indicator(pm)
    variable_bus_voltage_on_off(pm)

    variable_generation_indicator(pm)
    variable_generation_on_off(pm)

    PMs.variable_branch_flow(pm)
    PMs.variable_dcline_flow(pm)

    variable_demand_factor(pm)
    variable_shunt_factor(pm)


    objective_max_loadability(pm)


    for i in PMs.ids(pm, :ref_buses)
        PMs.constraint_theta_ref(pm, i)
    end
    constraint_bus_voltage_on_off(pm)


    for i in PMs.ids(pm, :gen)
        constraint_generation_on_off(pm, i)
    end

    for i in PMs.ids(pm, :bus)
        constraint_kcl_shunt_shed(pm, i)
    end

    for i in PMs.ids(pm, :branch)
        PMs.constraint_ohms_yt_from(pm, i)
        PMs.constraint_ohms_yt_to(pm, i)

        PMs.constraint_voltage_angle_difference(pm, i)

        PMs.constraint_thermal_limit_from(pm, i)
        PMs.constraint_thermal_limit_to(pm, i)
    end

    for i in PMs.ids(pm, :dcline)
        PMs.constraint_dcline(pm, i)
    end
end


function get_mld_solution(pm::PMs.GenericPowerModel, sol::Dict{String,Any})
    PMs.add_bus_voltage_setpoint(sol, pm)
    PMs.add_generator_power_setpoint(sol, pm)
    PMs.add_branch_flow_setpoint(sol, pm)
    add_bus_status_setpoint(sol, pm)
    add_load_setpoint(sol, pm)
    add_shunt_setpoint(sol, pm)
    add_generator_status_setpoint(sol, pm)
end

function add_load_setpoint(sol, pm::PMs.GenericPowerModel)
    PMs.add_setpoint(sol, pm, "load", "pd", :z_demand; scale = (x,item,i) -> x*item["pd"][i])
    PMs.add_setpoint(sol, pm, "load", "qd", :z_demand; scale = (x,item,i) -> x*item["qd"][i])
    PMs.add_setpoint(sol, pm, "load", "status", :z_demand; default_value = (item) -> if (item["status"] == 0) 0.0 else 1.0 end)
end

function add_shunt_setpoint(sol, pm::PMs.GenericPowerModel)
    PMs.add_setpoint(sol, pm, "shunt", "gs", :z_shunt; scale = (x,item,i) -> x*item["gs"][i])
    PMs.add_setpoint(sol, pm, "shunt", "bs", :z_shunt; scale = (x,item,i) -> x*item["bs"][i])
    PMs.add_setpoint(sol, pm, "shunt", "status", :z_shunt; default_value = (item) -> if (item["status"] == 0) 0.0 else 1.0 end)
end

function add_bus_status_setpoint(sol, pm::PMs.GenericPowerModel)
    PMs.add_setpoint(sol, pm, "bus", "status", :z_voltage; default_value = (item) -> if item["bus_type"] == 4 0.0 else 1.0 end)
end

function add_generator_status_setpoint(sol, pm::PMs.GenericPowerModel)
    PMs.add_setpoint(sol, pm, "gen", "gen_status", :z_gen; default_value = (item) -> item["gen_status"]*1.0)
end




# Maximum loadability with generator participation fixed
function run_mld_smpl(file, model_constructor, solver; kwargs...)
    return PMs.run_generic_model(file, model_constructor, solver, run_mld_smpl; solution_builder = get_mld_smpl_solution, kwargs...)
end

function run_mld_smpl(pm::PMs.GenericPowerModel)
    PMs.variable_voltage(pm, bounded = false)
    PMs.variable_generation(pm, bounded = false)

    PMs.variable_branch_flow(pm)
    PMs.variable_dcline_flow(pm)

    variable_demand_factor(pm)
    variable_shunt_factor(pm)

    PMs.var(pm)[:vm_vio] = JuMP.@variable(pm.model, vm_vio[i in PMs.ids(pm, :bus)] >= 0)
    PMs.var(pm)[:pg_vio] = JuMP.@variable(pm.model, pg_vio[i in PMs.ids(pm, :gen)] >= 0)
    vm = PMs.var(pm, :vm)
    pg = PMs.var(pm, :pg)
    qg = PMs.var(pm, :qg)

    z_demand = PMs.var(pm, :z_demand)
    z_shunt = PMs.var(pm, :z_shunt)

    M = maximum([abs(load["pd"]) for (i,load) in PMs.ref(pm, :load)])
    JuMP.@objective(pm.model, Max,
        sum( -10*M*vm_vio[i] for (i, bus) in PMs.ref(pm, :bus)) +
        sum( -10*M*pg_vio[i] for i in PMs.ids(pm, :gen) ) +
        sum( M*z_shunt[i] for (i, shunt) in PMs.ref(pm, :shunt)) +
        sum( abs(load["pd"])*z_demand[i] for (i, load) in PMs.ref(pm, :load))
    )

    for i in PMs.ids(pm, :ref_buses)
        PMs.constraint_theta_ref(pm, i)
    end

    PMs.constraint_voltage(pm)

    for (i, bus) in PMs.ref(pm, :bus)
        constraint_kcl_shunt_shed(pm, i)

        JuMP.@constraint(pm.model, vm[i] <= bus["vmax"] + vm_vio[i])
        JuMP.@constraint(pm.model, vm[i] >= bus["vmin"] - vm_vio[i])
    end

    for (i, gen) in PMs.ref(pm, :gen)
        JuMP.@constraint(pm.model, pg[i] <= gen["pmax"] + pg_vio[i])
        JuMP.@constraint(pm.model, pg[i] >= gen["pmin"] - pg_vio[i])

        JuMP.@constraint(pm.model, qg[i] <= gen["qmax"])
        JuMP.@constraint(pm.model, qg[i] >= gen["qmin"])
    end

    for i in PMs.ids(pm, :branch)
        PMs.constraint_ohms_yt_from(pm, i)
        PMs.constraint_ohms_yt_to(pm, i)

        PMs.constraint_voltage_angle_difference(pm, i)

        PMs.constraint_thermal_limit_from(pm, i)
        PMs.constraint_thermal_limit_to(pm, i)
    end
end


function get_mld_smpl_solution(pm::PMs.GenericPowerModel, sol::Dict{String,Any})
    PMs.add_bus_voltage_setpoint(sol, pm)
    PMs.add_generator_power_setpoint(sol, pm)
    PMs.add_branch_flow_setpoint(sol, pm)
    add_load_setpoint(sol, pm)
    add_shunt_setpoint(sol, pm)
end

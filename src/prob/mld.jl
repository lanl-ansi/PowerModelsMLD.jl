# Maximum loadability with generator and bus participation relaxed
function run_mld(file, model_constructor, solver; kwargs...)
    return _PMs.run_model(file, model_constructor, solver, post_mld; solution_builder = solution_mld, kwargs...)
end

function post_mld(pm::_PMs.GenericPowerModel)
    variable_bus_voltage_indicator(pm, relax=true)
    variable_bus_voltage_on_off(pm)

    _PMs.variable_generation_indicator(pm, relax=true)
    _PMs.variable_generation_on_off(pm)

    _PMs.variable_branch_flow(pm)
    _PMs.variable_dcline_flow(pm)

    variable_demand_factor(pm)
    variable_shunt_factor(pm)


    objective_max_loadability(pm)


    for i in _PMs.ids(pm, :ref_buses)
        _PMs.constraint_theta_ref(pm, i)
    end
    constraint_bus_voltage_on_off(pm)

    for i in _PMs.ids(pm, :gen)
        _PMs.constraint_generation_on_off(pm, i)
    end

    for i in _PMs.ids(pm, :bus)
        constraint_power_balance_shunt_shed(pm, i)
    end

    for i in _PMs.ids(pm, :branch)
        _PMs.constraint_ohms_yt_from(pm, i)
        _PMs.constraint_ohms_yt_to(pm, i)

        _PMs.constraint_voltage_angle_difference(pm, i)

        _PMs.constraint_thermal_limit_from(pm, i)
        _PMs.constraint_thermal_limit_to(pm, i)
    end

    for i in _PMs.ids(pm, :dcline)
        _PMs.constraint_dcline(pm, i)
    end
end


# this is the same as above, but variable_generation_indicator constraints are *not* relaxed

# Maximum loadability with flexible generator participation fixed
function run_mld_uc(file, model_constructor, solver; kwargs...)
    return _PMs.run_model(file, model_constructor, solver, post_mld_uc; solution_builder = solution_mld, kwargs...)
end

function post_mld_uc(pm::_PMs.GenericPowerModel)
    variable_bus_voltage_indicator(pm)
    variable_bus_voltage_on_off(pm)

    _PMs.variable_generation_indicator(pm)
    _PMs.variable_generation_on_off(pm)

    _PMs.variable_branch_flow(pm)
    _PMs.variable_dcline_flow(pm)

    variable_demand_factor(pm)
    variable_shunt_factor(pm)


    objective_max_loadability(pm)


    for i in _PMs.ids(pm, :ref_buses)
        _PMs.constraint_theta_ref(pm, i)
    end
    constraint_bus_voltage_on_off(pm)


    for i in _PMs.ids(pm, :gen)
        _PMs.constraint_generation_on_off(pm, i)
    end

    for i in _PMs.ids(pm, :bus)
        constraint_power_balance_shunt_shed(pm, i)
    end

    for i in _PMs.ids(pm, :branch)
        _PMs.constraint_ohms_yt_from(pm, i)
        _PMs.constraint_ohms_yt_to(pm, i)

        _PMs.constraint_voltage_angle_difference(pm, i)

        _PMs.constraint_thermal_limit_from(pm, i)
        _PMs.constraint_thermal_limit_to(pm, i)
    end

    for i in _PMs.ids(pm, :dcline)
        _PMs.constraint_dcline(pm, i)
    end
end


function solution_mld(pm::_PMs.GenericPowerModel, sol::Dict{String,Any})
    _PMs.add_setpoint_bus_voltage!(sol, pm)
    _PMs.add_setpoint_generator_power!(sol, pm)
    _PMs.add_setpoint_branch_flow!(sol, pm)
    _PMs.add_setpoint_generator_status!(sol, pm)
    add_setpoint_bus_status!(sol, pm)
    add_setpoint_load!(sol, pm)
    add_setpoint_shunt!(sol, pm)
end

function add_setpoint_load!(sol, pm::_PMs.GenericPowerModel)
    _PMs.add_setpoint!(sol, pm, "load", "pd", :z_demand; scale = (x,item,i) -> x*item["pd"][i])
    _PMs.add_setpoint!(sol, pm, "load", "qd", :z_demand; scale = (x,item,i) -> x*item["qd"][i])
    _PMs.add_setpoint!(sol, pm, "load", "status", :z_demand; default_value = (item) -> if (item["status"] == 0) 0.0 else 1.0 end)
end

function add_setpoint_shunt!(sol, pm::_PMs.GenericPowerModel)
    _PMs.add_setpoint!(sol, pm, "shunt", "gs", :z_shunt; scale = (x,item,i) -> x*item["gs"][i])
    _PMs.add_setpoint!(sol, pm, "shunt", "bs", :z_shunt; scale = (x,item,i) -> x*item["bs"][i])
    _PMs.add_setpoint!(sol, pm, "shunt", "status", :z_shunt; default_value = (item) -> if (item["status"] == 0) 0.0 else 1.0 end)
end

function add_setpoint_bus_status!(sol, pm::_PMs.GenericPowerModel)
    _PMs.add_setpoint!(sol, pm, "bus", "status", :z_voltage, status_name="bus_type", inactive_status_value = 4, conductorless=true, default_value = (item) -> if item["bus_type"] == 4 0.0 else 1.0 end)
end


# Maximum loadability with generator participation fixed
function run_mld_smpl(file, model_constructor, solver; kwargs...)
    return _PMs.run_model(file, model_constructor, solver, run_mld_smpl; solution_builder = solution_mld_smpl, kwargs...)
end

function run_mld_smpl(pm::_PMs.GenericPowerModel)
    _PMs.variable_voltage(pm, bounded = false)
    _PMs.variable_generation(pm, bounded = false)

    _PMs.variable_branch_flow(pm)
    _PMs.variable_dcline_flow(pm)

    variable_demand_factor(pm)
    variable_shunt_factor(pm)

    _PMs.var(pm)[:vm_vio] = JuMP.@variable(pm.model, vm_vio[i in _PMs.ids(pm, :bus)] >= 0)
    _PMs.var(pm)[:pg_vio] = JuMP.@variable(pm.model, pg_vio[i in _PMs.ids(pm, :gen)] >= 0)
    vm = _PMs.var(pm, :vm)
    pg = _PMs.var(pm, :pg)
    qg = _PMs.var(pm, :qg)

    z_demand = _PMs.var(pm, :z_demand)
    z_shunt = _PMs.var(pm, :z_shunt)

    load_weight = Dict(i => get(load, "weight", 1.0) for (i,load) in _PMs.ref(pm, :load))

    M = maximum(load_weight[i]*abs(load["pd"]) for (i,load) in _PMs.ref(pm, :load))
    JuMP.@objective(pm.model, Max,
        sum( -10*M*vm_vio[i] for (i, bus) in _PMs.ref(pm, :bus)) +
        sum( -10*M*pg_vio[i] for i in _PMs.ids(pm, :gen) ) +
        sum( M*z_shunt[i] for (i, shunt) in _PMs.ref(pm, :shunt)) +
        sum( load_weight[i]*abs(load["pd"])*z_demand[i] for (i, load) in _PMs.ref(pm, :load))
    )

    for i in _PMs.ids(pm, :ref_buses)
        _PMs.constraint_theta_ref(pm, i)
    end

    _PMs.constraint_model_voltage(pm)

    for (i, bus) in _PMs.ref(pm, :bus)
        constraint_power_balance_shunt_shed(pm, i)

        JuMP.@constraint(pm.model, vm[i] <= bus["vmax"] + vm_vio[i])
        JuMP.@constraint(pm.model, vm[i] >= bus["vmin"] - vm_vio[i])
    end

    for (i, gen) in _PMs.ref(pm, :gen)
        JuMP.@constraint(pm.model, pg[i] <= gen["pmax"] + pg_vio[i])
        JuMP.@constraint(pm.model, pg[i] >= gen["pmin"] - pg_vio[i])

        JuMP.@constraint(pm.model, qg[i] <= gen["qmax"])
        JuMP.@constraint(pm.model, qg[i] >= gen["qmin"])
    end

    for i in _PMs.ids(pm, :branch)
        _PMs.constraint_ohms_yt_from(pm, i)
        _PMs.constraint_ohms_yt_to(pm, i)

        _PMs.constraint_voltage_angle_difference(pm, i)

        _PMs.constraint_thermal_limit_from(pm, i)
        _PMs.constraint_thermal_limit_to(pm, i)
    end
end


function solution_mld_smpl(pm::_PMs.GenericPowerModel, sol::Dict{String,Any})
    _PMs.add_setpoint_bus_voltage!(sol, pm)
    _PMs.add_setpoint_generator_power!(sol, pm)
    _PMs.add_setpoint_branch_flow!(sol, pm)
    add_setpoint_load!(sol, pm)
    add_setpoint_shunt!(sol, pm)
end



# Maximum loadability with generator and bus participation relaxed
function run_mld_strg(file, model_constructor, solver; kwargs...)
    return _PMs.run_model(file, model_constructor, solver, post_mld_strg; solution_builder = solution_mld, kwargs...)
end

function post_mld_strg(pm::_PMs.GenericPowerModel)
    variable_bus_voltage_indicator(pm, relax=true)
    variable_bus_voltage_on_off(pm)

    _PMs.variable_generation_indicator(pm, relax=true)
    _PMs.variable_generation_on_off(pm)

    _PMs.variable_storage(pm)
    variable_storage_indicator(pm, relax = true)
    variable_storage_on_off(pm)

    _PMs.variable_branch_flow(pm)
    _PMs.variable_dcline_flow(pm)

    variable_demand_factor(pm)
    variable_shunt_factor(pm)


    objective_max_loadability_strg(pm)


    for i in _PMs.ids(pm, :ref_buses)
        _PMs.constraint_theta_ref(pm, i)
    end
    constraint_bus_voltage_on_off(pm)

    for i in _PMs.ids(pm, :gen)
        _PMs.constraint_generation_on_off(pm, i)
    end

    for i in _PMs.ids(pm, :bus)
        constraint_power_balance_shunt_storage_shed(pm, i)
    end

    for i in _PMs.ids(pm, :storage)
        _PMs.constraint_storage_state(pm, i)
        _PMs.constraint_storage_complementarity(pm, i)
        _PMs.constraint_storage_loss(pm, i)
        _PMs.constraint_storage_thermal_limit(pm, i)
    end

    for i in _PMs.ids(pm, :branch)
        _PMs.constraint_ohms_yt_from(pm, i)
        _PMs.constraint_ohms_yt_to(pm, i)

        _PMs.constraint_voltage_angle_difference(pm, i)

        _PMs.constraint_thermal_limit_from(pm, i)
        _PMs.constraint_thermal_limit_to(pm, i)
    end

    for i in _PMs.ids(pm, :dcline)
        _PMs.constraint_dcline(pm, i)
    end
end

function solution_mld_storage(pm::_PMs.GenericPowerModel, sol::Dict{String,Any})
    _PMs.add_setpoint_bus_voltage!(sol, pm)
    _PMs.add_setpoint_generator_power!(sol, pm)
    _PMs.add_setpoint_storage_power!(sol, pm)
    _PMs.add_setpoint_branch_flow!(sol, pm)
    add_setpoint_load!(sol, pm)
    add_setpoint_shunt!(sol, pm)
end

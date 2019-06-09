
function variable_demand_factor(pm::PMs.GenericPowerModel; nw::Int=pm.cnw, cnd::Int=pm.ccnd)
    PMs.var(pm, nw, cnd)[:z_demand] = JuMP.@variable(pm.model,
        [i in PMs.ids(pm, nw, :load)], base_name="$(nw)_$(cnd)_z_demand",
        lower_bound = 0,
        upper_bound = 1,
        start = PMs.comp_start_value(PMs.ref(pm, nw, :load, i), "z_demand_start", cnd, 1.0)
    )
end

function variable_shunt_factor(pm::PMs.GenericPowerModel; nw::Int=pm.cnw, cnd::Int=pm.ccnd)
    PMs.var(pm, nw, cnd)[:z_shunt] = JuMP.@variable(pm.model,
        [i in PMs.ids(pm, nw, :shunt)], base_name="$(nw)_$(cnd)_z_shunt",
        lower_bound = 0,
        upper_bound = 1,
        start = PMs.comp_start_value(PMs.ref(pm, nw, :shunt, i), "z_shunt_nstart", cnd, 1.0)
    )
end

function variable_generation_indicator(pm::PMs.GenericPowerModel; nw::Int=pm.cnw, cnd::Int=pm.ccnd, relax=false)
    if !relax
        PMs.var(pm, nw, cnd)[:z_gen] = JuMP.@variable(pm.model,
            [i in PMs.ids(pm, nw, :gen)], base_name="$(nw)_$(cnd)_z_gen",
            lower_bound = 0,
            upper_bound = 1,
            integer = true,
            start = PMs.comp_start_value(PMs.ref(pm, nw, :gen, i), "z_gen_start", cnd, 1.0)
        )
    else
        PMs.var(pm, nw, cnd)[:z_gen] = JuMP.@variable(pm.model,
            [i in PMs.ids(pm, nw, :gen)], base_name="$(nw)_$(cnd)_z_gen",
            lower_bound = 0,
            upper_bound = 1,
            start = PMs.comp_start_value(PMs.ref(pm, nw, :gen, i), "z_gen_start", cnd, 1.0)
        )
    end
end


function variable_generation_on_off(pm::PMs.GenericPowerModel; kwargs...)
    variable_active_generation_on_off(pm; kwargs...)
    variable_reactive_generation_on_off(pm; kwargs...)
end

function variable_active_generation_on_off(pm::PMs.GenericPowerModel; nw::Int=pm.cnw, cnd::Int=pm.ccnd)
    PMs.var(pm, nw, cnd)[:pg] = JuMP.@variable(pm.model,
        [i in PMs.ids(pm, nw, :gen)], base_name="$(nw)_$(cnd)_pg",
        lower_bound = min(0, PMs.ref(pm, nw, :gen, i, "pmin", cnd)),
        upper_bound = max(0, PMs.ref(pm, nw, :gen, i, "pmax", cnd)),
        start = PMs.comp_start_value(PMs.ref(pm, nw, :gen, i), "pg_start", cnd)
    )
end

function variable_reactive_generation_on_off(pm::PMs.GenericPowerModel; nw::Int=pm.cnw, cnd::Int=pm.ccnd)
    PMs.var(pm, nw, cnd)[:qg] = JuMP.@variable(pm.model,
        [i in PMs.ids(pm, nw, :gen)], base_name="$(nw)_$(cnd)_qg",
        lower_bound = min(0, PMs.ref(pm, nw, :gen, i, "qmin", cnd)),
        upper_bound = max(0, PMs.ref(pm, nw, :gen, i, "qmax", cnd)),
        start = PMs.comp_start_value(PMs.ref(pm, nw, :gen, i), "qg_start", cnd)
    )
end

function variable_bus_voltage_indicator(pm::PMs.GenericPowerModel; nw::Int=pm.cnw, cnd::Int=pm.ccnd, relax = false)
    if !relax
        PMs.var(pm, nw, cnd)[:z_voltage] = JuMP.@variable(pm.model,
            [i in PMs.ids(pm, nw, :bus)], base_name="$(nw)_$(cnd)_z_voltage",
            lower_bound = 0,
            upper_bound = 1,
            integer = true,
            start = PMs.comp_start_value(PMs.ref(pm, nw, :bus, i), "z_voltage_start", cnd, 1.0)
        )
    else
        PMs.var(pm, nw, cnd)[:z_voltage] = JuMP.@variable(pm.model,
            [i in PMs.ids(pm, nw, :bus)], base_name="$(nw)_$(cnd)_z_voltage",
            lower_bound = 0,
            upper_bound = 1,
            start = PMs.comp_start_value(PMs.ref(pm, nw, :bus, i), "z_voltage_start", cnd, 1.0)
        )
    end
end


function variable_voltage_magnitude_on_off(pm::PMs.GenericPowerModel; nw::Int=pm.cnw, cnd::Int=pm.ccnd)
    PMs.var(pm, nw, cnd)[:vm] = JuMP.@variable(pm.model,
        [i in PMs.ids(pm, nw, :bus)], base_name="$(nw)_$(cnd)_vm",
        lower_bound = 0,
        upper_bound = PMs.ref(pm, nw, :bus, i, "vmax", cnd),
        start = PMs.comp_start_value(PMs.ref(pm, nw, :bus, i), "vm_start", cnd, 1.0)
    )
end


function variable_voltage_magnitude_sqr_on_off(pm::PMs.GenericPowerModel; nw::Int=pm.cnw, cnd::Int=pm.ccnd)
    PMs.var(pm, nw, cnd)[:w] = JuMP.@variable(pm.model,
        [i in PMs.ids(pm, nw, :bus)], base_name="$(nw)_$(cnd)_w",
        lower_bound = 0,
        upper_bound = PMs.ref(pm, nw, :bus, i, "vmax", cnd)^2,
        start = PMs.comp_start_value(PMs.ref(pm, nw, :bus, i), "w_start", cnd, 1.001)
    )
end


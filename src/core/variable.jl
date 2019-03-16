
function variable_demand_factor(pm::GenericPowerModel; nw::Int=pm.cnw, cnd::Int=pm.ccnd)
    var(pm, nw, cnd)[:z_demand] = @variable(pm.model, 
        [i in ids(pm, nw, :load)], basename="$(nw)_$(cnd)_z_demand",
        lowerbound = 0,
        upperbound = 1,
        start = PMs.getval(ref(pm, nw, :load, i), "z_demand_start", cnd, 1.0)
    )
end

function variable_shunt_factor(pm::GenericPowerModel; nw::Int=pm.cnw, cnd::Int=pm.ccnd)
    var(pm, nw, cnd)[:z_shunt] = @variable(pm.model, 
        [i in ids(pm, nw, :shunt)], basename="$(nw)_$(cnd)_z_shunt",
        lowerbound = 0,
        upperbound = 1,
        start = PMs.getval(ref(pm, nw, :shunt, i), "z_shunt_nstart", cnd, 1.0)
    )
end

function variable_generation_indicator(pm::GenericPowerModel; nw::Int=pm.cnw, cnd::Int=pm.ccnd, relax=false)
    if !relax
        var(pm, nw, cnd)[:z_gen] = @variable(pm.model,
            [i in ids(pm, nw, :gen)], basename="$(nw)_$(cnd)_z_gen",
            lowerbound = 0,
            upperbound = 1,
            category = :Int, 
            start = PMs.getval(ref(pm, nw, :gen, i), "z_gen_start", cnd, 1.0)
        )
    else
        var(pm, nw, cnd)[:z_gen] = @variable(pm.model,
            [i in ids(pm, nw, :gen)], basename="$(nw)_$(cnd)_z_gen",
            lowerbound = 0,
            upperbound = 1,
            start = PMs.getval(ref(pm, nw, :gen, i), "z_gen_start", cnd, 1.0)
        )
    end
end


function variable_generation_on_off(pm::GenericPowerModel; kwargs...)
    variable_active_generation_on_off(pm; kwargs...)
    variable_reactive_generation_on_off(pm; kwargs...)
end

function variable_active_generation_on_off(pm::GenericPowerModel; nw::Int=pm.cnw, cnd::Int=pm.ccnd)
    var(pm, nw, cnd)[:pg] = @variable(pm.model, 
        [i in ids(pm, nw, :gen)], basename="$(nw)_$(cnd)_pg",
        lowerbound = min(0, ref(pm, nw, :gen, i, "pmin", cnd)),
        upperbound = max(0, ref(pm, nw, :gen, i, "pmax", cnd)),
        start = PMs.getval(ref(pm, nw, :gen, i), "pg_start", cnd)
    )
end

function variable_reactive_generation_on_off(pm::GenericPowerModel; nw::Int=pm.cnw, cnd::Int=pm.ccnd)
    var(pm, nw, cnd)[:qg] = @variable(pm.model, 
        [i in ids(pm, nw, :gen)], basename="$(nw)_$(cnd)_qg",
        lowerbound = min(0, ref(pm, nw, :gen, i, "qmin", cnd)),
        upperbound = max(0, ref(pm, nw, :gen, i, "qmax", cnd)), 
        start = PMs.getval(ref(pm, nw, :gen, i), "qg_start", cnd)
    )
end

function variable_bus_voltage_indicator(pm::GenericPowerModel; nw::Int=pm.cnw, cnd::Int=pm.ccnd, relax = false)
    if !relax
        var(pm, nw, cnd)[:z_voltage] = @variable(pm.model,
            [i in ids(pm, nw, :bus)], basename="$(nw)_$(cnd)_z_voltage",
            lowerbound = 0,
            upperbound = 1,
            category = :Int,
            start = PMs.getval(ref(pm, nw, :bus, i), "z_voltage_start", cnd, 1.0)
        )
    else
        var(pm, nw, cnd)[:z_voltage] = @variable(pm.model,
            [i in ids(pm, nw, :bus)], basename="$(nw)_$(cnd)_z_voltage",
            lowerbound = 0,
            upperbound = 1,
            start = PMs.getval(ref(pm, nw, :bus, i), "z_voltage_start", cnd, 1.0)
        )
    end
end


function variable_voltage_magnitude_on_off(pm::GenericPowerModel; nw::Int=pm.cnw, cnd::Int=pm.ccnd)
    var(pm, nw, cnd)[:vm] = @variable(pm.model,
        [i in ids(pm, nw, :bus)], basename="$(nw)_$(cnd)_vm",
        lowerbound = 0,
        upperbound = ref(pm, nw, :bus, i, "vmax", cnd),
        start = PMs.getval(ref(pm, nw, :bus, i), "vm_start", cnd, 1.0)
    )
end


function variable_voltage_magnitude_sqr_on_off(pm::GenericPowerModel; nw::Int=pm.cnw, cnd::Int=pm.ccnd)
    var(pm, nw, cnd)[:w] = @variable(pm.model,
        [i in ids(pm, nw, :bus)], basename="$(nw)_$(cnd)_w",
        lowerbound = 0,
        upperbound = ref(pm, nw, :bus, i, "vmax", cnd)^2,
        start = PMs.getval(ref(pm, nw, :bus, i), "w_start", cnd, 1.001)
    )
end


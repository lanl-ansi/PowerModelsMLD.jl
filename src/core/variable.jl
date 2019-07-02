
function variable_demand_factor(pm::_PMs.GenericPowerModel; nw::Int=pm.cnw, cnd::Int=pm.ccnd)
    _PMs.var(pm, nw, cnd)[:z_demand] = JuMP.@variable(pm.model,
        [i in _PMs.ids(pm, nw, :load)], base_name="$(nw)_$(cnd)_z_demand",
        lower_bound = 0,
        upper_bound = 1,
        start = _PMs.comp_start_value(_PMs.ref(pm, nw, :load, i), "z_demand_start", cnd, 1.0)
    )
end

function variable_shunt_factor(pm::_PMs.GenericPowerModel; nw::Int=pm.cnw, cnd::Int=pm.ccnd)
    _PMs.var(pm, nw, cnd)[:z_shunt] = JuMP.@variable(pm.model,
        [i in _PMs.ids(pm, nw, :shunt)], base_name="$(nw)_$(cnd)_z_shunt",
        lower_bound = 0,
        upper_bound = 1,
        start = _PMs.comp_start_value(_PMs.ref(pm, nw, :shunt, i), "z_shunt_nstart", cnd, 1.0)
    )
end


function variable_bus_voltage_indicator(pm::_PMs.GenericPowerModel; nw::Int=pm.cnw, relax = false)
    if !relax
        _PMs.var(pm, nw)[:z_voltage] = JuMP.@variable(pm.model,
            [i in _PMs.ids(pm, nw, :bus)], base_name="$(nw)_z_voltage",
            binary = true,
            start = _PMs.comp_start_value(_PMs.ref(pm, nw, :bus, i), "z_voltage_start", 1, 1.0)
        )
    else
        _PMs.var(pm, nw)[:z_voltage] = JuMP.@variable(pm.model,
            [i in _PMs.ids(pm, nw, :bus)], base_name="$(nw)_z_voltage",
            lower_bound = 0,
            upper_bound = 1,
            start = _PMs.comp_start_value(_PMs.ref(pm, nw, :bus, i), "z_voltage_start", 1, 1.0)
        )
    end
end


function variable_voltage_magnitude_on_off(pm::_PMs.GenericPowerModel; nw::Int=pm.cnw, cnd::Int=pm.ccnd)
    _PMs.var(pm, nw, cnd)[:vm] = JuMP.@variable(pm.model,
        [i in _PMs.ids(pm, nw, :bus)], base_name="$(nw)_$(cnd)_vm",
        lower_bound = 0,
        upper_bound = _PMs.ref(pm, nw, :bus, i, "vmax", cnd),
        start = _PMs.comp_start_value(_PMs.ref(pm, nw, :bus, i), "vm_start", cnd, 1.0)
    )
end


function variable_voltage_magnitude_sqr_on_off(pm::_PMs.GenericPowerModel; nw::Int=pm.cnw, cnd::Int=pm.ccnd)
    _PMs.var(pm, nw, cnd)[:w] = JuMP.@variable(pm.model,
        [i in _PMs.ids(pm, nw, :bus)], base_name="$(nw)_$(cnd)_w",
        lower_bound = 0,
        upper_bound = _PMs.ref(pm, nw, :bus, i, "vmax", cnd)^2,
        start = _PMs.comp_start_value(_PMs.ref(pm, nw, :bus, i), "w_start", cnd, 1.001)
    )
end

function variable_storage_indicator(pm::_PMs.GenericPowerModel; nw::Int=pm.cnw, relax=false)
    if !relax
        _PMs.var(pm, nw)[:z_storage] = JuMP.@variable(pm.model,
            [i in _PMs.ids(pm, nw, :storage)], base_name="$(nw)-z_storage",
            binary = true,
            start = _PMs.comp_start_value(_PMs.ref(pm, nw, :storage, i), "z_storage_start", 1, 1.0)
        )
    else
        _PMs.var(pm, nw)[:z_storage] = JuMP.@variable(pm.model,
            [i in _PMs.ids(pm, nw, :storage)], base_name="$(nw)_z_storage",
            lower_bound = 0,
            upper_bound = 1,
            start = _PMs.comp_start_value(_PMs.ref(pm, nw, :storage, i), "z_storage_start", 1, 1.0)
        )
    end
end

function variable_storage_on_off(pm::_PMs.GenericPowerModel; kwargs...)
    variable_active_storage_on_off(pm; kwargs...)
    variable_reactive_storage_on_off(pm; kwargs...)
end

function variable_active_storage_on_off(pm::_PMs.GenericPowerModel; nw::Int=pm.cnw, cnd::Int=pm.ccnd)
    inj_lb, inj_ub = _PMs.ref_calc_storage_injection_bounds(_PMs.ref(pm, nw, :storage), _PMs.ref(pm, nw, :bus), cnd)

    _PMs.var(pm, nw, cnd)[:ps] = JuMP.@variable(pm.model,
        [i in _PMs.ids(pm, nw, :storage)], base_name="$(nw)_$(cnd)_ps",
        lower_bound = min(0, inj_lb),
        upper_bound = max(0, inj_ub),
        start = _PMs.comp_start_value(_PMs.ref(pm, nw, :storage, i), "ps_start", cnd)
    )
end

function variable_reactive_storage_on_off(pm::_PMs.GenericPowerModel; nw::Int=pm.cnw, cnd::Int=pm.ccnd)
    inj_lb, inj_ub = _PMs.ref_calc_storage_injection_bounds(_PMs.ref(pm, nw, :storage), _PMs.ref(pm, nw, :bus), cnd)

    _PMs.var(pm, nw, cnd)[:qs] = JuMP.@variable(pm.model,
        [i in _PMs.ids(pm, nw, :storage)], base_name="$(nw)_$(cnd)_qs",
        lower_bound = min(0, max(inj_lb[i], ref(pm, nw, :storage, i, "qmin", cnd))),
        upper_bound = max(0, min(inj_ub[i], ref(pm, nw, :storage, i, "qmax", cnd))),
        start = _PMs.comp_start_value(_PMs.ref(pm, nw, :storage, i), "qs_start", cnd)
    )
end


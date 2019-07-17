
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



function constraint_voltage_magnitude_on_off(pm::_PMs.GenericPowerModel, n::Int, c::Int, i::Int, vmin, vmax)
    vm = _PMs.var(pm, n, c, :vm, i)
    z_voltage = _PMs.var(pm, n, :z_voltage, i)

    JuMP.@constraint(pm.model, vm <= vmax*z_voltage)
    JuMP.@constraint(pm.model, vm >= vmin*z_voltage)
end

function constraint_voltage_magnitude_sqr_on_off(pm::_PMs.GenericPowerModel, n::Int, c::Int, i::Int, vmin, vmax)
    w = _PMs.var(pm, n, c, :w, i)
    z_voltage = _PMs.var(pm, n, :z_voltage, i)

    JuMP.@constraint(pm.model, w <= vmax^2*z_voltage)
    JuMP.@constraint(pm.model, w >= vmin^2*z_voltage)
end

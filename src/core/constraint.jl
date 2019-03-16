

function constraint_voltage_magnitude_on_off(pm::GenericPowerModel, n::Int, c::Int, i::Int, vmin, vmax)
    vm = var(pm, n, c, :vm, i)
    z_voltage = var(pm, n, c, :z_voltage, i)

    @constraint(pm.model, vm <= vmax*z_voltage)
    @constraint(pm.model, vm >= vmin*z_voltage)
end

function constraint_voltage_magnitude_sqr_on_off(pm::GenericPowerModel, n::Int, c::Int, i::Int, vmin, vmax)
    w = var(pm, n, c, :w, i)
    z_voltage = var(pm, n, c, :z_voltage, i)

    @constraint(pm.model, w <= vmax^2*z_voltage)
    @constraint(pm.model, w >= vmin^2*z_voltage)
end

# Generic generator on/off constraint
function constraint_generation_on_off(pm::GenericPowerModel, n::Int, c::Int, i::Int, pmin, pmax, qmin, qmax)
    pg = var(pm, n, c, :pg, i)
    qg = var(pm, n, c, :qg, i)
    z = var(pm, n, c, :z_gen, i)

    @constraint(pm.model, pg <= pmax*z)
    @constraint(pm.model, pg >= pmin*z)
    @constraint(pm.model, qg <= qmax*z)
    @constraint(pm.model, qg >= qmin*z)
end



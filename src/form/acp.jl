
function variable_bus_voltage_on_off(pm::GenericPowerModel{T}; kwargs...) where T <: PMs.AbstractACPForm
    PMs.variable_voltage_angle(pm; kwargs...)
    variable_voltage_magnitude_on_off(pm; kwargs...)
end

function constraint_bus_voltage_on_off(pm::GenericPowerModel{T}; nw::Int=pm.cnw, cnd::Int=pm.ccnd, kwargs...) where T <: PMs.AbstractACPForm
    for (i,bus) in ref(pm, nw, :bus)
        # TODO turn off voltage angle too?
        constraint_voltage_magnitude_on_off(pm, i; nw=nw, cnd=cnd)
    end
end

function constraint_kcl_shunt_shed(pm::GenericPowerModel{T}, n::Int, c::Int, i::Int, bus_arcs, bus_arcs_dc, bus_gens, bus_pd, bus_qd, bus_gs, bus_bs) where T <: PMs.AbstractACPForm
    vm = var(pm, n, c, :vm, i)
    p = var(pm, n, c, :p)
    q = var(pm, n, c, :q)
    pg = var(pm, n, c, :pg)
    qg = var(pm, n, c, :qg)
    p_dc = var(pm, n, c, :p_dc)
    q_dc = var(pm, n, c, :q_dc)
    z_demand = var(pm, n, c, :z_demand)
    z_shunt = var(pm, n, c, :z_shunt)

    @NLconstraint(pm.model, sum(p[a] for a in bus_arcs) + sum(p_dc[a_dc] for a_dc in bus_arcs_dc) == sum(pg[g] for g in bus_gens) - sum(pd*z_demand[i] for (i,pd) in bus_pd) - sum(gs*vm^2*z_shunt[i] for (i,gs) in bus_gs))
    @NLconstraint(pm.model, sum(q[a] for a in bus_arcs) + sum(q_dc[a_dc] for a_dc in bus_arcs_dc) == sum(qg[g] for g in bus_gens) - sum(qd*z_demand[i] for (i,qd) in bus_qd) + sum(bs*vm^2*z_shunt[i] for (i,bs) in bus_bs))
end



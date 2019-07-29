
function variable_bus_voltage_on_off(pm::_PMs.GenericPowerModel{T}; kwargs...) where T <: _PMs.AbstractACPForm
    _PMs.variable_voltage_angle(pm; kwargs...)
    variable_voltage_magnitude_on_off(pm; kwargs...)
end

function constraint_bus_voltage_on_off(pm::_PMs.GenericPowerModel{T}; nw::Int=pm.cnw, cnd::Int=pm.ccnd, kwargs...) where T <: _PMs.AbstractACPForm
    for (i,bus) in _PMs.ref(pm, nw, :bus)
        # TODO turn off voltage angle too?
        constraint_voltage_magnitude_on_off(pm, i; nw=nw, cnd=cnd)
    end
end

function constraint_power_balance_shunt_shed(pm::_PMs.GenericPowerModel{T}, n::Int, c::Int, i::Int, bus_arcs, bus_arcs_dc, bus_gens, bus_pd, bus_qd, bus_gs, bus_bs) where T <: _PMs.AbstractACPForm
    vm = _PMs.var(pm, n, c, :vm, i)
    p = _PMs.var(pm, n, c, :p)
    q = _PMs.var(pm, n, c, :q)
    pg = _PMs.var(pm, n, c, :pg)
    qg = _PMs.var(pm, n, c, :qg)
    p_dc = _PMs.var(pm, n, c, :p_dc)
    q_dc = _PMs.var(pm, n, c, :q_dc)
    z_demand = _PMs.var(pm, n, :z_demand)
    z_shunt = _PMs.var(pm, n, :z_shunt)

    JuMP.@NLconstraint(pm.model, sum(p[a] for a in bus_arcs) + sum(p_dc[a_dc] for a_dc in bus_arcs_dc) == sum(pg[g] for g in bus_gens) - sum(pd*z_demand[i] for (i,pd) in bus_pd) - sum(gs*vm^2*z_shunt[i] for (i,gs) in bus_gs))
    JuMP.@NLconstraint(pm.model, sum(q[a] for a in bus_arcs) + sum(q_dc[a_dc] for a_dc in bus_arcs_dc) == sum(qg[g] for g in bus_gens) - sum(qd*z_demand[i] for (i,qd) in bus_qd) + sum(bs*vm^2*z_shunt[i] for (i,bs) in bus_bs))
end

function constraint_power_balance_shunt_storage_shed(pm::_PMs.GenericPowerModel{T}, n::Int, c::Int, i::Int, bus_arcs, bus_arcs_dc, bus_gens, bus_storage, bus_pd, bus_qd, bus_gs, bus_bs) where T <: _PMs.AbstractACPForm
    vm = _PMs.var(pm, n, c, :vm, i)
    p = _PMs.var(pm, n, c, :p)
    q = _PMs.var(pm, n, c, :q)
    pg = _PMs.var(pm, n, c, :pg)
    qg = _PMs.var(pm, n, c, :qg)
    ps = _PMs.var(pm, n, c, :ps)
    qs = _PMs.var(pm, n, c, :qs)
    p_dc = _PMs.var(pm, n, c, :p_dc)
    q_dc = _PMs.var(pm, n, c, :q_dc)
    z_demand = _PMs.var(pm, n, :z_demand)
    z_shunt = _PMs.var(pm, n, :z_shunt)

    JuMP.@NLconstraint(pm.model, sum(p[a] for a in bus_arcs) + sum(p_dc[a_dc] for a_dc in bus_arcs_dc) == sum(pg[g] for g in bus_gens) + sum(ps[s] for s in bus_storage) - sum(pd*z_demand[i] for (i,pd) in bus_pd) - sum(gs*vm^2*z_shunt[i] for (i,gs) in bus_gs))
    JuMP.@NLconstraint(pm.model, sum(q[a] for a in bus_arcs) + sum(q_dc[a_dc] for a_dc in bus_arcs_dc) == sum(qg[g] for g in bus_gens) + sum(qs[s] for s in bus_storage) - sum(qd*z_demand[i] for (i,qd) in bus_qd) + sum(bs*vm^2*z_shunt[i] for (i,bs) in bus_bs))
end



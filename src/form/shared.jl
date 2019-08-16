
# # same as AbstractWRForm
""
function variable_shunt_factor(pm::_PMs.AbstractWModels; nw::Int=pm.cnw, cnd::Int=pm.ccnd, relax = false)
    if relax == true
        _PMs.var(pm, nw)[:z_shunt] = JuMP.@variable(pm.model,
            [i in _PMs.ids(pm, nw, :shunt)], base_name="$(nw)_z_shunt", 
            upper_bound = 1, 
            lower_bound = 0,
            start = _PMs.comp_start_value(_PMs.ref(pm, nw, :shunt, i), "z_shunt_on_start", cnd, 1.0)
        )
    else
        _PMs.var(pm, nw)[:z_shunt] = JuMP.@variable(pm.model,
            [i in _PMs.ids(pm, nw, :shunt)], base_name="$(nw)_z_shunt", 
            binary = true,
            start = _PMs.comp_start_value(_PMs.ref(pm, nw, :shunt, i), "z_shunt_on_start", cnd, 1.0)
        )
    end
    _PMs.var(pm, nw)[:wz_shunt] = JuMP.@variable(pm.model,
            [i in _PMs.ids(pm, nw, :shunt)], base_name="$(nw)_wz_shunt",
            lower_bound = 0,
            upper_bound = _PMs.ref(pm, nw, :bus)[_PMs.ref(pm, nw, :shunt, i)["shunt_bus"]]["vmax"]^2,
            start = _PMs.comp_start_value(_PMs.ref(pm, nw, :shunt, i), "wz_shunt_start", cnd, 1.001)
        )
end

function constraint_power_balance_shunt_shed(pm::_PMs.AbstractWModels, n::Int, c::Int, i::Int, bus_arcs, bus_arcs_dc, bus_gens, bus_pd, bus_qd, bus_gs, bus_bs)
    w = _PMs.var(pm, n, c, :w, i)
    p = _PMs.var(pm, n, c, :p)
    q = _PMs.var(pm, n, c, :q)
    pg = _PMs.var(pm, n, c, :pg)
    qg = _PMs.var(pm, n, c, :qg)
    p_dc = _PMs.var(pm, n, c, :p_dc)
    q_dc = _PMs.var(pm, n, c, :q_dc)
    z_demand = _PMs.var(pm, n, :z_demand)
    z_shunt = _PMs.var(pm, n, :z_shunt)
    wz_shunt = _PMs.var(pm, n, :wz_shunt)


    JuMP.@constraint(pm.model, sum(p[a] for a in bus_arcs) + sum(p_dc[a_dc] for a_dc in bus_arcs_dc) == sum(pg[g] for g in bus_gens) - sum(pd*z_demand[i] for (i,pd) in bus_pd) - sum(gs*wz_shunt[i] for (i,gs) in bus_gs))
    JuMP.@constraint(pm.model, sum(q[a] for a in bus_arcs) + sum(q_dc[a_dc] for a_dc in bus_arcs_dc) == sum(qg[g] for g in bus_gens) - sum(qd*z_demand[i] for (i,qd) in bus_qd) + sum(bs*wz_shunt[i] for (i,bs) in bus_bs))

    for s in keys(bus_gs)
        InfrastructureModels.relaxation_product(pm.model, w, z_shunt[s], wz_shunt[s])
    end
end

function constraint_power_balance_shunt_storage_shed(pm::_PMs.AbstractWModels, n::Int, c::Int, i::Int, bus_arcs, bus_arcs_dc, bus_gens, bus_storage, bus_pd, bus_qd, bus_gs, bus_bs)
    w = _PMs.var(pm, n, c, :w, i)
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
    wz_shunt = _PMs.var(pm, n, :wz_shunt)

    
    JuMP.@constraint(pm.model, sum(p[a] for a in bus_arcs) + sum(p_dc[a_dc] for a_dc in bus_arcs_dc) == sum(pg[g] for g in bus_gens) - sum(ps[s] for s in bus_storage) - sum(pd*z_demand[i] for (i,pd) in bus_pd) - sum(gs*wz_shunt[i] for (i,gs) in bus_gs))
    JuMP.@constraint(pm.model, sum(q[a] for a in bus_arcs) + sum(q_dc[a_dc] for a_dc in bus_arcs_dc) == sum(qg[g] for g in bus_gens) - sum(qs[s] for s in bus_storage) - sum(qd*z_demand[i] for (i,qd) in bus_qd) + sum(bs*wz_shunt[i] for (i,bs) in bus_bs))

    for s in keys(bus_gs)
        InfrastructureModels.relaxation_product(pm.model, w, z_shunt[s], wz_shunt[s])
    end
end


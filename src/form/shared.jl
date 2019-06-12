

# same as AbstractWRForm
function variable_shunt_factor(pm::_PMs.GenericPowerModel{T}; nw::Int=pm.cnw, cnd::Int=pm.ccnd) where T <: _PMs.AbstractWRForms
    _PMs.var(pm, nw, cnd)[:z_shunt] = JuMP.@variable(pm.model,
        [i in _PMs.ids(pm, nw, :shunt)], base_name="$(nw)_$(cnd)_z_shunt",
        lower_bound = 0,
        upper_bound = 1,
        start = _PMs.comp_start_value(_PMs.ref(pm, nw, :shunt, i), "z_shunt_start", cnd, 1.0)
    )
    _PMs.var(pm, nw, cnd)[:wz_shunt] = JuMP.@variable(pm.model,
        [i in _PMs.ids(pm, nw, :shunt)], base_name="$(nw)_$(cnd)_wz_shunt",
        lower_bound = 0,
        upper_bound = _PMs.ref(pm, nw, :bus)[_PMs.ref(pm, nw, :shunt, i)["shunt_bus"]]["vmax"]^2,
        start = _PMs.comp_start_value(_PMs.ref(pm, nw, :shunt, i), "wz_shunt_start", cnd, 1.001)
    )
end


function constraint_bus_voltage_product_on_off(pm::_PMs.GenericPowerModel{T}; nw::Int=pm.cnw, cnd::Int=pm.ccnd) where T <: _PMs.AbstractWRForms
    wr_min, wr_max, wi_min, wi_max = _PMs.ref_calc_voltage_product_bounds(_PMs.ref(pm, nw, :buspairs))

    wr = _PMs.var(pm, nw, cnd, :wr)
    wi = _PMs.var(pm, nw, cnd, :wi)
    z_voltage = _PMs.var(pm, nw, :z_voltage)

    for bp in _PMs.ids(pm, nw, :buspairs)
        (i,j) = bp
        z_fr = z_voltage[i]
        z_to = z_voltage[j]

        JuMP.@constraint(pm.model, wr[bp] <= z_fr*wr_max[bp])
        JuMP.@constraint(pm.model, wr[bp] >= z_fr*wr_min[bp])
        JuMP.@constraint(pm.model, wi[bp] <= z_fr*wi_max[bp])
        JuMP.@constraint(pm.model, wi[bp] >= z_fr*wi_min[bp])

        JuMP.@constraint(pm.model, wr[bp] <= z_to*wr_max[bp])
        JuMP.@constraint(pm.model, wr[bp] >= z_to*wr_min[bp])
        JuMP.@constraint(pm.model, wi[bp] <= z_to*wi_max[bp])
        JuMP.@constraint(pm.model, wi[bp] >= z_to*wi_min[bp])
    end
end


function constraint_power_balance_shunt_shed(pm::_PMs.GenericPowerModel{T}, n::Int, c::Int, i::Int, bus_arcs, bus_arcs_dc, bus_gens, bus_pd, bus_qd, bus_gs, bus_bs) where T <: _PMs.AbstractWRForms
    w = _PMs.var(pm, n, c, :w, i)
    p = _PMs.var(pm, n, c, :p)
    q = _PMs.var(pm, n, c, :q)
    pg = _PMs.var(pm, n, c, :pg)
    qg = _PMs.var(pm, n, c, :qg)
    p_dc = _PMs.var(pm, n, c, :p_dc)
    q_dc = _PMs.var(pm, n, c, :q_dc)
    z_demand = _PMs.var(pm, n, c, :z_demand)
    z_shunt = _PMs.var(pm, n, c, :z_shunt)
    wz_shunt = _PMs.var(pm, n, c, :wz_shunt)


    JuMP.@constraint(pm.model, sum(p[a] for a in bus_arcs) + sum(p_dc[a_dc] for a_dc in bus_arcs_dc) == sum(pg[g] for g in bus_gens) - sum(pd*z_demand[i] for (i,pd) in bus_pd) - sum(gs*wz_shunt[i] for (i,gs) in bus_gs))
    JuMP.@constraint(pm.model, sum(q[a] for a in bus_arcs) + sum(q_dc[a_dc] for a_dc in bus_arcs_dc) == sum(qg[g] for g in bus_gens) - sum(qd*z_demand[i] for (i,qd) in bus_qd) + sum(bs*wz_shunt[i] for (i,bs) in bus_bs))

    for s in keys(bus_gs)
        InfrastructureModels.relaxation_product(pm.model, w, z_shunt[s], wz_shunt[s])
    end
end


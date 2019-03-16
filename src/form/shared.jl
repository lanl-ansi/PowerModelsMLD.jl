

# same as AbstractWRForm
function variable_shunt_factor(pm::GenericPowerModel{T}; nw::Int=pm.cnw, cnd::Int=pm.ccnd) where T <: PMs.AbstractWRForms
    var(pm, nw, cnd)[:z_shunt] = @variable(pm.model,
        [i in ids(pm, nw, :shunt)], basename="$(nw)_$(cnd)_z_shunt",
        lowerbound = 0,
        upperbound = 1,
        start = PMs.getval(ref(pm, nw, :shunt, i), "z_shunt_start", cnd, 1.0)
    )
    var(pm, nw, cnd)[:wz_shunt] = @variable(pm.model,
        [i in ids(pm, nw, :shunt)], basename="$(nw)_$(cnd)_wz_shunt",
        lowerbound = 0,
        upperbound = ref(pm, nw, :bus)[ref(pm, nw, :shunt, i)["shunt_bus"]]["vmax"]^2,
        start = PMs.getval(ref(pm, nw, :shunt, i), "wz_shunt_start", cnd, 1.001)
    )
end


function constraint_bus_voltage_product_on_off(pm::GenericPowerModel{T}; nw::Int=pm.cnw, cnd::Int=pm.ccnd) where T <: PMs.AbstractWRForms
    wr_min, wr_max, wi_min, wi_max = PMs.calc_voltage_product_bounds(ref(pm, nw, :buspairs))

    wr = var(pm, nw, cnd, :wr)
    wi = var(pm, nw, cnd, :wi)
    z_voltage = var(pm, nw, cnd, :z_voltage)

    for bp in ids(pm, nw, :buspairs)
        (i,j) = bp
        z_fr = z_voltage[i]
        z_to = z_voltage[j]

        @constraint(pm.model, wr[bp] <= z_fr*wr_max[bp])
        @constraint(pm.model, wr[bp] >= z_fr*wr_min[bp])
        @constraint(pm.model, wi[bp] <= z_fr*wi_max[bp])
        @constraint(pm.model, wi[bp] >= z_fr*wi_min[bp])

        @constraint(pm.model, wr[bp] <= z_to*wr_max[bp])
        @constraint(pm.model, wr[bp] >= z_to*wr_min[bp])
        @constraint(pm.model, wi[bp] <= z_to*wi_max[bp])
        @constraint(pm.model, wi[bp] >= z_to*wi_min[bp])
    end
end


function constraint_kcl_shunt_shed(pm::GenericPowerModel{T}, n::Int, c::Int, i::Int, bus_arcs, bus_arcs_dc, bus_gens, bus_pd, bus_qd, bus_gs, bus_bs) where T <: PMs.AbstractWRForms
    w = var(pm, n, c, :w, i)
    p = var(pm, n, c, :p)
    q = var(pm, n, c, :q)
    pg = var(pm, n, c, :pg)
    qg = var(pm, n, c, :qg)
    p_dc = var(pm, n, c, :p_dc)
    q_dc = var(pm, n, c, :q_dc)
    z_demand = var(pm, n, c, :z_demand)
    z_shunt = var(pm, n, c, :z_shunt)
    wz_shunt = var(pm, n, c, :wz_shunt)


    @constraint(pm.model, sum(p[a] for a in bus_arcs) + sum(p_dc[a_dc] for a_dc in bus_arcs_dc) == sum(pg[g] for g in bus_gens) - sum(pd*z_demand[i] for (i,pd) in bus_pd) - sum(gs*wz_shunt[i] for (i,gs) in bus_gs))
    @constraint(pm.model, sum(q[a] for a in bus_arcs) + sum(q_dc[a_dc] for a_dc in bus_arcs_dc) == sum(qg[g] for g in bus_gens) - sum(qd*z_demand[i] for (i,qd) in bus_qd) + sum(bs*wz_shunt[i] for (i,bs) in bus_bs))

    for s in keys(bus_gs)
        InfrastructureModels.relaxation_product(pm.model, w, z_shunt[s], wz_shunt[s])
    end
end


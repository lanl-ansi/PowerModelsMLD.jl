

function variable_bus_voltage_indicator(pm::GenericPowerModel{T}; nw::Int=pm.cnw, cnd::Int=pm.ccnd, kwargs...) where T <: PMs.AbstractDCPForm
end

variable_bus_voltage_on_off(pm::GenericPowerModel{T}; kwargs...) where T <: PMs.AbstractDCPForm = PMs.variable_voltage_angle(pm; kwargs...)

function constraint_bus_voltage_on_off(pm::GenericPowerModel{T}; nw::Int=pm.cnw, cnd::Int=pm.ccnd, kwargs...) where T <: PMs.AbstractDCPForm
end

function constraint_kcl_shunt_shed(pm::GenericPowerModel{T}, n::Int, c::Int, i::Int, bus_arcs, bus_arcs_dc, bus_gens, bus_pd, bus_qd, bus_gs, bus_bs) where T <: PMs.AbstractDCPForm
    p = var(pm, n, c, :p)
    pg = var(pm, n, c, :pg)
    p_dc = var(pm, n, c, :p_dc)
    z_demand = var(pm, n, c, :z_demand)
    z_shunt = var(pm, n, c, :z_shunt)

    @constraint(pm.model, sum(p[a] for a in bus_arcs) + sum(p_dc[a_dc] for a_dc in bus_arcs_dc) == sum(pg[g] for g in bus_gens) - sum(pd*z_demand[i] for (i,pd) in bus_pd) - sum(gs*1.0^2*z_shunt[i] for (i,gs) in bus_gs))
end


# Needed becouse DC models do not have the z_voltage variable
function objective_max_loadability(pm::GenericPowerModel{T}) where T <: PMs.AbstractDCPForm
    nws = nw_ids(pm)

    @assert all(!PMs.ismulticonductor(pm, n) for n in nws)

    z_demand = Dict(n => var(pm, :z_demand, nw=n) for n in nws)
    z_shunt = Dict(n => var(pm, :z_shunt, nw=n) for n in nws)
    z_gen = Dict(n => var(pm, :z_gen, nw=n) for n in nws)

    M = Dict(n => 10*maximum([abs(load["pd"]) for (i,load) in ref(pm, n, :load)]) for n in nws)

    return @objective(pm.model, Max, 
        sum(
            sum(M[n]*z_gen[n][i] for (i,gen) in ref(pm, n, :gen)) +
            sum(M[n]*z_shunt[n][i] for (i,shunt) in ref(pm, n, :shunt)) +
            sum(abs(load["pd"])*z_demand[n][i] for (i,load) in ref(pm, n, :load))
        for n in nws)
    )
end

# overload these to make clear that DC did not model reactive power
function add_load_setpoint(sol, pm::GenericPowerModel{T}) where T <: PMs.AbstractDCPForm
    mva_base = pm.data["baseMVA"]
    PMs.add_setpoint(sol, pm, "load", "pd", :z_demand; scale = (x,item,i) -> x*item["pd"][i])
    PMs.add_setpoint_fixed(sol, pm, "load", "qd")
    PMs.add_setpoint(sol, pm, "load", "status", :z_demand; default_value = (item) -> if (item["status"] == 0) 0 else 1 end)
end

function add_shunt_setpoint(sol, pm::GenericPowerModel{T}) where T <: PMs.AbstractDCPForm
    mva_base = pm.data["baseMVA"]
    PMs.add_setpoint(sol, pm, "shunt", "gs", :z_shunt; scale = (x,item,i) -> x*item["gs"][i])
    PMs.add_setpoint_fixed(sol, pm, "shunt", "bs")
    PMs.add_setpoint(sol, pm, "shunt", "status", :z_shunt; default_value = (item) -> if (item["status"] == 0) 0 else 1 end)
end

function add_bus_status_setpoint(sol, pm::GenericPowerModel{T}) where T <: PMs.AbstractDCPForm
    PMs.add_setpoint_fixed(sol, pm, "bus", "status")
end


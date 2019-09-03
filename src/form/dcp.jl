

function variable_bus_voltage_indicator(pm::_PMs.GenericPowerModel{T}; nw::Int=pm.cnw, cnd::Int=pm.ccnd, kwargs...) where T <: _PMs.AbstractDCPForm
end

variable_bus_voltage_on_off(pm::_PMs.GenericPowerModel{T}; kwargs...) where T <: _PMs.AbstractDCPForm = _PMs.variable_voltage_angle(pm; kwargs...)

function constraint_bus_voltage_on_off(pm::_PMs.GenericPowerModel{T}; nw::Int=pm.cnw, cnd::Int=pm.ccnd, kwargs...) where T <: _PMs.AbstractDCPForm
end

function constraint_power_balance_shunt_shed(pm::_PMs.GenericPowerModel{T}, n::Int, c::Int, i::Int, bus_arcs, bus_arcs_dc, bus_gens, bus_pd, bus_qd, bus_gs, bus_bs) where T <: _PMs.AbstractDCPForm
    p = _PMs.var(pm, n, c, :p)
    pg = _PMs.var(pm, n, c, :pg)
    p_dc = _PMs.var(pm, n, c, :p_dc)
    z_demand = _PMs.var(pm, n, :z_demand)
    z_shunt = _PMs.var(pm, n, :z_shunt)

    JuMP.@constraint(pm.model, sum(p[a] for a in bus_arcs) + sum(p_dc[a_dc] for a_dc in bus_arcs_dc) == sum(pg[g] for g in bus_gens) - sum(pd*z_demand[i] for (i,pd) in bus_pd) - sum(gs*1.0^2*z_shunt[i] for (i,gs) in bus_gs))
end

function constraint_power_balance_shunt_storage_shed(pm::_PMs.GenericPowerModel{T}, n::Int, c::Int, i::Int, bus_arcs, bus_arcs_dc, bus_gens, bus_storage, bus_pd, bus_qd, bus_gs, bus_bs) where T <: _PMs.AbstractDCPForm
    p = _PMs.var(pm, n, c, :p)
    pg = _PMs.var(pm, n, c, :pg)
    ps = _PMs.var(pm, n, c, :ps)
    p_dc = _PMs.var(pm, n, c, :p_dc)
    z_demand = _PMs.var(pm, n, :z_demand)
    z_shunt = _PMs.var(pm, n, :z_shunt)

    JuMP.@constraint(pm.model, sum(p[a] for a in bus_arcs) + sum(p_dc[a_dc] for a_dc in bus_arcs_dc) == sum(pg[g] for g in bus_gens) + sum(ps[s] for s in bus_storage) - sum(pd*z_demand[i] for (i,pd) in bus_pd) - sum(gs*1.0^2*z_shunt[i] for (i,gs) in bus_gs))
end


# Needed becouse DC models do not have the z_voltage variable
function objective_max_loadability(pm::_PMs.GenericPowerModel{T}) where T <: _PMs.AbstractDCPForm
    nws = _PMs.nw_ids(pm)

    @assert all(!_PMs.ismulticonductor(pm, n) for n in nws)

    z_demand = Dict(n => _PMs.var(pm, n, :z_demand) for n in nws)
    z_shunt = Dict(n => _PMs.var(pm, n, :z_shunt) for n in nws)
    z_gen = Dict(n => _PMs.var(pm, n, :z_gen) for n in nws)
    time_elapsed = Dict(n => get(_PMs.ref(pm, n), :time_elapsed, 1) for n in nws)

    load_weight = Dict(n =>
        Dict(i => get(load, "weight", 1.0) for (i,load) in _PMs.ref(pm, n, :load)) 
    for n in nws)
	
    M = Dict(n => 10*maximum([load_weight[n][i]*abs(load["pd"]) for (i,load) in _PMs.ref(pm, n, :load)]) for n in nws)

    return JuMP.@objective(pm.model, Max,
        sum( 
            ( 
                time_elapsed[n]*(
                 sum(M[n]*z_gen[n][i] for (i,gen) in _PMs.ref(pm, n, :gen)) +
                 sum(M[n]*z_shunt[n][i] for (i,shunt) in _PMs.ref(pm, n, :shunt)) +
                 sum(load_weight[n][i]*abs(load["pd"])*z_demand[n][i] for (i,load) in _PMs.ref(pm, n, :load))
             ) 
            )
        for n in nws)
    )
end

# can we just add storage to the regular max_loadability objective? #
function objective_max_loadability_strg(pm::_PMs.GenericPowerModel{T}) where T <: _PMs.AbstractDCPForm
    nws = _PMs.nw_ids(pm)

    @assert all(!_PMs.ismulticonductor(pm, n) for n in nws)

    z_demand = Dict(n => _PMs.var(pm, n, :z_demand) for n in nws)
    z_shunt = Dict(n => _PMs.var(pm, n, :z_shunt) for n in nws)
    z_gen = Dict(n => _PMs.var(pm, n, :z_gen) for n in nws)
    z_storage = Dict(n => _PMs.var(pm, n, :z_storage) for n in nws)
    time_elapsed = Dict(n => get(_PMs.ref(pm, n), :time_elapsed, 1) for n in nws)

    load_weight = Dict(n =>
        Dict(i => get(load, "weight", 1.0) for (i,load) in _PMs.ref(pm, n, :load)) 
    for n in nws)
	
    M = Dict(n => 10*maximum([load_weight[n][i]*abs(load["pd"]) for (i,load) in _PMs.ref(pm, n, :load)]) for n in nws)

    return JuMP.@objective(pm.model, Max,
        sum( 
            ( 
                time_elapsed[n]*(
                 sum(M[n]*z_gen[n][i] for (i,gen) in _PMs.ref(pm, n, :gen)) +
                 sum(M[n]*z_storage[n][i] for (i,storage) in _PMs.ref(pm, n, :storage)) +
                 sum(M[n]*z_shunt[n][i] for (i,shunt) in _PMs.ref(pm, n, :shunt)) +
                 sum(load_weight[n][i]*abs(load["pd"])*z_demand[n][i] for (i,load) in _PMs.ref(pm, n, :load))
             ) 
            )
        for n in nws)
    )
end


### These are needed to overload the default behavior for reactive power ###

function add_setpoint_load!(sol, pm::_PMs.GenericPowerModel{T}) where T <: _PMs.AbstractDCPForm
    mva_base = pm.data["baseMVA"]
    _PMs.add_setpoint!(sol, pm, "load", "pd", :z_demand; conductorless=true, scale = (x,item,i) -> x*item["pd"][i])
    _PMs.add_setpoint_fixed!(sol, pm, "load", "qd")
    _PMs.add_setpoint!(sol, pm, "load", "status", :z_demand; conductorless=true, default_value = (item) -> if (item["status"] == 0) 0 else 1 end)
end

function add_setpoint_shunt!(sol, pm::_PMs.GenericPowerModel{T}) where T <: _PMs.AbstractDCPForm
    mva_base = pm.data["baseMVA"]
    _PMs.add_setpoint!(sol, pm, "shunt", "gs", :z_shunt; conductorless=true, scale = (x,item,i) -> x*item["gs"][i])
    _PMs.add_setpoint_fixed!(sol, pm, "shunt", "bs")
    _PMs.add_setpoint!(sol, pm, "shunt", "status", :z_shunt; conductorless=true, default_value = (item) -> if (item["status"] == 0) 0 else 1 end)
end

#=
function add_setpoint_bus_status!(sol, pm::_PMs.GenericPowerModel{T}) where T <: _PMs.AbstractDCPForm
    _PMs.add_setpoint_fixed!(sol, pm, "bus", "status")
end
=#


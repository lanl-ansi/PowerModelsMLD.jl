
function objective_max_loadability(pm::_PMs.GenericPowerModel)
    nws = _PMs.nw_ids(pm)

    @assert all(!_PMs.ismulticonductor(pm, n) for n in nws)

    z_demand = Dict(n => _PMs.var(pm, :z_demand, nw=n) for n in nws)
    z_shunt = Dict(n => _PMs.var(pm, :z_shunt, nw=n) for n in nws)
    z_gen = Dict(n => _PMs.var(pm, n, :z_gen) for n in nws)
    z_voltage = Dict(n => _PMs.var(pm, n, :z_voltage) for n in nws)

    load_weight = Dict(n =>
        Dict(i => get(load, "weight", 1.0) for (i,load) in _PMs.ref(pm, n, :load)) 
    for n in nws)

    #println(load_weight)

    M = Dict(n => 10*maximum([load_weight[n][i]*abs(load["pd"]) for (i,load) in _PMs.ref(pm, n, :load)]) for n in nws)

    return JuMP.@objective(pm.model, Max,
        sum(
            sum(M[n]*10*z_voltage[n][i] for (i,bus) in _PMs.ref(pm, n, :bus)) +
            sum(M[n]*z_gen[n][i] for (i,gen) in _PMs.ref(pm, n, :gen)) +
            sum(M[n]*z_shunt[n][i] for (i,shunt) in _PMs.ref(pm, n, :shunt)) +
            sum(load_weight[n][i]*abs(load["pd"])*z_demand[n][i] for (i,load) in _PMs.ref(pm, n, :load))
        for n in nws)
    )

    #return JuMP.@objective(pm.model, Max, sum( M*z_gen[i] for (i,gen) in pm.ref[:gen]) + sum( M*z_shunt[i] + abs(bus["pd"])*z_demand[i] for (i,bus) in pm.ref[:bus]))

    #return JuMP.@objective(pm.model, Max, sum(abs(bus["pd"])*z_demand[i] for (i,bus) in pm.ref[:bus]))

    #pg = pm.var[:pg]
    #M = maximum([abs(gen["pmax"]) for (i,gen) in pm.ref[:gen]])
    #return JuMP.@objective(pm.model, Max, sum(z_gen[i] + pg[i] for (i,gen) in pm.ref[:gen]) + sum(M/10*z_voltage[i]^2 + M*abs(bus["pd"])*z_demand[i] for (i,bus) in pm.ref[:bus]))
end


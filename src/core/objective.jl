
function objective_max_loadability(pm::GenericPowerModel)
    nws = nw_ids(pm)

    @assert all(!PMs.ismulticonductor(pm, n) for n in nws)

    z_demand = Dict(n => var(pm, :z_demand, nw=n) for n in nws)
    z_shunt = Dict(n => var(pm, :z_shunt, nw=n) for n in nws)
    z_gen = Dict(n => var(pm, :z_gen, nw=n) for n in nws)
    z_voltage = Dict(n => var(pm, :z_voltage, nw=n) for n in nws)

    M = Dict(n => 10*maximum([abs(load["pd"]) for (i,load) in ref(pm, n, :load)]) for n in nws)

    return @objective(pm.model, Max,
        sum(
            sum(M[n]*10*z_voltage[n][i] for (i,bus) in ref(pm, n, :bus)) +
            sum(M[n]*z_gen[n][i] for (i,gen) in ref(pm, n, :gen)) +
            sum(M[n]*z_shunt[n][i] for (i,shunt) in ref(pm, n, :shunt)) +
            sum(abs(load["pd"])*z_demand[n][i] for (i,load) in ref(pm, n, :load))
        for n in nws)
    )

    #return @objective(pm.model, Max, sum( M*z_gen[i] for (i,gen) in pm.ref[:gen]) + sum( M*z_shunt[i] + abs(bus["pd"])*z_demand[i] for (i,bus) in pm.ref[:bus]))

    #return @objective(pm.model, Max, sum(abs(bus["pd"])*z_demand[i] for (i,bus) in pm.ref[:bus]))

    #pg = pm.var[:pg]
    #M = maximum([abs(gen["pmax"]) for (i,gen) in pm.ref[:gen]])
    #return @objective(pm.model, Max, sum(z_gen[i] + pg[i] for (i,gen) in pm.ref[:gen]) + sum(M/10*z_voltage[i]^2 + M*abs(bus["pd"])*z_demand[i] for (i,bus) in pm.ref[:bus]))
end


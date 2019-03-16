
""
function constraint_kcl_shunt_shed(pm::GenericPowerModel, i::Int; nw::Int=pm.cnw, cnd::Int=pm.ccnd)
    bus = ref(pm, nw, :bus, i)
    bus_arcs = ref(pm, nw, :bus_arcs, i)
    bus_arcs_dc = ref(pm, nw, :bus_arcs_dc, i)
    bus_gens = ref(pm, nw, :bus_gens, i)
    bus_loads = ref(pm, nw, :bus_loads, i)
    bus_shunts = ref(pm, nw, :bus_shunts, i)

    bus_pd = Dict(k => ref(pm, nw, :load, k, "pd", cnd) for k in bus_loads)
    bus_qd = Dict(k => ref(pm, nw, :load, k, "qd", cnd) for k in bus_loads)

    bus_gs = Dict(k => ref(pm, nw, :shunt, k, "gs", cnd) for k in bus_shunts)
    bus_bs = Dict(k => ref(pm, nw, :shunt, k, "bs", cnd) for k in bus_shunts)

    constraint_kcl_shunt_shed(pm, nw, cnd, i, bus_arcs, bus_arcs_dc, bus_gens, bus_pd, bus_qd, bus_gs, bus_bs)
end


function constraint_generation_on_off(pm::GenericPowerModel, i::Int; nw::Int=pm.cnw, cnd::Int=pm.ccnd)
    gen = ref(pm, nw, :gen, i)

    constraint_generation_on_off(pm, nw, cnd, i, gen["pmin"][cnd], gen["pmax"][cnd], gen["qmin"][cnd], gen["qmax"][cnd])
end


constraint_bus_voltage_on_off(pm::GenericPowerModel; nw::Int=pm.cnw, cnd::Int=pm.ccnd, kwargs...) = constraint_bus_voltage_on_off(pm, nw, cnd; kwargs...)


function constraint_voltage_magnitude_on_off(pm::GenericPowerModel, i::Int; nw::Int=pm.cnw, cnd::Int=pm.ccnd)
    bus = ref(pm, nw, :bus, i)

    constraint_voltage_magnitude_on_off(pm, nw, cnd, i, bus["vmin"][cnd], bus["vmax"][cnd])
end


function constraint_voltage_magnitude_sqr_on_off(pm::GenericPowerModel, i::Int; nw::Int=pm.cnw, cnd::Int=pm.ccnd)
    bus = ref(pm, nw, :bus, i)

    constraint_voltage_magnitude_sqr_on_off(pm, nw, cnd, i, bus["vmin"][cnd], bus["vmax"][cnd])
end


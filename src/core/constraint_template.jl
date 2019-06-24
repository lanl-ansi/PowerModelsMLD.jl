
""
function constraint_power_balance_shunt_shed(pm::_PMs.GenericPowerModel, i::Int; nw::Int=pm.cnw, cnd::Int=pm.ccnd)
    bus = _PMs.ref(pm, nw, :bus, i)
    bus_arcs = _PMs.ref(pm, nw, :bus_arcs, i)
    bus_arcs_dc = _PMs.ref(pm, nw, :bus_arcs_dc, i)
    bus_gens = _PMs.ref(pm, nw, :bus_gens, i)
    bus_loads = _PMs.ref(pm, nw, :bus_loads, i)
    bus_shunts = _PMs.ref(pm, nw, :bus_shunts, i)

    bus_pd = Dict(k => _PMs.ref(pm, nw, :load, k, "pd", cnd) for k in bus_loads)
    bus_qd = Dict(k => _PMs.ref(pm, nw, :load, k, "qd", cnd) for k in bus_loads)

    bus_gs = Dict(k => _PMs.ref(pm, nw, :shunt, k, "gs", cnd) for k in bus_shunts)
    bus_bs = Dict(k => _PMs.ref(pm, nw, :shunt, k, "bs", cnd) for k in bus_shunts)

    constraint_power_balance_shunt_shed(pm, nw, cnd, i, bus_arcs, bus_arcs_dc, bus_gens, bus_pd, bus_qd, bus_gs, bus_bs)
end

function constraint_power_balance_shunt_storage_shed(pm::_PMs.GenericPowerModel, i::Int; nw::Int=pm.cnw, cnd::Int=pm.ccnd)
    bus = _PMs.ref(pm, nw, :bus, i)
    bus_arcs = _PMs.ref(pm, nw, :bus_arcs, i)
    bus_arcs_dc = _PMs.ref(pm, nw, :bus_arcs_dc, i)
    bus_gens = _PMs.ref(pm, nw, :bus_gens, i)
    bus_storage = _PMs.ref(pm, nw, :bus_storage, i)
    bus_loads = _PMs.ref(pm, nw, :bus_loads, i)
    bus_shunts = _PMs.ref(pm, nw, :bus_shunts, i)

    bus_pd = Dict(k => _PMs.ref(pm, nw, :load, k, "pd", cnd) for k in bus_loads)
    bus_qd = Dict(k => _PMs.ref(pm, nw, :load, k, "qd", cnd) for k in bus_loads)

    bus_gs = Dict(k => _PMs.ref(pm, nw, :shunt, k, "gs", cnd) for k in bus_shunts)
    bus_bs = Dict(k => _PMs.ref(pm, nw, :shunt, k, "bs", cnd) for k in bus_shunts)

    constraint_power_balance_shunt_storage_shed(pm, nw, cnd, i, bus_arcs, bus_arcs_dc, bus_gens, bus_storage, bus_pd, bus_qd, bus_gs, bus_bs)
end


constraint_bus_voltage_on_off(pm::_PMs.GenericPowerModel; nw::Int=pm.cnw, cnd::Int=pm.ccnd, kwargs...) = constraint_bus_voltage_on_off(pm, nw, cnd; kwargs...)


function constraint_voltage_magnitude_on_off(pm::_PMs.GenericPowerModel, i::Int; nw::Int=pm.cnw, cnd::Int=pm.ccnd)
    bus = _PMs.ref(pm, nw, :bus, i)

    constraint_voltage_magnitude_on_off(pm, nw, cnd, i, bus["vmin"][cnd], bus["vmax"][cnd])
end


function constraint_voltage_magnitude_sqr_on_off(pm::_PMs.GenericPowerModel, i::Int; nw::Int=pm.cnw, cnd::Int=pm.ccnd)
    bus = _PMs.ref(pm, nw, :bus, i)

    constraint_voltage_magnitude_sqr_on_off(pm, nw, cnd, i, bus["vmin"][cnd], bus["vmax"][cnd])
end
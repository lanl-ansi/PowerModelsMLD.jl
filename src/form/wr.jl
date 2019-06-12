

function variable_bus_voltage_on_off(pm::_PMs.GenericPowerModel{T}; kwargs...) where T <: _PMs.AbstractWRForm
    variable_voltage_magnitude_sqr_on_off(pm; kwargs...)
    variable_bus_voltage_product_on_off(pm; kwargs...)
end


function variable_bus_voltage_product_on_off(pm::_PMs.GenericPowerModel{T}; nw::Int=pm.cnw, cnd::Int=pm.ccnd) where T <: _PMs.AbstractWRForm
    wr_min, wr_max, wi_min, wi_max = _PMs.ref_calc_voltage_product_bounds(_PMs.ref(pm, nw, :buspairs))

    _PMs.var(pm, nw, cnd)[:wr] = JuMP.@variable(pm.model,
        [bp in _PMs.ids(pm, nw, :buspairs)], base_name="$(nw)_$(cnd)_wr",
        lower_bound = min(0,wr_min[bp]),
        upper_bound = max(0,wr_max[bp]),
        start = _PMs.comp_start_value(_PMs.ref(pm, nw, :buspairs, bp), "wr_start", cnd, 1.0)
    )
    _PMs.var(pm, nw, cnd)[:wi] = JuMP.@variable(pm.model,
        wi[bp in _PMs.ids(pm, nw, :buspairs)], base_name="$(nw)_$(cnd)_wi",
        lower_bound = min(0,wi_min[bp]),
        upper_bound = max(0,wi_max[bp]),
        start = _PMs.comp_start_value(_PMs.ref(pm, nw, :buspairs, bp), "wi_start", cnd)
    )

end


function constraint_bus_voltage_on_off(pm::_PMs.GenericPowerModel{T}, n::Int, c::Int; kwargs...) where T <: _PMs.AbstractWRForm
    for (i,bus) in _PMs.ref(pm, n, :bus)
        constraint_voltage_magnitude_sqr_on_off(pm, i; nw=n, cnd=c)
    end

    constraint_bus_voltage_product_on_off(pm; nw=n, cnd=c)

    w = _PMs.var(pm, n, c, :w)
    wr = _PMs.var(pm, n, c, :wr)
    wi = _PMs.var(pm, n, c, :wi)

    for (i,j) in _PMs.ids(pm, n, :buspairs)
        InfrastructureModels.relaxation_complex_product(pm.model, w[i], w[j], wr[(i,j)], wi[(i,j)])
    end
end




function variable_bus_voltage_on_off(pm::_PMs.AbstractWRModel; kwargs...)
    variable_voltage_magnitude_sqr_on_off(pm; kwargs...)
    variable_bus_voltage_product_on_off(pm; kwargs...)
end


function variable_bus_voltage_product_on_off(pm::_PMs.AbstractWRModel; nw::Int=pm.cnw, cnd::Int=pm.ccnd)
    wr_min, wr_max, wi_min, wi_max = _PMs.ref_calc_voltage_product_bounds(_PMs.ref(pm, nw, :buspairs))

    _PMs.var(pm, nw, cnd)[:wr] = JuMP.@variable(pm.model,
        [bp in _PMs.ids(pm, nw, :buspairs)], base_name="$(nw)_$(cnd)_wr",
        lower_bound = min(0,wr_min[bp]),
        upper_bound = max(0,wr_max[bp]),
        start = _PMs.comp_start_value(_PMs.ref(pm, nw, :buspairs, bp), "wr_start", cnd, 1.0)
    )
    _PMs.var(pm, nw, cnd)[:wi] = JuMP.@variable(pm.model,
        [bp in _PMs.ids(pm, nw, :buspairs)], base_name="$(nw)_$(cnd)_wi",
        lower_bound = min(0,wi_min[bp]),
        upper_bound = max(0,wi_max[bp]),
        start = _PMs.comp_start_value(_PMs.ref(pm, nw, :buspairs, bp), "wi_start", cnd)
    )

end


function constraint_bus_voltage_product_on_off(pm::_PMs.AbstractWRModels; nw::Int=pm.cnw, cnd::Int=pm.ccnd)
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


function constraint_bus_voltage_on_off(pm::_PMs.AbstractWRModels, n::Int, c::Int; kwargs...)
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


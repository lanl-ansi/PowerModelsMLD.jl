

function variable_bus_voltage_on_off(pm::GenericPowerModel{T}; kwargs...) where T <: PMs.AbstractWRForm
    variable_voltage_magnitude_sqr_on_off(pm; kwargs...)
    variable_bus_voltage_product_on_off(pm; kwargs...)
end


function variable_bus_voltage_product_on_off(pm::GenericPowerModel{T}; nw::Int=pm.cnw, cnd::Int=pm.ccnd) where T <: PMs.AbstractWRForm
    wr_min, wr_max, wi_min, wi_max = PMs.calc_voltage_product_bounds(ref(pm, nw, :buspairs))

    var(pm, nw, cnd)[:wr] = @variable(pm.model,
        [bp in ids(pm, nw, :buspairs)], basename="$(nw)_$(cnd)_wr",
        lowerbound = min(0,wr_min[bp]),
        upperbound = max(0,wr_max[bp]),
        start = PMs.getval(ref(pm, nw, :buspairs, bp), "wr_start", cnd, 1.0)
    )
    var(pm, nw, cnd)[:wi] = @variable(pm.model, 
        wi[bp in ids(pm, nw, :buspairs)], basename="$(nw)_$(cnd)_wi",
        lowerbound = min(0,wi_min[bp]),
        upperbound = max(0,wi_max[bp]),
        start = PMs.getval(ref(pm, nw, :buspairs, bp), "wi_start", cnd)
    )

end


function constraint_bus_voltage_on_off(pm::GenericPowerModel{T}, n::Int, c::Int; kwargs...) where T <: PMs.AbstractWRForm
    for (i,bus) in ref(pm, n, :bus)
        constraint_voltage_magnitude_sqr_on_off(pm, i; nw=n, cnd=c)
    end

    constraint_bus_voltage_product_on_off(pm; nw=n, cnd=c)

    w = var(pm, n, c, :w)
    wr = var(pm, n, c, :wr)
    wi = var(pm, n, c, :wi)

    for (i,j) in ids(pm, n, :buspairs)
        InfrastructureModels.relaxation_complex_product(pm.model, w[i], w[j], wr[(i,j)], wi[(i,j)])
    end
end




function variable_bus_voltage_on_off(pm::GenericPowerModel{T}, nw::Int=pm.cnw, cnd::Int=pm.ccnd; bounded = true, kwargs...) where T <: PMs.AbstractWRMForm
    wr_min, wr_max, wi_min, wi_max = PMs.calc_voltage_product_bounds(ref(pm, nw, :buspairs))

    bus_count = length(ref(pm, nw, :bus))
    w_index = 1:bus_count
    lookup_w_index = Dict([(bi, i) for (i,bi) in enumerate(keys(ref(pm, nw, :bus)))])

    WR = var(pm, nw, cnd)[:WR] = @variable(pm.model, [1:bus_count, 1:bus_count], Symmetric, basename="$(nw)_$(cnd)_WR")
    WI = var(pm, nw, cnd)[:WI] = @variable(pm.model, [1:bus_count, 1:bus_count], basename="$(nw)_$(cnd)_WI")

    # bounds on diagonal
    for (i, bus) in ref(pm, nw, :bus)
        w_idx = lookup_w_index[i]
        wr_ii = WR[w_idx,w_idx]
        wi_ii = WR[w_idx,w_idx]

        if bounded
            setlowerbound(wr_ii, min(0, bus["vmin"][cnd]^2))
            setupperbound(wr_ii, max(0, bus["vmax"][cnd]^2))

            #this breaks SCS on the 3 bus exmple
            #setlowerbound(wi_ii, 0)
            #setupperbound(wi_ii, 0)
        else
             setlowerbound(wr_ii, 0)
        end
    end

    # bounds on off-diagonal
    for (i,j) in ids(pm, nw, :buspairs)
        wi_idx = lookup_w_index[i]
        wj_idx = lookup_w_index[j]

        if bounded
            setupperbound(WR[wi_idx, wj_idx], max(0, wr_max[(i,j)]))
            setlowerbound(WR[wi_idx, wj_idx], min(0, wr_min[(i,j)]))

            setupperbound(WI[wi_idx, wj_idx], max(0, wi_max[(i,j)]))
            setlowerbound(WI[wi_idx, wj_idx], min(0, wi_min[(i,j)]))
        end
    end

    var(pm, nw, cnd)[:w] = Dict{Int,Any}()
    for (i, bus) in ref(pm, nw, :bus)
        w_idx = lookup_w_index[i]
        var(pm, nw, cnd, :w)[i] = WR[w_idx,w_idx]
    end

    var(pm, nw, cnd)[:wr] = Dict{Tuple{Int,Int},Any}()
    var(pm, nw, cnd)[:wi] = Dict{Tuple{Int,Int},Any}()
    for (i,j) in ids(pm, nw, :buspairs)
        w_fr_index = lookup_w_index[i]
        w_to_index = lookup_w_index[j]

        var(pm, nw, cnd, :wr)[(i,j)] = WR[w_fr_index, w_to_index]
        var(pm, nw, cnd, :wi)[(i,j)] = WI[w_fr_index, w_to_index]
    end
end


function constraint_bus_voltage_on_off(pm::GenericPowerModel{T}, n::Int, c::Int) where T <: PMs.AbstractWRMForm
    WR = var(pm, n, c, :WR)
    WI = var(pm, n, c, :WI)
    z_voltage = var(pm, n, c, :z_voltage)

    @SDconstraint(pm.model, [WR WI; -WI WR] >= 0)

    for (i,bus) in ref(pm, n, :bus)
        constraint_voltage_magnitude_sqr_on_off(pm, i; nw=n, cnd=c)
    end

    # is this correct?
    constraint_bus_voltage_product_on_off(pm; nw=n, cnd=c)
end



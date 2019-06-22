function add_load_weights!(data::Dict{String,<:Any})
    if !haskey(data, "source_type") || data["source_type"] != "pti"
        warn(_LOGGER, "add_load_weights! currently only supports networks from pti files")
        return
    end

    for (i,load) in data["load"]
        @assert(haskey(load, "source_id") && length(load["source_id"]) == 3)
        load_ckt = lowercase(load["source_id"][3])
        if startswith(load_ckt, 'l')
            Memento.info(_LOGGER, "setting load $(i) to low priority")
            load["weight"] = 1.0
        elseif startswith(load_ckt, 'm')
            Memento.info(_LOGGER, "setting load $(i) to medium priority")
            load["weight"] = 10.0
        elseif startswith(load_ckt, 'h')
            Memento.info(_LOGGER, "setting load $(i) to high priority")
            load["weight"] = 100.0
        end
    end
end
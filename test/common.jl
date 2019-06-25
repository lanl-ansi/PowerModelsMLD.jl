
# helper functions 
function gen_status(result, gen_id)
    return result["solution"]["gen"][gen_id]["gen_status"]
end

function storage_status(result, storage_id)
    return result["solution"]["storage"][storage_id]["status"]
end

function bus_status(result, bus_id)
    return result["solution"]["bus"][bus_id]["status"]
end

function all_gens_on(result)
    #println([gen["gen_status"] for (i,gen) in result["solution"]["gen"]])
    #println(minimum([gen["gen_status"] for (i,gen) in result["solution"]["gen"]]))
    # tolerance of 1e-5 is needed for SCS tests to pass
    return minimum([gen["gen_status"] for (i,gen) in result["solution"]["gen"]]) >= 1.0 - 1e-5
end

function active_power_served(result)
    #println([bus["pd"] for (i,bus) in result["solution"]["bus"]])
    #println(sum([bus["pd"] for (i,bus) in result["solution"]["bus"]]))
    return sum([load["pd"] for (i,load) in result["solution"]["load"]])
end

function all_voltages_on(result)
    #println([bus["status"] for (i,bus) in result["solution"]["bus"]])
    return return minimum([bus["status"] for (i,bus) in result["solution"]["bus"]]) >= 1.0 - 1e-3 #(note, non-SCS solvers are more accurate)
end

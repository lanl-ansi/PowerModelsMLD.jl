using InfrastructureModels
using PowerModels
using PowerModels.Memento

# Suppress warnings during testing.
setlevel!(getlogger(InfrastructureModels), "error")
setlevel!(getlogger(PowerModels), "error")

using PowerModelsMLD

using Cbc
using Ipopt
using Pajarito
using Pavito
using Juniper
using SCS


if VERSION < v"0.7.0-"
    pms_path = Pkg.dir("PowerModels")
    using Base.Test
end

if VERSION > v"0.7.0-"
    pms_path = joinpath(dirname(pathof(PowerModels)), "..")
    using Test
end


cbc_solver = CbcSolver()

# default setup for solvers
ipopt_solver = IpoptSolver(tol=1e-6, print_level=0)
juniper_solver = JuniperSolver(IpoptSolver(tol=1e-4, print_level=0), mip_solver=cbc_solver, log_levels=[])
#juniper_solver = JuniperSolver(IpoptSolver(tol=1e-4, print_level=0), mip_solver=cbc_solver)
pavito_solver = PavitoSolver(mip_solver=cbc_solver, cont_solver=ipopt_solver, mip_solver_drives=false, log_level=0)

scs_solver = SCSSolver(max_iters=1000000, acceleration_lookback=1, alpha=1.9, verbose=0)
pajarito_sdp_solver = PajaritoSolver(mip_solver=cbc_solver, cont_solver=scs_solver, mip_solver_drives=false, log_level=0)


# parse test cases
case3_mld = PowerModels.parse_file("../test/data/case3_mld.m")
case3_mld_s = PowerModels.parse_file("../test/data/case3_mld_s.m")
case3_mld_uc = PowerModels.parse_file("../test/data/case3_mld_uc.m")
case3_mld_lc = PowerModels.parse_file("../test/data/case3_mld_lc.m")
case5_mld_ft = PowerModels.parse_file("../test/data/case5_mld_ft.m")
case24 = PowerModels.parse_file("$(pms_path)/test/data/matpower/case24.m")


# testing threshold parameters
opt_gap_tol = 1e-3 # in the case of max, throw error if ub/lb < 1 - opt_gap_tol (note, non-SCS solvers are more accurate)


include("common.jl")


@testset "PowerModelsMLD" begin

include("mld_output.jl")

include("mld_data.jl")

include("mld.jl")

include("mld_uc.jl")

include("mld_smpl.jl")

include("util.jl")

end
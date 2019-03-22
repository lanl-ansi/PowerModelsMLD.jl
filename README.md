# PowerModelsMLD.jl

A PowerModelsMLD provides extensions to [PowerModels](https://github.com/lanl-ansi/PowerModels.jl) for solving the Maximum Load Delivery (MLD) problem.
The MLD problem provides a reliable numerical method for solving challenging N-k damage scenarios, such as those that arise in the analysis of extreme events.

**Core Problem Specifications**
* Maximum Load Delivery with Discrete Variables (mld_uc)
* Maximum Load Delivery with Continuous Variables (mld)

**Core Network Formulations**
* AC (polar coordinates)
* DC Approximation (polar coordinates)
* SDP Relaxation (W-space)
* SOC Relaxation (W-space)


## Quick Start

The primary entry point of the PowerModelsMLD package is the `PowerModelsMLD.run_ac_mld_uc` function, which provides a scalable heuristic for solving the AC-MLD problem.
The following example illustrates how to load a network, damage components and solve the AC-MLD problem.
```
using PowerModels; using PowerModelsMLD; using Ipopt
network_file = joinpath(dirname(pathof(PowerModels)), "../test/data/matpower/case5.m")
case = PowerModels.parse_file(network_file)

case["bus"]["2"]["bus_type"] = 4
case["gen"]["2"]["gen_status"] = 0
case["branch"]["7"]["br_status"] = 0

result = PowerModelsMLD.run_ac_mld_uc(case, IpoptSolver())
```
The result data indicates that only 700 of the 1000 MWs can be delivered given the removal of bus 2, generator 2 and branch 7.


## Citing PowerModelsMLD

If you find PowerModelsMLD useful in your work, we kindly request that you cite the following [publication](https://ieeexplore.ieee.org/document/8494809):
```
@article{8494809, 
  author={Carleton Coffrin and Russel Bent and Byron Tasseff and Kaarthik Sundar and Scott Backhaus}, 
  title={Relaxations of AC Maximal Load Delivery for Severe Contingency Analysis}, 
  journal={IEEE Transactions on Power Systems}, 
  volume={34}, number={2}, pages={1450-1458},
  month={March}, year={2019},
  doi={10.1109/TPWRS.2018.2876507}, ISSN={0885-8950}
}
```
Citation of the [PowerModels framework](https://ieeexplore.ieee.org/document/8442948/) is also encouraged when publishing works that use PowerModels extension packages.


## License

This code is provided under a BSD license as part of the Multi-Infrastructure Control and Optimization Toolkit (MICOT) project, LA-CC-13-108.

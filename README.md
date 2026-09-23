# AlphaFold 3 to AMBER molecular dynamics templates

This repository contains editable templates for preparing a protein–DNA complex predicted by AlphaFold 3 and running wild-type (WT) and mutant (MUT) molecular dynamics with AMBER 24 on a SLURM cluster. It includes ChimeraX preparation commands, `tleap` topology inputs, AMBER control files, and CPU/GPU batch scripts. It does not contain a structure, trajectory, simulation result, or automated validation.

## Workflow

1. Inspect the predicted complex and edit [`chimerax/prep_and_mutate.cxc`](chimerax/prep_and_mutate.cxc) for its chain IDs, residue numbers, and input file. Save cleaned WT and MUT structures and verify each intended substitution.
2. Add protein hydrogens and inspect the output. Edit [`inputs/tleap_WT.in`](inputs/tleap_WT.in) and [`inputs/tleap_MUT.in`](inputs/tleap_MUT.in) for the actual files and the `N_IONS` placeholder. Build and check both topologies. The templates select ff14SB, OL21 DNA, and TIP3P water.
3. Edit the paths, module name, partition, and resource requests in [`scripts/`](scripts/). Submit energy minimization, NVT equilibration, NPT equilibration, and production in that order for each system.
4. Inspect each stage's logs, energies, and restart files before using the next stage. The production control file specifies 25,000,000 steps at 0.002 ps, or 50 ns per system.

The [extended workflow notes](docs/legacy-readme.md) include example commands, job dependencies, and parameter descriptions. They are a template record and require review against the chosen structure and cluster configuration.

## Requirements and scope

The templates call ChimeraX, AMBER 24 tools (`reduce`, `tleap`, `pmemd`, and `pmemd.cuda`), and SLURM. The batch scripts currently contain `/path/to/your/simulation` placeholders, and the ChimeraX script contains `YOURFILE.pdb` and `RES1`–`RES3` placeholders. Replace these before running anything. The ion count must be calculated for the solvated system. No cluster-independent run command is provided because the batch scripts specify site-dependent partitions and modules.

The workflow prepares two variants for simulation. It does not establish that a predicted complex is stable or that a mutation changes binding. No quantitative result or benchmark is supplied. The repository contains no license file; reuse permissions should be confirmed with the owner.

## References

The force-field choices are documented by [Maier et al. (2015), ff14SB](https://doi.org/10.1021/acs.jctc.5b00255) and [Zgarbová et al. (2021), OL21](https://doi.org/10.1021/acs.jctc.0c01067). The AMBER project provides [equilibration guidance](https://ambermd.org/Questions/equilibration.html).

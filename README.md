# AF3 to AMBER MD Simulation Pipeline

A template pipeline for running molecular dynamics simulations of protein-DNA complexes using AMBER, starting from AlphaFold3 structural predictions. The pipeline covers structure preparation in ChimeraX, topology building with tleap, and a full equilibration and production MD workflow on a SLURM-based HPC cluster with GPU acceleration.

This repository contains template SLURM scripts, AMBER input files, and a ChimeraX workflow guide. It is set up for two systems, a wild type and a mutant, referred to throughout as WT and MUT.

---

## Prerequisites

- AMBER 24 (pmemd and pmemd.cuda)
- ChimeraX 1.7 or later
- A SLURM cluster with GPU nodes (tested on Hellbender HPC, University of Missouri)
- AlphaFold3 output in PDB or mmCIF format

---

## Repository Structure

```
AF3ToGromacsMDSim/
├── chimerax/
│   └── prep_and_mutate.cxc       # ChimeraX commands for structure cleaning and mutagenesis
├── inputs/
│   ├── tleap_WT.in               # tleap topology input for wild type
│   ├── tleap_MUT.in              # tleap topology input for mutant
│   ├── em.in                     # AMBER energy minimization input
│   ├── nvt.in                    # AMBER NVT equilibration input
│   ├── npt.in                    # AMBER NPT equilibration input
│   └── prod.in                   # AMBER production MD input
├── scripts/
│   ├── em_WT.sh / em_MUT.sh      # SLURM energy minimization (CPU)
│   ├── nvt_WT.sh / nvt_MUT.sh    # SLURM NVT equilibration (GPU)
│   ├── npt_WT.sh / npt_MUT.sh    # SLURM NPT equilibration (GPU)
│   └── prod_WT.sh / prod_MUT.sh  # SLURM production MD (GPU)
└── README.md
```

During a run, the following directories are created at your working path:

```
/your/working/directory/
├── WT/      # Wild type input and output files
├── MUT/     # Mutant input and output files
├── logs/    # SLURM and program logs
└── inputs/  # Symlinked or copied from this repo
```

---

## Workflow Overview

### Step 1: Structure Preparation in ChimeraX

Open your AlphaFold3 output and clean the structure before running any MD. See `chimerax/prep_and_mutate.cxc` for the full command set. The key steps are:

1. Open the structure and inspect chain layout
2. Delete solvent and unknown residues
3. Verify that key contact residues are present and positioned correctly
4. Save the cleaned wild type structure
5. Apply alanine substitutions at target positions using `swapaa`
6. Verify the mutations in the sequence panel before saving the mutant

AlphaFold3 outputs occasionally include a 5' phosphate group on terminal DNA nucleotides (OP3, P, OP1, OP2 on residue 1 of each DNA chain). These atoms are not present in tleap's terminal nucleotide templates and must be removed before running tleap. This can be done with `delete` in ChimeraX or with awk on the PDB file after exporting.

### Step 2: Add Hydrogens

Use `reduce -BUILD` from the AMBER suite to add hydrogens to the protein. Reduce does not handle DNA nucleotides, which is expected. tleap will add DNA hydrogens from the force field parameters.

```bash
module load amber/24
reduce -BUILD WT/PROTEIN_WT_clean.pdb > WT/PROTEIN_WT_H.pdb 2> logs/reduce_WT.log
reduce -BUILD MUT/PROTEIN_MUT_clean.pdb > MUT/PROTEIN_MUT_H.pdb 2> logs/reduce_MUT.log
```

Check logs for any histidine protonation issues. If `HIP` appears and the simulation is at physiological pH, change those residues to `HIE`.

### Step 3: Build Topology with tleap

Edit `inputs/tleap_WT.in` and `inputs/tleap_MUT.in` to point to your working directory and PDB files. The templates use:

- Protein force field: ff14SB
- DNA force field: OL21
- Water model: TIP3P
- Box type: truncated octahedron with 12 A padding
- Ions: neutralization with Na+, then additional Na+/Cl- for physiological salt (150 mM)

To calculate the number of additional ion pairs for 150 mM NaCl, count the water molecules in your solvated PDB and apply:

```
N_ions = 0.15 * N_water / 55.5
```

Run tleap and check for zero errors before proceeding:

```bash
module load amber/24
tleap -f inputs/tleap_WT.in 2>&1 | tee logs/tleap_WT.log
grep -i "error\|fatal\|unknown" logs/tleap_WT.log
```

### Step 4: AMBER Input Files

The `inputs/` directory contains ready-to-use AMBER input files. Key parameter choices:

| Parameter | Value | Notes |
|---|---|---|
| Timestep | 0.002 ps | Requires SHAKE (ntc=2, ntf=2) |
| Thermostat | Langevin, gamma=2.0 | NVT and NPT equilibration |
| Barostat | Monte Carlo (barostat=2) | NPT equilibration and production |
| Nonbonded cutoff | 10.0 A | PME handles long-range electrostatics |
| Production length | 50 ns | 25,000,000 steps |

### Step 5: SLURM Scripts

Edit the `#SBATCH --chdir` and `#SBATCH --output` lines in each script to point to your working directory. Then update the prmtop and inpcrd filenames to match your system.

Submit the EM jobs first (CPU partition), then chain the GPU jobs as dependencies:

```bash
EM_WT=$(sbatch --parsable scripts/em_WT.sh)
EM_MUT=$(sbatch --parsable scripts/em_MUT.sh)

NVT_WT=$(sbatch --parsable --dependency=afterok:${EM_WT} scripts/nvt_WT.sh)
NPT_WT=$(sbatch --parsable --dependency=afterok:${NVT_WT} scripts/npt_WT.sh)
PROD_WT=$(sbatch --parsable --dependency=afterok:${NPT_WT} scripts/prod_WT.sh)

NVT_MUT=$(sbatch --parsable --dependency=afterok:${EM_MUT} scripts/nvt_MUT.sh)
NPT_MUT=$(sbatch --parsable --dependency=afterok:${NVT_MUT} scripts/npt_MUT.sh)
PROD_MUT=$(sbatch --parsable --dependency=afterok:${NPT_MUT} scripts/prod_MUT.sh)
```

### Step 6: Monitor and Verify

After energy minimization, confirm the total energy decreased from a large positive value (typical for an AF3 structure with close contacts) to a large negative value. If any downstream job fails, the remaining jobs in the chain will be automatically cancelled due to the `afterok` dependency.

Once production is running, check ns/day to estimate completion time:

```bash
grep "ns/day" WT/prod_WT.out | tail -3
```

Expected throughput on an A100 GPU for a system of this size is 80 to 150 ns/day.

---

## Notes

- This pipeline was written for AMBER 24 on a SLURM cluster. Partition names (`general`, `gpu`) and module names may differ on your system.
- OL24 (2024 DNA force field, corrects A-DNA stability in OL21) was not available on the development cluster. If your AMBER installation includes it, substitute `leaprc.DNA.OL24` in the tleap inputs.
- The `--gres=gpu:1` directive requests any available GPU. To target a specific type (for example an A100), use `--gres=gpu:A100:1`.
- Coordinate wrapping (`iwrap=1`) is enabled during production. Use cpptraj with `autoimage` before analysis to unwrap trajectories.

---

## References

1. Maier et al. ff14SB. JCTC 2015. https://doi.org/10.1021/acs.jctc.5b00255
2. Zgarbova et al. OL21 DNA force field. JCTC 2021. https://doi.org/10.1021/acs.jctc.0c01067
3. Zgarbova et al. OL24. JCTC 2025. https://doi.org/10.1021/acs.jctc.4c01100
4. AMBER equilibration documentation. https://ambermd.org/Questions/equilibration.html

# Nicholson-Ross-Weir (NRW) Permittivity & Permeability Extraction

A MATLAB implementation of the Nicholson-Ross-Weir (NRW) algorithm for extracting the complex relative permittivity (εr) and permeability (μr) of a material from two-port S-parameter measurements in a rectangular waveguide. The algorithm is based on [NIST Technical Note 1536](https://nvlpubs.nist.gov/nistpubs/Legacy/TN/nbstechnicalnote1536.pdf) (page 112).

---

## Contents

| File | Description |
|------|-------------|
| `NRW_extraction.m` | Main MATLAB script implementing the NRW algorithm |
| `NRW_SimulationTest_teflon_6p3mm.s2p` | Reference S-parameter data (Touchstone format) |
| `NRW_SimulationTest.aedt` | ANSYS HFSS simulation file used to generate the `.s2p` |

---

## Reference Simulation

The included `.s2p` and `.aedt` files are provided as a reference test case. The simulation models a **6.3 mm block of PTFE (Teflon)** inside a **WR-90 rectangular waveguide** (X-band, 8–12 GHz). Running the script against this file should return values close to the well-known properties of Teflon (ε′ ≈ 2.1, tan δ ≈ 0.0002).

> **Important — HFSS Export Setting:** When exporting S-parameters from the `.aedt` file, **do not renormalize the S-parameters**. The Touchstone file must be normalized to the characteristic impedance of the waveguide, not a standard 50 Ω port impedance. Renormalizing will produce incorrect results.

---

## Requirements

- MATLAB (any recent version)
- [`SPARAMS` MATLAB Touchstone Reader](https://github.com/njchorda/MATLAB-Touchstone-Reader) — place on your MATLAB path before running

---

## Usage

1. Place your `.s2p` file and the script in the same directory (or update `filepath`).
2. Set the waveguide width `a` and sample length `L` to match your setup.
3. Run the script. Two figures will be produced:
   - **Figure 1** — Complex relative permittivity (ε′, ε″) and dielectric loss tangent (tan δ)
   - **Figure 2** — Complex relative permeability (μ′, μ″) and magnetic loss tangent (tan δ_m)
4. Average values and values at a user-specified frequency are printed to the command window.

```matlab
a = 22.86e-3;   % WR-90 waveguide width (m)
L = 6.3e-3;     % Sample thickness (m) — measure this carefully!
```

---

## Measurement Guidelines

### Sample Thickness
Accurate knowledge of the physical sample thickness `L` is one of the most important inputs to the NRW algorithm. A small error in `L` propagates directly into errors in both ε and μ across the entire frequency band. **Measure the sample thickness with a micrometer or calibrated caliper**, and use the average of several measurements across the sample face.

### Sample Holder / Sample Length Selection
The sample length should be chosen to be approximately **one-quarter of the guided wavelength** within the material at the frequency of interest:

$$L \approx \frac{\lambda_g}{4} = \frac{\lambda_0}{4\sqrt{\varepsilon_r \mu_r - \left(\frac{\lambda_0}{\lambda_c}\right)^2}}$$

For **high-permittivity materials**, the guided wavelength inside the sample is shorter, so a **thinner sample holder must be used** to satisfy this condition. Using a sample that is too long relative to the guided wavelength can introduce phase ambiguity errors in the extraction.

---

## Output Example

```
Averages:
er = 2.1000
tanD = 0.0010584
ur = 0.99962
magtanD = 8.2202e-05
At 10 GHz
er = 2.1000
tanD = 0.0010094
ur = 0.99962
magtanD = 8.9186e-06
```

---

## References

- Nicholson, A. M., & Ross, G. F. (1970). *Measurement of the intrinsic properties of materials by time-domain techniques.* IEEE Transactions on Instrumentation and Measurement.
- Weir, W. B. (1974). *Automatic measurement of complex dielectric constant and permeability at microwave frequencies.* Proceedings of the IEEE.
- Janezic, M. D., & Jargon, J. A. (2004). [*Complex Permittivity Determination from Propagation Constant Measurements.*](https://nvlpubs.nist.gov/nistpubs/Legacy/TN/nbstechnicalnote1536.pdf) NIST Technical Note 1536.


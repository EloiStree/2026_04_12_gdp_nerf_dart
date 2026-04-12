**# Nerf Dart Physics Cheatsheet**  
*For Godot Game Development & Realistic Projectile Simulation*

### 1. Core Physics Summary
Nerf darts are **low-mass** (~1 g), **blunt**, foam projectiles.  
**Air drag dominates** over inertia — they do **not** follow nice parabolas.

- **Drag regime**: Strongly **quadratic** (proportional to v²)
- **Typical terminal velocity**: ~10–15 m/s (much lower than bullets)
- **Flight behavior**: Quick drop, short range (10–25 m), curved trajectory, sensitive to launch angle
- **Stability**: Front-weighted darts fly straighter (center of mass ahead of center of pressure)

### 2. Key Equations

#### Quadratic Drag Force
$$
\mathbf{F}_d = -\frac{1}{2} \rho C_d A \, v \, \mathbf{v}
$$

Where:
- \(\rho\) = air density = **1.225 kg/m³**
- \(C_d\) = drag coefficient
- \(A = \pi r^2\) = cross-sectional area
- \(v = |\mathbf{v}|\)

#### Drag Constant (pre-compute for code)
$$
K = \frac{\rho \cdot C_d \cdot A}{2 \cdot m}
$$
Then:  
$$
\mathbf{a}_{drag} = -K \cdot v \cdot \mathbf{v}
$$

#### Total Acceleration (in simulation)
$$
\mathbf{a} = \mathbf{g} + \mathbf{a}_{drag}
$$

### 3. Recommended Parameters (from papers)

| Parameter              | Value                  | Source / Notes                     |
|------------------------|------------------------|------------------------------------|
| Mass (m)               | 0.001 kg (1 g)         | Standard Nerf Elite dart           |
| Radius (r)             | 0.006 m (6 mm)         | Typical                            |
| Area (A)               | ~1.13 × 10⁻⁴ m²        | πr²                                |
| Drag Coefficient (Cd)  | **0.67 – 0.8** (best)  | Trettel 2013                       |
| Cd (vertical fall)     | ~1.6                   | Hughes 2024                        |
| Muzzle Velocity        | 20–45 m/s              | Stock → modded blasters            |
| Gravity                | 9.81 m/s²              | Can lower for "fun" feel           |

### 4. Main Scientific Sources

- **Hughes (2024) – "The physics of nerf guns"**  
  [PDF](https://iopscience.iop.org/article/10.1088/1361-6552/ad4c47/pdf)  
  Excellent classroom experiment using smartphone video. Vertical shot data. Good for Cd estimation from fall phase.

- **Trettel (2013) – Ballistic Notes**  
  [PDF](http://www.trettel.us/pubs/2013/Trettel-2013-Ballistics-notes.pdf)  
  **Most practical reference** for Nerf. Covers internal + external ballistics, quadratic drag, stability, flat-fire approximations, and barrel friction.

- **Howard & Linhart (2022) – Ballistic Modeling of Sponge Dart (SIMIODE)**  
  [Link](https://qubeshub.org/publications/3162)  
  Compares 3 models (no drag, linear drag, quadratic drag). Includes real data + MATLAB/Python code.

### 5. Godot Implementation Tips

- Use **CharacterBody3D** + manual integration (as we did)
- Or **RigidBody3D** + `_integrate_forces()`
- Pre-compute `_drag_k`
- Apply drag every `_physics_process(delta)`
- `velocity += (gravity + drag_accel) * delta`
- `move_and_slide()`
- Tune `Cd` between **0.7** (flatter) and **1.4** (very floaty)

### 6. Quick Tuning Guide

| Desired Feel         | Cd     | Muzzle Speed | Notes                     |
|----------------------|--------|--------------|---------------------------|
| Stock Nerf           | 1.2–1.6| 25–30 m/s    | Drops fast                |
| Balanced Game        | 0.8–1.0| 32–38 m/s    | Recommended starting point|
| Modded / Powerful    | 0.65–0.8 | 45+ m/s    | Flatter arcs              |

### 7. Extra Realism Tips
- Add tiny random angular velocity (spin) for wobble
- Front-heavy darts = better stability
- Trail particles should reduce with speed
- Optional: simple trajectory predictor line using numerical integration

---

**Best starting point for your game jam**:  
Use `Cd = 0.8`, muzzle velocity ~32–35 m/s, and the CharacterBody3D script we built.

Copy-paste this cheatsheet into your project notes!  
Need a version with more equations, trajectory prediction code, or impact effects? Just ask. 🎯





--------------------



**Drag Coefficient (Cd) Derivation for Nerf Darts – Explained Simply**

The **drag coefficient (Cd)** is a **dimensionless number** that quantifies how "draggy" an object is in air. It lumps together shape, surface roughness, and flow separation effects. For Nerf darts, Cd is typically between **0.67 and 1.6**, much higher than a streamlined bullet (~0.3) because darts are blunt and light.

### General Drag Force Equation
$$
F_d = \frac{1}{2} \rho \, C_d \, A \, v^2
$$
- \(F_d\): Drag force (N)
- \(\rho\): Air density (~1.225 kg/m³)
- \(A = \pi r^2\): Cross-sectional area
- \(v\): Speed
- \(C_d\): What we want to find

Rearranged to solve for **Cd**:
$$
C_d = \frac{2 F_d}{\rho \, A \, v^2}
$$

### 1. Hughes (2024) – Vertical Shot Method (Classroom Experiment)

This is the most straightforward experimental derivation:

**Method**:
1. Fire a Nerf dart **straight up** and record with a high-speed phone camera (240 fps).
2. Measure:
   - Time to reach max height (**t₁**)
   - Time to fall back down (**t₂**)

3. From ascent (drag is small at the top):
   - Max height \( h \approx \frac{1}{2} g t_1^2 \)
   - Initial velocity \( v_0 = g t_1 \)

4. From descent (drag is significant):
   - Average downward acceleration \( a_2 = \frac{2h}{t_2^2} \) (less than g because drag opposes gravity)
   - Net downward force: \( m a_2 = m g - F_d \)
   - So drag force \( F_d = m (g - a_2) \)

5. Plug into the Cd formula using **mean fall velocity**:
   $$
   C_D \approx \frac{2 F_D}{\rho \, v^2 \, A}
   $$

**Result from Hughes**: **Cd ≈ 1.6**

This higher value makes sense for the **fall phase**, where the dart is slower and more affected by turbulence.

### 2. Trettel (2013) + Beaver’s Flat-Fire Tests – Cd ≈ 0.67

**Method**:
- Fire darts **horizontally** (flat) at known muzzle velocities.
- Measure actual range.
- Compare to theoretical range with and without drag.
- Use the quadratic drag trajectory model to back-calculate Cd that best fits the data.

Trettel references Daniel Beaver’s careful experiments (level barrel, chronograph) and matches them to Hoerner’s classic cylinder drag data.

**Result**: **Cd = 0.67 ± 0.029**

This is the value most Nerf ballistics enthusiasts use because it works well for **typical shooting angles** (not straight up).

### Why Different Cd Values?

| Situation              | Cd Value | Reason                              |
|------------------------|----------|-------------------------------------|
| Vertical fall (Hughes) | ~1.6     | Slower speeds, more flow separation |
| Horizontal / angled    | ~0.67    | Better match to real game ranges    |
| CFD / Wind tunnel      | 0.62     | Very clean measurement              |

**For game development**, start with **Cd = 0.8** (a good compromise) and tune it until the arc and range feel right.

### Practical Takeaway for Your Godot Script

The `_drag_k` constant you calculate is exactly this derivation in code form:
```gdscript
_drag_k = (air_density * drag_coefficient * area) / (2.0 * mass)
```
Then `drag_accel = -_drag_k * speed * velocity`

This is why small changes in Cd have a big effect on how "floaty" or "sniper-like" your Nerf darts feel.

Would you like me to show a step-by-step numerical example (with sample numbers from a vertical shot) or add a simple trajectory predictor that uses the same equations?

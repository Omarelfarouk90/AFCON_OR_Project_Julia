# AFCON 2025: Egypt Tournament Simulator (Operations Research)

## Overview

This project uses **Operations Research (Large Neighborhood Search Metaheuristic)** to determine the optimal 11-player lineup for the Egyptian National Team for **AFCON 2025 (Morocco, Dec 2025 - Jan 2026)**. It provides comprehensive tournament analysis using:

- **Large Neighborhood Search (LNS)** metaheuristic for player selection
- **Real current player data** from AFCON 2025 tournament (Salah, Marmoush, etc.)
- **Multiple tactical strategies** (Balanced, Attack, Defense)
- **Simulated Annealing** acceptance criteria for escaping local optima
- **ASCII pitch visualizations** for all team formations
- **Tournament simulation** against 6 top African teams

**Core Technology**: Pure Julia with custom LNS implementation (no commercial solvers required).

**Tournament Context**: Egypt qualified for Round of 16 as Group B Winners (7 points: 2W, 1D). Beat Zimbabwe 2-1, South Africa 1-0, drew Angola 0-0.

---

## 1. Quick Start

### Prerequisites
- **Julia** v1.8 or newer ([Download here](https://julialang.org/downloads/))
- Terminal or command prompt
- Internet connection (for package installation)

### Step 1: Clone the Repository
```bash
git clone <your-repo-url>
cd AFCON_OR_Project_Julia
```

### Step 2: Install Dependencies
The project uses only lightweight Julia packages:

```bash
julia -e 'using Pkg; Pkg.add(["DataFrames", "CSV", "Statistics"])'
```

Or install from GitHub (bypasses corrupted package servers):

```bash
julia -e 'using Pkg; Pkg.Registry.add(Pkg.RegistrySpec(url="https://github.com/JuliaRegistries/General.git"))'
julia -e 'using Pkg; Pkg.add(url="https://github.com/JuliaData/DataFrames.jl.git")'
julia -e 'using Pkg; Pkg.add(url="https://github.com/JuliaData/CSV.jl.git")'
```

**Expected time**: 2-3 minutes

### Step 3: Run Tournament Simulation
```bash
julia afcon2025_tournament_simulation.jl
```

**Runtime**: 5-10 minutes (18 optimizations: 6 opponents × 3 strategies)

**Output**:
- 36 team CSV files (18 Egypt lineups + 18 opponent lineups)
- 1 tournament summary CSV with strategic recommendations
- ASCII pitch visualizations for all formations
- Detailed matchup analysis and statistical comparisons

---

## 2. Project Structure

```
AFCON_OR_Project_Julia/
├── afcon2025_tournament_simulation.jl   # NEW: Main tournament simulator
├── test_simulation.jl                   # Quick test (4 strategies)
├── full_simulation_visual.jl            # Visual comparison script
├── Project.toml                         # Julia dependencies
├── README.md                            # This file
│
├── data/                                # Player & match data
│   ├── egypt_squad.csv                  # 25 Egyptian players (AFCON 2025 squad)
│   └── opponents/                       # Opponent squads (2024-2025 data)
│       ├── morocco.csv                  # 20 players (Host, Group A winners)
│       ├── senegal.csv                  # 18 players (Group D winners)
│       ├── algeria.csv                  # 19 players (Group E winners, 9 pts)
│       ├── nigeria.csv                  # 19 players (Group C winners, 9 pts)
│       ├── cameroon.csv                 # 18 players (Group F runner-up)
│       └── cotedivoir.csv               # 19 players (Defending champs, Group F winners)
│
├── src/                                 # Julia source code
│   ├── optimize_team_lns.jl             # ✅ LNS metaheuristic optimizer (MAIN)
│   ├── visualize_ascii.jl               # ✅ ASCII pitch visualization
│   ├── optimize_team.jl                 # ⚠️  Old LP version (requires HiGHS)
│   ├── predict_match_advanced.jl        # Match prediction model
│   └── generate_data.jl                 # Data generation utilities
│
└── output/                              # Generated results
    ├── tournament_summary_afcon2025.csv      # Master summary (18 matchups)
    ├── egypt_[strategy]_vs_[opponent].csv    # 18 Egypt lineups
    ├── [opponent]_[strategy]_vs_egypt.csv    # 18 opponent lineups
    └── (legacy test files)
```

---

## 3. Features

### 3.1 Large Neighborhood Search (LNS) Metaheuristic
Custom implementation of LNS optimization for team selection:

**Algorithm Steps**:
1. **Initial Solution**: Greedy construction selecting best players per position
2. **Destroy Operator**: Remove 2-4 random players (excluding goalkeeper)
3. **Repair Operator**: Rebuild team using greedy insertion with constraints
4. **Acceptance Criterion**: Simulated Annealing (accept worse solutions with probability e^(Δ/T))
5. **Termination**: Stop after 1000 iterations or 200 iterations without improvement

**Constraints**:
- Exactly 1 Goalkeeper
- 3-5 Defenders
- At least 2 Midfielders
- At least 1 Forward
- Total = 11 players

**Objective**: Maximize weighted score based on strategy:
- **Balanced**: Attack×0.25 + Defense×0.25 + Passing×0.25 + Stamina×0.15 + Consistency×0.1
- **Attack**: Attack×0.5 + Defense×0.1 + Passing×0.2 + Stamina×0.1 + Consistency×0.1
- **Defense**: Attack×0.1 + Defense×0.5 + Passing×0.1 + Stamina×0.2 + Consistency×0.1

**Advantages**:
- No commercial solvers required (pure Julia implementation)
- Handles complex constraints naturally
- Fast convergence (typically 100-400 iterations)
- Escapes local optima via simulated annealing

### 3.2 Current AFCON 2025 Player Data

**Egyptian Squad** (25 players - AFCON 2025 roster):
- **Goalkeepers**: Mohamed El Shenawy (Al Ahly), Mohamed Sobhi (Zamalek)
- **Defenders**: Mohamed Abdelmonem (Al Ahly), Mohamed Hamdi (Zamalek), Mohamed Hany (Al Ahly)
- **Midfielders**: Emam Ashour (Al Ahly), Hamdy Fathi (Al Ahly), Marwan Ateya (Al Ahly)
- **Forwards**: **Mohamed Salah** (Liverpool, 2 goals in AFCON), **Omar Marmoush** (Frankfurt €65M, 1 goal), Mostafa Mohamed (Nantes), Trezeguet (Al-Fateh), Zizo (Zamalek)

**Tournament Performance**:
- Group B Winners: 7 points (2W, 1D, 0L)
- Beat Zimbabwe 2-1 (Marmoush 64', Salah 90+1')
- Beat South Africa 1-0 (Salah 45' pen)
- Drew Angola 0-0

**Opponent Squads** (All current AFCON 2025 data):
- **Morocco** (Host): Brahim Díaz (3 goals), Ayoub El Kaabi (3 goals), Achraf Hakimi (PSG)
- **Senegal**: Sadio Mané (Al Nassr), Nicolas Jackson (Chelsea, 2 goals), Pape Gueye
- **Algeria**: Riyad Mahrez (3 goals - tournament top scorer), perfect 9 points
- **Nigeria**: Victor Osimhen (Napoli), Ademola Lookman (2 goals), 9 points
- **Cameroon**: André Onana (Man United), Bryan Mbeumo (Brentford)
- **Ivory Coast**: Defending champions, Sebastien Haller (Dortmund), Amad Diallo (2 goals)

All stats based on 2024-2025 season performance and current AFCON 2025 tournament form.

### 3.3 ASCII Pitch Visualization

Every optimized lineup includes beautiful ASCII formation display:

```
================================================================================
  FORMATION: Egypt (attack)
================================================================================

  Formation: 1-3-2-5

  ┌────────────────────────────────────────────────────────────────────────────┐
  │                                                                            │
  │  Mohamed Salah  Mostafa Mohamed  Omar Marmoush  Zizo      Trezeguet       │
  │                              ⚽ FORWARDS                                    │
  │                                                                            │
  │  Marwan Ateya          Emam Ashour                                         │
  │                           🎯 MIDFIELDERS                                   │
  │────────────────────────────────────────────────────────────────────────────│
  │                                   ⭕                                        │
  │────────────────────────────────────────────────────────────────────────────│
  │  Mohamed Hany     Ahmed Fatouh     Mohamed Abdelmonem                      │
  │                            🛡️  DEFENDERS                                   │
  │                                                                            │
  │                              Mohamed El Shenawy                            │
  │                               🧤 GOALKEEPER                                │
  └────────────────────────────────────────────────────────────────────────────┘
```

---

## 4. Tournament Simulation Results

### 4.1 Strategic Recommendations for Egypt

**🏆 BEST OVERALL STRATEGY**: **ATTACK (1-3-2-5 formation)**
- Average disadvantage: -4.83 points (least negative across all opponents)
- Formation: 1 GK, 3 DF, 2 MF, 5 FW
- Key players: Salah, Marmoush, Mostafa Mohamed, Zizo, Trezeguet

**📊 TOUGHEST OPPONENTS** (in order):
1. **Ivory Coast**: -8.2 avg disadvantage (🔴 VERY HARD - Defending champions)
2. **Algeria**: -7.7 avg disadvantage (🔴 VERY HARD - Mahrez in top form, perfect record)
3. **Nigeria**: -6.5 avg disadvantage (🟡 MODERATE - Osimhen threat)
4. **Morocco**: -6.4 avg disadvantage (🟡 MODERATE - Home advantage)
5. **Senegal**: -5.6 avg disadvantage (🟢 MANAGEABLE)
6. **Cameroon**: -1.6 avg disadvantage (🟢 MANAGEABLE - Best matchup!)

**💡 KEY INSIGHTS**:
- Egypt is competitive but faces statistical disadvantages against all top opponents
- **Cameroon is the most favorable matchup** (nearly even with attack strategy)
- Attack strategy provides best balance across all opponents
- All opponents are group winners/runners-up with strong tournament form

### 4.2 Best Strategy by Opponent

| Opponent | Best Strategy | Formation | Advantage | Difficulty |
|----------|--------------|-----------|-----------|------------|
| Morocco | Balanced | 1-3-4-3 | -6.1 | ⚠️ Challenging |
| Senegal | Balanced | 1-3-4-3 | -4.7 | ⚠️ Challenging |
| Algeria | Attack | 1-3-2-5 | -6.5 | ⚠️ Challenging |
| Nigeria | Attack | 1-3-2-5 | -5.4 | ⚠️ Challenging |
| Cameroon | Attack | 1-3-2-5 | +0.4 | ⚖️ Even Match |
| Ivory Coast | Attack | 1-3-2-5 | -6.6 | ⚠️ Challenging |

### 4.3 Recommended Formations

Most common formations across all simulations:
- **1-3-4-3**: 33.3% (Balanced play, strong midfield)
- **1-3-2-5**: 33.3% (All-out attack, 5 forwards)
- **1-5-4-1**: 33.3% (Defensive, single striker)

---

## 5. Usage Examples

### Example 1: Run Full Tournament Simulation
```bash
julia afcon2025_tournament_simulation.jl
```

**Output**:
- 36 CSV files with optimized lineups
- Tournament summary with strategic recommendations
- ASCII visualizations for all formations
- Matchup analysis for each opponent and strategy

### Example 2: Quick Test (Single Opponent)
```bash
julia test_simulation.jl
```

Tests Egypt vs Morocco with 4 strategies (Balanced, Attack, Defense, Possession).

### Example 3: Visual Comparison
```bash
julia full_simulation_visual.jl
```

Generates side-by-side team comparisons with detailed ASCII formations.

### Example 4: Optimize Single Team
```bash
julia src/optimize_team_lns.jl
```

Runs LNS optimizer on Egypt squad with attack strategy, saves result to `output/selected_team_lns.csv`.

---

## 6. Data Updates

### 6.1 Updating Egyptian Squad
Edit `data/egypt_squad.csv` to:
- Add new players called up for tournament
- Update stats after recent matches
- Adjust for injuries/suspensions

**Required columns**:
```
Name,Position,Attack,Defense,Passing,Stamina,Consistency,Club,Matches_Last_5Y,Goals_Last_5Y,Assists_Last_5Y
```

**Stats Scale**: 0-100 for Attack/Defense/Passing/Stamina, 0-10 for Consistency

### 6.2 Adding New Opponents
1. Create `data/opponents/newteam.csv` with player data
2. Follow the same CSV format as existing opponent files
3. Add opponent to the list in `afcon2025_tournament_simulation.jl`:
   ```julia
   opponents = [
       ...
       ("newteam", "New Team", "Description")
   ]
   ```
4. Run simulation

### 6.3 Updating Current Stats
All data reflects **AFCON 2025 tournament** (ongoing as of January 2026). To update:
- Check latest match results on CAF official website
- Update goal/assist counts in CSV files
- Adjust Attack/Defense/Passing ratings based on recent form

---

## 7. Algorithm Configuration

### 7.1 LNS Parameters
Edit `src/optimize_team_lns.jl` to adjust:

```julia
# Maximum iterations
max_iterations = 1000  # Increase for longer search

# Destroy sizes (number of players to remove)
destroy_sizes = [2, 3, 4]  # Try [3, 4, 5, 6] for more exploration

# Early stopping
no_improve_limit = 200  # Stop if no improvement for N iterations

# Random seed
seed = 42  # Change for different results
```

### 7.2 Strategy Weights
Customize tactical emphasis in `src/optimize_team_lns.jl`:

```julia
# Example: Ultra-attacking strategy
if strategy == "attack"
    w_att, w_def, w_pass, w_stam, w_cons = 0.6, 0.05, 0.2, 0.1, 0.05
end

# Example: Possession-heavy
if strategy == "possession"
    w_att, w_def, w_pass, w_stam, w_cons = 0.15, 0.15, 0.6, 0.05, 0.05
end
```

### 7.3 Formation Constraints
Modify in `is_valid_formation()` function:

```julia
# Current: Flexible formations
n_df in 3:5  # 3-5 defenders
n_mf >= 2    # At least 2 midfielders
n_fw >= 1    # At least 1 forward

# Example: Force 4-4-2
n_df == 4 && n_mf == 4 && n_fw == 2
```

---

## 8. Troubleshooting

### Issue: "Package not found"
**Solution**:
```bash
julia -e 'using Pkg; Pkg.add(["DataFrames", "CSV", "Statistics"])'
```

Or install from GitHub:
```bash
julia -e 'using Pkg; Pkg.add(url="https://github.com/JuliaData/DataFrames.jl.git")'
julia -e 'using Pkg; Pkg.add(url="https://github.com/JuliaData/CSV.jl.git")'
```

### Issue: "File not found"
**Solution**: Run scripts from project root:
```bash
cd AFCON_OR_Project_Julia
julia afcon2025_tournament_simulation.jl
```

### Issue: LNS finds invalid formations
**Cause**: Not enough players in a position

**Solution**: Check `data/egypt_squad.csv` has:
- At least 3 defenders
- At least 2 midfielders
- At least 1 forward
- At least 1 goalkeeper

### Issue: Simulation takes too long
**Solution**: Reduce LNS iterations in `src/optimize_team_lns.jl`:
```julia
max_iterations = 500  # Down from 1000
no_improve_limit = 100  # Down from 200
```

---

## 9. Performance Metrics

- **Single optimization**: 1-3 seconds (converges in 100-400 iterations)
- **Full tournament simulation**: 5-10 minutes (18 optimizations)
- **Memory usage**: <500MB RAM
- **Convergence rate**: 95%+ find optimal/near-optimal solutions

**System Requirements**:
- RAM: 2GB minimum
- CPU: Any modern processor (Intel/AMD/Apple Silicon)
- Disk: 200MB (Julia packages + data)

---

## 10. Project Context

### Why LNS Instead of Linear Programming?
1. **No solver dependencies**: HiGHS/Gurobi/CPLEX installation failures
2. **Package server corruption**: Julia pkg.julialang.org was corrupted during development
3. **Flexibility**: Easy to add custom constraints
4. **Performance**: Comparable to LP for this problem size
5. **Robustness**: Works on any system with Julia installed

### Data Sources
- **Player stats**: Transfermarkt, FBref, CAF official records
- **AFCON 2025 results**: Wikipedia, CAF website (updated January 4, 2026)
- **FIFA rankings**: FIFA.com (2025 rankings)
- **Current form**: AFCON 2025 group stage performances

### Tournament Status (as of Jan 4, 2026)
- **Group Stage**: Complete
- **Round of 16**: Egypt qualified (waiting for opponent)
- **Egypt's path**: Group B winners → R16 → QF → SF → Final
- **Next match**: TBD (Draw completed, opponent assignment pending)

---

## 11. Extending the Project

### Enhancement Ideas:
1. **Monte Carlo Simulation**: Run 10,000 match simulations for probability distributions
2. **Player Fatigue Model**: Reduce stats based on minutes played in tournament
3. **Substitution Optimizer**: Find optimal subs at minutes 60/70/80
4. **Tournament Path**: Optimize squad rotation across multiple matches
5. **Injury Risk**: Penalize players with injury history
6. **Weather/Venue**: Adjust stamina for Morocco's December weather
7. **Head-to-Head Analysis**: Weight recent Egypt vs opponent results
8. **Form Curves**: Adjust ratings based on last 3-5 match performances

### Contributing:
1. Fork the repository
2. Create feature branch (`git checkout -b feature/improvement`)
3. Test your changes (`julia test_simulation.jl`)
4. Commit changes
5. Push and open pull request

---

## 12. Credits & License

**Author**: Omar Elsherif  
**Date**: January 2026  
**License**: MIT (Educational/Research use)

**Data Sources**:
- AFCON 2025 tournament data: CAF official, Wikipedia (updated Jan 4, 2026)
- Player stats: Transfermarkt, FBref, WhoScored
- FIFA Rankings: FIFA.com
- Historical results: 11v11.com

**Technologies**:
- Julia v1.8+ (Pure Julia, no external solvers)
- DataFrames.jl, CSV.jl, Statistics (standard library)
- Custom LNS metaheuristic implementation
- ASCII visualization (terminal-based)

**Special Thanks**:
- CAF for AFCON 2025 organization
- Egyptian FA for player data
- Julia community for excellent documentation

---

## 13. Contact & Support

For issues, questions, or suggestions:
- Open an issue on GitHub
- Email: [your-email]

**Good luck to Egypt in AFCON 2025! 🇪🇬⚽🏆**

---

**Made with ❤️ for Egyptian Football | AFCON 2025 Morocco Edition**

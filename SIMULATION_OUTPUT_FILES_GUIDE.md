# Simulation Output Files - January 12, 2026

## Complete List of Generated Results

All simulation results are stored in the `output/` directory with the latest data from the semifinal update.

### 📊 Summary Files

1. **tournament_summary_afcon2025.csv**
   - All 18 matchup scenarios
   - Egypt vs 6 opponents × 3 strategies
   - Score comparisons and advantages
   - Formation recommendations

2. **strategy_summary.csv**
   - Strategic analysis by opponent
   - Best strategy recommendations
   - Formation effectiveness

3. **all_strategies_comparison.csv**
   - Side-by-side comparison
   - All strategies tested
   - Complete statistical breakdown

### 🇪🇬 Egypt Optimal Lineups (18 files)

#### vs Morocco
- `egypt_attack_vs_morocco.csv` - 1-3-2-5 formation (236.2 total)
- `egypt_balanced_vs_morocco.csv` - 1-3-3-4 formation (239.4 total)
- `egypt_defense_vs_morocco.csv` - 1-3-3-4 formation (239.4 total)

#### vs Senegal
- `egypt_attack_vs_senegal.csv` - 1-3-2-5 formation (236.2 total)
- `egypt_balanced_vs_senegal.csv` - 1-3-3-4 formation (239.4 total)
- `egypt_defense_vs_senegal.csv` - 1-3-3-4 formation (239.4 total)

#### vs Algeria
- `egypt_attack_vs_algeria.csv` - 1-3-2-5 formation (236.2 total)
- `egypt_balanced_vs_algeria.csv` - 1-3-3-4 formation (239.4 total)
- `egypt_defense_vs_algeria.csv` - 1-3-3-4 formation (239.4 total)

#### vs Nigeria
- `egypt_attack_vs_nigeria.csv` - 1-3-2-5 formation (236.2 total)
- `egypt_balanced_vs_nigeria.csv` - 1-3-3-4 formation (239.4 total)
- `egypt_defense_vs_nigeria.csv` - 1-3-3-4 formation (239.4 total)

#### vs Cameroon
- `egypt_attack_vs_cameroon.csv` - 1-3-2-5 formation (236.2 total)
- `egypt_balanced_vs_cameroon.csv` - 1-3-3-4 formation (239.4 total)
- `egypt_defense_vs_cameroon.csv` - 1-3-3-4 formation (239.4 total)

#### vs Ivory Coast
- `egypt_attack_vs_cotedivoir.csv` - 1-3-2-5 formation (236.2 total)
- `egypt_balanced_vs_cotedivoir.csv` - 1-3-3-4 formation (239.4 total)
- `egypt_defense_vs_cotedivoir.csv` - 1-3-3-4 formation (239.4 total)

### 🌍 Opponent Optimal Lineups (18 files)

Each opponent has 3 strategy files showing their best lineup against Egypt:

**Morocco** (3 files):
- `morocco_attack_vs_egypt.csv`
- `morocco_balanced_vs_egypt.csv`
- `morocco_defense_vs_egypt.csv`

**Senegal** (3 files):
- `senegal_attack_vs_egypt.csv`
- `senegal_balanced_vs_egypt.csv`
- `senegal_defense_vs_egypt.csv`

**Algeria** (3 files):
- `algeria_attack_vs_egypt.csv`
- `algeria_balanced_vs_egypt.csv`
- `algeria_defense_vs_egypt.csv`

**Nigeria** (3 files):
- `nigeria_attack_vs_egypt.csv`
- `nigeria_balanced_vs_egypt.csv`
- `nigeria_defense_vs_egypt.csv`

**Cameroon** (3 files):
- `cameroon_attack_vs_egypt.csv`
- `cameroon_balanced_vs_egypt.csv`
- `cameroon_defense_vs_egypt.csv`

**Ivory Coast** (3 files):
- `cotedivoir_attack_vs_egypt.csv`
- `cotedivoir_balanced_vs_egypt.csv`
- `cotedivoir_defense_vs_egypt.csv`

## How to Read the Results

### CSV File Structure

Each lineup file contains:
```csv
Name,Position,Attack,Defense,Passing,Stamina,Consistency,Club,Matches_Last_5Y,Goals_Last_5Y,Assists_Last_5Y,Injury_Risk,Fitness_Percent,Score
```

### Key Columns

- **Name**: Player name
- **Position**: GK, DF, MF, FW
- **Attack/Defense/Passing**: Core attributes (0-100)
- **Stamina/Consistency**: Supporting attributes
- **Fitness_Percent**: Current fitness level (updated for semifinal)
- **Injury_Risk**: Risk score (0-10, where 8+ = unavailable)
- **Score**: Player's weighted contribution to team total

### Tournament Summary Structure

```csv
Opponent,Strategy,Egypt_Attack,Egypt_Defense,Egypt_Passing,Egypt_Total,Opp_Attack,Opp_Defense,Opp_Passing,Opp_Total,Egypt_Advantage,Egypt_Formation,Opp_Formation
```

**Example Row**:
```
Morocco,attack,82.0,70.6,83.6,236.2,85.0,67.7,84.0,236.7,-0.5,1-3-2-5,1-3-3-4
```

This shows:
- Egypt uses ATTACK strategy vs Morocco
- Egypt total: 236.2 (Attack 82.0, Defense 70.6, Passing 83.6)
- Morocco total: 236.7 (Attack 85.0, Defense 67.7, Passing 84.0)
- Egypt disadvantage: -0.5 (very close match!)
- Egypt formation: 1-3-2-5 (1 GK, 3 DF, 2 MF, 5 FW)
- Morocco formation: 1-3-3-4

## Quick Analysis Commands

### View Tournament Summary
```bash
# Open in spreadsheet
open output/tournament_summary_afcon2025.csv

# Or view in terminal
cat output/tournament_summary_afcon2025.csv | column -t -s,
```

### View Egypt's Best Lineup (Defense vs Morocco)
```bash
cat output/egypt_defense_vs_morocco.csv
```

### Compare Strategies
```bash
cat output/strategy_summary.csv
```

## Key Insights from Output Files

### Formation Distribution
- **1-3-3-4**: Used 12 times (66.7%) - Defense/Balanced strategies
- **1-3-2-5**: Used 6 times (33.3%) - Attack strategy

### Best Matchups (from CSV data)
1. **vs Cameroon (ATTACK)**: +3.4 advantage ✅
2. **vs Cameroon (DEFENSE)**: +2.0 advantage ✅
3. **vs Cameroon (BALANCED)**: +1.2 advantage ✅

### Toughest Matchups (from CSV data)
1. **vs Ivory Coast (BALANCED)**: -6.2 disadvantage ❌
2. **vs Algeria (BALANCED)**: -4.9 disadvantage ❌
3. **vs Nigeria (BALANCED)**: -4.6 disadvantage ❌

### Closest Matches (Semifinals relevant)
1. **vs Morocco (ATTACK)**: -0.5 (nearly even) 🎯
2. **vs Morocco (DEFENSE)**: -0.9 (competitive) 🎯
3. **vs Senegal (DEFENSE)**: -1.2 (winnable) 🎯
4. **vs Nigeria (DEFENSE)**: -1.3 (competitive) 🎯

## Accessing the Files

All files are located in:
```
c:\Users\omohammedelsherif\OneDrive - Universiteit Antwerpen\Documenten\AFCON_OR_Project_Julia\output\
```

### Total Files Generated
- 18 Egypt lineups
- 18 Opponent lineups
- 3 Summary files
- **Total: 39 CSV files**

### File Size
- Each lineup file: ~1-2 KB
- Tournament summary: ~2 KB
- Total output: ~50 KB

---

**All simulation results based on January 12, 2026 semifinal data update!** 🏆

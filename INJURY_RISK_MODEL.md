# 🏥 Injury Risk Model Documentation

## Overview

The optimization model now incorporates **injury risk** and **fitness levels** to make realistic team selections that account for player availability and physical condition.

---

## Mathematical Formulation

### Enhanced Objective Function

```
Player Score = Base Score × Fitness Multiplier × Injury Penalty
```

**Formula**:
```
Score(i) = [w_a·A_i + w_d·D_i + w_p·P_i + w_s·S_i + 10·w_c·C_i] × (F_i/100) × e^(-0.3·R_i)
```

Where:
- **Base Score**: Weighted combination of player attributes
- **F_i**: Fitness percentage (0-100%)
- **R_i**: Injury risk score (0-10)
- **e^(-0.3·R_i)**: Exponential injury penalty

---

## Injury Risk Scale

| Score | Status | Description | Selection Impact | Penalty Factor |
|-------|--------|-------------|------------------|----------------|
| **0** | ✅ Fully Fit | 100% available, no concerns | No penalty | 1.00 (100%) |
| **1** | ✅ Minor | Recent knock, slight concern | ~10% penalty | 0.74 (74%) |
| **2** | ⚠️ Slight | Fatigued, minor issue | ~20% penalty | 0.55 (55%) |
| **3** | ⚠️ Moderate | Returning from injury | ~40% penalty | 0.41 (41%) |
| **4** | ⚠️ Concern | Significant fitness doubt | ~50% penalty | 0.30 (30%) |
| **5** | 🟡 High | Major doubt, limited training | ~70% penalty | 0.22 (22%) |
| **6** | 🟡 Very High | Severe doubt, barely trained | ~80% penalty | 0.16 (16%) |
| **7** | 🔴 Extreme | Last-minute fitness test | ~88% penalty | 0.12 (12%) |
| **8+** | 🚫 **EXCLUDED** | Suspended/Injured/Unavailable | **Cannot be selected** | 0.00 (0%) |

---

## Fitness Percentage Impact

| Fitness % | Status | Impact on Score | Example Scenario |
|-----------|--------|-----------------|------------------|
| **100%** | Perfect | No reduction | Fully fit, full training |
| **98%** | Excellent | -2% | Slight fatigue |
| **95%** | Very Good | -5% | Minor knock recovered |
| **92%** | Good | -8% | Recent return |
| **88%** | Decent | -12% | Limited training |
| **85%** | Reduced | -15% | Injury concern |
| **80%** | Limited | -20% | Significant issue |
| **70%** | Doubtful | -30% | Major problem |

---

## Current Egypt Squad Status (Jan 6, 2026)

### Fully Fit (Risk = 0, Fitness = 100%)
✅ **Mohamed Salah** - Liverpool, 3 goals in tournament  
✅ **Omar Marmoush** - Manchester City, 1 goal  
✅ **Yasser Ibrahim** - Al Ahly, scored vs Benin  
✅ **Marwan Attia** - Al Ahly, scored vs Benin  
✅ **Mohamed El Shenawy** - Al Ahly, starting GK  

### Minor Concerns (Risk = 1-2, Fitness = 95-98%)
⚠️ **Zizo** - Risk 1, Fitness 98%  
⚠️ **Ahmed Fatouh** - Risk 1, Fitness 98%  
⚠️ **Trezeguet** - Risk 2, Fitness 95%  
⚠️ **Mohamed Hamdi** - Risk 2, Fitness 95%  

### Moderate Risk (Risk = 3-4, Fitness = 85-92%)
🟡 **Hamdy Fathy** - Risk 3, Fitness 92%  
🟡 **Ramy Rabia** - Risk 4, Fitness 85%  
🟡 **Mohamed Shehata** - Risk 4, Fitness 88%  

### High Risk (Risk = 5-7, Fitness = 70-85%)
🔴 **Mohamed Ismail** - Risk 5, Fitness 80%  
🔴 **Salah Mohsen** - Risk 5, Fitness 82%  

### Unavailable (Risk = 8+)
🚫 **Mohamed Hany** - Risk 8, Fitness 70% (SUSPENDED - red card vs South Africa)

---

## Impact on Team Selection

### Example: Comparing Two Similar Players

**Player A** (Fully Fit):
- Base Score: 850
- Fitness: 100%
- Injury Risk: 0
- **Final Score**: 850 × 1.00 × 1.00 = **850**

**Player B** (Moderate Risk):
- Base Score: 870 (slightly better)
- Fitness: 90%
- Injury Risk: 4
- **Final Score**: 870 × 0.90 × 0.30 = **235** ❌

**Result**: Player A selected despite lower base score due to fitness advantage!

---

## Penalty Calculation Examples

### Example 1: Minor Fatigue
```
Player: Ibrahim Adel
- Base Score: 750
- Fitness: 96%
- Injury Risk: 2

Final Score = 750 × 0.96 × e^(-0.3×2)
           = 750 × 0.96 × 0.549
           = 396 (53% of base)
```

### Example 2: Returning from Injury
```
Player: Hamdy Fathy
- Base Score: 820
- Fitness: 92%
- Injury Risk: 3

Final Score = 820 × 0.92 × e^(-0.3×3)
           = 820 × 0.92 × 0.407
           = 307 (37% of base)
```

### Example 3: Suspended Player
```
Player: Mohamed Hany
- Base Score: 780
- Fitness: 70%
- Injury Risk: 8

Status: AUTOMATICALLY EXCLUDED (cannot be selected)
Algorithm filters out before optimization begins
```

---

## Algorithm Implementation

### Step 1: Pre-Filtering (Hard Constraint)
```julia
# Exclude high-risk players (Injury_Risk >= 8)
available_players = filter(row -> row.Injury_Risk < 8, df_players)
```

**Impact**: Mohamed Hany automatically excluded due to suspension.

### Step 2: Score Calculation (Soft Penalty)
```julia
base_score = w_a·Attack + w_d·Defense + w_p·Passing + w_s·Stamina + 10·w_c·Consistency
fitness_multiplier = Fitness_Percent / 100.0
injury_penalty = exp(-Injury_Risk × 0.3)
final_score = base_score × fitness_multiplier × injury_penalty
```

### Step 3: Optimization
LNS algorithm selects 11 players maximizing total team score while respecting formation constraints.

---

## Practical Implications

### 1. **Automatic Exclusions**
Players with Injury_Risk ≥ 8 are never considered:
- Suspended players (red/yellow card accumulation)
- Severely injured (ruled out by medical staff)
- Unavailable for personal reasons

### 2. **Risk-Based Selection**
Players with Risk 1-7 can still be selected, but:
- Higher risk → lower selection probability
- Fitness level further modulates effectiveness
- Algorithm naturally prefers fit players when quality is similar

### 3. **Strategic Trade-offs**
Coach/optimizer must balance:
- **Quality**: Player skill and attributes
- **Availability**: Injury risk and fitness
- **Formation**: Positional constraints

### 4. **Dynamic Updates**
Injury status should be updated before each match:
- Recovered players: decrease Risk, increase Fitness
- New injuries: increase Risk, decrease Fitness
- Suspended players: set Risk = 8 or higher

---

## Real-World Example: Egypt vs Benin (R16)

### Selection Impact
**Mohamed Hany** (normally starting RB):
- Strong defender (Defense: 85, Attack: 72)
- Suspended after red card vs South Africa
- Set to Injury_Risk = 8 → **Automatically excluded**
- Replacement: Ahmed Fatouh or Mohamed Hamdi selected instead

**Result**: Egypt won 3-1 (AET) with adjusted lineup accounting for Hany's suspension.

---

## Updating Injury Status

### After Each Match
1. Check for **new suspensions** (yellow/red cards)
2. Update **injury reports** from medical staff
3. Assess **player fatigue** (minutes played, physical load)
4. Adjust **Injury_Risk** and **Fitness_Percent** in CSV

### Injury Risk Guidelines
- **Risk 0**: Started last match, full training, no issues
- **Risk 1-2**: Played recently, minor fatigue/knock
- **Risk 3-4**: Missed training, doubtful availability
- **Risk 5-7**: Major doubt, fitness test required
- **Risk 8+**: Confirmed unavailable (injury/suspension)

---

## Validation & Testing

### Test Case 1: All Players Fit (Risk = 0)
- Model reduces to standard optimization
- No injury penalties applied
- Best 11 players selected purely on attributes

### Test Case 2: Key Player Suspended (Risk = 8)
- Player automatically excluded
- Algorithm selects best alternative
- Team score slightly reduced

### Test Case 3: Multiple Minor Injuries (Risk = 2-3)
- Slight penalties applied (~40-55% retention)
- High-quality injured players may still be selected
- Lower-quality fit players become competitive

---

## Summary

The injury risk model adds **realism and strategic depth** to team selection:

✅ **Hard Constraint**: Excludes unavailable players (Risk ≥ 8)  
✅ **Soft Penalty**: Reduces appeal of risky selections (Risk 1-7)  
✅ **Fitness Multiplier**: Accounts for partial fitness levels  
✅ **Exponential Decay**: Heavily penalizes high-risk players  
✅ **Automatic**: Integrated seamlessly into LNS algorithm  

**Result**: More realistic lineups that balance quality with availability! 🏆

---

**Last Updated**: January 6, 2026  
**Model Version**: v2.0 with Injury Risk Integration

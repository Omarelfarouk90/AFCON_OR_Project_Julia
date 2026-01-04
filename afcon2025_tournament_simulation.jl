#!/usr/bin/env julia
"""
AFCON 2025 Tournament Simulation - Egypt vs All Top Opponents
Tests Egypt's optimal lineup against 6 major opponents using LNS metaheuristic
Based on current AFCON 2025 (Morocco) tournament data - December 2025/January 2026
"""

using CSV, DataFrames

# Add src directory to load path
push!(LOAD_PATH, joinpath(@__DIR__, "src"))

include("src/optimize_team_lns.jl")
include("src/visualize_ascii.jl")

println("="^80)
println("AFCON 2025 TOURNAMENT SIMULATION - EGYPT OPTIMAL LINEUP ANALYSIS")
println("="^80)
println("\nTournament: AFCON 2025 (Morocco)")
println("Dates: December 21, 2025 - January 18, 2026")
println("Egypt Status: Qualified for Round of 16 (Group B Winners, 7 points)")
println("\nSimulation: Testing Egypt's optimal lineup vs 6 top opponents")
println("Optimizer: Large Neighborhood Search (LNS) Metaheuristic")
println("="^80)
println()

# Define opponents
opponents = [
    ("morocco", "Morocco", "Group A Winners (7 pts) - Host Nation, Brahim 3 goals, El Kaabi 3 goals"),
    ("senegal", "Senegal", "Group D Winners (7 pts) - Jackson 2 goals, P. Gueye 2 goals, beat Sudan 3-1"),
    ("algeria", "Algeria", "Group E Winners (9 pts) - Mahrez 3 goals, perfect record 3-0, 1-0, 3-1"),
    ("nigeria", "Nigeria", "Group C Winners (9 pts) - Lookman 2 goals, Osimhen 1, Onyedika 2"),
    ("cameroon", "Cameroon", "Group F Runner-up (7 pts) - Drew Ivory Coast 1-1, beat Mozambique"),
    ("cotedivoir", "Ivory Coast", "Group F Winners (7 pts) - Defending Champions, Amad Diallo 2 goals")
]

# Define strategies to test
strategies = ["balanced", "attack", "defense"]

# Create summary dataframe
summary_results = DataFrame(
    Opponent = String[],
    Strategy = String[],
    Egypt_Attack = Float64[],
    Egypt_Defense = Float64[],
    Egypt_Passing = Float64[],
    Egypt_Total = Float64[],
    Opp_Attack = Float64[],
    Opp_Defense = Float64[],
    Opp_Passing = Float64[],
    Opp_Total = Float64[],
    Egypt_Advantage = Float64[],
    Egypt_Formation = String[],
    Opp_Formation = String[]
)

# Load Egypt squad
egypt_data = CSV.read("data/egypt_squad.csv", DataFrame)
println("✓ Loaded Egypt squad: $(nrow(egypt_data)) players")
println("  Key Players: Mohamed Salah (Liverpool), Omar Marmoush (Frankfurt €65M)")
println("  AFCON 2025 Results: Beat Zimbabwe 2-1, Beat South Africa 1-0, Drew Angola 0-0")
println()

# Run simulations for each opponent
for (file, name, info) in opponents
    println("\n" * "="^80)
    println("OPPONENT: $name")
    println("Info: $info")
    println("="^80)
    
    # Load opponent data
    opponent_file = "data/opponents/$(file).csv"
    if !isfile(opponent_file)
        println("⚠️  Warning: File not found: $opponent_file - Skipping")
        continue
    end
    
    opponent_data = CSV.read(opponent_file, DataFrame)
    println("\n✓ Loaded $name squad: $(nrow(opponent_data)) players")
    
    # Test each strategy
    for strategy in strategies
        println("\n" * "-"^80)
        println("STRATEGY: $(uppercase(strategy))")
        println("-"^80)
        
        # Optimize Egypt team
        println("\n[1/2] Optimizing Egypt team with $strategy strategy...")
        egypt_team, egypt_status = select_optimal_team(egypt_data, strategy)
        egypt_formation = visualize_formation_ascii(egypt_team, "Egypt ($strategy)")
        
        # Calculate Egypt stats
        egypt_attack = mean(egypt_team[egypt_team.Position .!= "GK", :Attack])
        egypt_defense = mean(egypt_team[egypt_team.Position .!= "GK", :Defense])
        egypt_passing = mean(egypt_team[egypt_team.Position .!= "GK", :Passing])
        egypt_total = egypt_attack + egypt_defense + egypt_passing
        
        println("\n  Egypt Stats:")
        println("    ⚔️  Attack: $(round(egypt_attack, digits=1))")
        println("    🛡️  Defense: $(round(egypt_defense, digits=1))")
        println("    🎯 Passing: $(round(egypt_passing, digits=1))")
        println("    📊 Total: $(round(egypt_total, digits=1))")
        println("    📐 Formation: $egypt_formation")
        
        # Optimize opponent team with same strategy
        println("\n[2/2] Optimizing $name team with $strategy strategy...")
        opp_team, opp_status = select_optimal_team(opponent_data, strategy)
        opp_formation = visualize_formation_ascii(opp_team, "$name ($strategy)")
        
        # Calculate opponent stats
        opp_attack = mean(opp_team[opp_team.Position .!= "GK", :Attack])
        opp_defense = mean(opp_team[opp_team.Position .!= "GK", :Defense])
        opp_passing = mean(opp_team[opp_team.Position .!= "GK", :Passing])
        opp_total = opp_attack + opp_defense + opp_passing
        
        println("\n  $name Stats:")
        println("    ⚔️  Attack: $(round(opp_attack, digits=1))")
        println("    🛡️  Defense: $(round(opp_defense, digits=1))")
        println("    🎯 Passing: $(round(opp_passing, digits=1))")
        println("    📊 Total: $(round(opp_total, digits=1))")
        println("    📐 Formation: $opp_formation")
        
        # Calculate advantage
        advantage = egypt_total - opp_total
        advantage_pct = (advantage / opp_total) * 100
        
        println("\n  📊 MATCHUP ANALYSIS:")
        if advantage > 5
            println("    ✅ Egypt has STRONG advantage: +$(round(advantage, digits=1)) (+$(round(advantage_pct, digits=1))%)")
        elseif advantage > 0
            println("    ⚖️  Egypt has SLIGHT advantage: +$(round(advantage, digits=1)) (+$(round(advantage_pct, digits=1))%)")
        elseif advantage > -5
            println("    ⚖️  $name has SLIGHT advantage: $(round(advantage, digits=1)) ($(round(advantage_pct, digits=1))%)")
        else
            println("    ❌ $name has STRONG advantage: $(round(advantage, digits=1)) ($(round(advantage_pct, digits=1))%)")
        end
        
        # Save teams to CSV
        output_dir = "output"
        isdir(output_dir) || mkdir(output_dir)
        
        egypt_output = joinpath(output_dir, "egypt_$(strategy)_vs_$(file).csv")
        opp_output = joinpath(output_dir, "$(file)_$(strategy)_vs_egypt.csv")
        
        CSV.write(egypt_output, egypt_team)
        CSV.write(opp_output, opp_team)
        
        println("\n  💾 Saved:")
        println("    - $egypt_output")
        println("    - $opp_output")
        
        # Add to summary
        push!(summary_results, (
            name, strategy,
            egypt_attack, egypt_defense, egypt_passing, egypt_total,
            opp_attack, opp_defense, opp_passing, opp_total,
            advantage,
            egypt_formation, opp_formation
        ))
    end
end

# Save summary report
println("\n\n" * "="^80)
println("TOURNAMENT SUMMARY REPORT")
println("="^80)

summary_file = "output/tournament_summary_afcon2025.csv"
CSV.write(summary_file, summary_results)
println("\n✓ Saved tournament summary: $summary_file")

# Analyze results
println("\n" * "="^80)
println("STRATEGIC RECOMMENDATIONS FOR EGYPT")
println("="^80)

# Best strategy by opponent
println("\n1️⃣  BEST STRATEGY BY OPPONENT:")
for (file, name, info) in opponents
    opp_results = summary_results[summary_results.Opponent .== name, :]
    if nrow(opp_results) == 0
        continue
    end
    
    best_row = opp_results[argmax(opp_results.Egypt_Advantage), :]
    advantage = best_row.Egypt_Advantage
    
    status = advantage > 5 ? "✅ FAVORABLE" : advantage > 0 ? "⚖️  COMPETITIVE" : "⚠️  CHALLENGING"
    
    println("  • vs $name: $(uppercase(best_row.Strategy)) formation $(best_row.Egypt_Formation) ($status, +$(round(advantage, digits=1)))")
end

# Overall best strategy
println("\n2️⃣  OVERALL BEST STRATEGY:")
strategy_avg = combine(groupby(summary_results, :Strategy), 
    :Egypt_Advantage => mean => :Avg_Advantage,
    :Egypt_Total => mean => :Avg_Total_Score
)
sort!(strategy_avg, :Avg_Advantage, rev=true)

println("\n  Strategy Performance (Average Advantage vs All Opponents):")
for row in eachrow(strategy_avg)
    status = row.Avg_Advantage > 3 ? "🔥 EXCELLENT" : row.Avg_Advantage > 0 ? "✅ GOOD" : "⚠️  RISKY"
    println("    $(uppercase(row.Strategy)): +$(round(row.Avg_Advantage, digits=2)) ($status)")
end

best_strategy = strategy_avg[1, :Strategy]
println("\n  🏆 RECOMMENDED: $(uppercase(best_strategy)) strategy")
println("     - Best average advantage: +$(round(strategy_avg[1, :Avg_Advantage], digits=2))")
println("     - Highest total score: $(round(strategy_avg[1, :Avg_Total_Score], digits=1))")

# Toughest opponents
println("\n3️⃣  TOUGHEST OPPONENTS FOR EGYPT:")
opponent_avg = combine(groupby(summary_results, :Opponent), 
    :Egypt_Advantage => mean => :Avg_Advantage
)
sort!(opponent_avg, :Avg_Advantage)

println()
for (i, row) in enumerate(eachrow(opponent_avg))
    difficulty = i <= 2 ? "🔴 VERY HARD" : i <= 4 ? "🟡 MODERATE" : "🟢 MANAGEABLE"
    println("  $(i). $(row.Opponent): $(round(row.Avg_Advantage, digits=1)) ($difficulty)")
end

# Formation analysis
println("\n4️⃣  RECOMMENDED FORMATIONS:")
egypt_formations = combine(groupby(summary_results, :Egypt_Formation), nrow => :Count)
sort!(egypt_formations, :Count, rev=true)

println()
for row in eachrow(egypt_formations)
    pct = round((row.Count / nrow(summary_results)) * 100, digits=1)
    println("  • $(row.Egypt_Formation): appeared $(row.Count)/$(nrow(summary_results)) times ($(pct)%)")
end

println("\n" * "="^80)
println("✓ SIMULATION COMPLETE!")
println("="^80)
println("\nGenerated Files:")
println("  • $(length(opponents) * length(strategies) * 2) team CSV files in output/")
println("  • 1 tournament summary report: output/tournament_summary_afcon2025.csv")
println("\nNext Steps:")
println("  1. Review tournament summary CSV for detailed comparisons")
println("  2. Run visualization: julia full_simulation_visual.jl")
println("  3. Prepare optimal lineup for upcoming Round of 16 match")
println("\n🇪🇬 Best of luck to Egypt in AFCON 2025! 🏆")
println("="^80)

using DataFrames, CSV, Statistics

# Include required modules
include("src/optimize_team_lns.jl")
include("src/visualize_ascii.jl")

println("\n" * "█"^100)
println("█" * " "^98 * "█")
println("█" * " "^25 * "AFCON 2025 - EGYPT VS MOROCCO SIMULATION" * " "^33 * "█")
println("█" * " "^30 * "Using LNS Metaheuristic" * " "^48 * "█")
println("█" * " "^98 * "█")
println("█"^100)

# Load squads
println("\n📂 Loading team data...")
egypt_squad = DataFrame(CSV.File("data/egypt_squad.csv"))
morocco_squad = DataFrame(CSV.File("data/opponents/morocco.csv"))

println("✓ Egypt squad: $(nrow(egypt_squad)) players")
println("✓ Morocco squad: $(nrow(morocco_squad)) players")

# Test different strategies
strategies = ["balanced", "attack", "defense"]

println("\n" * "="^100)
println("  TESTING MULTIPLE STRATEGIES")
println("="^100)

results_summary = DataFrame(
    Strategy = String[],
    Formation = String[],
    Avg_Attack = Float64[],
    Avg_Defense = Float64[],
    Avg_Passing = Float64[]
)

selected_teams = Dict()

for (i, strategy) in enumerate(strategies)
    println("\n\n" * "▓"^100)
    println("▓  STRATEGY $(i)/$(length(strategies)): $(uppercase(strategy))")
    println("▓"^100)
    
    # Select Egypt team
    println("\n🇪🇬 Selecting Egypt team...")
    egypt_team, status = select_optimal_team(egypt_squad, strategy)
    
    # Select Morocco team
    println("\n🇲🇦 Selecting Morocco team...")
    morocco_team, status2 = select_optimal_team(morocco_squad, strategy)
    
    if nrow(egypt_team) == 11 && nrow(morocco_team) == 11
        # Store teams
        selected_teams["egypt_$strategy"] = egypt_team
        selected_teams["morocco_$strategy"] = morocco_team
        
        # Visualize Egypt formation
        formation_egypt = visualize_formation_ascii(egypt_team, "🇪🇬 EGYPT ($strategy)")
        
        # Visualize Morocco formation
        formation_morocco = visualize_formation_ascii(morocco_team, "🇲🇦 MOROCCO ($strategy)")
        
        # Side-by-side formation comparison
        compare_formations_side_by_side(egypt_team, morocco_team, "🇪🇬 EGYPT ($strategy)", "🇲🇦 MOROCCO ($strategy)")
        
        # Display team details
        display_team_details(egypt_team, "🇪🇬 EGYPT")
        display_team_details(morocco_team, "🇲🇦 MOROCCO")
        
        # Compare teams
        compare_teams_ascii(egypt_team, morocco_team, "🇪🇬 EGYPT", "🇲🇦 MOROCCO")
        
        # Calculate stats
        egypt_stats = (
            mean(egypt_team.Attack),
            mean(egypt_team.Defense),
            mean(egypt_team.Passing)
        )
        
        push!(results_summary, (
            strategy,
            formation_egypt,
            egypt_stats[1],
            egypt_stats[2],
            egypt_stats[3]
        ))
        
        # Save teams
        mkpath("output")
        CSV.write("output/egypt_$(strategy)_vs_morocco.csv", egypt_team)
        CSV.write("output/morocco_$(strategy)_vs_egypt.csv", morocco_team)
        
        println("\n💾 Teams saved:")
        println("   - output/egypt_$(strategy)_vs_morocco.csv")
        println("   - output/morocco_$(strategy)_vs_egypt.csv")
    else
        println("\n❌ Failed to generate valid teams for $strategy strategy")
    end
    
    println("\n" * "▓"^100)
end

# Final summary
println("\n\n" * "█"^100)
println("█" * " "^40 * "FINAL SUMMARY" * " "^47 * "█")
println("█"^100)
println()

println("📊 Egypt Team Performance Across Strategies:")
println()
for row in eachrow(results_summary)
    println("  $(uppercase(rpad(row.Strategy, 12))) │ Formation: $(row.Formation)  │  Attack: $(round(row.Avg_Attack, digits=1))  │  Defense: $(round(row.Avg_Defense, digits=1))  │  Passing: $(round(row.Avg_Passing, digits=1))")
end

CSV.write("output/strategy_summary.csv", results_summary)
println("\n💾 Summary saved to: output/strategy_summary.csv")

# Find best strategy for Egypt
best_overall_idx = argmax(results_summary.Avg_Attack .+ results_summary.Avg_Defense .+ results_summary.Avg_Passing)
best_strategy = results_summary.Strategy[best_overall_idx]

println("\n🏆 RECOMMENDATION")
println("="^100)
println("  Best Overall Strategy: $(uppercase(best_strategy))")
println("  Formation: $(results_summary.Formation[best_overall_idx])")
println("  Balanced Score: $(round(results_summary.Avg_Attack[best_overall_idx] + results_summary.Avg_Defense[best_overall_idx] + results_summary.Avg_Passing[best_overall_idx], digits=1))")
println("="^100)

# Display best team again
if haskey(selected_teams, "egypt_$best_strategy")
    println("\n🎖️  RECOMMENDED STARTING XI ($(uppercase(best_strategy)) Strategy):")
    visualize_formation_ascii(selected_teams["egypt_$best_strategy"], "🇪🇬 EGYPT - OPTIMAL LINEUP")
end

println("\n" * "█"^100)
println("█" * " "^30 * "SIMULATION COMPLETE!" * " "^48 * "█")
println("█"^100)
println()

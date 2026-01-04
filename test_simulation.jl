using DataFrames, CSV, Statistics

# Include the LNS optimizer
include("src/optimize_team_lns.jl")

println("="^60)
println("  AFCON 2025 - Egypt Team Optimization Test")
println("  Using LNS Metaheuristic")
println("="^60)

# Load Egypt squad
println("\n📊 Loading Egypt squad data...")
egypt_squad = DataFrame(CSV.File("data/egypt_squad.csv"))
println("✓ Loaded $(nrow(egypt_squad)) players")

# Load Morocco as test opponent
println("\n📊 Loading Morocco squad data...")
morocco_squad = DataFrame(CSV.File("data/opponents/morocco.csv"))
println("✓ Loaded $(nrow(morocco_squad)) players")

# Test all 4 strategies
strategies = ["balanced", "attack", "defense", "possession"]

println("\n" * "="^60)
println("  Testing All Strategies Against Morocco")
println("="^60)

results = DataFrame(
    Strategy = String[],
    Team_Score = Float64[],
    Avg_Attack = Float64[],
    Avg_Defense = Float64[],
    Avg_Passing = Float64[]
)

for strategy in strategies
    println("\n\n" * "-"^60)
    println("  Strategy: $(uppercase(strategy))")
    println("-"^60)
    
    # Select optimal team
    selected_team, status = select_optimal_team(egypt_squad, strategy)
    
    if nrow(selected_team) == 11
        # Calculate team statistics
        team_weights = get_strategy_weights(strategy)
        team_score = calculate_team_score(selected_team, team_weights)
        avg_attack = mean(selected_team.Attack)
        avg_defense = mean(selected_team.Defense)
        avg_passing = mean(selected_team.Passing)
        
        println("\n📊 Team Statistics:")
        println("   Total Score: $(round(team_score, digits=2))")
        println("   Avg Attack:  $(round(avg_attack, digits=2))")
        println("   Avg Defense: $(round(avg_defense, digits=2))")
        println("   Avg Passing: $(round(avg_passing, digits=2))")
        
        push!(results, (strategy, team_score, avg_attack, avg_defense, avg_passing))
        
        # Save team
        filename = "output/optimal_11_vs_morocco_$(strategy).csv"
        CSV.write(filename, selected_team)
        println("\n✓ Team saved to: $filename")
        
        # Show starting XI
        println("\n⚽ Starting XI:")
        println(selected_team[:, [:Name, :Position, :Attack, :Defense, :Passing]])
    else
        println("❌ Failed to generate valid team")
    end
end

# Save comparison
println("\n\n" * "="^60)
println("  Strategy Comparison Summary")
println("="^60)
println(results)

CSV.write("output/all_strategies_comparison.csv", results)
println("\n✓ Comparison saved to: output/all_strategies_comparison.csv")

# Find best strategy
best_idx = argmax(results.Team_Score)
best_strategy = results.Strategy[best_idx]
best_score = results.Team_Score[best_idx]

println("\n🏆 Best Strategy: $(uppercase(best_strategy))")
println("   Score: $(round(best_score, digits=2))")

println("\n" * "="^60)
println("  Simulation Complete!")
println("="^60)

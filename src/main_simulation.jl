using DataFrames, CSV, Statistics
include("optimize_team.jl")
include("predict_match_advanced.jl")
include("visualize_pitch.jl")

"""
Interactive opponent selection menu
"""
function select_opponent()
    opponents = ["Morocco", "Senegal", "Algeria", "Nigeria", "Mali", "Cote d'Ivoire"]
    
    println("\n" * "=" ^ 60)
    println("Select Opponent Team:")
    println("=" ^ 60)
    
    for (i, opp) in enumerate(opponents)
        fifa_rank = get(FIFA_RANKINGS, opp, "N/A")
        println("  [$i] $opp (FIFA Rank: #$fifa_rank)")
    end
    println("  [7] Compare against all opponents")
    println("  [0] Exit")
    println("=" ^ 60)
    
    print("\nEnter your choice (0-7): ")
    choice = readline()
    
    try
        choice_num = parse(Int, choice)
        if choice_num == 0
            return nothing
        elseif choice_num == 7
            return "ALL"
        elseif 1 <= choice_num <= length(opponents)
            return opponents[choice_num]
        else
            println("Invalid choice. Please try again.")
            return select_opponent()
        end
    catch
        println("Invalid input. Please enter a number.")
        return select_opponent()
    end
end

"""
Run simulation against a single opponent
"""
function run_simulation_vs_opponent(opponent_name::String)
    println("\n" * "=" ^ 70)
    println("  AFCON 2025: Egypt vs $opponent_name - Optimal Strategy Finder")
    println("=" ^ 70)
    
    # Load Egyptian squad
    df_egypt = DataFrame(CSV.File("data/egypt_squad.csv"))
    
    # Load opponent squad
    opponent_file = joinpath("data", "opponents", lowercase(opponent_name) * ".csv")
    if !isfile(opponent_file)
        println("❌ Error: Opponent data file not found: $opponent_file")
        return
    end
    
    df_opponent = DataFrame(CSV.File(opponent_file))
    
    println("\n📋 Squad sizes:")
    println("  Egypt: $(nrow(df_egypt)) players")
    println("  $opponent_name: $(nrow(df_opponent)) players")
    
    strategies = ["balanced", "attack", "defense", "possession"]
    strategy_results = DataFrame(
        Strategy = String[],
        Win_Prob = Float64[],
        Draw_Prob = Float64[],
        Loss_Prob = Float64[],
        Expected_Score = String[],
        Team_Attack = Float64[],
        Team_Defense = Float64[]
    )
    
    best_win_prob = 0.0
    best_strategy = ""
    best_team_df = DataFrame()
    best_prediction = Dict()
    
    for strat in strategies
        println("\n" * "─" ^ 70)
        println("🎯 Testing Strategy: $(uppercase(strat))")
        println("─" ^ 70)
        
        # 1. Optimize Egyptian lineup
        team, status = select_optimal_team(df_egypt, strategy=strat)
        
        if status != "OPTIMAL"
            println("⚠️  Skipping $strat: Optimization failed.")
            continue
        end
        
        println("\n✓ Optimal 11 selected for $(uppercase(strat)) strategy")
        println("  Formation: $(sum(team.Position .== "DF"))D-$(sum(team.Position .== "MF"))M-$(sum(team.Position .== "FW"))F")
        
        # 2. Select opponent's best 11
        if nrow(df_opponent) > 11
            df_opponent.Overall = (df_opponent.Attack .+ df_opponent.Defense .+ 
                                  df_opponent.Passing .+ df_opponent.Stamina) ./ 4
            sort!(df_opponent, :Overall, rev=true)
            opp_best_11 = df_opponent[1:11, :]
        else
            opp_best_11 = df_opponent
        end
        
        # 3. Advanced prediction
        prediction = predict_match_advanced(team, opp_best_11, opponent_name, strategy=strat)
        
        # Store results
        push!(strategy_results, (
            strat,
            prediction["win_prob"],
            prediction["draw_prob"],
            prediction["loss_prob"],
            "$(round(prediction["expected_score_egypt"], digits=1))-$(round(prediction["expected_score_opponent"], digits=1))",
            prediction["egypt_stats"]["Attack"],
            prediction["egypt_stats"]["Defense"]
        ))
        
        if prediction["win_prob"] > best_win_prob
            best_win_prob = prediction["win_prob"]
            best_strategy = strat
            best_team_df = team
            best_prediction = prediction
        end
    end
    
    # Summary
    println("\n" * "=" ^ 70)
    println("📊 STRATEGY COMPARISON SUMMARY")
    println("=" ^ 70)
    println(strategy_results)
    
    println("\n" * "=" ^ 70)
    println("🏆 FINAL RECOMMENDATION")
    println("=" ^ 70)
    println("\n✓ Best Strategy: $(uppercase(best_strategy))")
    println("✓ Win Probability: $(round(best_win_prob, digits=1))%")
    println("✓ Expected Score: Egypt $(round(best_prediction["expected_score_egypt"], digits=1)) - $(round(best_prediction["expected_score_opponent"], digits=1)) $opponent_name")
    
    # Save results
    if nrow(best_team_df) > 0
        # Save optimal lineup
        output_file = "output/optimal_11_vs_" * lowercase(opponent_name) * ".csv"
        CSV.write(output_file, best_team_df)
        println("\n💾 Optimal lineup saved to: $output_file")
        
        # Generate formation visualization
        output_map = "output/formation_vs_" * lowercase(opponent_name) * ".png"
        visualize_formation(best_team_df, output_path=output_map)
        println("💾 Formation map saved to: $output_map")
        
        # Save prediction summary
        summary_file = "output/prediction_vs_" * lowercase(opponent_name) * ".csv"
        CSV.write(summary_file, strategy_results)
        println("💾 Strategy comparison saved to: $summary_file")
    end
    
    println("\n" * "=" ^ 70)
end

"""
Compare Egypt against all opponents
"""
function run_comparison_all_opponents()
    println("\n" * "=" ^ 70)
    println("  AFCON 2025: Egypt vs ALL Opponents - Comprehensive Analysis")
    println("=" ^ 70)
    
    opponents = ["Morocco", "Senegal", "Algeria", "Nigeria", "Mali", "Cote d'Ivoire"]
    
    # Load Egyptian squad
    df_egypt = DataFrame(CSV.File("data/egypt_squad.csv"))
    
    # Use balanced strategy as default for comparison
    egypt_team, status = select_optimal_team(df_egypt, strategy="balanced")
    
    if status != "OPTIMAL"
        println("❌ Error: Could not optimize Egyptian team")
        return
    end
    
    println("\n✓ Using BALANCED strategy for all comparisons")
    println("✓ Egyptian Starting XI optimized\n")
    
    # Run predictions against all opponents
    all_results = DataFrame(
        Opponent = String[],
        FIFA_Rank = Int[],
        Win_Prob = Float64[],
        Draw_Prob = Float64[],
        Loss_Prob = Float64[],
        Expected_Score = String[],
        Difficulty = String[]
    )
    
    for opponent in opponents
        opponent_file = joinpath("data", "opponents", lowercase(opponent) * ".csv")
        
        if !isfile(opponent_file)
            println("⚠️  Skipping $opponent: Data file not found")
            continue
        end
        
        df_opponent = DataFrame(CSV.File(opponent_file))
        
        # Select opponent's best 11
        if nrow(df_opponent) > 11
            df_opponent.Overall = (df_opponent.Attack .+ df_opponent.Defense .+ 
                                  df_opponent.Passing .+ df_opponent.Stamina) ./ 4
            sort!(df_opponent, :Overall, rev=true)
            opp_best_11 = df_opponent[1:11, :]
        else
            opp_best_11 = df_opponent
        end
        
        # Predict
        prediction = predict_match_advanced(egypt_team, opp_best_11, opponent, strategy="balanced")
        
        # Determine difficulty
        difficulty = if prediction["win_prob"] >= 60.0
            "Easy"
        elseif prediction["win_prob"] >= 45.0
            "Medium"
        else
            "Hard"
        end
        
        fifa_rank = get(FIFA_RANKINGS, opponent, 99)
        
        push!(all_results, (
            opponent,
            fifa_rank,
            prediction["win_prob"],
            prediction["draw_prob"],
            prediction["loss_prob"],
            "$(round(prediction["expected_score_egypt"], digits=1))-$(round(prediction["expected_score_opponent"], digits=1))",
            difficulty
        ))
    end
    
    # Sort by difficulty (win probability descending)
    sort!(all_results, :Win_Prob, rev=true)
    
    println("\n" * "=" ^ 70)
    println("📊 COMPREHENSIVE OPPONENT ANALYSIS")
    println("=" ^ 70)
    println(all_results)
    
    println("\n🎯 Match Difficulty Ranking:")
    println("  Easiest opponents: ", join(all_results[all_results.Difficulty .== "Easy", :Opponent], ", "))
    println("  Medium difficulty: ", join(all_results[all_results.Difficulty .== "Medium", :Opponent], ", "))
    println("  Hardest opponents: ", join(all_results[all_results.Difficulty .== "Hard", :Opponent], ", "))
    
    # Save results
    CSV.write("output/all_opponents_comparison.csv", all_results)
    println("\n💾 Full comparison saved to: output/all_opponents_comparison.csv")
    
    println("\n" * "=" ^ 70)
end

"""
Main simulation entry point
"""
function run_simulation()
    println("\n" * "╔" * "=" ^ 68 * "╗")
    println("║" * " " ^ 68 * "║")
    println("║" * " " ^ 15 * "AFCON 2025 - OPERATIONS RESEARCH" * " " ^ 21 * "║")
    println("║" * " " ^ 12 * "Egyptian National Team Optimizer & Predictor" * " " ^ 12 * "║")
    println("║" * " " ^ 68 * "║")
    println("╚" * "=" ^ 68 * "╝")
    
    opponent_choice = select_opponent()
    
    if opponent_choice === nothing
        println("\n👋 Exiting. Thank you!")
        return
    elseif opponent_choice == "ALL"
        run_comparison_all_opponents()
    else
        run_simulation_vs_opponent(opponent_choice)
    end
    
    println("\n✅ Analysis complete!")
    println("📂 Check the 'output/' directory for detailed results.\n")
end

# Run the simulation
run_simulation()
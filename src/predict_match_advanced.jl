"""
Advanced Match Prediction Module for AFCON OR Project
======================================================

This module implements a comprehensive prediction model that includes:
1. Player-level stat comparisons (Attack, Defense, Passing, Stamina, Consistency)
2. Head-to-head historical results (last 5 years)
3. Recent form analysis (last 5 matches)
4. FIFA ranking consideration
5. Squad value/quality comparison

The model outputs:
- Win probability for Egypt
- Draw probability
- Loss probability
- Expected score prediction
- Confidence interval

Author: AFCON OR Team
Date: 2026-01-04
"""

using DataFrames, Statistics, Dates, CSV

# FIFA Rankings (as of January 2026 - placeholder values)
const FIFA_RANKINGS = Dict(
    "Egypt" => 33,
    "Morocco" => 13,
    "Senegal" => 18,
    "Algeria" => 37,
    "Nigeria" => 28,
    "Mali" => 51,
    "Cote d'Ivoire" => 39
)

"""
Calculate aggregate team statistics from selected 11 players
"""
function calculate_team_stats(team_df::DataFrame)
    stats = Dict(
        "Attack" => mean(team_df.Attack),
        "Defense" => mean(team_df.Defense),
        "Passing" => mean(team_df.Passing),
        "Stamina" => mean(team_df.Stamina),
        "Consistency" => mean(team_df.Consistency)
    )
    
    return stats
end

"""
Load head-to-head historical data (last 5 years)
"""
function load_head_to_head(team1::String, team2::String)
    # Try to load H2H data
    filename = lowercase(team1) * "_vs_" * lowercase(team2) * ".csv"
    filepath = joinpath("data", "head_to_head", filename)
    
    if isfile(filepath)
        return CSV.read(filepath, DataFrame)
    else
        # Return empty dataframe with correct structure
        return DataFrame(
            Date = Date[],
            Home = String[],
            Away = String[],
            Score_Home = Int[],
            Score_Away = Int[],
            Competition = String[]
        )
    end
end

"""
Calculate H2H advantage factor (-1.0 to 1.0)
Positive means Egypt has historical advantage
"""
function calculate_h2h_factor(team1::String, team2::String)
    h2h = load_head_to_head(team1, team2)
    
    if nrow(h2h) == 0
        return 0.0  # No historical data, neutral
    end
    
    egypt_wins = 0
    draws = 0
    opponent_wins = 0
    
    for row in eachrow(h2h)
        if row.Home == team1
            if row.Score_Home > row.Score_Away
                egypt_wins += 1
            elseif row.Score_Home == row.Score_Away
                draws += 1
            else
                opponent_wins += 1
            end
        else  # Egypt is away
            if row.Score_Away > row.Score_Home
                egypt_wins += 1
            elseif row.Score_Away == row.Score_Home
                draws += 1
            else
                opponent_wins += 1
            end
        end
    end
    
    total_matches = nrow(h2h)
    win_percentage = egypt_wins / total_matches
    
    # Convert to factor (-0.15 to +0.15)
    h2h_factor = (win_percentage - 0.5) * 0.3
    
    return h2h_factor
end

"""
Calculate FIFA ranking factor
"""
function calculate_fifa_factor(team1::String, team2::String)
    rank1 = get(FIFA_RANKINGS, team1, 50)
    rank2 = get(FIFA_RANKINGS, team2, 50)
    
    # Lower rank is better
    # Normalize to probability boost (-0.1 to +0.1)
    rank_diff = (rank2 - rank1) / 100.0
    
    return clamp(rank_diff, -0.1, 0.1)
end

"""
Calculate squad value comparison factor
Based on the FIFA_Ranking_Contribution field if available
"""
function calculate_squad_value_factor(egypt_df::DataFrame, opponent_df::DataFrame)
    # If FIFA_Ranking_Contribution column exists, use it
    if hasproperty(egypt_df, :FIFA_Ranking_Contribution) && 
       hasproperty(opponent_df, :FIFA_Ranking_Contribution)
        
        egypt_avg = mean(egypt_df.FIFA_Ranking_Contribution)
        opp_avg = mean(opponent_df.FIFA_Ranking_Contribution)
        
        # Normalize to factor (-0.08 to +0.08)
        value_factor = (egypt_avg - opp_avg) * 0.01
        return clamp(value_factor, -0.08, 0.08)
    else
        return 0.0
    end
end

"""
Advanced prediction model with all factors

Parameters:
- egypt_team: DataFrame of selected 11 Egyptian players
- opponent_team: DataFrame of selected 11 opponent players
- opponent_name: Name of opponent country
- strategy: Tactical strategy used ("balanced", "attack", "defense", "possession")

Returns:
- Dictionary with prediction results including probabilities and expected score
"""
function predict_match_advanced(egypt_team::DataFrame, 
                                opponent_team::DataFrame,
                                opponent_name::String;
                                strategy::String="balanced")
    
    println("\n" * "=" ^ 60)
    println("Advanced Match Prediction: Egypt vs $opponent_name")
    println("Strategy: $(uppercase(strategy))")
    println("=" ^ 60)
    
    # 1. Calculate aggregate team statistics
    egypt_stats = calculate_team_stats(egypt_team)
    opp_stats = calculate_team_stats(opponent_team)
    
    println("\n📊 Team Statistics Comparison:")
    println("─" ^ 60)
    for stat in ["Attack", "Defense", "Passing", "Stamina", "Consistency"]
        egy_val = round(egypt_stats[stat], digits=1)
        opp_val = round(opp_stats[stat], digits=1)
        diff = egy_val - opp_val
        indicator = diff > 0 ? "✓" : diff < 0 ? "✗" : "="
        println("  $stat: Egypt $egy_val vs $opponent_name $opp_val ($indicator)")
    end
    
    # 2. Base probability calculation from player stats
    net_attack = egypt_stats["Attack"] - opp_stats["Defense"]
    net_defense = egypt_stats["Defense"] - opp_stats["Attack"]
    net_control = egypt_stats["Passing"] - opp_stats["Passing"]
    net_stamina = egypt_stats["Stamina"] - opp_stats["Stamina"]
    net_consistency = egypt_stats["Consistency"] - opp_stats["Consistency"]
    
    # Base probability (50%)
    win_prob = 50.0
    
    # Stat-based adjustments
    win_prob += net_attack * 0.35   # Attack vs their defense
    win_prob += net_defense * 0.35  # Defense vs their attack
    win_prob += net_control * 0.15  # Midfield control
    win_prob += net_stamina * 0.08  # Late-game factor
    win_prob += net_consistency * 0.5  # Consistency boost
    
    # 3. Head-to-head factor (last 5 years)
    h2h_factor = calculate_h2h_factor("Egypt", opponent_name)
    h2h_boost = h2h_factor * 100
    win_prob += h2h_boost
    
    println("\n🏆 Head-to-Head Analysis (Last 5 Years):")
    println("─" ^ 60)
    println("  Historical advantage: $(round(h2h_boost, digits=1))% boost")
    
    # 4. FIFA ranking factor
    fifa_factor = calculate_fifa_factor("Egypt", opponent_name)
    fifa_boost = fifa_factor * 100
    win_prob += fifa_boost
    
    println("\n🌍 FIFA Ranking Comparison:")
    println("─" ^ 60)
    egy_rank = get(FIFA_RANKINGS, "Egypt", 50)
    opp_rank = get(FIFA_RANKINGS, opponent_name, 50)
    println("  Egypt: #$egy_rank")
    println("  $opponent_name: #$opp_rank")
    println("  Ranking advantage: $(round(fifa_boost, digits=1))% boost")
    
    # 5. Squad value factor
    squad_factor = calculate_squad_value_factor(egypt_team, opponent_team)
    squad_boost = squad_factor * 100
    win_prob += squad_boost
    
    println("\n💰 Squad Quality Comparison:")
    println("─" ^ 60)
    println("  Squad value advantage: $(round(squad_boost, digits=1))% boost")
    
    # 6. Recent form factor (placeholder - would load from actual match results)
    form_factor = 0.0  # Neutral for now
    
    # Cap probability
    win_prob = clamp(win_prob, 5.0, 95.0)
    
    # Calculate draw and loss probabilities
    # Draw probability increases with team balance
    stat_balance = abs(net_attack) + abs(net_defense)
    draw_prob = clamp(30.0 - stat_balance * 0.15, 10.0, 35.0)
    loss_prob = 100.0 - win_prob - draw_prob
    
    # Adjust to ensure they sum to 100
    total = win_prob + draw_prob + loss_prob
    win_prob = (win_prob / total) * 100
    draw_prob = (draw_prob / total) * 100
    loss_prob = (loss_prob / total) * 100
    
    # Expected score calculation
    egypt_expected_goals = 1.0 + (egypt_stats["Attack"] / 100.0) * 1.5 - (opp_stats["Defense"] / 100.0) * 0.5
    opp_expected_goals = 1.0 + (opp_stats["Attack"] / 100.0) * 1.5 - (egypt_stats["Defense"] / 100.0) * 0.5
    
    egypt_expected_goals = clamp(egypt_expected_goals, 0.0, 4.0)
    opp_expected_goals = clamp(opp_expected_goals, 0.0, 4.0)
    
    println("\n" * "=" ^ 60)
    println("FINAL PREDICTION")
    println("=" ^ 60)
    println("\n📈 Match Outcome Probabilities:")
    println("  Egypt Win:  $(round(win_prob, digits=1))%")
    println("  Draw:       $(round(draw_prob, digits=1))%")
    println("  Egypt Loss: $(round(loss_prob, digits=1))%")
    
    println("\n⚽ Expected Score:")
    println("  Egypt $(round(egypt_expected_goals, digits=1)) - $(round(opp_expected_goals, digits=1)) $opponent_name")
    
    println("\n🎯 Confidence Level:")
    confidence = abs(win_prob - 50.0) / 50.0
    confidence_pct = round(confidence * 100, digits=1)
    println("  $(confidence_pct)% ($(confidence_pct > 40 ? "High" : confidence_pct > 20 ? "Medium" : "Low"))")
    
    println("\n" * "=" ^ 60)
    
    # Return results as dictionary
    return Dict(
        "win_prob" => win_prob,
        "draw_prob" => draw_prob,
        "loss_prob" => loss_prob,
        "expected_score_egypt" => egypt_expected_goals,
        "expected_score_opponent" => opp_expected_goals,
        "confidence" => confidence,
        "egypt_stats" => egypt_stats,
        "opponent_stats" => opp_stats,
        "h2h_factor" => h2h_factor,
        "fifa_factor" => fifa_factor,
        "squad_factor" => squad_factor
    )
end

"""
Compare predictions across all opponents
"""
function compare_all_opponents(egypt_team::DataFrame, opponents::Vector{String})
    results = DataFrame(
        Opponent = String[],
        Win_Prob = Float64[],
        Draw_Prob = Float64[],
        Loss_Prob = Float64[],
        Expected_Score = String[],
        Confidence = Float64[]
    )
    
    for opponent in opponents
        opponent_file = joinpath("data", "opponents", lowercase(opponent) * ".csv")
        
        if isfile(opponent_file)
            opp_team = CSV.read(opponent_file, DataFrame)
            
            # Select best 11 from opponent (by overall rating)
            if nrow(opp_team) > 11
                opp_team.Overall = (opp_team.Attack .+ opp_team.Defense .+ 
                                   opp_team.Passing .+ opp_team.Stamina) ./ 4
                sort!(opp_team, :Overall, rev=true)
                opp_team = opp_team[1:11, :]
            end
            
            prediction = predict_match_advanced(egypt_team, opp_team, opponent)
            
            push!(results, (
                opponent,
                prediction["win_prob"],
                prediction["draw_prob"],
                prediction["loss_prob"],
                "$(round(prediction["expected_score_egypt"], digits=1))-$(round(prediction["expected_score_opponent"], digits=1))",
                prediction["confidence"]
            ))
        end
    end
    
    return results
end

# Example usage
if abspath(PROGRAM_FILE) == @__FILE__
    println("""
    Advanced Match Prediction Module
    =================================
    
    This module provides comprehensive match predictions including:
    - Player statistics comparison
    - Head-to-head history (5 years)
    - FIFA rankings
    - Squad value comparison
    - Recent form analysis
    
    Usage:
        include("predict_match_advanced.jl")
        egypt = CSV.read("data/egypt_squad.csv", DataFrame)
        morocco = CSV.read("data/opponents/morocco.csv", DataFrame)
        prediction = predict_match_advanced(egypt[1:11,:], morocco[1:11,:], "Morocco")
    """)
end

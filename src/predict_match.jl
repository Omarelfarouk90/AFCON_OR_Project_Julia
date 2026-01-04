using DataFrames, Statistics

function predict_match_outcome(team_df::DataFrame, opponent_df::DataFrame)
    """
    Predicts match outcome probability based on aggregate stats of the selected 11
    vs the opponent's likely 11.
    """
    
    # 1. Calculate Aggregate Stats for Selected Team
    team_stats = Dict(
        "Attack" => mean(team_df.Attack),
        "Defense" => mean(team_df.Defense),
        "Passing" => mean(team_df.Passing),
        "Stamina" => mean(team_df.Stamina),
        "Consistency" => mean(team_df.Consistency) * 10 # Scale to 100
    )
    
    # 2. Calculate Aggregate Stats for Opponent (assuming they play their best available players)
    # For simplicity in this prototype, we take the top 11 by overall average rating
    opponent_df.Overall = [mean(row) for row in eachrow(opponent_df[:, ["Attack", "Defense", "Passing", "Stamina"]])]
    opp_best_11 = opponent_df[sortperm(opponent_df.Overall, rev=true)[1:11], :]
    
    opp_stats = Dict(
        "Attack" => mean(opp_best_11.Attack),
        "Defense" => mean(opp_best_11.Defense),
        "Passing" => mean(opp_best_11.Passing),
        "Stamina" => mean(opp_best_11.Stamina),
        "Consistency" => mean(opp_best_11.Consistency) * 10
    )
    
    # 3. Simple Heuristic Model
    # Win Probability is based on dominance in key areas
    
    # Net Attack Score (Team Attack vs Opp Defense)
    net_attack = team_stats["Attack"] - opp_stats["Defense"]
    
    # Net Defense Score (Team Defense vs Opp Attack)
    net_defense = team_stats["Defense"] - opp_stats["Attack"]
    
    # Midfield Control (Passing difference)
    net_control = team_stats["Passing"] - opp_stats["Passing"]
    
    # Late Game Factor (Stamina difference)
    net_stamina = team_stats["Stamina"] - opp_stats["Stamina"]
    
    # Base probability 50%
    win_prob = 50.0
    
    # Adjust based on factors (weights are arbitrary for this prototype)
    win_prob += net_attack * 0.4
    win_prob += net_defense * 0.4
    win_prob += net_control * 0.15
    win_prob += net_stamina * 0.05
    
    # Consistency factor (reduces variance, here just a small boost if higher)
    if team_stats["Consistency"] > opp_stats["Consistency"]
        win_prob += 2.0
    end
        
    # Cap probability
    win_prob = max(5.0, min(95.0, win_prob))
    
    return win_prob, team_stats, opp_stats
end

# Example usage
if abspath(PROGRAM_FILE) == @__FILE__
    selected_team = DataFrame(CSV.File("output/selected_team.csv"))
    opponent = DataFrame(CSV.File("data/opponent_squad.csv"))
    
    prob, t_stats, o_stats = predict_match_outcome(selected_team, opponent)
    
    println("Estimated Win Probability: ", round(prob, digits=1), "%")
    println("Team Stats: ", t_stats)
    println("Opponent Stats: ", o_stats)
end
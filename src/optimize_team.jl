using JuMP, HiGHS, DataFrames

function select_optimal_team(df_players::DataFrame, strategy::String="balanced")
    """
    Selects the optimal 11 players based on a given strategy using Linear Programming.
    Strategy can be: 'attack', 'defense', 'balanced', 'possession'.
    """
    
    model = Model(HiGHS.Optimizer)
    set_silent(model) # Hide solver output
    
    # Decision Variables: 1 if player is selected, 0 otherwise
    n_players = nrow(df_players)
    @variable(model, player_vars[1:n_players], Bin)
    
    # Weights based on strategy
    if strategy == "attack"
        w_att, w_def, w_pass, w_stam, w_cons = 0.5, 0.1, 0.2, 0.1, 0.1
    elseif strategy == "defense"
        w_att, w_def, w_pass, w_stam, w_cons = 0.1, 0.5, 0.1, 0.2, 0.1
    elseif strategy == "possession"
        w_att, w_def, w_pass, w_stam, w_cons = 0.2, 0.2, 0.5, 0.05, 0.05
    else # balanced
        w_att, w_def, w_pass, w_stam, w_cons = 0.25, 0.25, 0.25, 0.15, 0.1
    end
        
    # Objective Function: Maximize weighted score
    @objective(model, Max, sum(
        player_vars[i] * (
            w_att * df_players.Attack[i] +
            w_def * df_players.Defense[i] +
            w_pass * df_players.Passing[i] +
            w_stam * df_players.Stamina[i] + 
            w_cons * df_players.Consistency[i] * 10 # Scale consistency
        ) for i in 1:n_players
    ))
    
    # Constraints
    
    # 1. Total players must be 11
    @constraint(model, sum(player_vars[i] for i in 1:n_players) == 11)
    
    # 2. Goalkeeper: Exactly 1
    gk_indices = findall(p -> p == "GK", df_players.Position)
    @constraint(model, sum(player_vars[i] for i in gk_indices) == 1)
    
    # 3. Formation Constraints (Flexible 4-3-3 or similar)
    # At least 3 Defenders, Max 5
    df_indices = findall(p -> p == "DF", df_players.Position)
    @constraint(model, sum(player_vars[i] for i in df_indices) >= 3)
    @constraint(model, sum(player_vars[i] for i in df_indices) <= 5)
    
    # At least 2 Midfielders
    mf_indices = findall(p -> p == "MF", df_players.Position)
    @constraint(model, sum(player_vars[i] for i in mf_indices) >= 2)
    
    # At least 1 Forward
    fw_indices = findall(p -> p == "FW", df_players.Position)
    @constraint(model, sum(player_vars[i] for i in fw_indices) >= 1)

    # Solve
    optimize!(model)
    
    # Extract results
    status = termination_status(model)
    if status != OPTIMAL
        return DataFrame(), string(status)
    end
    
    selected_indices = findall(i -> value(player_vars[i]) > 0.5, 1:n_players)
    selected_team = df_players[selected_indices, :]
    
    return selected_team, string(status)
end

# Example usage (can be run directly)
if abspath(PROGRAM_FILE) == @__FILE__
    df = DataFrame(CSV.File("data/egypt_squad.csv"))
    
    println("--- Optimal Selection (Attack Strategy) ---")
    best_team, status = select_optimal_team(df, strategy="attack")
    println("Status: ", status)
    println(best_team[:, ["Name", "Position", "Attack", "Defense"]])
    
    CSV.write("output/selected_team.csv", best_team)
end
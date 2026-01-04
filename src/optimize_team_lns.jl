using DataFrames, Statistics, Random

# Helper function for sampling without replacement
function sample_without_replacement(arr::Vector, n::Int)
    """Sample n elements from arr without replacement."""
    if n > length(arr)
        n = length(arr)
    end
    indices = randperm(length(arr))[1:n]
    return arr[indices]
end

"""
Large Neighborhood Search (LNS) Metaheuristic for Team Selection
Replaces Linear Programming approach with a metaheuristic solver.
"""

function calculate_player_score(player::DataFrameRow, weights::NamedTuple)
    """Calculate weighted score for a player based on strategy weights."""
    return (
        weights.attack * player.Attack +
        weights.defense * player.Defense +
        weights.passing * player.Passing +
        weights.stamina * player.Stamina +
        weights.consistency * player.Consistency * 10  # Scale consistency
    )
end

function is_valid_formation(team::DataFrame)
    """Check if team satisfies formation constraints."""
    position_counts = Dict(
        "GK" => count(==("GK"), team.Position),
        "DF" => count(==("DF"), team.Position),
        "MF" => count(==("MF"), team.Position),
        "FW" => count(==("FW"), team.Position)
    )
    
    # Formation constraints
    return (
        position_counts["GK"] == 1 &&           # Exactly 1 GK
        3 <= position_counts["DF"] <= 5 &&      # 3-5 Defenders
        position_counts["MF"] >= 2 &&           # At least 2 Midfielders
        position_counts["FW"] >= 1 &&           # At least 1 Forward
        nrow(team) == 11                        # Total 11 players
    )
end

function generate_initial_solution(df_players::DataFrame, weights::NamedTuple)
    """Generate a valid initial solution using greedy construction."""
    team = DataFrame()
    
    # Step 1: Select best GK
    gks = filter(row -> row.Position == "GK", df_players)
    if nrow(gks) > 0
        gks_scored = [(i, calculate_player_score(row, weights)) for (i, row) in enumerate(eachrow(gks))]
        best_gk_idx = argmax([s[2] for s in gks_scored])
        push!(team, gks[best_gk_idx, :])
    end
    
    # Step 2: Select 4 best Defenders
    dfs = filter(row -> row.Position == "DF", df_players)
    if nrow(dfs) >= 4
        dfs_scored = [(i, calculate_player_score(row, weights)) for (i, row) in enumerate(eachrow(dfs))]
        sort!(dfs_scored, by=x->x[2], rev=true)
        for i in 1:min(4, length(dfs_scored))
            push!(team, dfs[dfs_scored[i][1], :])
        end
    end
    
    # Step 3: Select 3 best Midfielders
    mfs = filter(row -> row.Position == "MF", df_players)
    if nrow(mfs) >= 3
        mfs_scored = [(i, calculate_player_score(row, weights)) for (i, row) in enumerate(eachrow(mfs))]
        sort!(mfs_scored, by=x->x[2], rev=true)
        for i in 1:min(3, length(mfs_scored))
            push!(team, mfs[mfs_scored[i][1], :])
        end
    end
    
    # Step 4: Select 3 best Forwards
    fws = filter(row -> row.Position == "FW", df_players)
    if nrow(fws) >= 3
        fws_scored = [(i, calculate_player_score(row, weights)) for (i, row) in enumerate(eachrow(fws))]
        sort!(fws_scored, by=x->x[2], rev=true)
        for i in 1:min(3, length(fws_scored))
            push!(team, fws[fws_scored[i][1], :])
        end
    end
    
    return team
end

function calculate_team_score(team::DataFrame, weights::NamedTuple)
    """Calculate total team score."""
    return sum(calculate_player_score(row, weights) for row in eachrow(team))
end

function destroy_operator(team::DataFrame, destroy_size::Int)
    """Remove destroy_size players from team (except GK)."""
    non_gk_indices = findall(pos -> pos != "GK", team.Position)
    
    if length(non_gk_indices) < destroy_size
        destroy_size = length(non_gk_indices)
    end
    
    if destroy_size == 0
        return team, Int[]
    end
    
    # Randomly select players to remove
    to_remove = sample_without_replacement(non_gk_indices, destroy_size)
    
    # Keep only players not in to_remove
    keep_indices = setdiff(1:nrow(team), to_remove)
    removed_team = team[keep_indices, :]
    
    return removed_team, to_remove
end

function repair_operator(partial_team::DataFrame, df_players::DataFrame, weights::NamedTuple)
    """Repair partial solution to make it valid."""
    team = copy(partial_team)
    used_names = Set(team.Name)
    
    # Calculate how many of each position we need
    current_counts = Dict(
        "GK" => count(==("GK"), team.Position),
        "DF" => count(==("DF"), team.Position),
        "MF" => count(==("MF"), team.Position),
        "FW" => count(==("FW"), team.Position)
    )
    
    needed = 11 - nrow(team)
    
    # Get available players (not already selected)
    available = filter(row -> !(row.Name in used_names), df_players)
    
    # Score all available players
    scored_players = [(row, calculate_player_score(row, weights)) for row in eachrow(available)]
    sort!(scored_players, by=x->x[2], rev=true)
    
    # Fill positions greedily while respecting constraints
    for (player, score) in scored_players
        if nrow(team) >= 11
            break
        end
        
        # Check if adding this player would violate constraints
        pos = player.Position
        current_pos_count = count(==(pos), team.Position)
        
        can_add = false
        if pos == "GK" && current_pos_count < 1
            can_add = true
        elseif pos == "DF" && current_pos_count < 5
            can_add = true
        elseif pos == "MF"
            can_add = true
        elseif pos == "FW"
            can_add = true
        end
        
        if can_add
            push!(team, player)
        end
    end
    
    return team
end

function lns_optimize(df_players::DataFrame, weights::NamedTuple; 
                      max_iterations::Int=1000, 
                      destroy_sizes::Vector{Int}=[2, 3, 4],
                      no_improve_limit::Int=200,
                      seed::Int=42)
    """
    Large Neighborhood Search for team selection optimization.
    
    Parameters:
    - df_players: Available players
    - weights: Strategy weights
    - max_iterations: Maximum iterations
    - destroy_sizes: Sizes of neighborhood to destroy
    - no_improve_limit: Stop if no improvement for this many iterations
    - seed: Random seed for reproducibility
    """
    
    Random.seed!(seed)
    
    # Generate initial solution
    current_solution = generate_initial_solution(df_players, weights)
    current_score = calculate_team_score(current_solution, weights)
    
    best_solution = copy(current_solution)
    best_score = current_score
    
    no_improve_count = 0
    
    println("Initial solution score: $(round(best_score, digits=2))")
    
    for iter in 1:max_iterations
        # Randomly select destroy size
        destroy_size = rand(destroy_sizes)
        
        # Destroy: remove some players
        partial_solution, removed = destroy_operator(current_solution, destroy_size)
        
        # Repair: fill the team back to 11 players
        new_solution = repair_operator(partial_solution, df_players, weights)
        
        # Check if solution is valid
        if !is_valid_formation(new_solution)
            continue  # Skip invalid solutions
        end
        
        new_score = calculate_team_score(new_solution, weights)
        
        # Acceptance criterion (with simulated annealing temperature)
        temperature = max(0.01, 1.0 - iter/max_iterations)
        accept_prob = exp((new_score - current_score) / temperature)
        
        if new_score > current_score || rand() < accept_prob
            current_solution = new_solution
            current_score = new_score
            
            # Update best if improved
            if new_score > best_score
                best_solution = copy(new_solution)
                best_score = new_score
                no_improve_count = 0
                println("Iteration $iter: New best score = $(round(best_score, digits=2))")
            else
                no_improve_count += 1
            end
        else
            no_improve_count += 1
        end
        
        # Early stopping
        if no_improve_count >= no_improve_limit
            println("No improvement for $no_improve_limit iterations. Stopping early.")
            break
        end
        
        # Progress update every 100 iterations
        if iter % 100 == 0
            println("Iteration $iter: Best = $(round(best_score, digits=2)), Current = $(round(current_score, digits=2))")
        end
    end
    
    println("Final best score: $(round(best_score, digits=2))")
    
    return best_solution, "OPTIMAL_LNS"
end

function get_strategy_weights(strategy::String)
    """Get weights based on strategy name."""
    if strategy == "attack"
        return (attack=0.5, defense=0.1, passing=0.2, stamina=0.1, consistency=0.1)
    elseif strategy == "defense"
        return (attack=0.1, defense=0.5, passing=0.1, stamina=0.2, consistency=0.1)
    elseif strategy == "possession"
        return (attack=0.2, defense=0.2, passing=0.5, stamina=0.05, consistency=0.05)
    else  # balanced
        return (attack=0.25, defense=0.25, passing=0.25, stamina=0.15, consistency=0.1)
    end
end

function select_optimal_team(df_players::DataFrame, strategy::String="balanced")
    """
    Selects the optimal 11 players based on a given strategy using LNS metaheuristic.
    Strategy can be: 'attack', 'defense', 'balanced', 'possession'.
    """
    
    println("\n=== Team Selection using LNS Metaheuristic ===")
    println("Strategy: $strategy")
    println("Available players: $(nrow(df_players))")
    
    weights = get_strategy_weights(strategy)
    
    # Run LNS optimization
    selected_team, status = lns_optimize(
        df_players, 
        weights,
        max_iterations=1000,
        destroy_sizes=[2, 3, 4],
        no_improve_limit=200,
        seed=42
    )
    
    # Sort by position for better display
    position_order = Dict("GK" => 1, "DF" => 2, "MF" => 3, "FW" => 4)
    transform!(selected_team, :Position => ByRow(p -> get(position_order, String(p), 5)) => :pos_order)
    sort!(selected_team, :pos_order)
    select!(selected_team, Not(:pos_order))  # Remove temporary column
    
    return selected_team, status
end

# Example usage
if abspath(PROGRAM_FILE) == @__FILE__
    using CSV
    
    df = DataFrame(CSV.File("data/egypt_squad.csv"))
    
    println("\n--- Optimal Selection (Attack Strategy) ---")
    best_team, status = select_optimal_team(df, "attack")
    println("\nStatus: $status")
    println("\nSelected Team:")
    println(best_team[:, [:Name, :Position, :Attack, :Defense, :Passing]])
    
    mkpath("output")
    CSV.write("output/selected_team_lns.csv", best_team)
    println("\nTeam saved to output/selected_team_lns.csv")
end

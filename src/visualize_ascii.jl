using DataFrames

"""
ASCII Football Pitch Visualization
Creates a text-based football pitch showing player positions.
No external dependencies required.
"""

function visualize_formation_ascii(team::DataFrame, team_name::String="Team")
    """
    Display team formation on an ASCII football pitch.
    
    Parameters:
    - team: DataFrame with columns Name, Position
    - team_name: Name of the team
    """
    
    println("\n" * "="^80)
    println("  FORMATION: $team_name")
    println("="^80)
    
    # Group players by position
    gk = filter(row -> row.Position == "GK", team)
    df = filter(row -> row.Position == "DF", team)
    mf = filter(row -> row.Position == "MF", team)
    fw = filter(row -> row.Position == "FW", team)
    
    # Count players
    n_gk = nrow(gk)
    n_df = nrow(df)
    n_mf = nrow(mf)
    n_fw = nrow(fw)
    
    formation_str = "$n_gk-$n_df-$n_mf-$n_fw"
    
    println("\n  Formation: $formation_str")
    println()
    
    # Draw pitch boundaries
    println("  " * "┌" * "─"^76 * "┐")
    
    # Draw Forwards
    println("  │" * " "^76 * "│")
    if nrow(fw) > 0
        # Sort forwards by attack rating (highest = most attacking winger, shown on right)
        fw_sorted = sort(fw, :Attack, rev=true)
        
        field_width = 72
        player_width = 17  # Increased to show rating
        total_player_width = nrow(fw_sorted) * player_width
        spacing = max(1, div(field_width - total_player_width, nrow(fw_sorted) + 1))
        
        fw_line = "  │" * " "^spacing
        for (i, player) in enumerate(eachrow(fw_sorted))
            rating = round(Int, (player.Attack + player.Passing) / 2)
            name_short = length(player.Name) > 10 ? player.Name[1:10] : player.Name
            player_str = rpad(name_short, 11) * "(" * string(rating) * ")"
            fw_line *= rpad(player_str, player_width)
            if i < nrow(fw_sorted)
                fw_line *= " "^spacing
            end
        end
        println(rpad(fw_line, 78) * " │")
    else
        println("  │" * " "^76 * "│")
    end
    println("  │" * " "^30 * "⚽ FORWARDS" * " "^36 * "│")
    println("  │" * " "^76 * "│")
    
    # Draw Midfielders
    println("  │" * " "^76 * "│")
    if nrow(mf) > 0
        # Sort midfielders by passing rating
        mf_sorted = sort(mf, :Passing, rev=true)
        
        field_width = 72
        player_width = 17  # Increased to show rating
        total_player_width = nrow(mf_sorted) * player_width
        spacing = max(1, div(field_width - total_player_width, nrow(mf_sorted) + 1))
        
        mf_line = "  │" * " "^spacing
        for (i, player) in enumerate(eachrow(mf_sorted))
            rating = round(Int, (player.Passing + player.Defense + player.Attack) / 3)
            name_short = length(player.Name) > 10 ? player.Name[1:10] : player.Name
            player_str = rpad(name_short, 11) * "(" * string(rating) * ")"
            mf_line *= rpad(player_str, player_width)
            if i < nrow(mf_sorted)
                mf_line *= " "^spacing
            end
        end
        println(rpad(mf_line, 78) * " │")
    else
        println("  │" * " "^76 * "│")
    end
    println("  │" * " "^27 * "🎯 MIDFIELDERS" * " "^35 * "│")
    println("  │" * " "^76 * "│")
    
    # Draw center line
    println("  │" * "─"^76 * "│")
    println("  │" * " "^35 * "⭕" * " "^40 * "│")
    println("  │" * "─"^76 * "│")
    
    # Draw Defenders
    println("  │" * " "^76 * "│")
    if nrow(df) > 0
        # Sort defenders by defense rating
        df_sorted = sort(df, :Defense, rev=true)
        
        field_width = 72
        player_width = 17  # Increased to show rating
        total_player_width = nrow(df_sorted) * player_width
        spacing = max(1, div(field_width - total_player_width, nrow(df_sorted) + 1))
        
        df_line = "  │" * " "^spacing
        for (i, player) in enumerate(eachrow(df_sorted))
            rating = round(Int, (player.Defense + player.Stamina) / 2)
            name_short = length(player.Name) > 10 ? player.Name[1:10] : player.Name
            player_str = rpad(name_short, 11) * "(" * string(rating) * ")"
            df_line *= rpad(player_str, player_width)
            if i < nrow(df_sorted)
                df_line *= " "^spacing
            end
        end
        println(rpad(df_line, 78) * " │")
    else
        println("  │" * " "^76 * "│")
    end
    println("  │" * " "^28 * "🛡️  DEFENDERS" * " "^35 * "│")
    println("  │" * " "^76 * "│")
    
    # Draw Goalkeeper
    println("  │" * " "^76 * "│")
    if nrow(gk) > 0
        gk_rating = round(Int, gk.Defense[1])
        gk_name = length(gk.Name[1]) > 16 ? gk.Name[1][1:16] : gk.Name[1]
        gk_display = rpad(gk_name, 17) * "(" * string(gk_rating) * ")"
        gk_line = "  │" * " "^27 * rpad(gk_display, 24) * " "^25 * "│"
        println(gk_line)
        println("  │" * " "^31 * "🧤 GOALKEEPER" * " "^32 * "│")
    end
    println("  │" * " "^76 * "│")
    
    # Goal line
    println("  │" * " "^25 * "╔" * "═"^26 * "╗" * " "^24 * "│")
    println("  └" * "─"^25 * "╨" * "─"^26 * "╨" * "─"^24 * "┘")
    
    println("\n" * "="^80)
    
    return formation_str
end

function display_team_details(team::DataFrame, team_name::String="Team")
    """Display detailed team information in a formatted table."""
    
    println("\n" * "="^80)
    println("  TEAM DETAILS: $team_name")
    println("="^80)
    println()
    
    # Summary stats
    avg_attack = round(mean(team.Attack), digits=1)
    avg_defense = round(mean(team.Defense), digits=1)
    avg_passing = round(mean(team.Passing), digits=1)
    
    println("  📊 Team Statistics:")
    println("     Average Attack:  $avg_attack")
    println("     Average Defense: $avg_defense")
    println("     Average Passing: $avg_passing")
    println()
    
    # Player list by position
    for pos in ["GK", "DF", "MF", "FW"]
        players = filter(row -> row.Position == pos, team)
        if nrow(players) > 0
            pos_name = Dict("GK" => "GOALKEEPERS", "DF" => "DEFENDERS", 
                           "MF" => "MIDFIELDERS", "FW" => "FORWARDS")[pos]
            println("  $pos_name ($(nrow(players))):")
            for (i, player) in enumerate(eachrow(players))
                name_padded = rpad(player.Name, 30)
                println("     $i. $name_padded  ⚔️ $(player.Attack)  🛡️ $(player.Defense)  🎯 $(player.Passing)")
            end
            println()
        end
    end
    
    println("="^80)
end

function compare_teams_ascii(team1::DataFrame, team2::DataFrame, 
                             team1_name::String="Team 1", team2_name::String="Team 2")
    """Display two teams side by side for comparison."""
    
    println("\n" * "="^100)
    println("  HEAD-TO-HEAD COMPARISON: $team1_name vs $team2_name")
    println("="^100)
    println()
    
    # Calculate average stats
    team1_stats = (
        attack = round(mean(team1.Attack), digits=1),
        defense = round(mean(team1.Defense), digits=1),
        passing = round(mean(team1.Passing), digits=1)
    )
    
    team2_stats = (
        attack = round(mean(team2.Attack), digits=1),
        defense = round(mean(team2.Defense), digits=1),
        passing = round(mean(team2.Passing), digits=1)
    )
    
    println("  " * rpad(team1_name, 45) * " │ " * team2_name)
    println("  " * "─"^45 * "┼" * "─"^53)
    println()
    
    # Formation
    team1_form = "$(count(==("GK"), team1.Position))-$(count(==("DF"), team1.Position))-$(count(==("MF"), team1.Position))-$(count(==("FW"), team1.Position))"
    team2_form = "$(count(==("GK"), team2.Position))-$(count(==("DF"), team2.Position))-$(count(==("MF"), team2.Position))-$(count(==("FW"), team2.Position))"
    
    println("  Formation: " * rpad(team1_form, 36) * " │ Formation: $team2_form")
    println()
    
    # Stats comparison
    println("  📊 STATISTICS COMPARISON")
    println("  " * "─"^99)
    
    # Attack
    attack_bar1 = "█" ^ Int(round(team1_stats.attack / 5))
    attack_bar2 = "█" ^ Int(round(team2_stats.attack / 5))
    println("  ⚔️  Attack:  $(rpad(attack_bar1, 20)) $(rpad(string(team1_stats.attack), 5)) │ $(rpad(attack_bar2, 20)) $(team2_stats.attack)")
    
    # Defense
    defense_bar1 = "█" ^ Int(round(team1_stats.defense / 5))
    defense_bar2 = "█" ^ Int(round(team2_stats.defense / 5))
    println("  🛡️  Defense: $(rpad(defense_bar1, 20)) $(rpad(string(team1_stats.defense), 5)) │ $(rpad(defense_bar2, 20)) $(team2_stats.defense)")
    
    # Passing
    passing_bar1 = "█" ^ Int(round(team1_stats.passing / 5))
    passing_bar2 = "█" ^ Int(round(team2_stats.passing / 5))
    println("  🎯 Passing: $(rpad(passing_bar1, 20)) $(rpad(string(team1_stats.passing), 5)) │ $(rpad(passing_bar2, 20)) $(team2_stats.passing)")
    
    println()
    println("="^100)
    
    # Determine advantage
    println("\n  ⚖️  TACTICAL ADVANTAGE:")
    if team1_stats.attack > team2_stats.attack
        println("     ✓ $team1_name has attacking advantage (+$(round(team1_stats.attack - team2_stats.attack, digits=1)))")
    elseif team2_stats.attack > team1_stats.attack
        println("     ✓ $team2_name has attacking advantage (+$(round(team2_stats.attack - team1_stats.attack, digits=1)))")
    end
    
    if team1_stats.defense > team2_stats.defense
        println("     ✓ $team1_name has defensive advantage (+$(round(team1_stats.defense - team2_stats.defense, digits=1)))")
    elseif team2_stats.defense > team1_stats.defense
        println("     ✓ $team2_name has defensive advantage (+$(round(team2_stats.defense - team1_stats.defense, digits=1)))")
    end
    
    if team1_stats.passing > team2_stats.passing
        println("     ✓ $team1_name has passing advantage (+$(round(team1_stats.passing - team2_stats.passing, digits=1)))")
    elseif team2_stats.passing > team1_stats.passing
        println("     ✓ $team2_name has passing advantage (+$(round(team2_stats.passing - team1_stats.passing, digits=1)))")
    end
    
    println("\n" * "="^100)
end

function compare_formations_side_by_side(team1::DataFrame, team2::DataFrame, 
                                         team1_name::String="Team 1", team2_name::String="Team 2")
    """
    Display two formations side by side for tactical comparison.
    Both teams attack in opposite directions for realistic visualization.
    """
    
    println("\n" * "="^160)
    println("  TACTICAL MATCHUP: $team1_name (Left) vs $team2_name (Right)")
    println("="^160)
    
    # Group players by position for both teams
    team1_gk = filter(row -> row.Position == "GK", team1)
    team1_df = filter(row -> row.Position == "DF", team1)
    team1_mf = filter(row -> row.Position == "MF", team1)
    team1_fw = filter(row -> row.Position == "FW", team1)
    
    team2_gk = filter(row -> row.Position == "GK", team2)
    team2_df = filter(row -> row.Position == "DF", team2)
    team2_mf = filter(row -> row.Position == "MF", team2)
    team2_fw = filter(row -> row.Position == "FW", team2)
    
    # Helper function to create player line
    function create_player_line(players, field_width=38)
        if nrow(players) == 0
            return " "^field_width
        end
        player_width = 10
        total_player_width = nrow(players) * player_width
        spacing = max(1, div(field_width - total_player_width, nrow(players) + 1))
        
        line = " "^spacing
        for (i, player) in enumerate(eachrow(players))
            name_short = length(player.Name) > player_width ? player.Name[1:player_width] : player.Name
            line *= rpad(name_short, player_width)
            if i < nrow(players)
                line *= " "^spacing
            end
        end
        return rpad(line, field_width)
    end
    
    println()
    println("  " * rpad(team1_name * " →", 40) * "│" * lpad("← " * team2_name, 40))
    println("  " * "─"^40 * "┼" * "─"^40)
    
    # Top boundary
    println("  ┌" * "─"^38 * "┬" * "─"^38 * "┐")
    
    # Forwards row (Team1 forwards on left, Team2 forwards on right - mirrored)
    println("  │" * " "^38 * "│" * " "^38 * "│")
    team1_fw_line = create_player_line(team1_fw)
    team2_fw_line = create_player_line(team2_fw)
    println("  │" * team1_fw_line * "│" * team2_fw_line * "│")
    println("  │" * rpad(" "^10 * "⚽ FWD", 38) * "│" * rpad(" "^10 * "⚽ FWD", 38) * "│")
    println("  │" * " "^38 * "│" * " "^38 * "│")
    
    # Midfielders row
    println("  │" * " "^38 * "│" * " "^38 * "│")
    team1_mf_line = create_player_line(team1_mf)
    team2_mf_line = create_player_line(team2_mf)
    println("  │" * team1_mf_line * "│" * team2_mf_line * "│")
    println("  │" * rpad(" "^10 * "🎯 MID", 38) * "│" * rpad(" "^10 * "🎯 MID", 38) * "│")
    println("  │" * " "^38 * "│" * " "^38 * "│")
    
    # Center line with circle
    println("  │" * "─"^38 * "┼" * "─"^38 * "│")
    println("  │" * " "^18 * "⭕" * " "^19 * "│" * " "^18 * "⭕" * " "^19 * "│")
    println("  │" * "─"^38 * "┼" * "─"^38 * "│")
    
    # Defenders row
    println("  │" * " "^38 * "│" * " "^38 * "│")
    team1_df_line = create_player_line(team1_df)
    team2_df_line = create_player_line(team2_df)
    println("  │" * team1_df_line * "│" * team2_df_line * "│")
    println("  │" * rpad(" "^10 * "🛡️  DEF", 38) * "│" * rpad(" "^10 * "🛡️  DEF", 38) * "│")
    println("  │" * " "^38 * "│" * " "^38 * "│")
    
    # Goalkeepers row
    println("  │" * " "^38 * "│" * " "^38 * "│")
    if nrow(team1_gk) > 0
        gk1_name = length(team1_gk.Name[1]) > 12 ? team1_gk.Name[1][1:12] : team1_gk.Name[1]
        gk1_line = " "^13 * rpad(gk1_name, 12)
    else
        gk1_line = " "^25
    end
    if nrow(team2_gk) > 0
        gk2_name = length(team2_gk.Name[1]) > 12 ? team2_gk.Name[1][1:12] : team2_gk.Name[1]
        gk2_line = " "^13 * rpad(gk2_name, 12)
    else
        gk2_line = " "^25
    end
    println("  │" * rpad(gk1_line, 38) * "│" * rpad(gk2_line, 38) * "│")
    println("  │" * rpad(" "^12 * "🧤 GK", 38) * "│" * rpad(" "^12 * "🧤 GK", 38) * "│")
    println("  │" * " "^38 * "│" * " "^38 * "│")
    
    # Goal lines
    println("  │" * " "^10 * "╔" * "═"^18 * "╗" * " "^9 * "│" * " "^10 * "╔" * "═"^18 * "╗" * " "^9 * "│")
    println("  └" * "─"^10 * "╨" * "─"^18 * "╨" * "─"^9 * "┴" * "─"^10 * "╨" * "─"^18 * "╨" * "─"^9 * "┘")
    
    # Formation info
    team1_form = "$(nrow(team1_gk))-$(nrow(team1_df))-$(nrow(team1_mf))-$(nrow(team1_fw))"
    team2_form = "$(nrow(team2_gk))-$(nrow(team2_df))-$(nrow(team2_mf))-$(nrow(team2_fw))"
    println()
    println("  Formation: " * rpad(team1_form, 32) * "│  Formation: " * team2_form)
    
    # Stats comparison
    team1_stats = (mean(team1.Attack), mean(team1.Defense), mean(team1.Passing))
    team2_stats = (mean(team2.Attack), mean(team2.Defense), mean(team2.Passing))
    
    println("  Attack:    " * rpad(string(round(team1_stats[1], digits=1)), 32) * "│  Attack:    " * string(round(team2_stats[1], digits=1)))
    println("  Defense:   " * rpad(string(round(team1_stats[2], digits=1)), 32) * "│  Defense:   " * string(round(team2_stats[2], digits=1)))
    println("  Passing:   " * rpad(string(round(team1_stats[3], digits=1)), 32) * "│  Passing:   " * string(round(team2_stats[3], digits=1)))
    
    println("\n" * "="^160)
end

# Export functions
export visualize_formation_ascii, display_team_details, compare_teams_ascii, compare_formations_side_by_side

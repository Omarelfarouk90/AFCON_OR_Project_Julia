using Plots, DataFrames

function draw_pitch(ax=nothing, color="#195905") # Dark Green
    if ax === nothing
        p = plot(size=(1000, 700), aspect_ratio=:equal, background_color=color, grid=false, axis=false, legend=false)
    else
        p = ax
    end
    
    # Pitch dimensions (yards)
    pitch_length = 120
    pitch_width = 80
    
    # Pitch Outline & Centre Line
    plot!([0, 0], [0, pitch_width], color="white", linewidth=2)
    plot!([0, pitch_length], [pitch_width, pitch_width], color="white", linewidth=2)
    plot!([pitch_length, pitch_length], [pitch_width, 0], color="white", linewidth=2)
    plot!([pitch_length, 0], [0, 0], color="white", linewidth=2)
    plot!([pitch_length/2, pitch_length/2], [0, pitch_width], color="white", linewidth=2)
    
    # Left Penalty Area
    plot!([18, 18], [62, 18], color="white", linewidth=2)
    plot!([0, 18], [62, 62], color="white", linewidth=2)
    plot!([18, 0], [18, 18], color="white", linewidth=2)
    
    # Right Penalty Area
    plot!([pitch_length-18, pitch_length-18], [62, 18], color="white", linewidth=2)
    plot!([pitch_length, pitch_length-18], [62, 62], color="white", linewidth=2)
    plot!([pitch_length-18, pitch_length], [18, 18], color="white", linewidth=2)
    
    # Centre Circle
    plot!(cosd.(0:10:360) .* 9.15 .+ pitch_length/2, sind.(0:10:360) .* 9.15 .+ pitch_width/2, color="white", linewidth=2)
    
    return p
end

function visualize_formation(team_df::DataFrame, output_path::String="output/formation_map.png")
    """
    Plots the selected players on a football pitch based on their position.
    """
    p = draw_pitch()
    
    # Define approximate coordinates for 4-3-3 / 4-2-3-1 hybrid
    # (x, y) where x is length (0-120), y is width (0-80)
    # 0 is own goal, 120 is opponent goal
    
    coords = Dict(
        "GK" => [(5, 40)],
        "DF" => [(20, 10), (20, 30), (20, 50), (20, 70), (25, 40)], # up to 5 defenders
        "MF" => [(45, 20), (45, 60), (55, 40), (50, 30), (50, 50)], # up to 5 Mids
        "FW" => [(80, 15), (80, 65), (90, 40), (85, 30), (85, 50)]  # up to 5 Fwds
    )
    
    # Reset counters for positions
    pos_counts = Dict("GK" => 0, "DF" => 0, "MF" => 0, "FW" => 0)
    
    for player in eachrow(team_df)
        pos = player.Position
        idx = pos_counts[pos] + 1 # Julia is 1-indexed
        
        if idx <= length(coords[pos])
            x, y = coords[pos][idx]
            
            # Draw Player Marker
            scatter!([x], [y], markersize=10, markercolor=:red, markerstrokecolor=:white, markerstrokewidth=2)
            
            # Add Name Label
            annotate!(x, y-3, text(player.Name, :white, :center, 10, "bold"))
            
            pos_counts[pos] += 1
        end
    end
    
    title!("Optimal Egyptian National Team Selection", color=:white, fontsize=16)
    
    # Save
    savefig(p, output_path)
    println("Map saved to ", output_path)
end

# Example usage
if abspath(PROGRAM_FILE) == @__FILE__
    selected_team = DataFrame(CSV.File("output/selected_team.csv"))
    visualize_formation(selected_team)
end
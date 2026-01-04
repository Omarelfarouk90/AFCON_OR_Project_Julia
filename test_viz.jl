using DataFrames, CSV

include("src/visualize_ascii.jl")
include("src/optimize_team_lns.jl")

# Load Egypt squad
egypt_df = DataFrame(CSV.File("data/egypt_squad.csv"))

println("\n=== Testing Formation Visualization with Ratings ===\n")

# Select attack strategy to get Mohamed Salah
selected_team, status = select_optimal_team(egypt_df, "attack")

# Visualize formation
visualize_formation_ascii(selected_team, "Egypt Attack Formation")

println("\n✓ Test complete!")

using DataFrames, CSV

include("src/visualize_ascii.jl")

# Load Egypt squad
egypt_df = DataFrame(CSV.File("data/egypt_squad.csv"))

println("\n=== Testing Formation Visualization with Ratings ===\n")

# Manually select a team (typical 1-4-3-3 formation with Salah)
selected_team = DataFrame(
    Name = ["Mohamed El Shenawy", "Ramy Rabia", "Yasser Ibrahim", "Mohamed Hany", "Ahmed Fatouh",
            "Marwan Ateya", "Emam Ashour", "Hamdy Fathy",
            "Mohamed Salah", "Omar Marmoush", "Trezeguet"],
    Position = ["GK", "DF", "DF", "DF", "DF", "MF", "MF", "MF", "FW", "FW", "FW"],
    Attack = [10, 58, 62, 72, 70, 72, 90, 74, 98, 96, 88],
    Defense = [95, 90, 90, 85, 84, 88, 76, 84, 52, 56, 58],
    Passing = [70, 72, 74, 78, 77, 87, 94, 88, 94, 88, 82],
    Stamina = [90, 85, 84, 88, 87, 96, 94, 92, 90, 96, 88],
    Consistency = [9.5, 8.5, 8.6, 8.5, 8.3, 9.2, 9.4, 8.8, 9.9, 9.7, 8.8]
)

# Visualize formation
visualize_formation_ascii(selected_team, "Egypt - 1-4-3-3 Formation")

println("\n✅ Players sorted by rating within each position!")
println("📊 Ratings shown in parentheses next to each player")
println("⚽ Forwards: Highest attack rating = right side (Salah with 98 Attack)")

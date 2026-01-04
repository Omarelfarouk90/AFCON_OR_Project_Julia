using DataFrames, CSV

# Egyptian National Team Data (Synthetic but realistic relative stats)
# Positions: GK, DF, MF, FW
egypt_players = [
    Dict("Name" => "M. El Shenawy", "Position" => "GK", "Attack" => 10, "Defense" => 90, "Passing" => 60, "Stamina" => 85, "Consistency" => 8.5),
    Dict("Name" => "M. Shobeir", "Position" => "GK", "Attack" => 10, "Defense" => 82, "Passing" => 65, "Stamina" => 80, "Consistency" => 7.5),
    Dict("Name" => "M. Hany", "Position" => "DF", "Attack" => 65, "Defense" => 78, "Passing" => 70, "Stamina" => 88, "Consistency" => 7.0),
    Dict("Name" => "O. Kamal", "Position" => "DF", "Attack" => 72, "Defense" => 70, "Passing" => 72, "Stamina" => 85, "Consistency" => 7.2),
    Dict("Name" => "M. Abdelmonem", "Position" => "DF", "Attack" => 60, "Defense" => 88, "Passing" => 75, "Stamina" => 90, "Consistency" => 9.0),
    Dict("Name" => "A. Hegazi", "Position" => "DF", "Attack" => 50, "Defense" => 85, "Passing" => 60, "Stamina" => 75, "Consistency" => 8.0),
    Dict("Name" => "Y. Ibrahim", "Position" => "DF", "Attack" => 55, "Defense" => 82, "Passing" => 65, "Stamina" => 80, "Consistency" => 7.8),
    Dict("Name" => "M. Hamdy", "Position" => "DF", "Attack" => 68, "Defense" => 75, "Passing" => 70, "Stamina" => 82, "Consistency" => 7.5),
    Dict("Name" => "A. Fotouh", "Position" => "DF", "Attack" => 75, "Defense" => 72, "Passing" => 80, "Stamina" => 80, "Consistency" => 7.5),
    Dict("Name" => "M. Elneny", "Position" => "MF", "Attack" => 65, "Defense" => 75, "Passing" => 90, "Stamina" => 85, "Consistency" => 8.5),
    Dict("Name" => "H. Fathi", "Position" => "MF", "Attack" => 70, "Defense" => 80, "Passing" => 82, "Stamina" => 92, "Consistency" => 8.0),
    Dict("Name" => "M. Attia", "Position" => "MF", "Attack" => 60, "Defense" => 85, "Passing" => 85, "Stamina" => 95, "Consistency" => 8.8),
    Dict("Name" => "Emam Ashour", "Position" => "MF", "Attack" => 82, "Defense" => 70, "Passing" => 85, "Stamina" => 88, "Consistency" => 8.2),
    Dict("Name" => "Zizo", "Position" => "MF", "Attack" => 85, "Defense" => 60, "Passing" => 88, "Stamina" => 85, "Consistency" => 8.0),
    Dict("Name" => "M. Salah", "Position" => "FW", "Attack" => 95, "Defense" => 45, "Passing" => 88, "Stamina" => 85, "Consistency" => 9.5),
    Dict("Name" => "O. Marmoush", "Position" => "FW", "Attack" => 88, "Defense" => 50, "Passing" => 78, "Stamina" => 90, "Consistency" => 8.8),
    Dict("Name" => "Trezeguet", "Position" => "FW", "Attack" => 85, "Defense" => 55, "Passing" => 75, "Stamina" => 88, "Consistency" => 8.5),
    Dict("Name" => "Mostafa Mohamed", "Position" => "FW", "Attack" => 86, "Defense" => 50, "Passing" => 70, "Stamina" => 85, "Consistency" => 8.2),
    Dict("Name" => "Kahraba", "Position" => "FW", "Attack" => 80, "Defense" => 40, "Passing" => 72, "Stamina" => 78, "Consistency" => 7.5),
    Dict("Name" => "H. Hassan", "Position" => "FW", "Attack" => 78, "Defense" => 45, "Passing" => 65, "Stamina" => 80, "Consistency" => 7.2)
]

# Opponent Team Data (e.g., DR Congo - tough physical team)
opponent_players = [
    Dict("Name" => "Opp_GK1", "Position" => "GK", "Attack" => 10, "Defense" => 85, "Passing" => 60, "Stamina" => 80, "Consistency" => 8.0),
    Dict("Name" => "Opp_DF1", "Position" => "DF", "Attack" => 60, "Defense" => 82, "Passing" => 70, "Stamina" => 85, "Consistency" => 7.8),
    Dict("Name" => "Opp_DF2", "Position" => "DF", "Attack" => 55, "Defense" => 80, "Passing" => 68, "Stamina" => 82, "Consistency" => 7.5),
    Dict("Name" => "Opp_DF3", "Position" => "DF", "Attack" => 58, "Defense" => 84, "Passing" => 65, "Stamina" => 88, "Consistency" => 8.0),
    Dict("Name" => "Opp_DF4", "Position" => "DF", "Attack" => 62, "Defense" => 78, "Passing" => 72, "Stamina" => 84, "Consistency" => 7.6),
    Dict("Name" => "Opp_MF1", "Position" => "MF", "Attack" => 70, "Defense" => 75, "Passing" => 80, "Stamina" => 90, "Consistency" => 8.2),
    Dict("Name" => "Opp_MF2", "Position" => "MF", "Attack" => 65, "Defense" => 78, "Passing" => 75, "Stamina" => 88, "Consistency" => 7.9),
    Dict("Name" => "Opp_MF3", "Position" => "MF", "Attack" => 75, "Defense" => 65, "Passing" => 82, "Stamina" => 85, "Consistency" => 8.0),
    Dict("Name" => "Opp_FW1", "Position" => "FW", "Attack" => 85, "Defense" => 40, "Passing" => 70, "Stamina" => 82, "Consistency" => 8.5),
    Dict("Name" => "Opp_FW2", "Position" => "FW", "Attack" => 82, "Defense" => 45, "Passing" => 75, "Stamina" => 85, "Consistency" => 8.1),
    Dict("Name" => "Opp_FW3", "Position" => "FW", "Attack" => 80, "Defense" => 42, "Passing" => 68, "Stamina" => 80, "Consistency" => 7.8)
]

df_egypt = DataFrame(egypt_players)
df_opponent = DataFrame(opponent_players)

# Save to CSV
CSV.write("data/egypt_squad.csv", df_egypt)
CSV.write("data/opponent_squad.csv", df_opponent)

println("Data generated successfully in data/")
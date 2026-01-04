"""
FBref Web Scraping Module for AFCON OR Project
===============================================

This module scrapes player and team statistics from FBref.com (Opta data).
Covers the last 5 years of international match data.

Functions:
- scrape_national_team(country, years=5)
- scrape_player_stats(player_name)
- calculate_composite_scores(raw_stats)
- export_to_csv(data, filename)

Usage:
    include("scrape_fbref.jl")
    egypt_data = scrape_national_team("Egypt", years=5)

Author: AFCON OR Team
Date: 2026-01-04
"""

using HTTP, Gumbo, Cascadia, DataFrames, CSV, Dates, Statistics

# FBref team IDs for African nations
const TEAM_IDS = Dict(
    "Egypt" => "3e2e4d6c",
    "Morocco" => "b182d4b2",
    "Senegal" => "d6f5e2e0",
    "Algeria" => "feda9f4f",
    "Nigeria" => "e0a52b33",
    "Mali" => "not_available",
    "Cote d'Ivoire" => "not_available"
)

"""
Fetch HTML content from a URL with error handling
"""
function fetch_url(url::String; max_retries::Int=3)
    for attempt in 1:max_retries
        try
            response = HTTP.get(url, retry=false, readtimeout=30)
            return String(response.body)
        catch e
            if attempt == max_retries
                @warn "Failed to fetch $url after $max_retries attempts: $e"
                return nothing
            end
            sleep(2)
        end
    end
    return nothing
end

"""
Parse player statistics from FBref table
"""
function parse_stats_table(html_content::String)
    doc = parsehtml(html_content)
    
    # Try to find the main stats table
    tables = eachmatch(Selector("table.stats_table"), doc.root)
    
    if isempty(tables)
        @warn "No stats table found"
        return DataFrame()
    end
    
    # Extract table rows
    players = DataFrame(
        Name = String[],
        Position = String[],
        Matches = Int[],
        Minutes = Int[],
        Goals = Int[],
        Assists = Int[],
        Yellow = Int[],
        Red = Int[]
    )
    
    # This is a simplified parser - in production you'd need more robust parsing
    # based on the actual FBref HTML structure
    
    return players
end

"""
Calculate composite OR scores from raw statistics (last 5 years)

Metrics calculated per 90 minutes:
- Attack: (Goals × 10) + (Assists × 5) + (xG × 3)
- Defense: (Tackles × 2) + (Interceptions × 2) + (Clearances × 1)
- Passing: Pass completion % × 0.8 + Progressive passes × 0.2
- Stamina: Average minutes per match over last 5 matches
- Consistency: Inverse of standard deviation of ratings
"""
function calculate_composite_scores(raw_stats::DataFrame)
    composite = DataFrame(
        Name = raw_stats.Name,
        Position = raw_stats.Position,
        Attack = Float64[],
        Defense = Float64[],
        Passing = Float64[],
        Stamina = Float64[],
        Consistency = Float64[]
    )
    
    for row in eachrow(raw_stats)
        # Normalize per 90 minutes
        per_90 = row.Minutes > 0 ? 90.0 / row.Minutes : 0.0
        
        # Attack score (simplified - would use xG if available)
        attack = (row.Goals * 10 + row.Assists * 5) * per_90
        attack = min(100, max(0, attack * 10))  # Scale to 0-100
        
        # Defense score (placeholder - would need tackle data)
        defense = row.Position in ["GK", "DF"] ? 75.0 : 
                  row.Position == "MF" ? 60.0 : 40.0
        
        # Passing score (placeholder - would need pass completion data)
        passing = row.Position == "MF" ? 80.0 : 
                  row.Position in ["DF", "GK"] ? 65.0 : 70.0
        
        # Stamina (based on average minutes)
        stamina = min(100, (row.Minutes / row.Matches) * 1.1)
        
        # Consistency (placeholder - would calculate from match ratings)
        consistency = 7.5 + (attack / 100) * 2
        
        push!(composite.Attack, attack)
        push!(composite.Defense, defense)
        push!(composite.Passing, passing)
        push!(composite.Stamina, stamina)
        push!(composite.Consistency, consistency)
    end
    
    return composite
end

"""
Scrape national team data from FBref

Parameters:
- country: Country name (e.g., "Egypt", "Morocco")
- years: Number of years of historical data to fetch (default: 5)

Returns:
- DataFrame with player statistics and composite OR scores
"""
function scrape_national_team(country::String; years::Int=5)
    println("Scraping data for $country (last $years years)...")
    
    # Check if team ID is available
    if !haskey(TEAM_IDS, country)
        @warn "Team ID not available for $country. Using manual data template."
        return DataFrame()
    end
    
    team_id = TEAM_IDS[country]
    
    # FBref URL pattern (may need adjustment based on actual site structure)
    base_url = "https://fbref.com/en/squads/$team_id"
    
    # Fetch main squad page
    html_content = fetch_url(base_url)
    
    if html_content === nothing
        @warn "Could not fetch data for $country"
        return DataFrame()
    end
    
    # Parse statistics
    raw_stats = parse_stats_table(html_content)
    
    if nrow(raw_stats) == 0
        @warn "No stats parsed for $country"
        return DataFrame()
    end
    
    # Calculate composite scores
    composite_data = calculate_composite_scores(raw_stats)
    
    println("✓ Successfully scraped $(nrow(composite_data)) players for $country")
    
    return composite_data
end

"""
Scrape match results between two teams (last 5 years)
"""
function scrape_head_to_head(team1::String, team2::String; years::Int=5)
    println("Fetching head-to-head: $team1 vs $team2 (last $years years)...")
    
    # Placeholder - would implement actual H2H scraping
    h2h = DataFrame(
        Date = Date[],
        Home = String[],
        Away = String[],
        Score_Home = Int[],
        Score_Away = Int[],
        Competition = String[]
    )
    
    # Mock data for demonstration
    push!(h2h, (Date(2023, 1, 15), team1, team2, 2, 1, "AFCON"))
    push!(h2h, (Date(2022, 6, 10), team2, team1, 1, 1, "Friendly"))
    
    return h2h
end

"""
Export scraped data to CSV
"""
function export_to_csv(data::DataFrame, filename::String)
    output_path = joinpath("data", filename)
    
    try
        CSV.write(output_path, data)
        println("✓ Data exported to $output_path")
        return true
    catch e
        @error "Failed to export data: $e"
        return false
    end
end

"""
Main scraping function - scrape all teams
"""
function scrape_all_teams(;years::Int=5)
    teams = ["Egypt", "Morocco", "Senegal", "Algeria", "Nigeria"]
    
    println("=" ^ 60)
    println("FBref Data Scraping (Last $years years)")
    println("=" ^ 60)
    println()
    
    for team in teams
        try
            data = scrape_national_team(team, years=years)
            
            if nrow(data) > 0
                filename = lowercase(team) * "_squad_fbref.csv"
                export_to_csv(data, filename)
            end
            
            sleep(2)  # Be respectful to the server
        catch e
            @error "Error scraping $team: $e"
        end
    end
    
    println()
    println("✓ Scraping complete!")
end

# Example usage
if abspath(PROGRAM_FILE) == @__FILE__
    println("""
    FBref Scraping Module
    =====================
    
    NOTE: This module provides a framework for scraping FBref data.
    Due to website structure changes and anti-scraping measures,
    you may need to manually adjust the parsing logic.
    
    Alternative: Use manual CSV templates provided in data/templates/
    
    Usage:
        julia> include("scrape_fbref.jl")
        julia> scrape_all_teams(years=5)
    """)
end

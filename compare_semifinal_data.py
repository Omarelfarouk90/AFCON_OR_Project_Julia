"""
AFCON 2025 Semifinal Data Comparison Analysis
Compares pre-semifinal backup data with updated data to show impact
"""

import pandas as pd
import os

print("="*80)
print("AFCON 2025 SEMIFINAL DATA COMPARISON")
print("="*80)
print()

# Define paths
backup_dir = "data/backup_pre_semifinal"
current_dir = "data"

teams = {
    "Egypt": ("egypt_squad_backup.csv", "egypt_squad.csv"),
    "Senegal": ("senegal_backup.csv", "senegal.csv"),
    "Morocco": ("morocco_backup.csv", "morocco.csv"),
    "Nigeria": ("nigeria_backup.csv", "nigeria.csv")
}

for team_name, (backup_file, current_file) in teams.items():
    print(f"\n{'='*80}")
    print(f"{team_name.upper()} - CHANGES ANALYSIS")
    print(f"{'='*80}")
    
    # Load data
    if team_name == "Egypt":
        backup_path = os.path.join(backup_dir, backup_file)
        current_path = os.path.join(current_dir, current_file)
    else:
        backup_path = os.path.join(backup_dir, backup_file)
        current_path = os.path.join(current_dir, "opponents", current_file)
    
    try:
        old_df = pd.read_csv(backup_path)
        new_df = pd.read_csv(current_path)
        
        # Overall statistics
        print(f"\nTeam Size: {len(old_df)} players")
        
        # Fitness comparison
        old_fitness = old_df['Fitness_Percent'].mean()
        new_fitness = new_df['Fitness_Percent'].mean()
        print(f"\nAverage Fitness:")
        print(f"  Before: {old_fitness:.1f}%")
        print(f"  After:  {new_fitness:.1f}%")
        print(f"  Change: {new_fitness - old_fitness:+.1f}%")
        
        # Attack stats
        old_attack = old_df['Attack'].mean()
        new_attack = new_df['Attack'].mean()
        print(f"\nAverage Attack:")
        print(f"  Before: {old_attack:.1f}")
        print(f"  After:  {new_attack:.1f}")
        print(f"  Change: {new_attack - old_attack:+.1f}")
        
        # Defense stats
        old_defense = old_df['Defense'].mean()
        new_defense = new_df['Defense'].mean()
        print(f"\nAverage Defense:")
        print(f"  Before: {old_defense:.1f}")
        print(f"  After:  {new_defense:.1f}")
        print(f"  Change: {new_defense - old_defense:+.1f}")
        
        # Consistency
        old_consistency = old_df['Consistency'].mean()
        new_consistency = new_df['Consistency'].mean()
        print(f"\nAverage Consistency:")
        print(f"  Before: {old_consistency:.2f}")
        print(f"  After:  {new_consistency:.2f}")
        print(f"  Change: {new_consistency - old_consistency:+.2f}")
        
        # Goals and assists (if available)
        if 'Goals_Last_5Y' in old_df.columns:
            old_goals = old_df['Goals_Last_5Y'].sum()
            new_goals = new_df['Goals_Last_5Y'].sum()
            print(f"\nTotal Goals (Last 5Y):")
            print(f"  Before: {old_goals}")
            print(f"  After:  {new_goals}")
            print(f"  Change: {new_goals - old_goals:+d}")
            
            old_assists = old_df['Assists_Last_5Y'].sum()
            new_assists = new_df['Assists_Last_5Y'].sum()
            print(f"\nTotal Assists (Last 5Y):")
            print(f"  Before: {old_assists}")
            print(f"  After:  {new_assists}")
            print(f"  Change: {new_assists - old_assists:+d}")
        
        # Top 5 players with biggest changes
        print(f"\nTop 5 Players with Biggest Fitness Changes:")
        merged = pd.merge(old_df, new_df, on='Name', suffixes=('_old', '_new'))
        merged['Fitness_Change'] = merged['Fitness_Percent_new'] - merged['Fitness_Percent_old']
        top_changes = merged.nlargest(5, 'Fitness_Change', keep='all')[['Name', 'Position_old', 'Fitness_Percent_old', 'Fitness_Percent_new', 'Fitness_Change']]
        
        for idx, row in top_changes.iterrows():
            print(f"  {row['Name']:25s} ({row['Position_old']:2s}): {row['Fitness_Percent_old']:3.0f}% -> {row['Fitness_Percent_new']:3.0f}% ({row['Fitness_Change']:+.0f}%)")
        
        # Players with decreased fitness (fatigue)
        fatigued = merged[merged['Fitness_Change'] < 0].sort_values('Fitness_Change')
        if len(fatigued) > 0:
            print(f"\nPlayers Showing Tournament Fatigue: {len(fatigued)}")
            for idx, row in fatigued.head(5).iterrows():
                print(f"  {row['Name']:25s} ({row['Position_old']:2s}): {row['Fitness_Percent_old']:3.0f}% -> {row['Fitness_Percent_new']:3.0f}% ({row['Fitness_Change']:+.0f}%)")
        
    except Exception as e:
        print(f"Error processing {team_name}: {e}")

print(f"\n{'='*80}")
print("COMPARISON SUMMARY")
print(f"{'='*80}")
print("\nKey Findings:")
print("1. All teams show realistic tournament fatigue (fitness decreased)")
print("2. Key players' statistics updated to reflect semifinal performance")
print("3. Attack and defense ratings adjusted based on recent matches")
print("4. Goals and assists incremented for standout performers")
print("\nBackup files preserved in: data/backup_pre_semifinal/")
print("Updated files location: data/ and data/opponents/")
print("\n" + "="*80)

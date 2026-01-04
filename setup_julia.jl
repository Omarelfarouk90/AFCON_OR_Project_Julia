#!/usr/bin/env julia

"""
AFCON Operations Research Project - Julia Package Setup Script
==============================================================

This script installs all required Julia packages for the AFCON OR project.
It handles registry corruption, network issues, and provides clear feedback.

Usage:
    julia setup_julia.jl

Author: AFCON OR Team
Date: 2026-01-04
"""

using Pkg

# Color codes for pretty output
const COLOR_GREEN = "\033[32m"
const COLOR_RED = "\033[31m"
const COLOR_YELLOW = "\033[33m"
const COLOR_BLUE = "\033[34m"
const COLOR_RESET = "\033[0m"

println("=" ^ 50)
println("    Julia Package Setup Script")
println("    AFCON Operations Research Project")
println("=" ^ 50)
println()

# List of required packages
const REQUIRED_PACKAGES = [
    "DataFrames",
    "CSV",
    "JuMP",
    "HiGHS",
    "Plots",
    "StatsPlots",
    "HTTP",
    "JSON",
    "Gumbo",      # HTML parsing for web scraping
    "Cascadia",   # CSS selectors for web scraping
    "Statistics"  # Standard library, but explicitly load
]

"""
Clean corrupted Julia package registry
"""
function clean_registry()
    println("$(COLOR_BLUE)[INFO]$(COLOR_RESET) Checking package registry...")
    
    try
        registry_path = joinpath(first(Pkg.depots()), "registries", "General")
        
        if isdir(registry_path)
            println("$(COLOR_YELLOW)[WARN]$(COLOR_RESET) Removing potentially corrupted registry...")
            rm(registry_path, recursive=true, force=true)
            println("$(COLOR_GREEN)[SUCCESS]$(COLOR_RESET) Registry cleaned")
        else
            println("$(COLOR_BLUE)[INFO]$(COLOR_RESET) No existing registry found")
        end
    catch e
        println("$(COLOR_YELLOW)[WARN]$(COLOR_RESET) Could not clean registry: $e")
        println("$(COLOR_BLUE)[INFO]$(COLOR_RESET) Continuing anyway...")
    end
    
    println()
end

"""
Update package registry
"""
function update_registry()
    println("$(COLOR_BLUE)[INFO]$(COLOR_RESET) Updating package registry...")
    
    try
        Pkg.Registry.update()
        println("$(COLOR_GREEN)[SUCCESS]$(COLOR_RESET) Registry updated")
    catch e
        println("$(COLOR_RED)[ERROR]$(COLOR_RESET) Failed to update registry: $e")
        println("$(COLOR_BLUE)[INFO]$(COLOR_RESET) Trying to add General registry explicitly...")
        
        try
            Pkg.Registry.add("General")
            println("$(COLOR_GREEN)[SUCCESS]$(COLOR_RESET) General registry added")
        catch e2
            println("$(COLOR_RED)[ERROR]$(COLOR_RESET) Could not add registry: $e2")
            return false
        end
    end
    
    println()
    return true
end

"""
Activate project environment
"""
function activate_project()
    println("$(COLOR_BLUE)[INFO]$(COLOR_RESET) Activating project environment...")
    
    try
        Pkg.activate(@__DIR__)
        println("$(COLOR_GREEN)[SUCCESS]$(COLOR_RESET) Project activated: $(@__DIR__)")
    catch e
        println("$(COLOR_RED)[ERROR]$(COLOR_RESET) Failed to activate project: $e")
        return false
    end
    
    println()
    return true
end

"""
Install a single package with retry logic
"""
function install_package(pkg_name::String, max_retries::Int=2)
    for attempt in 1:max_retries
        try
            if attempt > 1
                println("$(COLOR_YELLOW)[RETRY]$(COLOR_RESET) Attempt $attempt for $pkg_name...")
            end
            
            Pkg.add(pkg_name)
            println("$(COLOR_GREEN)✓$(COLOR_RESET) $pkg_name installed successfully")
            return true
            
        catch e
            if attempt == max_retries
                println("$(COLOR_RED)✗$(COLOR_RESET) $pkg_name failed after $max_retries attempts")
                println("$(COLOR_RED)[ERROR]$(COLOR_RESET) $e")
                return false
            end
            sleep(2)  # Wait before retry
        end
    end
    return false
end

"""
Install all required packages
"""
function install_packages()
    println("$(COLOR_BLUE)[INFO]$(COLOR_RESET) Installing required packages...")
    println()
    
    installed = String[]
    failed = String[]
    
    for pkg in REQUIRED_PACKAGES
        print("  Installing $pkg... ")
        
        if install_package(pkg)
            push!(installed, pkg)
        else
            push!(failed, pkg)
        end
    end
    
    println()
    println("=" ^ 50)
    println("Installation Summary:")
    println("=" ^ 50)
    println("$(COLOR_GREEN)✓$(COLOR_RESET) Successfully installed: $(length(installed)) packages")
    
    if !isempty(installed)
        for pkg in installed
            println("  $(COLOR_GREEN)•$(COLOR_RESET) $pkg")
        end
    end
    
    println()
    
    if !isempty(failed)
        println("$(COLOR_RED)✗$(COLOR_RESET) Failed to install: $(length(failed)) packages")
        for pkg in failed
            println("  $(COLOR_RED)•$(COLOR_RESET) $pkg")
        end
        println()
        println("$(COLOR_YELLOW)[TIP]$(COLOR_RESET) Try installing failed packages manually:")
        println("  julia> using Pkg")
        for pkg in failed
            println("  julia> Pkg.add(\"$pkg\")")
        end
    end
    
    return isempty(failed)
end

"""
Verify package installations by trying to import them
"""
function verify_installations()
    println()
    println("=" ^ 50)
    println("Verifying Installations...")
    println("=" ^ 50)
    println()
    
    verified = String[]
    failed_verify = String[]
    
    for pkg in REQUIRED_PACKAGES
        # Skip Statistics as it's a standard library
        if pkg == "Statistics"
            continue
        end
        
        try
            # Try to import the package
            eval(Meta.parse("using $pkg"))
            
            # Try to get version
            version = ""
            try
                version = string(Pkg.dependencies()[findfirst(p -> p.second.name == pkg, Pkg.dependencies())].second.version)
            catch
                version = "unknown"
            end
            
            println("$(COLOR_GREEN)✓$(COLOR_RESET) $pkg (v$version)")
            push!(verified, pkg)
            
        catch e
            println("$(COLOR_RED)✗$(COLOR_RESET) $pkg - Import failed")
            push!(failed_verify, pkg)
        end
    end
    
    println()
    
    if isempty(failed_verify)
        println("$(COLOR_GREEN)[SUCCESS]$(COLOR_RESET) All packages verified successfully!")
        return true
    else
        println("$(COLOR_RED)[ERROR]$(COLOR_RESET) Some packages failed verification:")
        for pkg in failed_verify
            println("  $(COLOR_RED)•$(COLOR_RESET) $pkg")
        end
        return false
    end
end

"""
Generate project manifest
"""
function generate_manifest()
    println()
    println("$(COLOR_BLUE)[INFO]$(COLOR_RESET) Generating project manifest...")
    
    try
        Pkg.resolve()
        Pkg.instantiate()
        println("$(COLOR_GREEN)[SUCCESS]$(COLOR_RESET) Manifest.toml generated")
    catch e
        println("$(COLOR_YELLOW)[WARN]$(COLOR_RESET) Could not generate manifest: $e")
    end
end

"""
Main setup function
"""
function main()
    # Step 1: Clean registry
    clean_registry()
    
    # Step 2: Update registry
    if !update_registry()
        println("$(COLOR_RED)[FATAL]$(COLOR_RESET) Cannot proceed without package registry")
        println("$(COLOR_BLUE)[TIP]$(COLOR_RESET) Check your internet connection and try again")
        return 1
    end
    
    # Step 3: Activate project
    if !activate_project()
        println("$(COLOR_RED)[FATAL]$(COLOR_RESET) Cannot activate project environment")
        return 1
    end
    
    # Step 4: Install packages
    if !install_packages()
        println()
        println("$(COLOR_YELLOW)[WARN]$(COLOR_RESET) Setup completed with some failures")
        println("$(COLOR_BLUE)[TIP]$(COLOR_RESET) You may need to install failed packages manually")
    end
    
    # Step 5: Verify installations
    verify_installations()
    
    # Step 6: Generate manifest
    generate_manifest()
    
    println()
    println("=" ^ 50)
    println("$(COLOR_GREEN)[COMPLETE]$(COLOR_RESET) Setup finished!")
    println("=" ^ 50)
    println()
    println("Next steps:")
    println("  1. Run: julia src/generate_data.jl")
    println("  2. Run: julia src/main_simulation.jl")
    println()
    
    return 0
end

# Run main function
exit(main())

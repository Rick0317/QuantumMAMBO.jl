using PackageCompiler

# Create a system image with QuantumMAMBO pre-compiled
# This will significantly reduce startup and first-run times

println("Creating QuantumMAMBO system image...")

# List of packages to include
packages = [
    "QuantumMAMBO",
    "LinearAlgebra", 
    "SparseArrays",
    "HDF5",
    "Optim",
    "JuMP",
    "PythonCall"
]

# Precompilation script to run common operations
precompile_script = """
using QuantumMAMBO
using LinearAlgebra, SparseArrays

println("Precompiling QuantumMAMBO functions...")

try
    # Basic Hamiltonian operations
    H = QuantumMAMBO.PAULI_L1([1,2], [1.0,1.0], [1,1], [1,1], [1.0,1.0])
    
    # Load a test molecule if available
    if isfile("SAVED/lih.h5")
        filename = "SAVED/lih"
        H, η = QuantumMAMBO.SAVELOAD_HAM("lih", filename)
        
        # Run some common operations
        QuantumMAMBO.RUN_L1(H, η=η, DO_CSA=false, DO_DF=true, DO_ΔE=false, 
                           DO_AC=true, verbose=false, COUNT=true)
    end
    
    println("✓ QuantumMAMBO functions precompiled successfully")
catch e
    println("Warning during precompilation: ", e)
end
"""

# Write precompilation script to file
open("precompile_quantummambo.jl", "w") do f
    write(f, precompile_script)
end

# Create the system image
create_sysimage(
    packages,
    sysimage_path="QuantumMAMBO.so",
    precompile_execution_file="precompile_quantummambo.jl",
    project=".",
    cpu_target="generic"
)

println("System image created: QuantumMAMBO.so")
println("To use: julia --sysimage QuantumMAMBO.so") 
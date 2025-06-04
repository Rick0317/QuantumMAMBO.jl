# QuantumMAMBO.jl Docker Setup

This Docker setup provides a containerized environment for QuantumMAMBO.jl that eliminates dependency issues and provides consistent results across different platforms.

## Prerequisites

- Docker installed on your system
- Docker Compose (usually included with Docker Desktop)

## Two Performance Options

### Option 1: Standard Docker (Basic performance)
- Build time: ~10 minutes
- First run: 2-5 minutes (compilation time)
- Subsequent runs: 10-30 seconds

### Option 2: PackageCompiler System Image (Ultra-fast ⚡)
- Build time: ~20-30 minutes (one-time cost)
- **First run: 10-30 seconds (no compilation!)**
- Subsequent runs: 5-10 seconds

## Quick Start

### Standard Version

```bash
# Build the Docker image
docker compose build quantummambo

# Run calculation for LiH
docker compose run --rm quantummambo-calc lih

# Interactive mode
docker compose run --rm quantummambo
```

### ⚡ Ultra-Fast System Image Version (Recommended!)

```bash
# Build the optimized system image (one-time, ~20-30 min)
docker compose build quantummambo-fast

# Run LiH calculation instantly (no compilation wait!)
docker compose run --rm quantummambo-calc-fast lih

# Run LCU analysis instantly
docker compose run --rm quantummambo-lcu-fast lih

# Interactive mode with instant startup
docker compose run --rm quantummambo-fast
```

## Usage Examples

### L1 Norm Calculations
```bash
# Standard (with compilation wait)
docker compose run --rm quantummambo-calc lih

# Ultra-fast (no compilation)
docker compose run --rm quantummambo-calc-fast lih
```

### LCU Circuit Analysis
```bash
# Standard
docker compose run --rm quantummambo julia --project=. LCU.jl lih

# Ultra-fast
docker compose run --rm quantummambo-lcu-fast lih
```

### Custom Code Development

#### Option 1: Interactive Container
```bash
# Start ultra-fast interactive container
docker compose run --rm quantummambo-fast

# Inside container:
julia> using QuantumMAMBO  # Loads instantly!
julia> # Your custom code here
```

#### Option 2: Mount Custom Scripts
```bash
# Create your script: my_analysis.jl
echo 'using QuantumMAMBO; println("Custom analysis")' > my_analysis.jl

# Run with volume mount
docker compose run --rm -v $(pwd)/my_analysis.jl:/app/my_analysis.jl quantummambo-fast julia --sysimage QuantumMAMBO.so --project=. /app/my_analysis.jl
```

#### Option 3: Extend the Container
```bash
# Start container with custom mount
docker compose run --rm -v $(pwd):/host quantummambo-fast bash

# Inside container:
cp /host/my_script.jl ./
julia --sysimage QuantumMAMBO.so --project=. my_script.jl
```

## Performance Comparison

| Method | Startup Time | Build Time | Best For |
|--------|-------------|------------|----------|
| Standard Docker | 2-5 minutes | 10 minutes | Testing |
| System Image | **10-30 seconds** | 20-30 minutes | **Production** |
| Local Julia | Variable | N/A | Development |

## Directory Structure

- `SAVED/` - Persistent molecular data
- `results/` - Calculation outputs
- `src/` - QuantumMAMBO source code
- `*.jl` - Analysis scripts

## Available Molecules

The `SAVED/` directory contains pre-computed molecular data:
- `lih` - Lithium Hydride
- `h2` - Hydrogen molecule  
- `h4` - H4 chain
- `beh2` - Beryllium Hydride
- And more...

## Troubleshooting

### Build Issues
```bash
# Clean rebuild
docker compose down
docker compose build --no-cache quantummambo-fast
```

### Volume Issues
```bash
# Ensure directories exist
mkdir -p results SAVED
```

### Performance Issues
- First time using system image: ~30 seconds (normal)
- Subsequent runs should be <10 seconds
- If slow, check you're using the `-fast` services

## Advanced Usage

### Custom Molecules
```bash
# Add your molecule data to SAVED/
cp my_molecule.h5 SAVED/

# Run analysis
docker compose run --rm quantummambo-calc-fast my_molecule
```

### Jupyter Notebooks
```bash
# Start with Jupyter
docker compose run --rm -p 8888:8888 quantummambo-fast jupyter notebook --ip=0.0.0.0 --allow-root
```

### Development
```bash
# Mount source for development
docker compose run --rm -v $(pwd)/src:/app/src quantummambo-fast
```

## Why PackageCompiler?

PackageCompiler creates a "system image" that:
1. **Pre-compiles all Julia functions** - eliminates JIT compilation wait
2. **Reduces startup time** from minutes to seconds
3. **Includes optimized binary code** for your specific calculations
4. **Maintains full compatibility** with regular Julia

This is especially valuable for QuantumMAMBO because:
- Complex quantum chemistry calculations
- Heavy use of symbolic math
- Extensive Python interoperability
- Large dependency tree

## Next Steps

1. **Start with system image**: `docker compose build quantummambo-fast`
2. **Test with LiH**: `docker compose run --rm quantummambo-calc-fast lih`
3. **Develop interactively**: `docker compose run --rm quantummambo-fast`
4. **Scale to your molecules**: Add data to `SAVED/` directory

The one-time build investment pays off immediately with 10-50x faster startup times! 
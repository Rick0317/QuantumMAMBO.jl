# QuantumMAMBO Distribution Guide
## Sharing Pre-compiled Images to Eliminate Compilation Wait Times

### Option 1: Enhanced Docker Image with Pre-compilation

#### Build the optimized image:
```bash
# Build with enhanced pre-compilation
docker build -f Dockerfile.precompiled -t quantummambo:precompiled .

# Or with docker-compose, update docker-compose.yml to use Dockerfile.precompiled
docker compose build quantummambo
```

#### Share via Docker Hub/Registry:
```bash
# Tag and push to Docker Hub
docker tag quantummambo:precompiled yourusername/quantummambo:latest
docker push yourusername/quantummambo:latest

# Others can pull and use:
docker pull yourusername/quantummambo:latest
docker run -it yourusername/quantummambo:latest
```

### Option 2: System Image Approach (Most Effective)

#### Create a system image (do this once):
```bash
# Inside the container or with Julia locally
julia create_sysimage.jl
```

This creates `QuantumMAMBO.so` - a pre-compiled system image.

#### Modified Dockerfile with system image:
```dockerfile
# Add to Dockerfile after installing packages
COPY create_sysimage.jl .
RUN julia --project=. create_sysimage.jl

# Modify the run command to use the system image
CMD ["julia", "--sysimage", "QuantumMAMBO.so", "--project=.", "-e", "using QuantumMAMBO; println(\"Ready!\")"]
```

### Option 3: Multi-stage Docker Build

Create a optimized production image:

```dockerfile
# Build stage
FROM julia:1.10 as builder
WORKDIR /build
COPY . .
RUN julia --project=. -e "using Pkg; Pkg.instantiate(); Pkg.precompile()"
RUN julia --project=. create_sysimage.jl

# Production stage  
FROM julia:1.10
WORKDIR /app
COPY --from=builder /build/QuantumMAMBO.so .
COPY --from=builder /build /app
CMD ["julia", "--sysimage", "QuantumMAMBO.so", "--project=."]
```

### Option 4: GitHub Container Registry

#### Setup GitHub Actions (`.github/workflows/docker.yml`):
```yaml
name: Build and Push Docker Image
on:
  push:
    branches: [ main ]
    
jobs:
  build:
    runs-on: ubuntu-latest
    steps:
    - uses: actions/checkout@v3
    
    - name: Log in to GitHub Container Registry
      uses: docker/login-action@v2
      with:
        registry: ghcr.io
        username: ${{ github.actor }}
        password: ${{ secrets.GITHUB_TOKEN }}
    
    - name: Build and push
      uses: docker/build-push-action@v4
      with:
        context: .
        file: Dockerfile.precompiled
        push: true
        tags: ghcr.io/${{ github.repository }}:latest
```

#### Users can then pull:
```bash
docker pull ghcr.io/yourusername/quantummambo:latest
```

### Option 5: Local Cache Sharing

For teams working locally:

#### Save Docker image to file:
```bash
docker save quantummambo:precompiled > quantummambo-precompiled.tar
```

#### Load on another machine:
```bash
docker load < quantummambo-precompiled.tar
```

### Performance Comparison

| Method | First Run Time | Subsequent Runs | Image Size | Setup Effort |
|--------|---------------|-----------------|------------|--------------|
| Basic Docker | 5-10 minutes | 30 seconds | ~2GB | Low |
| Enhanced Pre-compilation | 2-3 minutes | 10 seconds | ~2.5GB | Medium |
| System Image | 30 seconds | 5 seconds | ~3GB | High |
| Multi-stage Build | 30 seconds | 5 seconds | ~2GB | High |

### Recommendations

1. **For Development**: Use enhanced pre-compilation Dockerfile
2. **For Production**: Use system image approach
3. **For Teams**: Use GitHub Container Registry or Docker Hub
4. **For Offline**: Use local cache sharing

### Quick Start for Users

```bash
# Pull pre-compiled image (once available)
docker pull yourusername/quantummambo:precompiled

# Run immediately without compilation wait
docker run -it yourusername/quantummambo:precompiled julia -e "using QuantumMAMBO"
```

### Building Your Own Optimized Image

```bash
# Clone repository
git clone https://github.com/yourusername/QuantumMAMBO.jl
cd QuantumMAMBO.jl

# Build optimized image
docker build -f Dockerfile.precompiled -t quantummambo:fast .

# Test immediate startup
docker run --rm quantummambo:fast julia -e "using QuantumMAMBO; println(\"Ready in seconds!\")"
``` 
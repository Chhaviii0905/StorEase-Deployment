# ===================== FRONTEND BUILD =====================
FROM node:18-alpine AS frontend-build
WORKDIR /app

# Install git
RUN apk add --no-cache git

# Clone frontend repository
RUN git clone https://github.com/Chhaviii0905/Inventory_Management_Portal.git .

# Install dependencies
RUN npm ci --no-audit --no-fund --progress=false

# Build Angular in PRODUCTION mode
RUN npm run build --configuration=production


# ===================== BACKEND BUILD =====================
FROM mcr.microsoft.com/dotnet/sdk:8.0 AS backend-build
WORKDIR /src

# Install git
RUN apk add --no-cache git

# Clone backend repository
RUN git clone https://github.com/Chhaviii0905/InventoryManagementSystemApis.git .

# Restore & publish
RUN dotnet restore
RUN dotnet publish -c Release -o /app/publish


# ===================== RUNTIME =====================
FROM mcr.microsoft.com/dotnet/aspnet:8.0-alpine
WORKDIR /app

# Copy backend published output
COPY --from=backend-build /app/publish .

# Copy Angular build output into wwwroot
COPY --from=frontend-build /app/dist/inventory-management-ui/browser ./wwwroot

# Expose HTTP port
EXPOSE 80

# Start backend
ENTRYPOINT ["dotnet", "InventoryManagementSystem.dll"]

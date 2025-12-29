# ===================== FRONTEND BUILD =====================
FROM node:18-alpine AS frontend-build
WORKDIR /app

# Copy frontend source
COPY Inventory_Management_Portal/ .

# Install dependencies and build
RUN npm ci --no-audit --no-fund --progress=false
RUN npm run build --configuration=production

# ===================== BACKEND BUILD =====================
FROM mcr.microsoft.com/dotnet/sdk:8.0 AS backend-build
WORKDIR /src

# Copy backend source
COPY InventoryManagementSystemApis/ .

# Restore & publish
RUN dotnet restore
RUN dotnet publish -c Release -o /app/publish

# ===================== RUNTIME =====================
FROM mcr.microsoft.com/dotnet/aspnet:8.0
WORKDIR /app

# Copy backend published output
COPY --from=backend-build /app/publish .

# Copy Angular build output into wwwroot
COPY --from=frontend-build /app/dist/inventory-management-ui/browser ./wwwroot

# Expose HTTP port
EXPOSE 80

# Start backend
ENTRYPOINT ["dotnet", "InventoryManagementSystem.dll"]

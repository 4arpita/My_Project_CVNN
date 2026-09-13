FROM node:22-alpine AS build
WORKDIR /app
COPY package*.json ./
RUN npm install
COPY . .
ARG VITE_API_URL=http://localhost:8080/api
ARG VITE_OSM_TILE_URL=https://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png
ARG VITE_OSRM_URL=https://router.project-osrm.org
ENV VITE_API_URL=$VITE_API_URL
ENV VITE_OSM_TILE_URL=$VITE_OSM_TILE_URL
ENV VITE_OSRM_URL=$VITE_OSRM_URL
RUN npm run build

FROM nginx:alpine
COPY nginx.conf /etc/nginx/conf.d/default.conf
COPY --from=build /app/dist /usr/share/nginx/html
EXPOSE 80

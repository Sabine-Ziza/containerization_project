
# Backend dependencies

FROM node:20-alpine AS backend-deps

WORKDIR /app

RUN apk add --no-cache python3 make g++

COPY backend/package*.json ./

RUN npm install --ignore-scripts=false

# Backend development

FROM backend-deps AS backend-dev

WORKDIR /app

COPY backend .

EXPOSE 3000

CMD ["node", "src/index.js"]

# Backend tests

FROM backend-deps AS test

WORKDIR /app

COPY backend .

RUN npm test


# =========================
# Frontend development
# =========================

FROM node:20-alpine AS frontend-dev

WORKDIR /client

COPY client/package*.json ./

RUN npm install

COPY client .

EXPOSE 3000

CMD ["npm", "run", "dev", "--", "--host", "0.0.0.0"]


# =========================
# Frontend production build
# =========================

FROM node:20-alpine AS frontend-build

WORKDIR /client

COPY client/package*.json ./

RUN npm install

COPY client .

RUN npm run build


# =========================
# Final production image
# =========================

FROM node:20-alpine AS final

WORKDIR /app

RUN apk add --no-cache python3 make g++

COPY backend/package*.json ./

RUN npm install --omit=dev --ignore-scripts=false

COPY backend .

COPY --from=frontend-build /client/dist ./src/static

EXPOSE 3000

CMD ["node", "src/index.js"]
## Step 1. Install dependencies only when needed
# Use base image as node lts alpine.
FROM node:18-alpine as deps

# create & set working directory
WORKDIR /app

# Check https://github.com/nodejs/docker-node/tree/b4117f9333da4138b03a546ec926ef50a31506c3#nodealpine to understand why libc6-compat might be needed.
RUN apk add --no-cache libc6-compat

#copy package.json and lock file for using npm
COPY package.json package-lock.json ./
RUN npm ci


## Step 2. Rebuild the source code only when needed
FROM node:18-alpine as builder
WORKDIR /app
COPY --from=deps /app/node_modules ./node_modules
COPY . .

RUN npm run build

## Step 3. Production image, copy all the files and run next
FROM node:18-alpine AS runner
WORKDIR /app

COPY --from=deps /app/node_modules ./node_modules
COPY --from=builder /app/dist ./dist
RUN addgroup --system --gid 1001 nodejs && adduser --system --uid 1001 nest

# Setting ENVS
# Check .env for more detail.
# ARGS for ENV injecting.
ARG ARG_MYSQL_HOST
ARG ARG_MYSQL_PORT
ARG ARG_MYSQL_USERNAME
ARG ARG_MYSQL_PASSWORD
ARG ARG_MYSQL_DATABASE
ARG ARG_SMS_API_KEY
ARG ARG_SMS_SEND_PHONE_NUMBER
ARG ARG_SMS_SEND_ACCOUNT
ARG ARG_JWT_SEC_KEY
ARG ARG_AWS_ACCESS_KEY
ARG ARG_AWS_SECRET_ACCESS_KEY
ARG ARG_AWS_REGION
ARG ARG_AWS_S3_BUCKET_NAME
ARG ARG_REDIS_HOST
ARG ARG_REDIS_PORT
ARG ARG_NODEMAILER_USER
ARG ARG_NODEMAILER_PASS

# MYSQL
ENV MYSQL_HOST=$ARG_MYSQL_HOST
ENV MYSQL_PORT=$ARG_MYSQL_PORT
ENV MYSQL_USERNAME=$ARG_MYSQL_USERNAME
ENV MYSQL_PASSWORD=$ARG_MYSQL_PASSWORD
ENV MYSQL_DATABASE=$ARG_MYSQL_DATABASE
ENV SMS_API_KEY=$ARG_SMS_API_KEY
ENV SMS_SEND_PHONE_NUMBER=$ARG_SMS_SEND_PHONE_NUMBER
ENV SMS_SEND_ACCOUNT=$ARG_SMS_SEND_ACCOUNT
ENV JWT_SEC_KEY=$ARG_JWT_SEC_KEY
ENV AWS_ACCESS_KEY=$ARG_AWS_ACCESS_KEY
ENV AWS_SECRET_ACCESS_KEY=$ARG_AWS_SECRET_ACCESS_KEY
ENV AWS_REGION=$ARG_AWS_REGION
ENV AWS_S3_BUCKET_NAME=$ARG_AWS_S3_BUCKET_NAME
ENV REDIS_HOST=$ARG_REDIS_HOST
ENV REDIS_PORT=$ARG_REDIS_PORT
ENV NODEMAILER_USER=$ARG_NODEMAILER_USER
ENV NODEMAILER_PASS=$ARG_NODEMAILER_PASS

ENV NODE_ENV prod

USER nest

EXPOSE 9090

ENV PORT 9090

CMD ["node", "dist/main"]

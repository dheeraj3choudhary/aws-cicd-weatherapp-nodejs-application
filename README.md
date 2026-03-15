# weather-application

Node.js weather application deployed to AWS EC2 via CI/CD pipeline. This repository contains the application code, Dockerfile, and deployment configuration.

---

## Repository Structure

```
weather-application/
├── index.js
├── package.json
├── Dockerfile
├── buildspec.yml
├── appspec.yml
├── public/
│   └── index.html
├── __tests__/
│   └── app.test.js
├── scripts/
│   ├── before_install.sh
│   ├── after_install.sh
│   ├── application_start.sh
│   └── validate_service.sh
└── README.md
```

---

## Prerequisites

Before pushing code make sure the following are already done:

- `weather-app-infra` repo has been set up and infra pipeline has run successfully
- All CloudFormation stacks are in `CREATE_COMPLETE` state
- EC2 instance is running with CodeDeploy agent installed
- ECR repository `weather-app` exists
- SSM parameter `/weather-app/api-key` exists in Parameter Store as SecureString

> If any of the above are missing go to the [weather-app-infra](https://github.com/your-username/weather-app-infra) repository first.

---

## How It Works

```
Push to main branch
        ↓
App pipeline triggers automatically
        ↓
CodeBuild — install deps, run tests, build Docker image, push to ECR
        ↓
CodeDeploy — pull image from ECR, run container on EC2
        ↓
App is live on EC2 public IP
```

---

## Pipeline Stages

### Build Stage (CodeBuild)
- Installs Node.js dependencies
- Runs Jest unit tests — pipeline fails if any test fails
- Builds Docker image
- Pushes image to ECR with commit SHA tag and `latest` tag

### Deploy Stage (CodeDeploy)
Uses lifecycle hooks to deploy the Docker container:

| Hook | Script | What it does |
|------|--------|-------------|
| BeforeInstall | `before_install.sh` | Stops existing container, cleans up old images |
| AfterInstall | `after_install.sh` | Logs into ECR, pulls latest image |
| ApplicationStart | `application_start.sh` | Fetches API key from SSM, runs Docker container |
| ValidateService | `validate_service.sh` | Health check on `/health` endpoint |

---

## App Endpoints

| Endpoint | Method | Description |
|----------|--------|-------------|
| `/` | GET | Frontend UI |
| `/health` | GET | Health check — returns `{ status: "healthy" }` |
| `/weather?city=London` | GET | Returns weather data for given city |

---

## Running Locally

```bash
# Install dependencies
npm install

# Set environment variable
export WEATHER_API_KEY=your-api-key-here

# Start app
npm start

# Run tests
npm test
```

App will be available at `http://localhost:3000`

---

## Deploying

Simply push to `main` branch:

```bash
git add .
git commit -m "your commit message"
git push origin main
```

Pipeline triggers automatically. Monitor progress in AWS Console → CodePipeline → `weather-app-pipeline`.

---

## Verifying Deployment

Once pipeline completes:

1. Go to AWS Console → EC2 → Instances
2. Copy the Public IP of `weather-app-ec2`
3. Open `http://<public-ip>:3000` in browser

Or run a quick health check:

```bash
curl http://<public-ip>:3000/health
```

Expected response:
```json
{ "status": "healthy" }
```

---

## Tech Stack

| Tool | Purpose |
|------|---------|
| Node.js + Express | Backend API |
| HTML/CSS/JS | Frontend |
| Docker | Containerization |
| AWS CodePipeline | Pipeline orchestration |
| AWS CodeBuild | Build and test |
| AWS CodeDeploy | Deployment to EC2 |
| AWS ECR | Docker image registry |
| AWS SSM Parameter Store | API key management |
| OpenWeatherMap API | Weather data |
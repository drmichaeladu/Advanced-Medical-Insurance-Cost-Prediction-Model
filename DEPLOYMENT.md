# Deployment Guide

This guide provides step-by-step instructions for deploying the Medical Insurance Cost Prediction application to various platforms.

## 📋 Pre-Deployment Checklist

Before deploying, ensure:

- [ ] All code is committed and pushed to repository
- [ ] Health check passes: `Rscript health_check.R`
- [ ] All tests pass: `Rscript tests/test_application.R`
- [ ] README.md is up to date
- [ ] version.R reflects current version
- [ ] Models are in the `models/` directory
- [ ] Configuration is properly set in `config.R`
- [ ] .gitignore excludes sensitive files
- [ ] Dependencies are documented in requirements.txt

## 🐳 Docker Deployment (Recommended)

### Prerequisites
- Docker installed ([Install Docker](https://docs.docker.com/get-docker/))
- Docker Compose installed (usually included with Docker Desktop)

### Quick Start
```bash
# Clone the repository
git clone https://github.com/drmichaeladu/Advanced-Medical-Insurance-Cost-Prediction-Model.git
cd Advanced-Medical-Insurance-Cost-Prediction-Model

# Build and start the application
docker-compose up -d

# View logs
docker-compose logs -f

# Access the application
# Open browser to http://localhost:3838
```

### Manual Docker Build
```bash
# Build the image
docker build -t insurance-predictor:latest .

# Run the container
docker run -d \
  --name insurance-app \
  -p 3838:3838 \
  -v $(pwd)/logs:/srv/shiny-server/insurance-predictor/logs \
  insurance-predictor:latest

# Check status
docker ps

# View logs
docker logs -f insurance-app

# Stop the container
docker stop insurance-app

# Remove the container
docker rm insurance-app
```

### Docker Production Configuration

For production, create a `docker-compose.prod.yml`:

```yaml
version: '3.8'

services:
  app:
    image: insurance-predictor:latest
    container_name: insurance-predictor-prod
    ports:
      - "80:3838"
    volumes:
      - ./logs:/srv/shiny-server/insurance-predictor/logs
      - ./models:/srv/shiny-server/insurance-predictor/models:ro
    environment:
      - SHINY_LOG_LEVEL=WARN
      - TZ=America/New_York
    restart: always
    healthcheck:
      test: ["CMD", "curl", "-f", "http://localhost:3838"]
      interval: 30s
      timeout: 10s
      retries: 3
      start_period: 40s
    deploy:
      resources:
        limits:
          cpus: '2'
          memory: 4G
        reservations:
          cpus: '1'
          memory: 2G

  # Optional: Add nginx reverse proxy
  nginx:
    image: nginx:alpine
    container_name: insurance-nginx
    ports:
      - "443:443"
      - "80:80"
    volumes:
      - ./nginx.conf:/etc/nginx/nginx.conf:ro
      - ./ssl:/etc/nginx/ssl:ro
    depends_on:
      - app
    restart: always
```

Deploy with:
```bash
docker-compose -f docker-compose.prod.yml up -d
```

## ☁️ Cloud Platform Deployment

### AWS EC2

#### 1. Launch EC2 Instance
```bash
# Use Amazon Linux 2 or Ubuntu 20.04
# Recommended: t2.medium or larger (2 vCPU, 4GB RAM)
# Open port 3838 in security group
```

#### 2. Install Dependencies
```bash
# SSH into instance
ssh -i your-key.pem ec2-user@your-instance-ip

# Install Docker
sudo yum update -y
sudo yum install docker -y
sudo service docker start
sudo usermod -a -G docker ec2-user

# Install Docker Compose
sudo curl -L "https://github.com/docker/compose/releases/download/v2.20.0/docker-compose-$(uname -s)-$(uname -m)" -o /usr/local/bin/docker-compose
sudo chmod +x /usr/local/bin/docker-compose
```

#### 3. Deploy Application
```bash
# Clone repository
git clone https://github.com/drmichaeladu/Advanced-Medical-Insurance-Cost-Prediction-Model.git
cd Advanced-Medical-Insurance-Cost-Prediction-Model

# Start with Docker Compose
docker-compose up -d

# Access at http://your-instance-ip:3838
```

#### 4. Setup Auto-restart
```bash
# Create systemd service
sudo nano /etc/systemd/system/insurance-app.service
```

Add:
```ini
[Unit]
Description=Insurance Predictor App
Requires=docker.service
After=docker.service

[Service]
Type=oneshot
RemainAfterExit=yes
WorkingDirectory=/home/ec2-user/Advanced-Medical-Insurance-Cost-Prediction-Model
ExecStart=/usr/local/bin/docker-compose up -d
ExecStop=/usr/local/bin/docker-compose down
User=ec2-user

[Install]
WantedBy=multi-user.target
```

Enable and start:
```bash
sudo systemctl enable insurance-app
sudo systemctl start insurance-app
sudo systemctl status insurance-app
```

### Google Cloud Platform (GCP)

#### Using Cloud Run
```bash
# Install gcloud CLI
# Authenticate
gcloud auth login

# Set project
gcloud config set project YOUR_PROJECT_ID

# Build and push to Container Registry
gcloud builds submit --tag gcr.io/YOUR_PROJECT_ID/insurance-predictor

# Deploy to Cloud Run
gcloud run deploy insurance-predictor \
  --image gcr.io/YOUR_PROJECT_ID/insurance-predictor \
  --platform managed \
  --region us-central1 \
  --allow-unauthenticated \
  --memory 4Gi \
  --cpu 2 \
  --port 3838
```

### Microsoft Azure

#### Using Azure Container Instances
```bash
# Install Azure CLI and login
az login

# Create resource group
az group create --name insurance-app-rg --location eastus

# Create container
az container create \
  --resource-group insurance-app-rg \
  --name insurance-predictor \
  --image insurance-predictor:latest \
  --dns-name-label insurance-predictor-unique \
  --ports 3838 \
  --cpu 2 \
  --memory 4

# Get URL
az container show \
  --resource-group insurance-app-rg \
  --name insurance-predictor \
  --query ipAddress.fqdn
```

## 📱 Shinyapps.io Deployment

### Prerequisites
```R
install.packages("rsconnect")
```

### Setup Account
```R
library(rsconnect)

# Get token from https://www.shinyapps.io/admin/#/tokens
rsconnect::setAccountInfo(
  name="your-account-name",
  token="your-token",
  secret="your-secret"
)
```

### Deploy
```R
# Deploy the application
rsconnect::deployApp(
  appName = "insurance-cost-predictor",
  appTitle = "Medical Insurance Cost Predictor",
  account = "your-account-name",
  appFiles = c(
    "app.R",
    "config.R",
    "version.R",
    "R/",
    "utils/",
    "models/"
  )
)
```

### Update Deployment
```R
# Redeploy after changes
rsconnect::deployApp(
  appName = "insurance-cost-predictor",
  forceUpdate = TRUE
)
```

## 🔧 RStudio Connect

### Prerequisites
- RStudio Connect server
- rsconnect package

### Deploy
```R
library(rsconnect)

# Configure server
rsconnect::addServer(
  url = "https://your-connect-server.com",
  name = "your-server-name"
)

# Connect to server
rsconnect::connectUser(
  account = "your-username",
  server = "your-server-name"
)

# Deploy
rsconnect::deployApp(
  server = "your-server-name",
  appName = "insurance-predictor"
)
```

## 🌐 Nginx Reverse Proxy Setup

For production deployments, use Nginx as a reverse proxy:

### nginx.conf
```nginx
events {
    worker_connections 1024;
}

http {
    upstream shiny {
        server app:3838;
    }

    server {
        listen 80;
        server_name your-domain.com;

        # Redirect HTTP to HTTPS
        return 301 https://$server_name$request_uri;
    }

    server {
        listen 443 ssl http2;
        server_name your-domain.com;

        ssl_certificate /etc/nginx/ssl/cert.pem;
        ssl_certificate_key /etc/nginx/ssl/key.pem;

        # Security headers
        add_header X-Frame-Options "SAMEORIGIN" always;
        add_header X-Content-Type-Options "nosniff" always;
        add_header X-XSS-Protection "1; mode=block" always;

        location / {
            proxy_pass http://shiny;
            proxy_redirect off;
            proxy_http_version 1.1;
            
            # WebSocket support
            proxy_set_header Upgrade $http_upgrade;
            proxy_set_header Connection "upgrade";
            
            # Headers
            proxy_set_header Host $host;
            proxy_set_header X-Real-IP $remote_addr;
            proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
            proxy_set_header X-Forwarded-Proto $scheme;

            # Timeouts
            proxy_read_timeout 600s;
            proxy_connect_timeout 600s;
            proxy_send_timeout 600s;
        }
    }
}
```

## 📊 Monitoring and Logging

### CloudWatch (AWS)
```bash
# Install CloudWatch agent
sudo yum install amazon-cloudwatch-agent

# Configure logs
sudo /opt/aws/amazon-cloudwatch-agent/bin/amazon-cloudwatch-agent-ctl \
  -a fetch-config \
  -m ec2 \
  -s \
  -c file:/opt/aws/amazon-cloudwatch-agent/etc/config.json
```

### Application Monitoring
```R
# Add to app.R for monitoring
library(googleAnalyticsR)
# Or use custom monitoring solution
```

## 🔄 CI/CD Pipeline

### GitHub Actions Example

Create `.github/workflows/deploy.yml`:

```yaml
name: Deploy to Production

on:
  push:
    branches: [ main ]
    tags: [ 'v*' ]

jobs:
  deploy:
    runs-on: ubuntu-latest
    
    steps:
    - uses: actions/checkout@v3
    
    - name: Set up Docker Buildx
      uses: docker/setup-buildx-action@v2
    
    - name: Login to Docker Hub
      uses: docker/login-action@v2
      with:
        username: ${{ secrets.DOCKER_USERNAME }}
        password: ${{ secrets.DOCKER_PASSWORD }}
    
    - name: Build and push
      uses: docker/build-push-action@v4
      with:
        context: .
        push: true
        tags: |
          username/insurance-predictor:latest
          username/insurance-predictor:${{ github.sha }}
    
    - name: Deploy to production
      uses: appleboy/ssh-action@master
      with:
        host: ${{ secrets.SERVER_HOST }}
        username: ${{ secrets.SERVER_USER }}
        key: ${{ secrets.SSH_PRIVATE_KEY }}
        script: |
          cd ~/Advanced-Medical-Insurance-Cost-Prediction-Model
          git pull
          docker-compose pull
          docker-compose up -d
```

## 🔐 SSL/TLS Certificate Setup

### Using Let's Encrypt (Free)
```bash
# Install certbot
sudo yum install certbot python3-certbot-nginx

# Get certificate
sudo certbot --nginx -d your-domain.com

# Auto-renewal (added to cron)
sudo certbot renew --dry-run
```

## 🧪 Smoke Testing After Deployment

```bash
# Health check
curl -f http://your-domain.com:3838 || echo "Health check failed"

# Check specific endpoint
curl -s http://your-domain.com:3838 | grep "Medical Insurance"

# Load test (optional)
ab -n 100 -c 10 http://your-domain.com:3838/
```

## 📞 Support

For deployment issues:
- Email: mikekay262@gmail.com
- GitHub Issues: [Create an issue](https://github.com/drmichaeladu/Advanced-Medical-Insurance-Cost-Prediction-Model/issues)
- LinkedIn: [Dr. Michael Adu](https://www.linkedin.com/in/drmichael-adu)

## 📚 Additional Resources

- [Shiny Deployment Guide](https://shiny.rstudio.com/articles/deployment.html)
- [Docker Documentation](https://docs.docker.com/)
- [AWS EC2 Documentation](https://docs.aws.amazon.com/ec2/)
- [Google Cloud Run](https://cloud.google.com/run/docs)
- [Azure Container Instances](https://docs.microsoft.com/azure/container-instances/)

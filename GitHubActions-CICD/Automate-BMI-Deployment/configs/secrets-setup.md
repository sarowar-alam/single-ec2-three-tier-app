# GitHub Secrets Setup Guide

This guide explains how to configure GitHub Secrets for automated deployment to AWS EC2.

---

## 🔐 What Are GitHub Secrets?

- Encrypted environment variables
- Stored securely in GitHub
- Never exposed in logs
- Used in workflows as `${{ secrets.NAME }}`

---

## 📋 Secrets Required for Deployment

| Secret Name | Description | Example |
|-------------|-------------|---------|
| `EC2_HOST` | Your EC2 public IP or domain | `3.15.123.45` |
| `EC2_USERNAME` | SSH username (usually ubuntu) | `ubuntu` |
| `EC2_SSH_KEY` | Private SSH key for EC2 | Full RSA private key |
| `EC2_PORT` | SSH port (usually 22) | `22` |

---

## 🚀 Step-by-Step Setup

### **Step 1: Get Your EC2 SSH Private Key**

If you have the key file (e.g., `my-key.pem`):

```bash
# Display the private key
cat my-key.pem
```

**Copy the entire output** including:
```
-----BEGIN RSA PRIVATE KEY-----
...entire key content...
-----END RSA PRIVATE KEY-----
```

---

### **Step 2: Add Secrets to GitHub**

1. Go to your GitHub repository
2. Click **Settings** tab
3. In left sidebar: **Secrets and variables** → **Actions**
4. Click **New repository secret**

---

### **Secret 1: EC2_HOST**

- **Name:** `EC2_HOST`
- **Value:** Your EC2 public IP address
  ```
  3.15.123.45
  ```
- Click **Add secret**

**To find your EC2 IP:**
- AWS Console → EC2 → Instances → Select your instance
- Copy "Public IPv4 address"

---

### **Secret 2: EC2_USERNAME**

- **Name:** `EC2_USERNAME`
- **Value:** `ubuntu`
- Click **Add secret**

**Note:** For Amazon Linux AMIs, use `ec2-user` instead

---

### **Secret 3: EC2_SSH_KEY**

- **Name:** `EC2_SSH_KEY`
- **Value:** Paste your entire private key
  ```
  -----BEGIN RSA PRIVATE KEY-----
  MIIEpAIBAAKCAQEA1234567890...
  ...entire key content...
  ...no extra spaces or line breaks...
  -----END RSA PRIVATE KEY-----
  ```
- Click **Add secret**

**⚠️ Important:**
- Include `-----BEGIN` and `-----END` lines
- No extra spaces at beginning or end
- No line break at the end
- Copy entire key content

---

### **Secret 4: EC2_PORT** (Optional)

- **Name:** `EC2_PORT`
- **Value:** `22`
- Click **Add secret**

---

## ✅ Verify Secrets Are Added

You should see 4 secrets listed:
- ✅ EC2_HOST
- ✅ EC2_USERNAME
- ✅ EC2_SSH_KEY
- ✅ EC2_PORT

**Note:** You can't view secret values after adding them (security feature)

---

## 🧪 Test SSH Connection Manually

Before using in workflow, test SSH works:

```bash
# Replace with your actual values
ssh -i your-key.pem ubuntu@YOUR_EC2_IP

# If successful, you should be logged into EC2
# Type 'exit' to logout
```

**If this fails, GitHub Actions will also fail!**

---

## 🐛 Troubleshooting

### **Error: "Permission denied (publickey)"**

**Causes:**
1. Wrong private key
2. Missing `-----BEGIN` or `-----END` lines
3. Extra spaces or formatting issues
4. Key doesn't match EC2 instance

**Solutions:**
1. Re-copy the key carefully
2. Ensure entire key is copied
3. Test SSH manually first
4. Regenerate key pair if needed

---

### **Error: "Host key verification failed"**

**Solution:** Add to workflow:
```yaml
- uses: appleboy/ssh-action@v1.0.0
  with:
    host: ${{ secrets.EC2_HOST }}
    username: ${{ secrets.EC2_USERNAME }}
    key: ${{ secrets.EC2_SSH_KEY }}
    port: 22
    script_stop: true
```

The action handles host key verification automatically.

---

### **Error: "Bad decrypt" or "Invalid format"**

**Cause:** Key format issue

**Solution:**
1. Ensure key is RSA format
2. If ED25519 key, convert to RSA:
   ```bash
   ssh-keygen -t rsa -b 4096 -f new-key
   ```
3. Update EC2 instance with new public key

---

## 🔒 Security Best Practices

### **✅ Do:**
- Use secrets for all sensitive data
- Rotate keys periodically
- Limit EC2 security group to GitHub IPs (optional)
- Use principle of least privilege
- Delete secrets when no longer needed

### **❌ Don't:**
- Commit secrets to repository
- Share secrets publicly
- Use same key for multiple projects
- Echo secrets in workflow logs
- Store secrets in code comments

---

## 🎯 Using Secrets in Workflows

```yaml
jobs:
  deploy:
    runs-on: ubuntu-latest
    steps:
      - name: Deploy via SSH
        uses: appleboy/ssh-action@v1.0.0
        with:
          host: ${{ secrets.EC2_HOST }}
          username: ${{ secrets.EC2_USERNAME }}
          key: ${{ secrets.EC2_SSH_KEY }}
          port: ${{ secrets.EC2_PORT }}
          script: |
            echo "Deploying..."
```

**Secrets are automatically masked in logs!**

---

## 📝 Checklist

Before running your deployment workflow:

- [ ] EC2 instance is running
- [ ] Can SSH manually: `ssh -i key.pem ubuntu@EC2_IP`
- [ ] All 4 secrets added to GitHub
- [ ] SSH key includes BEGIN/END lines
- [ ] No extra spaces in secrets
- [ ] EC2 security group allows SSH (port 22)
- [ ] Deployment script exists on EC2

---

## 🆘 Still Having Issues?

1. **Test SSH manually** - If this fails, fix it first
2. **Check EC2 security group** - Ensure port 22 is open
3. **Verify key format** - Must be valid RSA private key
4. **Check logs** - GitHub Actions shows detailed errors
5. **Ask for help** - Instructor or course forum

---

**Next:** [Create Deployment Workflow](../workflows/deploy.yml)

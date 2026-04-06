# Python Executor Setup for n8n

## Architecture

- **n8n** (Port 5550): Orchestrator/UI - sends requests to task-runners
- **n8n-task-runners**: Executes JavaScript/n8n nodes via Redis queue
- **python-executor** (Port 5000): External Python code executor service

## How to Execute Python in n8n Workflows

### Method 1: Using n8n HTTP Request Node (Recommended)

1. Add an **HTTP Request** node to your workflow
2. Configure it as follows:
   - **URL**: `http://python-executor:5000/execute`
   - **Method**: POST
   - **Content-Type**: application/json
   - **Body**:
   ```json
   {
     "code": "print('Hello Python'); import pandas as pd; df = pd.DataFrame({'a': [1,2,3]}); print(df)"
   }
   ```

3. The response will be:
   ```json
   {
     "stdout": "Hello Python\n   a\n0  1\n1  2\n2  3",
     "stderr": "",
     "returncode": 0
   }
   ```

### Method 2: Using n8n Function Node (Advanced)

In an **Execute Code** node, use JavaScript to call the Python executor:

```javascript
const response = await fetch('http://python-executor:5000/execute', {
  method: 'POST',
  headers: { 'Content-Type': 'application/json' },
  body: JSON.stringify({
    code: "import json; print(json.dumps({'result': 42}))"
  })
});

const result = await response.json();
return { pythonOutput: result };
```

### Method 3: Docker Compose Environment Variable

If you need to make the Python executor available to other services, update your workflow:

```yaml
# In docker-compose.yml, python-executor is already configured to run
# and accessible at http://python-executor:5000 from any container on the n8n-network
```

## Testing the Python Executor

Test with this HTTP Request in n8n:

**Test 1: Simple Print**
```
POST http://python-executor:5000/execute
Body: {"code": "print('It works!')"}
```

**Test 2: Using Libraries (pandas, numpy, etc.)**
```
POST http://python-executor:5000/execute
Body: {"code": "import numpy as np; x = np.array([1,2,3]); print(x.sum())"}
```

**Test 3: Health Check**
```
GET http://python-executor:5000/health
```

## Installing Additional Python Packages

To add more Python packages to the executor:

1. Edit `Dockerfile.python-executor`
2. Add to the pip install line:
   ```dockerfile
   RUN pip install --no-cache-dir flask pandas numpy scipy scikit-learn matplotlib
   ```
3. Rebuild: `docker compose build python-executor`
4. Restart: `docker compose up -d python-executor`

## Current Installed Packages

- flask (web server)
- Python standard library
- Subprocess support for external executables

## Limitations

- Code execution timeout: 30 seconds
- No file persistence between calls (each execution is isolated)
- No direct access to n8n workflow variables (pass via request body)
- Code runs in a subprocess (not in-process)

## Troubleshooting

- **Connection refused**: Ensure `python-executor` container is running: `docker ps | grep python-executor`
- **Timeout**: Python code took > 30 seconds, increase timeout in app.py if needed
- **Import errors**: Package not installed, add to Dockerfile.python-executor and rebuild
- **Network issues**: Ensure both n8n-task-runners and python-executor are on the same network (`n8n-network`)

require('dotenv').config({ path: 'idp-backstage/packages/backend/.env' });

async function run() {
  const token = process.env.AZURE_TOKEN;
  const authHeader = `Basic ${Buffer.from(':' + token).toString('base64')}`;
  const baseUrl = `https://dev.azure.com/ymi0337/IDP-MIC/_apis/pipelines`;

  // Get pipelines
  const getResp = await fetch(`${baseUrl}?api-version=7.1-preview.1`, {
    headers: { Authorization: authHeader },
  });
  const data = await getResp.json();
  const pipeline = data.value.find(p => p.name === 'pipeline-resource-group-rggg');
  
  if (!pipeline) {
    console.log("Pipeline not found");
    return;
  }

  console.log(`Found pipeline ${pipeline.name} with ID ${pipeline.id}`);

  // Run pipeline
  const runResp = await fetch(`${baseUrl}/${pipeline.id}/runs?api-version=7.1-preview.1`, {
    method: 'POST',
    headers: { Authorization: authHeader, 'Content-Type': 'application/json' },
    body: JSON.stringify({
      previewRun: false,
      resources: {
        repositories: {
          self: {
            refName: "refs/heads/main"
          }
        }
      },
      templateParameters: {
        action: "destroy"
      }
    }),
  });

  if (!runResp.ok) {
    console.log("Error:", await runResp.text());
    return;
  }

  const runData = await runResp.json();
  console.log(`Run started: ${runData._links.web.href}`);
  console.log("Run variables/parameters:", runData.templateParameters);
}

run();

import { createTemplateAction, scaffolderActionsExtensionPoint } from '@backstage/plugin-scaffolder-node';
import { createBackendModule } from '@backstage/backend-plugin-api';
import fetch from 'node-fetch';

export const adoPipelineModule = createBackendModule({
  pluginId: 'scaffolder',
  moduleId: 'ado-pipeline',
  register(reg) {
    reg.registerInit({
      deps: { scaffolder: scaffolderActionsExtensionPoint },
      async init({ scaffolder }) {
        scaffolder.addActions(
          createTemplateAction({
            id: 'ado:pipeline:run',
            schema: {
              input: (z) => z.object({
                organization: z.string(),
                project: z.string(),
                repo: z.string(),
                pipelineName: z.string(),
                yamlPath: z.string(),
                templateParameters: z.record(z.string()).optional(),
              }),
              output: (z) => z.object({
                pipelineRunUrl: z.string(),
                pipelineId: z.string(),
              }),
            },
            async handler(ctx) {
              const { organization, project, repo, pipelineName, yamlPath, templateParameters } = ctx.input;
              ctx.logger.info(`Starting ADO Pipeline Automation for ${pipelineName}`);

              const token = process.env.AZURE_TOKEN;
              if (!token) {
                throw new Error("AZURE_TOKEN environment variable is missing.");
              }

              const baseUrl = `https://dev.azure.com/${organization}/${project}/_apis/pipelines`;
              const authHeader = `Basic ${Buffer.from(':' + token).toString('base64')}`;

              // Get Repository Info
              ctx.logger.info(`Fetching repository info for ${repo}...`);
              const repoUrl = `https://dev.azure.com/${organization}/${project}/_apis/git/repositories/${repo}?api-version=7.1`;
              const repoResp = await fetch(repoUrl, {
                headers: { Authorization: authHeader },
              });
              if (!repoResp.ok) {
                  const errText = await repoResp.text();
                  throw new Error(`Failed to get repository info for ${repo}: ${errText}`);
              }
              const repoData = await repoResp.json() as any;
              const repoId = repoData.id;

              // 1. Get existing pipelines
              const getResp = await fetch(`${baseUrl}?api-version=7.1-preview.1`, {
                headers: { Authorization: authHeader },
              });
              if (!getResp.ok) throw new Error(`Failed to list pipelines: ${getResp.statusText}`);
              const data = await getResp.json() as any;

              let pipelineId = data.value?.find((p: any) => p.name === pipelineName)?.id;

              // 2. Create if not exists
              if (!pipelineId) {
                ctx.logger.info(`Pipeline NOT found. Creating Pipeline: ${pipelineName}...`);
                const createResp = await fetch(`${baseUrl}?api-version=7.1-preview.1`, {
                  method: 'POST',
                  headers: { Authorization: authHeader, 'Content-Type': 'application/json' },
                  body: JSON.stringify({
                    name: pipelineName,
                    folder: '\\',
                    configuration: {
                      type: 'yaml',
                      path: yamlPath,
                      repository: {
                        id: repoId,
                        type: 'azureReposGit',
                        name: repo
                      }
                    }
                  }),
                });
                
                if (!createResp.ok) {
                    const errText = await createResp.text();
                    throw new Error(`Failed to create pipeline: ${errText}`);
                }
                const createData = await createResp.json() as any;
                pipelineId = createData.id;
              }

              ctx.logger.info(`Pipeline ID is ${pipelineId}. Triggering pipeline run...`);

              // Wait a few seconds for ADO to parse the newly pushed YAML file
              if (!pipelineId) {
                 // only delay if we just created it
                 await new Promise(resolve => setTimeout(resolve, 3000));
              }

              // 3. Run Pipeline
              const runResp = await fetch(`${baseUrl}/${pipelineId}/runs?api-version=7.1-preview.1`, {
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
                  templateParameters: templateParameters || {}
                }),
              });

              if (!runResp.ok) {
                  const errText = await runResp.text();
                  throw new Error(`Failed to trigger pipeline: ${errText}`);
              }
              const runData = await runResp.json() as any;
              
              const runUrl = runData._links?.web?.href;
              ctx.logger.info(`Pipeline triggered successfully! Run URL: ${runUrl}`);
              
              ctx.output('pipelineRunUrl', runUrl);
              ctx.output('pipelineId', pipelineId.toString());
            },
          }),
        );
      },
    });
  },
});

export default adoPipelineModule;
